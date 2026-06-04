<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import { loadSavedRoom, saveRoomPayload } from './lib/roomPersistence';
  import { toRoomPayload, makeInstanceId, type PlacedEntity, type WorldSettings } from './lib/canvasState';
  import { getThemeEmoji } from './lib/themeRooms';

  export let rooms: string[] = [];
  export let activeRoomId = '';

  const dispatch = createEventDispatcher<{
    loadRoom: string;
    saveRoom: void;
  }>();

  const GRID_SIZE = 6; // 6x6 grid of rooms (plenty for a child's game)
  let roomDataMap: Record<string, any> = {};
  let loaded = false;

  async function loadAllRooms() {
    loaded = false;
    for (const id of rooms) {
      try {
        const data = await loadSavedRoom(id);
        roomDataMap[id] = data;
      } catch (e) {
        console.error("Failed to load room data for map:", id, e);
      }
    }
    roomDataMap = { ...roomDataMap };
    loaded = true;
  }

  onMount(() => {
    loadAllRooms();
  });

  // Calculate grid representation
  $: grid = Array.from({ length: GRID_SIZE }, (_, r) => 
    Array.from({ length: GRID_SIZE }, (_, c) => {
      const room = Object.entries(roomDataMap).find(([_, data]) => 
        data.world_settings?.grid_x === c && data.world_settings?.grid_y === r
      );
      return room ? { id: room[0], data: room[1] } : null;
    })
  );

  $: unplacedRooms = Object.entries(roomDataMap)
    .filter(([_, data]) => data.world_settings?.grid_x === undefined || data.world_settings?.grid_y === undefined)
    .map(([id, data]) => ({ id, data }));

  let dragOverCell: { r: number; c: number } | null = null;

  function handleDragStart(event: DragEvent, roomId: string) {
    event.dataTransfer?.setData('text/plain', roomId);
    event.dataTransfer!.effectAllowed = 'move';
  }

  function handleDragOver(event: DragEvent, r: number, c: number) {
    event.preventDefault();
    dragOverCell = { r, c };
  }

  function handleDragLeave() {
    dragOverCell = null;
  }

  async function handleDrop(event: DragEvent, targetR: number, targetC: number) {
    event.preventDefault();
    dragOverCell = null;

    const roomId = event.dataTransfer?.getData('text/plain');
    if (!roomId || !roomDataMap[roomId]) return;

    const room = roomDataMap[roomId];
    if (!room.world_settings) room.world_settings = {};
    
    // Assign position
    room.world_settings.grid_x = targetC;
    room.world_settings.grid_y = targetR;

    // Auto-connect with neighbors
    await autoConnectNeighbors(roomId, targetC, targetR);

    // Save updated room
    await saveRoomState(roomId);
    await loadAllRooms();
  }

  async function removeRoomFromGrid(roomId: string) {
    const room = roomDataMap[roomId];
    if (!room) return;

    if (room.world_settings) {
      room.world_settings.grid_x = undefined;
      room.world_settings.grid_y = undefined;
    }

    // Clean up connections pointing to this room from other rooms
    for (const [otherId, otherRoom] of Object.entries(roomDataMap)) {
      if (otherId === roomId) continue;
      if (otherRoom.entities) {
        otherRoom.entities = otherRoom.entities.filter((ent: PlacedEntity) => 
          !(ent.category === 'portals' && ent.modifiers?.target_room === roomId)
        );
        await saveRoomState(otherId);
      }
    }

    // Clean up this room's portals that point outwards
    if (room.entities) {
      room.entities = room.entities.filter((ent: PlacedEntity) => 
        !(ent.category === 'portals' && ent.instance_id.startsWith('auto_portal_'))
      );
    }

    await saveRoomState(roomId);
    await loadAllRooms();
  }

  async function saveRoomState(roomId: string) {
    const data = roomDataMap[roomId];
    if (!data) return;
    
    const payload = toRoomPayload(
      data.entities || [], 
      data.world_settings || {}, 
      'demo_project', 
      roomId
    );
    // Persist difficulty/calm mode values
    payload.world_settings.difficulty = data.world_settings.difficulty ?? 'normal';
    payload.world_settings.calm_mode = data.world_settings.calm_mode ?? false;

    await saveRoomPayload(roomId, payload);
  }

  async function autoConnectNeighbors(roomId: string, c: number, r: number) {
    const room = roomDataMap[roomId];
    if (!room) return;

    if (!room.entities) room.entities = [];

    // Neighbors check
    const directions = [
      { dx: 0, dy: -1, label: 'north', opp: 'south', x: 500, y: 150 },
      { dx: 0, dy: 1, label: 'south', opp: 'north', x: 580, y: 300 },
      { dx: -1, dy: 0, label: 'west', opp: 'east', x: 80, y: 300 },
      { dx: 1, dy: 0, label: 'east', opp: 'west', x: 860, y: 300 }
    ];

    for (const dir of directions) {
      const targetC = c + dir.dx;
      const targetR = r + dir.dy;

      // Find neighbor
      const neighborEntry = Object.entries(roomDataMap).find(([_, nd]) => 
        nd.world_settings?.grid_x === targetC && nd.world_settings?.grid_y === targetR
      );

      if (neighborEntry) {
        const neighborId = neighborEntry[0];
        const neighborRoom = neighborEntry[1];

        if (!neighborRoom.entities) neighborRoom.entities = [];

        // Check if connection already exists
        const exists = room.entities.some((ent: PlacedEntity) => 
          ent.category === 'portals' && ent.modifiers?.target_room === neighborId
        );

        if (!exists) {
          const portalIdA = `auto_portal_${dir.label}_to_${neighborId}`;
          const portalIdB = `auto_portal_${dir.opp}_to_${roomId}`;

          // Create portal in this room
          room.entities.push({
            instance_id: portalIdA,
            asset_id: 'portal_door',
            category: 'portals',
            type: 'portal',
            position: { x: dir.x, y: dir.y },
            modifiers: {
              variant: 'default',
              scale_multiplier: 1.0,
              target_room: neighborId,
              target_portal: portalIdB
            }
          });

          // Create matching portal in neighbor
          neighborRoom.entities.push({
            instance_id: portalIdB,
            asset_id: 'portal_door',
            category: 'portals',
            type: 'portal',
            position: { x: dir.opp === 'west' ? 80 : dir.opp === 'east' ? 860 : dir.opp === 'north' ? 300 : 580, y: dir.opp === 'north' ? 160 : 300 },
            modifiers: {
              variant: 'default',
              scale_multiplier: 1.0,
              target_room: roomId,
              target_portal: portalIdA
            }
          });

          // Save neighbor too
          await saveRoomState(neighborId);
        }
      }
    }
  }

  function handleJump(roomId: string) {
    dispatch('loadRoom', roomId);
  }
