<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import BeatComposerModal from './BeatComposerModal.svelte';
  import BookshelfModal from './BookshelfModal.svelte';
  import PlayModal from './PlayModal.svelte';
  import SpriteEditorModal from './SpriteEditorModal.svelte';
  import ThemeSelectorModal from './ThemeSelectorModal.svelte';
  import ToyboxModal from './ToyboxModal.svelte';
  import type { AssetInventory, ToyboxAsset } from './lib/canvasState';
  import type { ThemeName } from './lib/themeRooms';

  export let toyboxOpen = false;
  export let bookshelfOpen = false;
  export let spriteEditorOpen = false;
  export let themeSelectorOpen = false;
  export let beatComposerOpen = false;
  export let playModalOpen = false;
  export let inventory: AssetInventory = {};
  export let isMuted = false;
  export let favorites: string[] = [];
  export let rooms: string[] = [];
  export let activeRoomId = '';
  export let getThumbnail: (roomId: string) => string | null = () => null;
  export let editingAssetId = '';
  export let editingCategory = 'decorations';
  export let themeDraft: { theme: ThemeName; adjective: string; noun: string };
  export let customBgmSequence: number[][] | undefined = undefined;

  const dispatch = createEventDispatcher<{
    selectToyboxItem: ToyboxAsset;
    closeToybox: void;
    selectRoom: string;
    newRoom: void;
    deleteRoom: string;
    closeBookshelf: void;
    closeSpriteEditor: void;
    drawingSaved: string;
    createThemeRoom: { theme: ThemeName; adjective: string; noun: string };
    closeThemeSelector: void;
    previewBeat: void;
    saveBeat: number[][];
    closeBeatComposer: void;
    closePlayModal: void;
    playStatus: string;
    toggleMute: void;
    restartSound: void;
    launchWindow: void;
  }>();
</script>

<ToyboxModal
  isVisible={toyboxOpen}
  {inventory}
  {isMuted}
  bind:favorites
  on:itemSelected={(event) => dispatch('selectToyboxItem', event.detail)}
  on:close={() => dispatch('closeToybox')}
/>

<BookshelfModal
  isVisible={bookshelfOpen}
  {rooms}
  {activeRoomId}
  {getThumbnail}
  on:selectRoom={(event) => dispatch('selectRoom', event.detail)}
  on:newRoom={() => dispatch('newRoom')}
  on:deleteRoom={(event) => dispatch('deleteRoom', event.detail)}
  on:close={() => dispatch('closeBookshelf')}
/>

<SpriteEditorModal
  isVisible={spriteEditorOpen}
  targetAssetId={editingAssetId}
  category={editingCategory}
  {isMuted}
  on:close={() => dispatch('closeSpriteEditor')}
  on:saved={(event) => dispatch('drawingSaved', event.detail)}
/>

<ThemeSelectorModal
  isVisible={themeSelectorOpen}
  initialTheme={themeDraft.theme}
  initialAdjective={themeDraft.adjective}
  initialNoun={themeDraft.noun}
  on:create={(event) => dispatch('createThemeRoom', event.detail)}
  on:close={() => dispatch('closeThemeSelector')}
/>

<BeatComposerModal
  isVisible={beatComposerOpen}
  initialSequence={customBgmSequence}
  on:previewStart={() => dispatch('previewBeat')}
  on:save={(event) => dispatch('saveBeat', event.detail)}
  on:close={() => dispatch('closeBeatComposer')}
/>

<PlayModal
  isVisible={playModalOpen}
  {isMuted}
  on:close={() => dispatch('closePlayModal')}
  on:status={(event) => dispatch('playStatus', event.detail)}
  on:toggleMute={() => dispatch('toggleMute')}
  on:restartSound={() => dispatch('restartSound')}
  on:launchWindow={() => dispatch('launchWindow')}
/>
