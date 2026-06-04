# Section 12: Implementation Roadmap

The 345+ features catalogued across the preceding eleven chapters represent KidGameMaker's complete creative vision. Not every feature can ship on day one, and not every feature is equally urgent. This roadmap establishes a four-phase prioritization matrix, a complexity-versus-impact analysis for the top-priority items, and a strategy for evolving the JSON contract that binds the Svelte/Tauri editor to the Godot 4 runner. The goal is to deliver a system that feels complete at each milestone while building toward the full feature set.

---

## 12.1 Phase-by-Phase Priority Matrix

### Phase A: Foundation (P0) — "It Feels Like a Real Engine"

Phase A delivers the minimum viable feature set that makes KidGameMaker feel complete rather than like a prototype. These are the mechanics players expect from any commercial platformer or action game. Without them, the product feels broken. With them, a child can ship a game that genuinely impresses.

**Movement & Traversal (Core Layer)** — Implement wall jump, double jump, dash (with cooldown meter), glide (with stamina depletion), ledge grab, and ground pound. These six features cover the traversal vocabulary of modern platformers from *Celeste* to *Super Mario Odyssey*. Each is a single-action mechanic that requires only state-machine wiring and minimal parameter tuning. The JSON contract needs only a `movement_id` enum and a `params` block for duration, speed, and cooldown values. The stamp system already supports placing these as movement-tool stamps on any entity.

**Combat Fundamentals** — Sword combo (three-hit string with finisher), charge shot (hold-to-charge with visual indicator), parry (frame-perfect with generous 8-frame window), and shield block. These four mechanics form the complete defense-and-offense loop. The combo system requires an input-buffer timer; the charge shot needs an `is_charging` state flag and a scalar `charge_ratio` exported to the JSON; the parry needs a brief invulnerability window and a counter-attack state transition. All are well-understood problems with established Godot patterns.

**Rules Engine Primitives** — Switch-and-door pairs, key-and-lock systems, pressure plates, collectible counters, and win-condition triggers. These are the puzzle grammar. Each rule is a small finite-state machine: `on_activated -> set_target_state`. The editor already represents these as connection lines between stamps; Phase A simply hardens the runtime evaluation to handle the ten most common rule patterns.

**AI-Assisted Quality of Life** — The Level Balancer (auto-tune enemy density and platform spacing for target difficulty) and the Smart Tutorial Whisperer (context-sensitive hint system that watches player failure patterns and suggests mechanics before frustration sets in). These two features are KidGameMaker's signature AI layer and should ship early so every game made in the platform benefits from them from the start.

Phase A estimate: 14 core features, 10–12 weeks.

---

### Phase B: Depth (P1) — "Every Game Feels Different"

Phase B introduces systems that create meaningful variety between games. Where Phase A gives every player the same toolbox, Phase B gives them different toolboxes that dramatically change how a game plays.

**Classes & Job Badges** — Eight starter classes (Warrior, Mage, Rogue, Archer, Paladin, Necromancer, Engineer, Bard), each with a unique starting ability, stat profile, and equip-restriction set. The JSON contract adds a `class_id` field to the player entity and a `class_definitions` lookup table. Badge icons use the existing sprite-slicing pipeline; no new asset tooling is required.

**Transformation System** — Super-form triggers (Super Sonic, Super Saiyan, Fire Mario), copy-ability absorption (Kirby-style), and temporary power-up forms (Tanooki suit, Metal form). Each transformation swaps the player's sprite sheet, movement parameters, and ability set. The JSON contract extends `player_state` with a `transform_stack` array so multiple forms can queue and expire independently.

**Companions & Familiars** — Three companion archetypes: damage familiars (floating orb that fires projectiles), utility familiars (Pikmin-style followers that carry objects and press buttons), and spirit ashes (summonable ghost allies with timed lifespan). Each companion type requires a new AI behavior tree node and a `companion` entity definition in JSON. The Pikmin-style followers are the highest complexity due to swarm pathfinding, but Godot 4's navigation mesh and `NavigationAgent2D` handle the heavy lifting.

**Crafting & Cooking** — Recipes with ingredient requirements, crafting stations, and consumable output items. The system needs a `recipe_book` JSON block, an `inventory` state tracker, and a simple UI panel in the editor for recipe discovery. Cooking adds status-effect food buffs, requiring a `status_effects` array on the player entity.

**Boss Constructor** — A multi-phase boss builder where creators define phase transitions via HP thresholds, each phase swapping attack patterns, movement behaviors, and vulnerability windows. The JSON contract adds a `boss_phases` array with per-phase `trigger_condition`, `behavior_override`, and `vulnerability_flags`. This is the single most requested feature from playtesters.

