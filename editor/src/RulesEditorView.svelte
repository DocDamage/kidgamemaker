<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { PlacedEntity, ToyboxAsset, WorldSettings } from './lib/canvasState';
  import { triggerAssetForRule, usesLogicGateAction, usesLogicGateTrigger } from './lib/roomRules';

  export let worldSettings: WorldSettings;
  export let placed: PlacedEntity[] = [];
  export let findAsset: (assetId: string) => ToyboxAsset | undefined;

  const dispatch = createEventDispatcher<{
    addRule: void;
    deleteRule: number;
    saveRoom: void;
  }>();

  function saveRoom() {
    dispatch('saveRoom');
  }

  function ensureRisingHazardDefaults() {
    if (worldSettings.rising_hazard_type && !worldSettings.rising_hazard_speed) {
      worldSettings.rising_hazard_speed = 20;
    }
    saveRoom();
  }

  function ensureAutoscrollDefaults() {
    if (worldSettings.camera_autoscroll && !worldSettings.camera_autoscroll_direction) {
      worldSettings.camera_autoscroll_direction = 'right';
    }
    if (worldSettings.camera_autoscroll && !worldSettings.camera_autoscroll_speed) {
      worldSettings.camera_autoscroll_speed = 40;
    }
    saveRoom();
  }
</script>