</script>

<div class="world-map-canvas">
  <div class="map-left-sidebar">
    <div class="sidebar-header">
      <h3>🚪 Unplaced Rooms</h3>
      <p>Drag rooms onto the grid to connect them!</p>
    </div>
    
    <div class="unplaced-list">
      {#each unplacedRooms as room}
        <div 
          class="unplaced-room-card"
          draggable="true"
          on:dragstart={(e) => handleDragStart(e, room.id)}
        >
          <span class="room-theme-ico">{getThemeEmoji(room.data.world_settings?.theme || 'default')}</span>
          <div class="room-card-meta">
            <h4>{room.id}</h4>
            <span class="theme-tag">{room.data.world_settings?.theme || 'default'}</span>
          </div>
          <button class="jump-btn-small" on:click={() => handleJump(room.id)} title="Edit Room">📂</button>
        </div>
      {:else}
        <div class="empty-list-notice">
          ✨ All rooms placed!
        </div>
      {/each}
    </div>
  </div>

  <div class="map-grid-workspace">
    <div class="workspace-header">
      <h2>🗺️ Metroidvania World Map Canvas 🏰</h2>
      <p>Drag rooms adjacent to each other to automatically link them with magical portal doors!</p>
    </div>

    {#if !loaded}
      <div class="loading-state">
        <div class="spinner"></div>
        <p>Loading magical world connections...</p>
      </div>
    {:else}
      <div class="grid-container">
        {#each grid as row, r}
          {#each row as cell, c}
            <!-- svelte-ignore a11y_no_static_element_interactions -->
            <div 
              class="grid-cell"
              class:drag-over={dragOverCell?.r === r && dragOverCell?.c === c}
              on:dragover={(e) => handleDragOver(e, r, c)}
              on:dragleave={handleDragLeave}
              on:drop={(e) => handleDrop(e, r, c)}
            >
              {#if cell}
                <div 
                  class="placed-room-tile theme-{cell.data.world_settings?.theme || 'default'}"
                  class:active-room={cell.id === activeRoomId}
                  draggable="true"
                  on:dragstart={(e) => handleDragStart(e, cell.id)}
                >
                  <div class="tile-header">
                    <span class="emoji-indicator">{getThemeEmoji(cell.data.world_settings?.theme || 'default')}</span>
                    <span class="active-badge">{cell.id === activeRoomId ? 'EDITING' : ''}</span>
                  </div>
                  <h3>{cell.id}</h3>
                  <div class="tile-footer">
                    <button class="tile-action-btn jump" on:click={() => handleJump(cell.id)}>Jump In</button>
                    <button class="tile-action-btn remove" on:click={() => removeRoomFromGrid(cell.id)}>Remove</button>
                  </div>
                </div>
              {:else}
                <div class="empty-cell-label">
                  ({c}, {r})
                </div>
              {/if}
            </div>
          {/each}
        {/each}
      </div>
    {/if}
  </div>
</div>

<style>
  .world-map-canvas {
    display: flex;
    flex: 1;
    background: #090f19;
    height: calc(100vh - 70px);
    overflow: hidden;
  }

  .map-left-sidebar {
    width: 320px;
    background: rgba(30, 41, 59, 0.4);
    backdrop-filter: blur(10px);
    border-right: 3px solid rgba(255, 255, 255, 0.08);
    display: flex;
    flex-direction: column;
    padding: 20px;
    box-sizing: border-box;
  }

  .sidebar-header h3 {
    color: #fbbf24;
    margin: 0 0 6px 0;
    font-size: 1.2rem;
  }

  .sidebar-header p {
    color: #94a3b8;
    font-size: 0.85rem;
    margin: 0 0 20px 0;
  }

  .unplaced-list {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 12px;
    overflow-y: auto;
    padding-right: 6px;
  }

  .unplaced-room-card {
    background: #1e293b;
    border: 2px solid #334155;
    border-radius: 12px;
    padding: 12px;
    display: flex;
    align-items: center;
    gap: 12px;
    cursor: grab;
    transition: transform 0.2s, border-color 0.2s;
  }

  .unplaced-room-card:active {
    cursor: grabbing;
  }

  .unplaced-room-card:hover {
    border-color: #6366f1;
    transform: scale(1.02);
  }

  .room-theme-ico {
    font-size: 1.8rem;
  }

  .room-card-meta {
    flex: 1;
  }

  .room-card-meta h4 {
    margin: 0;
    color: white;
    font-size: 0.95rem;
    word-break: break-all;
  }

  .theme-tag {
    font-size: 0.75rem;
    color: #38bdf8;
    font-weight: 700;
    text-transform: uppercase;
  }

  .jump-btn-small {
    background: #334155;
    border: none;
    border-radius: 8px;
    color: white;
    width: 32px;
    height: 32px;
    cursor: pointer;
    font-size: 1rem;
    display: grid;
    place-items: center;
  }

  .jump-btn-small:hover {
    background: #4f46e5;
  }

  .empty-list-notice {
    color: #64748b;
    font-size: 0.9rem;
    text-align: center;
    padding: 40px 0;
    font-style: italic;
  }

  .map-grid-workspace {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 30px;
    overflow-y: auto;
    align-items: center;
  }

  .workspace-header {
    text-align: center;
    margin-bottom: 24px;
  }

  .workspace-header h2 {
    color: white;
    margin: 0 0 6px 0;
    font-size: 1.6rem;
  }

  .workspace-header p {
    color: #94a3b8;
    margin: 0;
    font-size: 0.95rem;
    max-width: 600px;
  }

  .loading-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    flex: 1;
    color: #94a3b8;
  }

  .spinner {
    border: 4px solid rgba(255, 255, 255, 0.1);
    border-left-color: #6366f1;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 16px;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .grid-container {
    display: grid;
    grid-template-columns: repeat(6, 150px);
    grid-template-rows: repeat(6, 150px);
    gap: 12px;
    background: rgba(30, 41, 59, 0.2);
    border: 3px dashed #334155;
    padding: 16px;
    border-radius: 16px;
    margin-bottom: 40px;
  }

  .grid-cell {
    background: rgba(15, 23, 42, 0.6);
    border: 2px solid rgba(255, 255, 255, 0.05);
    border-radius: 12px;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background-color 0.2s, border-color 0.2s;
  }

  .grid-cell.drag-over {
    background: rgba(99, 102, 241, 0.2);
    border-color: #6366f1;
  }

  .empty-cell-label {
    font-size: 0.75rem;
    color: #475569;
    font-family: monospace;
  }

  .placed-room-tile {
    width: 100%;
    height: 100%;
    border-radius: 10px;
    padding: 10px;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    cursor: grab;
    box-shadow: 0 4px 6px rgba(0,0,0,0.3);
    border: 2px solid #475569;
    transition: transform 0.2s;
  }

  .placed-room-tile:active {
    cursor: grabbing;
  }

  .placed-room-tile:hover {
    transform: translateY(-2px);
  }

  .placed-room-tile.active-room {
    border-color: #f59e0b;
    box-shadow: 0 0 12px rgba(245, 158, 11, 0.4);
  }

  .placed-room-tile.theme-space {
    background: linear-gradient(#1e1e38, #0d0d21);
  }
  .placed-room-tile.theme-candy {
    background: linear-gradient(#fda4af, #f43f5e);
  }
  .placed-room-tile.theme-jungle {
    background: linear-gradient(#16a34a, #14532d);
  }
  .placed-room-tile.theme-ice {
    background: linear-gradient(#bae6fd, #0284c7);
  }
  .placed-room-tile.theme-volcano {
    background: linear-gradient(#b91c1c, #450a0a);
  }
  .placed-room-tile.theme-default {
    background: linear-gradient(#3b82f6, #1d4ed8);
  }

  .tile-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .emoji-indicator {
    font-size: 1.2rem;
  }

  .active-badge {
    background: #f59e0b;
    color: black;
    font-weight: 900;
    font-size: 0.65rem;
    padding: 2px 4px;
    border-radius: 4px;
  }

  .placed-room-tile h3 {
    margin: 4px 0;
    color: white;
    font-size: 0.8rem;
    word-break: break-all;
    text-shadow: 0 2px 4px rgba(0,0,0,0.5);
    text-align: center;
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .tile-footer {
    display: flex;
    gap: 4px;
  }

  .tile-action-btn {
    flex: 1;
    border: none;
    border-radius: 4px;
    padding: 4px;
    font-size: 0.65rem;
    font-weight: 800;
    cursor: pointer;
    color: white;
  }

  .tile-action-btn.jump {
    background: #4f46e5;
  }
  .tile-action-btn.jump:hover {
    background: #4338ca;
  }

  .tile-action-btn.remove {
    background: #e11d48;
  }
  .tile-action-btn.remove:hover {
    background: #be123c;
  }
</style>