**Elemental Chemistry Engine** — Fire melts ice into water, water conducts lightning, lightning ignites oil, oil burns into smoke, smoke blocks sight. A five-element interaction matrix with 25 pairwise reactions. Each reaction is a rule predicate (`if element_a touches element_b then spawn element_c`), compactly represented as a lookup table in JSON. Implementation is straightforward; design balance is the challenge.

Phase B estimate: 48 features across six subsystems, 14–16 weeks.

---

### Phase C: Magic (P2) — "Only KidGameMaker Does This"

Phase C is KidGameMaker's competitive moat. These features are not just nice to have; they are the reason a family chooses this tool over any other. They leverage AI and procedural generation to make creation effortless.

**Magic Stamp Generator** — Text-to-image stamp creation. A child types "flying blue robot cat" and receives a transparent-background sprite sheet ready to drop on the canvas. Integrates with the existing asset-inbox pipeline for auto-slicing and frame detection. Requires an image-generation backend endpoint; the editor UI is a text field and a "Generate" button.

**Talk-to-Build Voice Assistant** — Speech-to-level-design. A child says "make a platform that moves up and down" and the system places a moving-platform stamp, configures its path points, and opens the parameter panel pre-filled with sensible defaults. Uses a speech-to-text layer feeding into a natural-language-to-JSON-template translator. The "secret sauce" is the template library that maps common phrases to pre-validated stamp configurations.

**Procedural Level Generation** — Creator-defined constraints (biome, length, difficulty, theme) fed into a grammar-based generator that produces full platforming levels as stamp collections. The output is standard KidGameMaker JSON that can be edited by hand or accepted as-is. The generator runs server-side and returns a level file; no runtime integration needed.

**Adaptive Difficulty — Helper Fairy** — A real-time difficulty adjustment agent that monitors player performance (death rate, completion time, item usage) and subtly tweaks enemy HP, platform spacing, and hint frequency. The agent communicates via the existing `game_events` telemetry stream and writes adjustments to a `difficulty_override` block in the runner's live state.

**Voice NPC Dialog** — Text-to-speech for NPC lines with per-character voice profiles. A child writes dialog in the editor; the runner speaks it aloud using a lightweight voice synthesis layer. Voice profiles (gruff, squeaky, regal, robotic) are selectable from a dropdown. No backend dependency; runs locally in Godot via speech synthesis libraries.

**Auto-Music Composer** — Mood-driven procedural music. The creator selects a mood (battle, exploration, puzzle, boss) and a tempo; the system generates a looping track that reacts to gameplay events (intensity rises when enemies appear, shifts to minor key on player damage). Exports to the existing audio-inbox pipeline as a `.ogg` loop.

**Ghost Racer** — Time-trial mode where a translucent replay of the creator's best run appears as a competitor. Records input sequences and replays them on a ghost entity. Uses the `input_recording` and `ghost_playback` JSON blocks, leveraging the deterministic runner for frame-accurate replay.

Phase C estimate: 26 features, 12–14 weeks.

---

### Phase D: Polish (P3) — "A Product Worth Sharing"

Phase D transforms KidGameMaker from a powerful creation tool into a social platform and a lasting experience. These features focus on expression, community, and replayability.

**Photo Studio** — In-game screenshot mode with freeze-frame, camera orbit, filter overlays, and sticker placement. Outputs PNGs to the community gallery. A single stamp-entity with camera control and filter post-processing.

**Replay Theater** — Full gameplay recording with rewind, slow-motion, and highlight auto-detection (deaths, boss kills, speed-run splits). Uses the Ghost Racer recording pipeline but extends it to full video-like playback with scrubbing controls.

**Achievement Scrapbook** — Creator-defined achievements ("Collect 100 coins," "Beat the boss without taking damage") with custom badge art. Scrapbook layout auto-generates from achievement definitions in the project JSON.

**Community Gallery** — Web-based showcase of published games with rating, tagging, and remix forking. Requires a lightweight backend for project storage and metadata indexing; the runner and editor already handle JSON serialization.

**New Game Plus** — Post-completion mode that carries over upgrades, unlocks hard-mode enemy variants, and introduces remix rules (mirrored levels, speed runs, limited lives). NG+ flags live in a `completion_carryover` JSON block.

**Minigames** — Turf War (Splatoon-style territory painting), Card Battles (deck-building combat), and three additional arcade-style minigames. Each is a self-contained rule set packaged as a "game mode template" that creators can drop into their projects.

**Seasonal Events** — Time-limited stamps, themes, and challenge modes that rotate monthly. Event content is delivered via JSON patch files downloaded to the asset inbox. No client update required.

Phase D estimate: 32 features, 10–12 weeks.

---

## 12.2 Complexity vs. Impact Analysis

