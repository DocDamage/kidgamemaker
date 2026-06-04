<script lang="ts">
  export let status: string;
  export let levelLengthLabel: string;
  export let objectCount: number;
  export let zoom: number;
</script>

<footer>
  <code>{status}</code>
  <span class="status-meta">
    <span class="level-length">{levelLengthLabel}</span>
    <span>{objectCount} stamped objects | Zoom: {Math.round(zoom * 100)}%</span>
  </span>
</footer>

<style>
  footer {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    align-items: center;
    padding: 12px;
    background: #101827;
    border-top: 3px solid rgba(255, 255, 255, 0.08);
  }

  .status-meta {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .level-length {
    background: rgba(255, 255, 255, 0.1);
    padding: 2px 8px;
    border-radius: 12px;
    font-weight: bold;
    font-size: 0.85rem;
    color: #fbbf24;
  }
</style>
