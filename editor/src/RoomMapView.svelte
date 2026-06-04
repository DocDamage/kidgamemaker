<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity } from './lib/canvasState';

  export let rooms: string[] = [];
  export let activeRoomId = '';
  export let placed: PlacedEntity[] = [];

  const dispatch = createEventDispatcher<{
    loadRoom: string;
    saveRoom: void;
  }>();

  $: roomPortals = placed.filter((entity) => entity.category === 'portals' || entity.type === 'portal');
</script>

<div class="map-view-container">
  <h2>🗺️ Connect-the-Rooms Map 🏰</h2>
  <p>
    Visual room portal connections. Link portal destinations directly by selecting target rooms from the cards.
  </p>

  <div class="rooms-grid">
    {#each rooms as roomId}
      <div class="room-node-card" class:active-room={roomId === activeRoomId}>
        <div class="room-card-header">
          <h3>🚪 {roomId}</h3>
          {#if roomId === activeRoomId}
            <span>EDITING</span>
          {/if}
        </div>

        <div class="portal-panel">
          <strong>Portal Links in room:</strong>
          {#if roomId === activeRoomId}
            {#if roomPortals.length === 0}
              <em>No portals stamped in this room yet.</em>
            {:else}
              {#each roomPortals as portal}
                <div class="portal-row">
                  <span>🌀 {portal.instance_id.slice(0, 8)}...</span>
                  <select
                    bind:value={portal.modifiers.target_room}
                    on:change={() => dispatch('saveRoom')}
                  >
                    <option value="">(Select Target Room)</option>
                    {#each rooms as destination}
                      {#if destination !== roomId}
                        <option value={destination}>➡️ {destination}</option>
                      {/if}
                    {/each}
                  </select>
                </div>
              {/each}
            {/if}
          {:else}
            <em>Switch room to configure portal connections.</em>
          {/if}
        </div>

        <button disabled={roomId === activeRoomId} on:click={() => dispatch('loadRoom', roomId)}>
          📂 Jump into Room
        </button>
      </div>
    {/each}
  </div>
</div>

<style>
  .map-view-container {
    flex: 1;
    padding: 30px;
    background: #0f172a;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: calc(100vh - 70px);
  }

  h2 {
    color: white;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  p {
    color: #94a3b8;
    margin-bottom: 24px;
    text-align: center;
    max-width: 600px;
  }

  .rooms-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    width: 100%;
    max-width: 1200px;
  }

  .room-node-card {
    background: #1e293b;
    border: 2px solid #334155;
    border-radius: 12px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
  }

  .room-node-card.active-room {
    border-color: #6366f1;
  }

  .room-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  h3 {
    color: white;
    margin: 0;
    font-size: 1.1rem;
  }

  .room-card-header span {
    background: #6366f1;
    color: white;
    font-size: 0.75rem;
    padding: 2px 6px;
    border-radius: 4px;
    font-weight: bold;
  }

  .portal-panel {
    background: rgba(0, 0, 0, 0.2);
    padding: 8px;
    border-radius: 8px;
    font-size: 0.85rem;
    color: #cbd5e1;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .portal-panel strong {
    color: #94a3b8;
  }

  .portal-panel em {
    color: #64748b;
    font-size: 0.75rem;
  }

  .portal-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    background: rgba(0, 0, 0, 0.2);
    padding: 6px;
    border-radius: 6px;
  }

  select {
    background: #0f172a;
    color: white;
    border: 1px solid #475569;
    border-radius: 4px;
    padding: 2px 4px;
    font-size: 0.8rem;
  }

  button {
    margin-top: 8px;
    padding: 6px;
    border-radius: 6px;
    border: none;
    font-weight: bold;
    background: #334155;
    color: white;
    cursor: pointer;
    font-size: 0.85rem;
  }

  button:disabled {
    background: #475569;
    cursor: default;
  }
</style>
