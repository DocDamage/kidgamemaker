<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { SpriteTemplateName } from './lib/spriteTemplates';

  const dispatch = createEventDispatcher<{
    select: SpriteTemplateName;
  }>();

  function selectTemplate(name: SpriteTemplateName) {
    dispatch('select', name);
  }
</script>

<div class="templates-panel">
  <span class="panel-label">Templates:</span>
  <div class="templates-buttons">
    <button class="tpl-btn" on:click={() => selectTemplate('sword')}>⚔️ Sword</button>
    <button class="tpl-btn" on:click={() => selectTemplate('monster')}>👾 Slime</button>
    <button class="tpl-btn" on:click={() => selectTemplate('coin')}>🪙 Coin</button>
    <button class="tpl-btn" on:click={() => selectTemplate('heart')}>❤️ Heart</button>
    <button class="tpl-btn" on:click={() => selectTemplate('star')}>⭐️ Star</button>
    <button class="tpl-btn" on:click={() => selectTemplate('key')}>🔑 Key</button>
    <button class="tpl-btn" on:click={() => selectTemplate('crown')}>👑 Crown</button>
  </div>
</div>

<style>
  .templates-panel {
    display: flex;
    align-items: center;
    gap: 16px;
    background: #0f172a;
    padding: 12px 20px;
    border-radius: 20px;
  }

  .panel-label {
    font-weight: 900;
    color: #94a3b8;
    font-size: 1rem;
  }

  .templates-buttons {
    display: flex;
    gap: 10px;
  }

  .tpl-btn {
    border: 0;
    background: #1e293b;
    color: white;
    font-weight: 800;
    padding: 8px 16px;
    border-radius: 14px;
    cursor: pointer;
    font-size: 0.95rem;
    box-shadow: 0 4px 0 rgba(0, 0, 0, 0.25);
    transition: background 0.2s, transform 0.1s;
  }

  .tpl-btn:hover {
    background: #334155;
  }

  .tpl-btn:active {
    transform: translateY(2px);
  }
</style>
