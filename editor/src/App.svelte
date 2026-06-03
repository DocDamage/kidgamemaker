<script lang="ts">
  import { onMount } from 'svelte';
  import { invoke, convertFileSrc } from '@tauri-apps/api/core';
  import ToyboxModal from './ToyboxModal.svelte';
  import BookshelfModal from './BookshelfModal.svelte';
  import SpriteEditorModal from './SpriteEditorModal.svelte';
  import {
    eraseEntity,
    fallbackInventory,
    snapPosition,
    stampEntity,
    toRoomPayload,
    type AssetInventory,
    type PlacedEntity,
    type ToyboxAsset,
    type WorldSettings
  } from './lib/canvasState';

  let spriteEditorOpen = false;
  let editingAssetId = '';
  let editingCategory = 'decorations';

  function openCustomAssetCanvas() {
    editingAssetId = '';
    editingCategory = 'decorations';
    spriteEditorOpen = true;
  }

  function editActiveAsset() {
    if (activeAsset) {
      editingAssetId = activeAsset.id;
      editingCategory = activeAsset.category;
      spriteEditorOpen = true;
    }
  }

  function handleDrawingSaved(event: CustomEvent<string>) {
    status = `Magic Brush auto-saved toy: ${event.detail}`;
    refreshInventory();
  }


  let placed: PlacedEntity[] = [
    {
      instance_id: 'hero_001',
      asset_id: 'hero_knight',
      category: 'heroes',
      type: 'player',
      position: { x: 128, y: 216 },
      is_camera_target: true,
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    },
    {
      instance_id: 'floor_001',
      asset_id: 'stone_floor',
      category: 'terrain',
      type: 'terrain',
      position: { x: 320, y: 392 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    },
    {
      instance_id: 'enemy_001',
      asset_id: 'slime_patrol',
      category: 'enemies',
      type: 'enemy',
      position: { x: 520, y: 344 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    }
  ];

  let inventory: AssetInventory = fallbackInventory;
  let activeAsset: ToyboxAsset = fallbackInventory.terrain[0];
  let eraserMode = false;
  let toyboxOpen = false;
  let bookshelfOpen = false;
  let snapEnabled = true;
  let status = 'Ready';

  // World settings — drives time_of_day / weather in saved JSON
  let worldSettings: WorldSettings = { time_of_day: 'day', weather: 'clear' };

  // Multi-room state
  let rooms: string[] = ['test_chamber_01'];
  let activeRoomId = 'test_chamber_01';

  // Viewport Pan/Zoom state
  let zoom = 1.0;
  let offsetX = 100;
  let offsetY = 100;
  let isPanning = false;
  let panStart = { x: 0, y: 0 };
  
  // Drag-to-paint and hover guide state
  let isDrawing = false;
  let hoverPos = { x: 0, y: 0 };
  let isHovering = false;

  $: quickRibbon = Object.values(inventory).flat().slice(0, 8);

  onMount(async () => {
    try {
      inventory = await invoke<AssetInventory>('get_asset_inventory');
      activeAsset = inventory.terrain?.[0] ?? Object.values(inventory).flat()[0] ?? activeAsset;
      status = 'Loaded toybox assets.';
    } catch (error) {
      status = `Using fallback toybox: ${error}`;
    }

    await loadRoomList();
    
    if (rooms.includes(activeRoomId)) {
      await loadSelectedRoom(activeRoomId);
    } else {
      try {
        const savedState = await invoke<any>('load_game_state');
        if (savedState && Array.isArray(savedState.entities)) {
          placed = savedState.entities;
          status += ' Restored saved game state.';
        }
      } catch (error) {
        status += ' No saved game state found, starting fresh.';
      }
    }

    // Auto-save every 60 seconds
    const saveId = setInterval(() => {
      if (placed.length > 0) saveCurrentRoom();
    }, 60_000);

    // Refresh Toybox inventory every 5 seconds (picks up inbox-ingested assets)
    const refreshId = setInterval(async () => {
      try {
        inventory = await invoke<AssetInventory>('get_asset_inventory');
      } catch { /* silent */ }
    }, 5_000);

    // Return cleanup so intervals are cancelled on unmount / hot-reload
    return () => {
      clearInterval(saveId);
      clearInterval(refreshId);
    };
  });

  async function loadRoomList() {
    try {
      rooms = await invoke<string[]>('list_rooms');
      if (rooms.length === 0) {
        rooms = [activeRoomId];
      }
    } catch (err) {
      console.error('Failed to list rooms:', err);
    }
  }

  function getCanvasCoords(clientX: number, clientY: number, rect: DOMRect) {
    const screenX = clientX - rect.left;
    const screenY = clientY - rect.top;
    return {
      x: (screenX - offsetX) / zoom,
      y: (screenY - offsetY) / zoom
    };
  }

  function getSnappedPosition(rawCoords: { x: number; y: number }, asset: ToyboxAsset): { x: number; y: number } {
    if (!snapEnabled) return rawCoords;

    const snapping = asset.snapping_type ?? (asset.category === 'terrain' ? 'edge_to_edge' : 'gravity_snap');

    if (snapping === 'edge_to_edge') {
      // Terrain edge-to-edge snapping to 32px grid
      return {
        x: Math.round(rawCoords.x / 32) * 32,
        y: Math.round(rawCoords.y / 32) * 32
      };
    } else if (snapping === 'gravity_snap') {
      // Gravity snap: snap X to 8px, snap Y to stand on top of terrain block below cursor
      const snapX = Math.round(rawCoords.x / 8) * 8;
      
      let stampHeight = 32;
      if (asset.category === 'heroes') stampHeight = 48;
      if (asset.frames && asset.frames[0]) {
        stampHeight = asset.frames[0].h;
      }

      // Scan placed terrain blocks to find the topmost terrain block below the cursor
      let bestTopY: number | null = null;
      for (const item of placed) {
        if (item.category === 'terrain') {
          // Default terrain width is 128 (64px half-width margin)
          const left = item.position.x - 64;
          const right = item.position.x + 64;
          
          if (snapX >= left && snapX <= right) {
            const topEdge = item.position.y - 16; // Terrain half-height margin
            // If the block top edge is below the cursor y position (with small buffer)
            if (topEdge >= rawCoords.y - 16) {
              if (bestTopY === null || topEdge < bestTopY) {
                bestTopY = topEdge;
              }
            }
          }
        }
      }

      if (bestTopY !== null) {
        return {
          x: snapX,
          y: bestTopY - stampHeight / 2
        };
      }

      // Fallback: grid snap if no terrain block is directly below
      return {
        x: snapX,
        y: Math.round(rawCoords.y / 8) * 8
      };
    }

    // Default 8px snap
    return {
      x: Math.round(rawCoords.x / 8) * 8,
      y: Math.round(rawCoords.y / 8) * 8
    };
  }

  function handleCanvasClick(event: MouseEvent) {
    const target = event.currentTarget as HTMLDivElement;
    const rect = target.getBoundingClientRect();
    const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
    const position = getSnappedPosition(rawCoords, activeAsset);

    if (eraserMode) {
      const hit = [...placed].reverse().find((item) => {
        const dx = item.position.x - position.x;
        const dy = item.position.y - position.y;
        return Math.sqrt(dx * dx + dy * dy) < 36 / zoom;
      });

      if (hit) placed = eraseEntity(placed, hit.instance_id);
      return;
    }

    const exists = placed.some(
      (ent) => ent.asset_id === activeAsset.id && 
               Math.abs(ent.position.x - position.x) < 4 && 
               Math.abs(ent.position.y - position.y) < 4
    );
    if (!exists) {
      if (activeAsset.category === 'portals' || activeAsset.type === 'portal') {
        handlePortalPlacement(position, activeAsset);
      } else {
        placed = stampEntity(placed, activeAsset, position);
      }
    }
  }

  function paintStamp(event: MouseEvent) {
    const target = event.currentTarget as HTMLDivElement;
    const rect = target.getBoundingClientRect();
    const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
    const position = getSnappedPosition(rawCoords, activeAsset);

    const spacingThreshold = activeAsset.category === 'terrain' ? 48 : 24;

    const exists = placed.some(
      (ent) => ent.asset_id === activeAsset.id && 
               Math.abs(ent.position.x - position.x) < spacingThreshold && 
               Math.abs(ent.position.y - position.y) < 8
    );
    if (!exists) {
      if (activeAsset.category === 'portals' || activeAsset.type === 'portal') {
        handlePortalPlacement(position, activeAsset);
      } else {
        placed = stampEntity(placed, activeAsset, position);
      }
    }
  }

  function startDrawing(event: MouseEvent) {
    if (event.button === 0) {
      isDrawing = true;
      handleCanvasClick(event);
    }
  }

  function stopDrawing(event: MouseEvent) {
    if (event.button === 0) {
      isDrawing = false;
    }
  }

  function handleWheel(event: WheelEvent) {
    event.preventDefault();
    const zoomFactor = 0.08;
    let newZoom = zoom;
    if (event.deltaY < 0) {
      newZoom += zoomFactor;
    } else {
      newZoom -= zoomFactor;
    }
    zoom = Math.max(0.5, Math.min(2.0, newZoom));
  }

  function handleMouseDown(event: MouseEvent) {
    if (event.button === 1 || event.button === 2) {
      isPanning = true;
      panStart = { x: event.clientX - offsetX, y: event.clientY - offsetY };
      event.preventDefault();
    }
  }

  function handleMouseMove(event: MouseEvent) {
    if (isPanning) {
      offsetX = event.clientX - panStart.x;
      offsetY = event.clientY - panStart.y;
    } else {
      const target = event.currentTarget as HTMLDivElement;
      const rect = target.getBoundingClientRect();
      const rawCoords = getCanvasCoords(event.clientX, event.clientY, rect);
      hoverPos = getSnappedPosition(rawCoords, activeAsset);
      isHovering = true;

      if (isDrawing && !eraserMode) {
        paintStamp(event);
      }
    }
  }

  function handleMouseUp(event: MouseEvent) {
    if (event.button === 1 || event.button === 2) {
      isPanning = false;
    }
  }

  async function handlePortalPlacement(position: { x: number; y: number }, asset: ToyboxAsset) {
    let targetRoomId = '';
    do {
      targetRoomId = `room_${Math.random().toString(36).substring(2, 8)}`;
    } while (rooms.includes(targetRoomId));

    const thisPortalId = `portal_${Math.random().toString(36).substring(2, 8)}`;
    const targetPortalId = `portal_${Math.random().toString(36).substring(2, 8)}`;

    const newPortal: PlacedEntity = {
      instance_id: thisPortalId,
      asset_id: asset.id,
      category: asset.category,
      type: asset.type ?? asset.category,
      position,
      modifiers: {
        variant: 'default',
        scale_multiplier: 1.0,
        target_room: targetRoomId,
        target_portal: targetPortalId
      }
    };

    placed = [...placed, newPortal];
    status = `Placed portal ${thisPortalId} linking to room ${targetRoomId}`;

    try {
      const returnPortal: PlacedEntity = {
        instance_id: targetPortalId,
        asset_id: asset.id,
        category: asset.category,
        type: asset.type ?? asset.category,
        position: { x: position.x, y: position.y },
        modifiers: {
          variant: 'default',
          scale_multiplier: 1.0,
          target_room: activeRoomId,
          target_portal: thisPortalId
        }
      };

      const terrainAsset = findAsset('stone_floor') ?? { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', type: 'terrain' };
      const floorUnderPortal: PlacedEntity = {
        instance_id: `stone_floor_${Math.random().toString(36).substring(2, 8)}`,
        asset_id: terrainAsset.id,
        category: terrainAsset.category,
        type: terrainAsset.type ?? terrainAsset.category,
        position: { x: position.x, y: position.y + 48 },
        modifiers: {
          variant: 'default',
          scale_multiplier: 1.0
        }
      };

      const targetPayload = {
        schema_version: 1,
        project_id: 'demo_project',
        room_id: targetRoomId,
        world_settings: {
          time_of_day: 'day',
          weather: 'clear'
        },
        entities: [returnPortal, floorUnderPortal]
      };

      const jsonString = JSON.stringify(targetPayload);
      await invoke('save_room', { roomId: targetRoomId, jsonString });
      await loadRoomList();
      status = `Placed portal linking to auto-created room ${targetRoomId}!`;
    } catch (err) {
      status = `Failed to auto-create target room: ${err}`;
    }
  }

  async function saveCurrentRoom() {
    status = `Saving room ${activeRoomId}...`;
    try {
      const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
      const jsonString = JSON.stringify(payload);
      status = await invoke<string>('save_room', { roomId: activeRoomId, jsonString });
      await loadRoomList();
      generateThumbnail(activeRoomId);
    } catch (error) {
      status = `Save failed: ${String(error)}`;
    }
  }

  async function deleteRoom(roomId: string) {
    if (!confirm(`Delete room "${roomId}"? This cannot be undone.`)) return;
    try {
      await invoke('delete_room', { roomId });
      await loadRoomList();
      if (activeRoomId === roomId) {
        activeRoomId = rooms[0] ?? 'test_chamber_01';
        placed = [];
        status = `Deleted room. Now editing: ${activeRoomId}`;
      } else {
        status = `Deleted room: ${roomId}`;
      }
    } catch (error) {
      // delete_room command may not exist yet — fallback gracefully
      status = `Could not delete room: ${String(error)}`;
    }
  }

  async function loadSelectedRoom(roomId: string) {
    status = `Loading room ${roomId}...`;
    try {
      const savedState = await invoke<any>('load_room', { roomId });
      if (savedState && Array.isArray(savedState.entities)) {
        placed = savedState.entities;
        activeRoomId = roomId;
        // Restore world settings from saved JSON
        if (savedState.world_settings) {
          worldSettings = {
            time_of_day: savedState.world_settings.time_of_day ?? 'day',
            weather: savedState.world_settings.weather ?? 'clear'
          };
        }
        status = `Loaded room: ${roomId}`;
      }
    } catch (error) {
      status = `Failed to load room ${roomId}: ${error}`;
    }
  }

  async function refreshInventory() {
    try {
      inventory = await invoke<AssetInventory>('get_asset_inventory');
      status = 'Toybox refreshed.';
    } catch (error) {
      status = `Refresh failed: ${error}`;
    }
  }

  // ── Thumbnail generation using a hidden <canvas> ──────────────────────────
  const CATEGORY_COLORS: Record<string, string> = {
    heroes: '#60a5fa',
    terrain: '#6b7280',
    enemies: '#f87171',
    collectibles: '#fbbf24',
    portals: '#a78bfa',
    decorations: '#34d399'
  };

  function generateThumbnail(roomId: string) {
    try {
      const canvas = document.createElement('canvas');
      canvas.width = 160;
      canvas.height = 90;
      const ctx = canvas.getContext('2d');
      if (!ctx) return;

      // Background
      ctx.fillStyle = worldSettings.time_of_day === 'night' ? '#0f172a'
        : worldSettings.time_of_day === 'sunset' ? '#7c2d12'
        : worldSettings.time_of_day === 'morning' ? '#164e63'
        : '#1e3a5f';
      ctx.fillRect(0, 0, 160, 90);

      if (placed.length === 0) {
        localStorage.setItem(`thumb_${roomId}`, canvas.toDataURL());
        return;
      }

      // Compute world bounds from placed entities
      const xs = placed.map(e => e.position.x);
      const ys = placed.map(e => e.position.y);
      const minX = Math.min(...xs) - 32;
      const minY = Math.min(...ys) - 32;
      const rangeX = Math.max(...xs) - minX + 64;
      const rangeY = Math.max(...ys) - minY + 64;

      const scaleX = 160 / rangeX;
      const scaleY = 90 / rangeY;
      const scale = Math.min(scaleX, scaleY);

      for (const e of placed) {
        const px = (e.position.x - minX) * scale;
        const py = (e.position.y - minY) * scale;
        ctx.fillStyle = CATEGORY_COLORS[e.category] ?? '#94a3b8';
        if (e.category === 'terrain') {
          ctx.fillRect(px - 6, py - 2, 12, 4);
        } else {
          ctx.beginPath();
          ctx.arc(px, py, e.category === 'heroes' ? 5 : 3, 0, Math.PI * 2);
          ctx.fill();
        }
      }

      localStorage.setItem(`thumb_${roomId}`, canvas.toDataURL());
    } catch { /* non-critical */ }
  }

  function getThumbnail(roomId: string): string | null {
    try { return localStorage.getItem(`thumb_${roomId}`); }
    catch { return null; }
  }

  function createNewRoom() {
    const newId = `room_${Math.floor(Math.random() * 900 + 100)}`;
    activeRoomId = newId;
    placed = [];
    status = `Created new empty room: ${newId}`;
  }

  async function play() {
    status = 'Saving and launching...';
    try {
      await saveCurrentRoom();
      const payload = toRoomPayload(placed, worldSettings, 'demo_project', activeRoomId);
      status = await invoke<string>('compile_and_play', { roomPayload: payload });
    } catch (error) {
      status = `Play failed: ${String(error)}`;
    }
  }

  async function exportGame() {
    status = 'Saving and exporting...';
    try {
      await saveCurrentRoom();
      const payload = toRoomPayload(placed);
      status = await invoke<string>('export_game', { projectId: payload.project_id });
    } catch (error) {
      status = `Export failed: ${String(error)}`;
    }
  }

  function selectAsset(asset: ToyboxAsset) {
    activeAsset = asset;
    eraserMode = false;
    toyboxOpen = false;
  }

  function findAsset(assetId: string): ToyboxAsset | undefined {
    return Object.values(inventory).flat().find((asset) => asset.id === assetId);
  }

  function isEmoji(str: string | undefined): boolean {
    if (!str) return true;
    return !str.includes('.') && !str.includes('/') && !str.includes('\\');
  }

  function getAssetUrl(asset: ToyboxAsset): string {
    if (!asset.visual || isEmoji(asset.visual)) return '';
    if (!asset.sidecar_path) return asset.visual;
    const lastSlash = Math.max(asset.sidecar_path.lastIndexOf('/'), asset.sidecar_path.lastIndexOf('\\'));
    if (lastSlash === -1) return asset.visual;
    const dir = asset.sidecar_path.substring(0, lastSlash + 1);
    return convertFileSrc(dir + asset.visual);
  }
</script>

<main class="app-shell">
  <header class="topbar">
    <span class="logo">🧸 KidGameMaker</span>

    <button class="bookshelf-btn" id="btn-bookshelf" on:click={() => (bookshelfOpen = true)}>📚 Rooms</button>

    <div class="room-controls">
      <select id="room-selector" value={activeRoomId} on:change={(e) => loadSelectedRoom(e.currentTarget.value)}>
        {#each rooms as room}
          <option value={room}>{room}</option>
        {/each}
      </select>
      <input id="room-name-input" type="text" bind:value={activeRoomId} placeholder="Room ID" title="Change Room Name" />
      <button id="btn-new-room" on:click={createNewRoom} title="New Room" class="icon-btn">➕ New</button>
    </div>

    <!-- World settings: time of day + weather -->
    <div class="world-controls">
      <label class="world-label" for="world-time">🕐</label>
      <select id="world-time" bind:value={worldSettings.time_of_day} class="world-select" title="Time of day">
        <option value="day">☀️ Day</option>
        <option value="morning">🌅 Morning</option>
        <option value="sunset">🌇 Sunset</option>
        <option value="night">🌙 Night</option>
      </select>
      <label class="world-label" for="world-weather">🌤</label>
      <select id="world-weather" bind:value={worldSettings.weather} class="world-select" title="Weather">
        <option value="clear">Clear</option>
        <option value="rain">🌧 Rain</option>
        <option value="snow">❄️ Snow</option>
      </select>
    </div>

    <button id="btn-play" class="play" on:click={play}>▶ PLAY</button>
    <button id="btn-save" class="save" on:click={saveCurrentRoom}>💾 SAVE</button>
    <button id="btn-export" class="export" on:click={exportGame} style="background: #10b981; color: white;">📦 EXPORT</button>
    <button id="btn-refresh-toybox" class="icon-btn refresh-btn" on:click={refreshInventory} title="Refresh Toybox from disk">🔄</button>
    <button class:active={!eraserMode} on:click={() => (eraserMode = false)} style="display: flex; align-items: center; gap: 8px;">
      <span>Stamp:</span>
      <span class="active-visual-container">
        {#if activeAsset.visual && !isEmoji(activeAsset.visual)}
          {#if activeAsset.is_spritesheet && activeAsset.frames && activeAsset.frames[0]}
            <img
              src={getAssetUrl(activeAsset)}
              alt={activeAsset.name}
              style="
                width: {activeAsset.frames[0].w}px;
                height: {activeAsset.frames[0].h}px;
                object-fit: none;
                object-position: -{activeAsset.frames[0].x}px -{activeAsset.frames[0].y}px;
                transform: scale({Math.min(1.5, 24 / Math.max(activeAsset.frames[0].w, activeAsset.frames[0].h))});
                transform-origin: center;
                display: block;
              "
            />
          {:else}
            <img
              src={getAssetUrl(activeAsset)}
              alt={activeAsset.name}
              style="max-width: 24px; max-height: 24px; object-fit: contain; display: block;"
            />
          {/if}
        {:else}
          <span>{activeAsset.visual ?? '🎮'}</span>
        {/if}
      </span>
      <span>{activeAsset.name}</span>
    </button>
    {#if activeAsset}
      <button on:click={editActiveAsset} title="Paint/Edit this toy" style="background: #eab308; color: #0f172a; padding: 6px 12px; font-weight: 800; border-radius: 12px; border: 0; cursor: pointer; display: flex; align-items: center; gap: 4px;">🎨 Edit</button>
    {/if}
    <button class:active={eraserMode} on:click={() => (eraserMode = !eraserMode)}>🧽 Eraser</button>
    <button class:active={snapEnabled} on:click={() => (snapEnabled = !snapEnabled)}>🧲 Snap</button>
    <button on:click={() => (toyboxOpen = true)}>🧰 Toybox</button>
    <button on:click={openCustomAssetCanvas} style="background: linear-gradient(135deg, #a855f7, #7c3aed); color: white; font-weight: 800; border: 0; border-radius: 12px; padding: 6px 12px; cursor: pointer; display: flex; align-items: center; gap: 4px;">🎨 Draw Toy</button>
  </header>

  <section class="quick-ribbon" aria-label="Quick toybox ribbon">
    {#each quickRibbon as asset}
      <button
        class:active={activeAsset.id === asset.id && !eraserMode}
        on:click={() => selectAsset(asset)}
        title={asset.name}
      >
        <span class="ribbon-visual-container">
          {#if asset.visual && !isEmoji(asset.visual)}
            {#if asset.is_spritesheet && asset.frames && asset.frames[0]}
              <img
                src={getAssetUrl(asset)}
                alt={asset.name}
                style="
                  width: {asset.frames[0].w}px;
                  height: {asset.frames[0].h}px;
                  object-fit: none;
                  object-position: -{asset.frames[0].x}px -{asset.frames[0].y}px;
                  transform: scale({Math.min(1.5, 48 / Math.max(asset.frames[0].w, asset.frames[0].h))});
                  transform-origin: center;
                  display: block;
                "
              />
            {:else}
              <img
                src={getAssetUrl(asset)}
                alt={asset.name}
                style="max-width: 48px; max-height: 48px; object-fit: contain; display: block;"
              />
            {/if}
          {:else}
            <span>{asset.visual ?? '🎮'}</span>
          {/if}
        </span>
        <small>{asset.name}</small>
      </button>
    {/each}
  </section>

  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div 
    class="canvas" 
    on:mousedown={startDrawing}
    on:mousemove={handleMouseMove}
    on:mouseup={stopDrawing}
    on:mouseleave={() => { isHovering = false; isDrawing = false; }}
    on:wheel={handleWheel}
    on:contextmenu|preventDefault
    on:mousedown|stopPropagation={handleMouseDown}
    on:mouseup|stopPropagation={handleMouseUp}
    aria-label="Game canvas"
  >
    <div 
      class="canvas-inner" 
      style:transform={`translate(${offsetX}px, ${offsetY}px) scale(${zoom})`}
      style:transform-origin="0 0"
    >
      <div class="horizon"></div>
      {#each placed as item (item.instance_id)}
        {@const asset = findAsset(item.asset_id)}
        <button
          class="stamp {item.category}"
          style:left={`${item.position.x}px`}
          style:top={`${item.position.y}px`}
          title={`${item.asset_id} ${item.instance_id}${item.modifiers.target_room ? ` (Leads to ${item.modifiers.target_room})` : ''}`}
          on:click|stopPropagation={() => {
            if (eraserMode) placed = eraseEntity(placed, item.instance_id);
          }}
          on:mousedown|stopPropagation
          style:border-radius={item.category === 'terrain' ? '14px' : '50%'}
          style:width={item.category === 'terrain' ? '160px' : '56px'}
          style:overflow="hidden"
        >
          <span class="stamp-visual-container">
            {#if asset && asset.visual && !isEmoji(asset.visual)}
              {#if asset.is_spritesheet && asset.frames && asset.frames[0]}
                <img
                  src={getAssetUrl(asset)}
                  alt={asset.name}
                  style="
                    width: {asset.frames[0].w}px;
                    height: {asset.frames[0].h}px;
                    object-fit: none;
                    object-position: -{asset.frames[0].x}px -{asset.frames[0].y}px;
                    transform: scale({item.category === 'terrain' ? Math.min(2.0, 160 / asset.frames[0].w) : Math.min(1.5, 48 / Math.max(asset.frames[0].w, asset.frames[0].h))});
                    transform-origin: center;
                    display: block;
                  "
                />
              {:else}
                <img
                  src={getAssetUrl(asset)}
                  alt={asset.name}
                  style="max-width: {item.category === 'terrain' ? '150px' : '48px'}; max-height: 48px; object-fit: contain; display: block;"
                />
              {/if}
            {:else}
              <span>{asset?.visual ?? '🎮'}</span>
            {/if}
          </span>
        </button>
      {/each}

      {#if isHovering && !eraserMode}
        <div 
          class="hover-guide {activeAsset.category}"
          style:left={`${hoverPos.x}px`}
          style:top={`${hoverPos.y}px`}
          style:border-radius={activeAsset.category === 'terrain' ? '14px' : '50%'}
          style:width={activeAsset.category === 'terrain' ? '160px' : '56px'}
          style:overflow="hidden"
        >
          <span class="stamp-visual-container">
            {#if activeAsset.visual && !isEmoji(activeAsset.visual)}
              {#if activeAsset.is_spritesheet && activeAsset.frames && activeAsset.frames[0]}
                <img
                  src={getAssetUrl(activeAsset)}
                  alt={activeAsset.name}
                  style="
                    width: {activeAsset.frames[0].w}px;
                    height: {activeAsset.frames[0].h}px;
                    object-fit: none;
                    object-position: -{activeAsset.frames[0].x}px -{activeAsset.frames[0].y}px;
                    transform: scale({activeAsset.category === 'terrain' ? Math.min(2.0, 160 / activeAsset.frames[0].w) : Math.min(1.5, 48 / Math.max(activeAsset.frames[0].w, activeAsset.frames[0].h))});
                    transform-origin: center;
                    display: block;
                  "
                />
              {:else}
                <img
                  src={getAssetUrl(activeAsset)}
                  alt={activeAsset.name}
                  style="max-width: {activeAsset.category === 'terrain' ? '150px' : '48px'}; max-height: 48px; object-fit: contain; display: block;"
                />
              {/if}
            {:else}
              <span>{activeAsset.visual ?? '🎮'}</span>
            {/if}
          </span>
        </div>
      {/if}
    </div>
  </div>

  <footer>
    <code>{status}</code>
    <span>{placed.length} stamped objects | Zoom: {Math.round(zoom * 100)}%</span>
  </footer>

  <ToyboxModal
    isVisible={toyboxOpen}
    inventory={inventory}
    on:itemSelected={(event) => selectAsset(event.detail)}
    on:close={() => (toyboxOpen = false)}
  />

  <BookshelfModal
    isVisible={bookshelfOpen}
    {rooms}
    {activeRoomId}
    {getThumbnail}
    on:selectRoom={(e) => { loadSelectedRoom(e.detail); bookshelfOpen = false; }}
    on:newRoom={() => { createNewRoom(); bookshelfOpen = false; }}
    on:deleteRoom={(e) => deleteRoom(e.detail)}
    on:close={() => (bookshelfOpen = false)}
  />

  <SpriteEditorModal
    isVisible={spriteEditorOpen}
    targetAssetId={editingAssetId}
    category={editingCategory}
    on:close={() => (spriteEditorOpen = false)}
    on:saved={handleDrawingSaved}
  />
</main>

<style>
  .app-shell {
    height: 100vh;
    display: grid;
    grid-template-rows: auto auto 1fr auto;
  }

  .ribbon-visual-container,
  .stamp-visual-container {
    width: 100%;
    height: 100%;
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  .active-visual-container {
    width: 24px;
    height: 24px;
    display: grid;
    place-items: center;
    overflow: hidden;
  }

  .topbar,
  .quick-ribbon,
  footer {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 12px;
    background: #101827;
    border-bottom: 3px solid rgba(255, 255, 255, 0.08);
  }

  .topbar {
    flex-wrap: wrap;
  }

  .logo {
    font-size: 1.5rem;
    font-weight: 900;
    color: #ffd84d;
    margin-right: 12px;
  }

  .room-controls {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(255, 255, 255, 0.05);
    padding: 4px 10px;
    border-radius: 18px;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .room-controls select,
  .room-controls input {
    background: #1f2937;
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 12px;
    padding: 4px 8px;
    font-weight: 800;
    font-size: 0.9rem;
  }

  .room-controls input {
    width: 130px;
  }

  .bookshelf-btn {
    background: linear-gradient(135deg, #f59e0b, #d97706);
    color: white;
  }

  .world-controls {
    display: flex;
    align-items: center;
    gap: 6px;
    background: rgba(255, 255, 255, 0.05);
    padding: 4px 10px;
    border-radius: 18px;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .world-label {
    font-size: 1rem;
    line-height: 1;
  }

  .world-select {
    background: #1f2937;
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 10px;
    padding: 4px 8px;
    font-weight: 700;
    font-size: 0.85rem;
    cursor: pointer;
  }

  .save {
    background: #3b82f6;
    color: white;
  }

  button {
    border: 0;
    border-radius: 18px;
    padding: 12px 18px;
    font-weight: 900;
    cursor: pointer;
    background: #f3f5ff;
    color: #101827;
    box-shadow: 0 5px 0 rgba(0, 0, 0, 0.35);
  }

  button:active {
    transform: translateY(3px);
    box-shadow: 0 2px 0 rgba(0, 0, 0, 0.35);
  }

  button.active {
    outline: 4px solid #ffd84d;
  }

  .play {
    background: #55e36f;
    font-size: 1.2rem;
  }

  .icon-btn {
    padding: 6px 12px;
    border-radius: 12px;
  }

  .refresh-btn {
    background: #92400e;
    color: #fde68a;
    font-size: 1rem;
  }

  .refresh-btn:hover {
    background: #b45309;
  }


  .quick-ribbon {
    overflow-x: auto;
  }

  .quick-ribbon button {
    display: grid;
    place-items: center;
    min-width: 104px;
  }

  .quick-ribbon span {
    font-size: 2rem;
  }

  .canvas {
    position: relative;
    overflow: hidden;
    background: linear-gradient(#31466d, #1d2d45 55%, #1b2331 55%);
    cursor: grab;
  }

  .canvas:active {
    cursor: grabbing;
  }

  .canvas-inner {
    position: absolute;
    width: 5000px;
    height: 3000px;
    pointer-events: none;
    background:
      linear-gradient(rgba(255, 255, 255, 0.05) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
    background-size: 32px 32px, 32px 32px;
  }

  .canvas-inner :global(*) {
    pointer-events: auto;
  }

  .horizon {
    position: absolute;
    left: 0;
    right: 0;
    top: 55%;
    height: 4px;
    background: rgba(255, 255, 255, 0.08);
  }

  .stamp {
    position: absolute;
    transform: translate(-50%, -50%);
    width: 56px;
    height: 56px;
    padding: 0;
    display: grid;
    place-items: center;
    font-size: 2rem;
    border-radius: 50%;
  }

  .stamp.terrain {
    width: 160px;
    border-radius: 14px;
  }

  .hover-guide {
    position: absolute;
    transform: translate(-50%, -50%);
    width: 56px;
    height: 56px;
    opacity: 0.5;
    border: 3px dashed #ffd84d;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 2rem;
    pointer-events: none;
  }

  .hover-guide.terrain {
    width: 160px;
    border-radius: 14px;
  }

  footer {
    justify-content: space-between;
    border-top: 3px solid rgba(255, 255, 255, 0.08);
    border-bottom: 0;
  }
</style>
