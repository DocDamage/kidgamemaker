<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { SPRITE_TEMPLATE_GROUPS, type SpriteTemplateName } from './lib/spriteTemplates';

  const dispatch = createEventDispatcher<{
    select: SpriteTemplateName;
  }>();

  function selectTemplate(name: SpriteTemplateName) {
    dispatch('select', name);
  }
</script>

<div class="templates-panel">
  <span class="panel-label">Templates</span>
  <div class="template-groups">
    {#each SPRITE_TEMPLATE_GROUPS as group}
      <section class="template-group" aria-label={`${group.label} templates`}>
        <span class="group-label">{group.label}</span>
        <div class="templates-buttons">
          {#each group.templates as template}
            <button class="tpl-btn" on:click={() => selectTemplate(template.name)}>{template.label}</button>
          {/each}
        </div>
      </section>
    {/each}
  </div>
</div>

<style>
  .templates-panel {
    display: flex;
    align-items: flex-start;
    gap: 14px;
    background: #0f172a;
    padding: 14px 16px;
    border-radius: 18px;
    max-height: 220px;
    overflow: auto;
  }

  .panel-label {
    font-weight: 900;
    color: #94a3b8;
    font-size: 1rem;
    min-width: 84px;
    padding-top: 8px;
  }

  .template-groups {
    display: grid;
    gap: 12px;
    flex: 1;
  }

  .template-group {
    display: grid;
    grid-template-columns: 96px 1fr;
    gap: 10px;
    align-items: start;
  }

  .group-label {
    color: #cbd5e1;
    font-size: 0.78rem;
    font-weight: 900;
    padding-top: 8px;
    text-transform: uppercase;
    letter-spacing: 0;
  }

  .templates-buttons {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  .tpl-btn {
    border: 0;
    background: #1e293b;
    color: white;
    font-weight: 800;
    padding: 8px 10px;
    border-radius: 10px;
    cursor: pointer;
    font-size: 0.82rem;
    box-shadow: none;
    transition: background 0.2s, transform 0.1s;
  }

  .tpl-btn:hover {
    background: #334155;
  }

  .tpl-btn:active {
    transform: translateY(2px);
  }

  @media (max-width: 760px) {
    .templates-panel {
      display: grid;
      max-height: 260px;
    }

    .panel-label {
      min-width: 0;
      padding-top: 0;
    }

    .template-group {
      grid-template-columns: 1fr;
      gap: 6px;
    }

    .group-label {
      padding-top: 0;
    }
  }
</style>