The following table identifies the fifteen highest-priority features across all four phases, scored by implementation complexity (engineering effort, unknowns, integration risk) and player impact (how dramatically the feature improves the creator or player experience). Features with high impact and medium-or-lower complexity are the optimal development targets.

| # | Feature | Source Inspiration | Complexity | Impact | Phase |
|---|---------|-------------------|------------|--------|-------|
| 1 | Wall Jump / Dash / Double Jump | Celeste, Hollow Knight | Low | Critical | A |
| 2 | Sword Combo + Charge Shot + Parry | Zelda, Hollow Knight | Medium | Critical | A |
| 3 | Switch-Door-Key Rule System | Zelda, Portal | Low | Critical | A |
| 4 | AI Level Balancer | KidGameMaker Original | Medium | High | A |
| 5 | Smart Tutorial Whisperer | KidGameMaker Original | Medium | High | A |
| 6 | Boss Phase Constructor | Dark Souls, Cuphead | High | Critical | B |
| 7 | Classes & Job Badges | Final Fantasy, Terraria | Medium | High | B |
| 8 | Elemental Chemistry Engine | Zelda: BotW, Divinity OS | Medium | High | B |
| 9 | Pikmin-Style Companion Swarm | Pikmin, Spirit Ashes | High | High | B |
| 10 | Crafting & Cooking System | Zelda, Stardew Valley | Medium | Medium | B |
| 11 | Magic Stamp Generator (Text-to-Sprite) | KidGameMaker Original | High | Critical | C |
| 12 | Talk-to-Build Voice Assistant | KidGameMaker Original | High | Critical | C |
| 13 | Procedural Level Generator | Spelunky, Hades | High | High | C |
| 14 | Adaptive Difficulty (Helper Fairy) | KidGameMaker Original | Medium | High | C |
| 15 | Community Gallery + Remix Forking | Roblox, Minecraft | Medium | High | D |

**Analysis.** The eight features ranked Critical impact are non-negotiable for product-market fit. Items 1–3 (core movement and rules) are low-complexity and should be the very first engineering tasks. Items 6 and 11–12 (boss constructor, Magic Stamp, Talk-to-Build) are the highest complexity but also the strongest differentiators; they require dedicated prototyping sprints before full implementation. Items 4–5 and 14 (AI-assisted quality-of-life features) punch above their weight: medium complexity, high impact, and they improve every game made on the platform automatically.

---

## 12.3 JSON Contract Evolution Strategy

KidGameMaker's architecture depends on a clean separation between the Svelte/Tauri editor (which produces project JSON) and the Godot 4 runner (which consumes it). As the feature set expands from the current Phase 9 baseline through Phases A–D, the JSON schema must grow without breaking existing projects.

### Backward-Compatible Schema Versioning

Every project file carries a top-level `schema_version` field (current: `"1.9.0"`, Phase A target: `"2.0.0"`). The runner implements a version-compatibility layer that upgrades older project files on load using a chain of migration functions: `migrate_1_9_to_2_0`, `migrate_2_0_to_2_1`, and so on. Each migration is a pure function that takes a JSON object and returns a modified JSON object with deprecated fields remapped to their modern equivalents and new fields populated with sensible defaults. Migrations are tested against a corpus of real project files from each historical phase to prevent regressions. Breaking schema changes are reserved for major version bumps and are announced two release cycles in advance.

### Sidecar Metadata Block Extension Plan

Large feature additions do not bloat the core entity format. Instead, they attach as sidecar metadata blocks keyed by feature domain. For example, the elemental chemistry system adds a top-level `"elemental_rules"` array; the class system adds a `"class_definitions"` lookup table; the companion system adds a `"companion_behaviors"` dictionary. Each sidecar block is self-describing with a `"_meta"` sub-field that declares its feature domain and minimum schema version. The runner only loads sidecar blocks for features it supports, gracefully ignoring unknown domains. This pattern keeps the core `entity`, `level`, and `tilemap` structures stable while allowing unlimited orthogonal extension.

### Runtime Template Expansion Strategy

KidGameMaker supports template macros — reusable JSON fragments that expand at runtime. A template reference like `{ "$template": "boss_phase_standard", "$params": { "hp_threshold": 0.5 } }` is resolved by the runner against a built-in template library before the scene is instantiated. Phase C's procedural level generator and Talk-to-Build assistant both produce template-heavy JSON rather than raw scene data, which dramatically reduces file sizes and ensures generated content follows best-practice patterns. Templates are versioned independently of the schema and can be hot-updated via the asset inbox without a client release. Creators can also define custom templates in their project, enabling a library of reusable components that improve with every project.

The combination of versioned migrations, sidecar metadata blocks, and runtime template expansion ensures that KidGameMaker's JSON contract remains a stable, evolvable foundation for the full 345-feature vision — and for whatever features come after it.