<div class="rules-view-container">
  <h2>✨ Magic Rules Engine ⚙️</h2>
  <p>Create rules without code! Tell the game what should happen when you flip a lever, collect gems, or step on buttons.</p>

  <div class="rules-stack">
    <div class="global-rules-card">
      <h3>🏆 Victory & Loss Rules</h3>

      <div class="global-rule-grid">
        <section class="rule-section victory">
          <strong>🥇 VICTORY RULE</strong>
          {#if worldSettings.victory_rules}
            <label>
              <span>Win Condition:</span>
              <select bind:value={worldSettings.victory_rules.win_condition} on:change={saveRoom}>
                <option value="all_enemies">👾 Defeat all Monsters</option>
                <option value="all_coins">💎 Collect all Rubies</option>
                <option value="portal">🌀 Reach the Exit Portal</option>
              </select>
            </label>
            <label>
              <span>Celebration Effect:</span>
              <select bind:value={worldSettings.victory_rules.celebration} on:change={saveRoom}>
                <option value="confetti">🎉 Rainbow Confetti</option>
                <option value="simple">🌟 Simple Victory Page</option>
              </select>
            </label>
          {/if}
        </section>

        <section class="rule-section loss">
          <strong>💀 GAME OVER RULE</strong>
          {#if worldSettings.loss_rules}
            <label>
              <span>Lose Condition:</span>
              <select bind:value={worldSettings.loss_rules.lose_condition} on:change={saveRoom}>
                <option value="health_0">💔 Health Falls to 0</option>
              </select>
            </label>
            <label>
              <span>Action on Defeat:</span>
              <select bind:value={worldSettings.loss_rules.action} on:change={saveRoom}>
                <option value="game_over">💀 Show Game Over Screen</option>
                <option value="respawn">🔄 Auto-Respawn Player</option>
              </select>
            </label>
          {/if}
        </section>

        <section class="rule-section hazard">
          <strong>🌋 RISING DANGER</strong>
          <label>
            <span>Hazard Type:</span>
            <select bind:value={worldSettings.rising_hazard_type} on:change={ensureRisingHazardDefaults}>
              <option value="">🚫 No Danger</option>
              <option value="water">🌊 Rising Water (Drowns Slowly)</option>
              <option value="lava">🌋 Rising Lava (Burns Quickly)</option>
            </select>
          </label>
          {#if worldSettings.rising_hazard_type}
            <label>
              <span>Rising Speed:</span>
              <select bind:value={worldSettings.rising_hazard_speed} on:change={saveRoom}>
                <option value={10}>🐌 Slow (10)</option>
                <option value={20}>🚶 Normal (20)</option>
                <option value={40}>🏃 Fast (40)</option>
                <option value={80}>⚡ Extreme (80)</option>
              </select>
            </label>
          {/if}
        </section>

        <section class="rule-section camera">
          <strong>🎥 CAMERA AUTO-SCROLL</strong>
          <label>
            <span>Auto-Scroll:</span>
            <select bind:value={worldSettings.camera_autoscroll} on:change={ensureAutoscrollDefaults}>
              <option value={false}>🚫 Normal Follow Camera</option>
              <option value={true}>🎬 Auto-Scroll Camera</option>
            </select>
          </label>
          {#if worldSettings.camera_autoscroll}
            <label>
              <span>Direction:</span>
              <select bind:value={worldSettings.camera_autoscroll_direction} on:change={saveRoom}>
                <option value="right">➡️ Right</option>
                <option value="left">⬅️ Left</option>
                <option value="up">⬆️ Up</option>
                <option value="down">⬇️ Down</option>
              </select>
            </label>
            <label>
              <span>Scroll Speed:</span>
              <select bind:value={worldSettings.camera_autoscroll_speed} on:change={saveRoom}>
                <option value={15}>🐌 Slow (15)</option>
                <option value={40}>🚶 Normal (40)</option>
                <option value={80}>🏃 Fast (80)</option>
                <option value={150}>⚡ Extreme (150)</option>
              </select>
            </label>
          {/if}
        </section>

        <section class="rule-section turf-war">
          <strong>🎨 TURF WAR MINIGAME</strong>
          <label>
            <span>Turf War Mode:</span>
            <select bind:value={worldSettings.turf_war_enabled} on:change={saveRoom}>
              <option value={false}>🚫 Disabled</option>
              <option value={true}>🟢 Enabled (3-Min Paint Run)</option>
            </select>
          </label>
        </section>
      </div>
    </div>

    <button class="add-rule-btn" on:click={() => dispatch('addRule')}>➕ Add New Rule</button>

    {#if !worldSettings.room_rules || worldSettings.room_rules.length === 0}
      <div class="empty-rules">
        <span>🧙‍♂️</span>
        <h3>No Magic Rules Yet!</h3>
        <p>Click "Add New Rule" to link buttons, levers, or coin targets to events.</p>
      </div>
    {:else}
      <div class="rule-list">
        {#each worldSettings.room_rules as rule, index}
          <div class="rule-card">
            <strong class="if-label">IF</strong>
            <select bind:value={rule.trigger_type} on:change={() => { rule.trigger_id = ''; saveRoom(); }}>
              <option value="button_step">🔘 Floor Button Stepped</option>
              <option value="lever_flip">🕹️ Wall Lever Flipped</option>
              <option value="target_hit">🎯 Target Practice Hit</option>
              <option value="pressure_plate_on">🟨 Pressure Plate Pressed</option>
              <option value="pressure_plate_off">🟨 Pressure Plate Released</option>
              <option value="logic_gate_on">⚡ Logic Gate output goes ON</option>
              <option value="logic_gate_off">⚪ Logic Gate output goes OFF</option>
              <option value="coins_5">💎 Collected 5 Rubies</option>
              <option value="coins_10">💎 Collected 10 Rubies</option>
            </select>

            {#if triggerAssetForRule(rule)}
              <select bind:value={rule.trigger_id} on:change={saveRoom}>
                <option value="">(Select Trigger Entity)</option>
                {#each placed.filter((entity) => entity.asset_id === triggerAssetForRule(rule)) as entity}
                  <option value={entity.instance_id}>{entity.instance_id.slice(0, 8)}... ({findAsset(entity.asset_id)?.name})</option>
                {/each}
              </select>
            {:else if usesLogicGateTrigger(rule)}
              <select bind:value={rule.trigger_id} on:change={saveRoom}>
                <option value="">(Select Logic Gate)</option>
                {#each placed.filter((entity) => entity.type === 'logic_and' || entity.type === 'logic_or' || entity.type === 'logic_not') as entity}
                  <option value={entity.instance_id}>{entity.instance_id.slice(0, 8)}... ({findAsset(entity.asset_id)?.name})</option>
                {/each}
              </select>
            {/if}

            <strong class="then-label">➡️ THEN</strong>
            <select bind:value={rule.action_type} on:change={saveRoom}>
              <option value="toggle_gate">🚪 Open/Close Switch Gate</option>
              <option value="spawn_sparkles">✨ Spawn Magic Sparkles</option>
              <option value="heal_player">💖 Heal Player 20 HP</option>
              <option value="play_sfx_chime">🔔 Play Chime Sound</option>
              <option value="set_logic_input_1_on">🔴 Set AND/OR/NOT Input 1 ON</option>
              <option value="set_logic_input_1_off">⚪ Set AND/OR/NOT Input 1 OFF</option>
              <option value="set_logic_input_2_on">🔵 Set AND/OR Input 2 ON</option>
              <option value="set_logic_input_2_off">⚪ Set AND/OR Input 2 OFF</option>
            </select>

            {#if rule.action_type === 'toggle_gate'}
              <select bind:value={rule.action_id} on:change={saveRoom}>
                <option value="">(Select Gate)</option>
                {#each placed.filter((entity) => entity.type === 'gate') as entity}
                  <option value={entity.instance_id}>{entity.instance_id.slice(0, 8)}... ({findAsset(entity.asset_id)?.name})</option>
                {/each}
              </select>
            {:else if usesLogicGateAction(rule)}
              <select bind:value={rule.action_id} on:change={saveRoom}>
                <option value="">(Select Logic Gate)</option>
                {#each placed.filter((entity) => entity.type === 'logic_and' || entity.type === 'logic_or' || entity.type === 'logic_not') as entity}
                  <option value={entity.instance_id}>{entity.instance_id.slice(0, 8)}... ({findAsset(entity.asset_id)?.name})</option>
                {/each}
              </select>
            {/if}

            <button class="delete-rule-btn" on:click={() => dispatch('deleteRule', index)}>🗑️ Delete</button>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>

<style>
  .rules-view-container {
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

  .rules-stack {
    width: 100%;
    max-width: 800px;
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-bottom: 30px;
  }

  .global-rules-card,
  .empty-rules,
  .rule-card {
    background: #1e293b;
    color: white;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.35);
  }

  .global-rules-card {
    border: 3px solid #fbbf24;
    border-radius: 16px;
    padding: 20px;
  }

  .global-rules-card h3 {
    color: #fbbf24;
    margin: 0 0 16px;
  }

  .global-rule-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
  }

  .rule-section,
  label {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .rule-section {
    background: rgba(0, 0, 0, 0.15);
    padding: 12px;
    border-radius: 10px;
  }

  label span {
    font-size: 0.85rem;
    color: #94a3b8;
  }

  select {
    background: #0f172a;
    color: white;
    border: 1px solid #475569;
    padding: 6px;
    border-radius: 6px;
    font-size: 0.85rem;
  }

  .add-rule-btn {
    align-self: flex-end;
    padding: 8px 16px;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    background: #10b981;
    color: white;
    font-weight: bold;
  }

  .empty-rules {
    padding: 40px;
    border-radius: 12px;
    border: 2px dashed #475569;
    text-align: center;
  }

  .empty-rules span {
    font-size: 3rem;
    display: block;
    margin-bottom: 12px;
  }

  .rule-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .rule-card {
    border-radius: 10px;
    padding: 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    border: 1px solid #334155;
  }

  .if-label {
    color: #38bdf8;
  }

  .then-label {
    color: #a78bfa;
  }

  .delete-rule-btn {
    margin-left: auto;
    padding: 6px 12px;
    border-radius: 6px;
    border: none;
    background: #ef4444;
    color: white;
    cursor: pointer;
    font-size: 0.85rem;
    font-weight: bold;
  }
</style>
