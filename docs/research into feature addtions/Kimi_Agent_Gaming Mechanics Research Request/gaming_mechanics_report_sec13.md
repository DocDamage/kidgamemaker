# 13. Implementation Roadmap

Building a stamp-based game creation platform for children is not a feature-sprint; it is a trust-sprint. Every month of development must answer one question first: can a five-year-old place a stamp and see something wonderful happen? If the answer is no, the feature waits. This roadmap organizes twelve months of engineering into four sequential phases, each delivering a shippable milestone that a child can play. The ordering follows the cross-dimensional insight that forgiveness — not graphics, not AI, not physics — is the platform's core architectural value proposition[^77^][^78^]. A physics engine without invisible assists is just math. A combat system without auto-aim is just frustration. A world builder without validation is just broken levels. Each phase layers new capability onto a foundation that already feels good.

The roadmap table below maps every system described in Chapters 1–12 to a specific development window, with team sizing estimates, deliverable definitions, and measurable success criteria. The critical path runs through the LLM stamp-to-code pipeline (§7.1), the forgiveness engine (§1.2), and the three-tier assist system (§10.1). Everything else branches from these roots.

| Phase | Months | Core Deliverables | Systems (Chapter Refs) | Team Size | Success Criteria |
|---|---|---|---|---|---|
| **Phase 1: Foundation** | 1–3 | Stamp canvas with 80px snap grid; 5 physics presets; 9-part forgiveness engine; 20 basic stamp types; Mellow Mode; LLM pipeline v1 with template fallback; COPPA architecture | §1.1–1.3, §7.1–7.3, §10.1, §12.3 | 6–8 engineers | Child places character + platform + coin stamps and plays a platformer within 3 seconds; template fallback delivers game in <200ms on LLM failure; 5 consecutive deaths trigger invisible assist |
| **Phase 2: Systems** | 4–6 | Combat stamp system (38 stamps, 6 elements); visual progression (size/color/aura); 5 movement abilities; puzzle auto-connection; Growing Mode; LLM design intelligence v2 | §2.1–2.3, §3.1, §4.1, §6.1, §10.1, §11.1 | 8–10 engineers | Auto-aim hits first enemy 100% of the time for 5-year-old input patterns; visual progression triggers evolution animation at XP threshold; puzzle solvability check runs in <5ms per stamp placement |
| **Phase 3: World Building** | 7–9 | Room stamp Metroidvania builder; procedural room stitching; era/style switching (8-bit/16-bit/hand-painted); atmosphere inference engine; diegetic UI; parallax backgrounds; Creator Mode | §5.1–5.3, §9.1–9.3, §10.1 | 8–10 engineers | 4×4 room graph validates BFS reachability in <10ms; atmosphere inference generates 20+ parameters from 3 stamps; era switch renders without engine restart; diegetic UI shows zero HUD pixels |
| **Phase 4: Social & Polish** | 10–12 | Safe sharing with QR codes; bubble respawn co-op; companion AI stamps; daily discovery system; creation challenges; parent dashboard; remix system | §8.1–8.3, §11.1–11.3, §12.1–12.3 | 6–8 engineers | QR code generation → playable game in <2 seconds; co-op bubble rescue works with 4 players at 60fps; daily discovery delivers 3 stamps with no streak mechanics; parent dashboard reviews all activity |

**Chart: Cumulative System Delivery Over 12 Months**

The delivery velocity follows an S-curve: Phase 1 builds the engine core (20% of total systems, 40% of architectural risk); Phase 2 adds gameplay systems (35% of total systems, highest user-facing value); Phase 3 enables creative expression (25% of total systems, highest differentiation); Phase 4 polishes social features (20% of total systems, highest retention impact). By month 3, a child can build and play a basic platformer. By month 6, they can build a combat level with progression. By month 9, they can build a connected multi-room world. By month 12, they can share that world with a friend and remix creations from the community.

---

## 13.1 Phase 1: Foundation (Months 1–3)

Phase 1 has one job: make stamp placement feel magical. A child drags a character stamp onto a grid, adds a platform beneath it, scatters some coins, and presses Play. Three seconds later, they are jumping. If this core loop is not solid, no amount of later feature work matters. The team focuses on four interlocking subsystems: the stamp canvas, the physics engine, the forgiveness layer, and the LLM pipeline with its circuit-breaker fallback.

### 13.1.1 Core Stamp System and Canvas

The stamp canvas is the primary interface. It renders on a Phaser.js WebGL surface with an 80×80 pixel snap grid — large enough that a five-year-old's imprecise finger placement consistently lands on the intended cell[^3^]. Each grid cell accepts one functional stamp (character, enemy, platform, collectible) and unlimited decorative overlays (flowers, clouds, stars). The canvas supports drag-and-drop with haptic feedback on successful snap, a 64×64 pixel undo button always visible in the top-right corner, and a 2-second hold-to-delete gesture that shakes the stamp before removal to prevent accidental destruction.

The initial stamp library contains exactly 20 types organized into four categories: Hero (Player Character, Companion Pet), Enemy (Slime Hopper, Bat Patroller), Platform (Static Ground, Moving Platform, Cloud Platform, Ice Surface), and Collectible (Coin, Star, Heart, Key, Door, Goal Flag, Checkpoint). These 20 stamps provide enough expressive range for a child to build a recognizable platformer — a hero who jumps across platforms, avoids enemies, collects coins, and reaches a goal — without overwhelming a working memory that holds only 2–3 items[^2^]. The LLM maps each stamp to a pre-validated code template; 20 stamps means 20 template functions that compose into a complete Phaser scene. This constraint is intentional: every stamp added beyond these 20 introduces template combinations that multiply exponentially. Phase 1 locks the stamp set to ensure 100% template coverage.

### 13.1.2 Physics Engine with Three Presets

The `ConfigurablePhysicsEngine` (§1.1.3) loads from a preset table containing three feel profiles at launch: Bouncy (Mario-inspired, heavy acceleration curve, 180 px/s max speed), Fast (Sonic-inspired, momentum-based, 480 px/s max speed), and Floaty (Kirby-inspired, low gravity, slow max fall). Each preset carries a kid-friendly variant with child-optimized defaults: gravity at 800 px/s² ascending and 900 px/s² descending, coyote time at 0.15 seconds, jump buffer at 0.15 seconds, corner correction at 8 pixels, and max fall speed capped at 350 px/s[^93^][^141^]. The engine runs a 60 FPS fixed-timestep loop regardless of display refresh rate, ensuring consistent physics across devices from budget tablets to high-refresh phones[^162^].

The physics system integrates with the forgiveness engine (§1.2) through a dual-pipeline architecture. Raw input passes through the `ForgivenessJumpPipeline` before reaching the physics integrator; post-movement positions pass through the `SpatialForgiveness` layer before collision resolution. Both pipelines expose an `adjustConfig()` interface that the struggle detector uses to silently increase help parameters when the child is struggling.

### 13.1.3 Mellow Mode Assist Layer

Mellow Mode (§10.1.1) ships complete in Phase 1 because it defines the default experience for the target audience. Grid cells are 80×80 pixels, touch targets are 64×64 pixels, game speed runs at 75% of normal, and auto-correct silently fixes impossible stamp configurations. Health is infinite: enemies bump the player harmlessly, pits bounce the player back with a giggle animation, and there are no fail states of any kind[^17^][^18^]. Auto-checkpoints fire every 10 seconds. Visual guides — subtle dotted lines — show connections between interactive stamps. The undo system is infinite, implemented via a Command Pattern with a 100-command history cap to prevent memory issues.

The Struggle Detector (§1.3) ships alongside Mellow Mode. It monitors death frequency, hesitation time, and input patterns through a rolling 5-minute window. Five deaths in 60 seconds triggers help mode: coyote time drifts up to 0.20 seconds, enemy speed drops to 70%, invisible platforms spawn at 15% opacity below death hotspots, and game time subtly slows to 88%[^139^][^161^]. All adjustments use linear interpolation over 10+ seconds — the child never perceives a change[^457^].

### 13.1.4 LLM Pipeline v1 with Template Fallback

The stamp-to-code pipeline (§7.1) is the highest-risk technical component. Phase 1 implements the complete six-stage pipeline — Stamp Parser, Prompt Builder, Constrained LLM, two-pass Validator, Sandboxed Execution, and Game Engine hot-reload — with a three-tier fallback architecture. Tier 1: primary LLM call with exponential backoff (2^n seconds, capped at 60 seconds). Tier 2: circuit breaker opens after 5 consecutive failures, halting LLM calls for 60 seconds and switching to pre-validated templates. Tier 3: emergency template mode generates a functional platformer from any stamp configuration in 30–200 milliseconds without any LLM involvement[^12^].

Constrained decoding via Outlines or XGrammar guarantees syntactically valid output[^5^]. The template library contains 50+ code snippets covering all 20 Phase 1 stamp types. When the LLM is unavailable — rate limiting, network failure, or classroom-scale load of 30 concurrent users — the pipeline falls back to template assembly. The child sees only a "Making your game..." animation; the fallback is entirely invisible. The circuit breaker pattern ensures the platform never fails visibly to a child.

**Phase 1 Exit Criteria:** A child can place a character stamp, two platform stamps, three coin stamps, and a goal stamp; press Play; and play a functional platformer within 3 seconds. If the LLM is disconnected, the template fallback delivers the same game in under 200 milliseconds. Five consecutive deaths at the same location spawn an invisible platform. The parent gate blocks dashboard access behind a math problem.

---

## 13.2 Phase 2: Systems (Months 4–6)

Phase 2 layers gameplay depth onto the foundation. The core loop — place stamps, press Play, jump around — is now solid. The child needs things to do within that loop: fight enemies, earn visual upgrades, unlock movement abilities, and solve simple puzzles. Phase 2 introduces the combat stamp system, the visual progression engine, five movement abilities, the puzzle auto-connection system, and Growing Mode for 7–8 year olds.

### 13.2.1 Combat Stamp System

The combat system (§2.1) adds 38 combat stamps across seven categories: Hero (3 stamps), Enemy (6 behavioral archetypes including Patrol, Chaser, Shooter, Heavy, Flying, and Boss), Weapon (6 firing patterns with Spread as the always-on default), Element (6 types in a rock-paper-scissors weakness cycle), Vehicle (4 types), Environment (5 hazard types), and Helper (4 buff stamps). The Spread Stamp fires five projectiles in a widening fan that requires no aiming precision — the child faces an enemy and projectiles auto-target[^25^].

The six-element weakness cycle (§2.1.2) encodes rock-paper-scissors through physical intuition: Fire beats Ice (flame melts snowflake), Ice beats Electric (frost insulates), Electric beats Metal (lightning fries circuits), Metal beats Nature (metal cuts plants), Nature beats Water (plants absorb), and Water beats Fire (water extinguishes). Super-effective hits produce a gold flash and explosion popup; resisted hits show gray with a shield icon. Numbers never appear on screen[^28^].

The LLM auto-generates the `WeaknessSystem` class when the child places their first Element Stamp. The system runs entirely behind the scenes — no damage numbers, no health bars, no menus. The child sees only colors, icons, and particle bursts. The combat system integrates with the forgiveness engine: after 3 consecutive deaths near an enemy, that enemy falls "asleep" (Zzz particles), reducing speed to 30% and disabling attacks.

### 13.2.2 Visual Progression System

The progression system (§3.1) replaces every numeric RPG indicator with a visible transformation. Character stamp size grows with each enemy defeated. Color intensity shifts from pale to deeply saturated. A companion orb follows the character, changing from green to yellow to red to signal health status[^187^]. An outline glow shifts from bronze to silver to gold to platinum. Particle density increases through five tiers. When thresholds are crossed — at 3, 6, 10, and 15 cumulative defeats — the character stamp performs an evolution animation: it pulses, briefly doubles in scale, emits celebration particles, then settles at a new permanent base size[^155^].

The underlying system tracks only visual state properties. There is no `level` integer exposed to the player. The `VisualProgressionSystem` stores base scale, glow intensity, particle count, and outline tier — all values consumed by the renderer, never shown in the UI. This design ensures that a child who cannot read numbers still understands exactly how powerful their character has become.

### 13.2.3 Five Movement Abilities and Growing Mode

The movement system (§4.1) introduces five traversal stamps in a dependency-gated progression: Double Jump (unlocked after 3 games completed), Wall Jump (requires Double Jump), Dash (requires Double Jump), Grapple Hook (requires Dash and Wall Jump), and Transformation (requires all previous). The `MovementAbilityManager` validates unlocks via a directed acyclic graph — a child cannot place Wall Jump before Double Jump, nor Grapple before Dash. Locked stamps appear grayed out with messages like "Complete 2 more levels to unlock!"[^164^].

Growing Mode (§10.1.2) activates for children aged 7–8. The grid shrinks to 64×64 pixels, touch targets to 48×48 pixels, game speed increases to 90%. Five hearts of health regenerate when standing still. Visual guides shift to on-request via tap-and-hold. Undo is capped at 50 actions. Checkpoints become player-placed checkpoint stamps following Ori's Soul Link model[^9^][^10^]. The Struggle Detector activates with progressive adaptation: after three failures in 30 seconds, snap radius increases 10%, enemy speed drops 15%, and invisible safety platforms spawn below wide gaps.

### 13.2.4 Puzzle Auto-Connection and LLM v2

The puzzle system (§6.1) enables switch-door auto-connection via proximity: when any switch-type stamp and any door-type stamp are within five grid cells, the LLM auto-generates a logical connection. Color-coded dotted lines pulse between connected pairs when the switch activates. The solvability checker runs after every stamp placement using A* pathfinding from the player start to the exit. If the level becomes unsolvable, a friendly mascot suggests a fix[^363^]. Push blocks are checked for corner dead-ends — the classic Sokoban trap[^261^].

LLM v2 introduces design intelligence (§7.1.1). The pipeline now applies 200+ game design heuristics automatically: adding checkpoint stamps before hard sections, balancing enemy counts, ensuring reachable platforms. The LLM acts as an invisible game designer who improves the child's creation — not just translating stamps to code, but making their game more fun, balanced, and complete.

**Phase 2 Exit Criteria:** A child can build a combat level with 3 enemy types, collect coins that make their character grow bigger, solve a switch-door puzzle, and experience the evolution animation at least once. Growing Mode unlocks after age detection or parent configuration. The LLM suggests stamp placements that improve level design.

---

## 13.3 Phase 3: World Building (Months 7–9)

Phase 3 transforms individual levels into connected worlds. The child who has mastered single-screen platformers now wants to build castles with multiple rooms, forests that connect to caves, and worlds that feel alive. Phase 3 introduces the Room Stamp Metroidvania builder, procedural room stitching, era and style switching, the atmosphere inference engine, diegetic UI, parallax backgrounds, and Creator Mode for 9+ year olds.

### 13.3.1 Room Stamp System

The Room Stamp system (§5.1) treats each room as a node on a sticker-book canvas. A child drags Room Stamps onto a grid; when two occupy adjacent cells, the system automatically generates a bidirectional door connection with a satisfying "zip" animation[^241^]. Each Room Stamp carries four directional door indicators, a `biome` field (forest, castle, cave, underwater, sky, volcano), and a `room_type` (start, end, boss, treasure, shop, secret, normal). Warp Stamps create zero-weight shortcut edges between any two rooms[^238^].

The gear-gating system presents Metroidvania progression as simple color matching: a Gate Stamp shows a colored lock on a door, and a Key Stamp of the same color placed in any reachable room unlocks it. The LLM validates that every gate color has at least one matching key placed somewhere reachable before the gate, preventing the classic design error of keys trapped behind their own locks[^276^].

### 13.3.2 Procedural Stitching and World Validation

Every stamp placement triggers incremental BFS validation from the Start room (§5.1.2). The validation pipeline answers three questions: Is every room reachable? Is the End/Boss room reachable? Are all gear gates solvable? Petri net reachability analysis classifies maps as viable, non-viable, or inviable[^276^]. Visual feedback uses a gentle color language: green pulse for well-connected rooms, yellow shimmer for rooms needing attention, red outline only for genuinely problematic placements. The Play Test button traces the expected player path with a glowing trail[^227^].

Procedural room stitching (§5.2) uses Dead Cells-inspired room templates with graph-guided placement. The system maintains a library of hand-crafted room layouts for each biome, stitches them according to the child's graph structure, and runs A* playability validation before presenting the result. Spelunky's insight that procedural worlds must guarantee a solvable path before decorative content is added drives the ordering: connectivity first, content second[^267^].

### 13.3.3 Era/Style Switching and Atmosphere Inference

Era switching (§5.3) lets children transform their world's visual style with a single stamp placement. Three era stamps — 8-Bit, 16-Bit, and Hand-Painted — trigger complete asset pipeline swaps without changing game logic. The 8-Bit era uses 16-color palettes, 1-bit alpha, and square pixels. The 16-Bit era uses 256-color palettes, parallax scrolling, and Mode 7-style rotation effects. The Hand-Painted era uses full-color artwork with normal-mapped lighting. Era stamps can be placed per-room, allowing a child to build a world where a pixel-art dungeon connects to a hand-painted forest.

The atmosphere inference engine (§9.1) reads stamp combinations and generates 20+ atmospheric parameters. When a child places Forest + Night + Fog stamps, the LLM produces a complete `AtmosphereConfig`: ambient light color and intensity, directional light angle, up to 8 point lights, fog density and height, ambient audio bed, foreground sounds, particle effects, and color grading values[^374^][^403^]. The procedural lighting engine uses decal-layering inspired by Playdead's *Inside*. The atmospheric audio mixer synthesizes environmental sound via the Web Audio API — rain from random-pitched oscillators, wind from filtered noise[^404^].

### 13.3.4 Diegetic UI, Parallax, and Creator Mode

The diegetic UI system (§9.2) eliminates every HUD element. Health is shown through character stamp visual state (pristine → scratched → cracked → flashing). Score appears as collectible stamps on a "trophy shelf" area of the canvas. Abilities show through character stamp aura changes. Objectives are indicated by a Compass Stamp that rotates toward the goal. Zero HUD pixels — everything is embedded in the stamps themselves[^187^][^403^].

Parallax backgrounds (§9.3) distribute background stamps across seven depth layers, each scrolling at a different rate for cinematic depth. The system auto-assigns depth based on stamp type: distant mountains at layer 7 (slowest), midground trees at layer 4, foreground flowers at layer 1 (fastest). Atmospheric particles (fireflies, dust motes, snow) spawn from the atmosphere config with a hard cap of 500 active particles and automatic LOD reduction below 30 FPS[^377^].

Creator Mode (§10.1.3) removes scaffolding for 9+ year olds. Stamps place freely on a 16×16 grid or with no grid. Full undo/redo (100 actions) with keyboard shortcuts. Game speed at 100%. Health has real consequences, though checkpoint stamps remain unlimited. Creator Mode is never forced — transition is gradual and celebrated, offered when the platform detects readiness.

**Phase 3 Exit Criteria:** A child can build a 4×4 room world with 3 biomes, validate that every room is reachable, switch visual eras between rooms, and see atmosphere auto-generate from stamp combinations. Creator Mode unlocks for age 9+ with parent override. Diegetic UI displays all game state without a single HUD pixel.

---

## 13.4 Phase 4: Social & Polish (Months 10–12)

Phase 4 makes creation social. A child who has built worlds now wants to share them — to show a sibling the castle they built, to play together, to discover what others have made. Phase 4 introduces safe sharing with QR codes, bubble respawn co-op, companion AI stamps, the daily discovery system, creation challenges, the parent dashboard, and the remix system. All social features are opt-in with parent approval; the default experience remains entirely private.

### 13.4.1 Safe Sharing with QR Codes

The sharing system (§8.1) generates QR codes from completed stamp canvases. A child taps "Share My Game" and the system produces a QR code encoding a compressed stamp layout and a unique share URL. A friend scans the code and plays the game immediately — no download, no account, no waiting. The QR code also supports remix: the recipient can stamp their own additions and re-share, creating a chain of collaborative creations. All sharing routes through the parent dashboard for approval; the child sees a friendly "Ask a grown-up to share!" message if no consent is on file.

The system uses a zero-data architecture: no usernames, no profiles, no persistent identifiers[^302^]. Session codes are random 4-digit numbers with one-hour TTL. IP addresses are hashed and discarded after the session ends. No cookies or tracking mechanisms exist. The parent dashboard provides full visibility into all sharing activity, the ability to block specific peers, and controls for setting safety levels[^580^].

### 13.4.2 Bubble Respawn Co-op

The co-op system (§8.2) implements Nintendo-inspired bubble respawn from *New Super Mario Bros. Wii*. When a player loses their last heart, they transform into a bubble and float to the nearest surviving player. A tap on the bubble releases them back into play. The design eliminates "game over" for any player while creating moments of cooperation — "rescue me!" becomes a fun interaction rather than a failure state. Gentle Mode is ON by default: players cannot push each other or cause harm[^335^]. Voluntary bubbling has a cooldown timer; after 10 seconds in a bubble, it auto-pops. The buddy AI auto-prioritizes bubble rescue.

If a human player disconnects, their character becomes AI-controlled instantly with no interruption[^417^]. Disconnected players have a 20-second grace period to reconnect. Empty rooms persist for 60 seconds before cleanup. Visual feedback during reconnection uses a fun animation rather than an error message.

### 13.4.3 Companion AI Stamps and Daily Discovery

Companion AI stamps (§8.1.2) give children an in-game partner when no friend is available. Three archetypes ship: the Speedy Pet (follows closely, prioritizes bubble rescue), the Strong Robot (auto-attacks nearby enemies), and the Helpful Fairy (floats above hazards, reaches any area). Each companion uses a 120-entry position-recording ring buffer to produce smooth following behavior[^375^][^426^].

The daily discovery system (§11.1) delivers 2–3 mystery stamps each day in the Creator Village. Stamps remain available for 3 calendar days and accumulate if missed — no streaks, no FOMO, no penalties[^626^][^545^]. Unlock conditions are visible: "Create 2 more games to unlock Ocean stamps!" The system responds to engagement patterns, not calendar dates[^579^].

### 13.4.4 Parent Dashboard and Remix System

The parent dashboard (§12.3) provides activity review, peer blocking, time limits, data export and deletion, and creation-only mode toggle. Parents can review every stamp placed, every game created, every co-op session joined. The dashboard shows which invisible assists activated during play and suggests when to reduce them. All data can be exported or deleted at any time[^580^].

The remix system allows children to take any shared game, add their own stamps, and re-share the modified version. Remix chains are tracked and displayed as family trees — "Your game was remixed 3 times!" — providing positive reinforcement for creation without competitive pressure. No like counts, no rankings, no leaderboards. Every creation receives equal showcase in the private Family Gallery.

**Phase 4 Exit Criteria:** A child generates a QR code for their game in under 2 seconds; a friend scans it and plays within 3 seconds. Four-player co-op maintains 60fps with bubble respawn working. Daily discovery delivers 3 stamps with no streak mechanics. Parent dashboard reviews all activity with assist transparency. Remix chains display as family trees without competitive metrics.

---

## 13.5 Risk Mitigation and Contingency Planning

Three risks could derail the roadmap. The first is LLM latency under classroom-scale load. If 30 concurrent children generate games simultaneously, the LLM backend must not degrade. The mitigation is a local LLM pool (Microsoft Phi-3 running on edge hardware) that handles template assembly and basic design intelligence, reserving cloud LLM calls for novel stamp configurations[^17^]. Request deduplication caches responses for identical stamp layouts, reducing redundant calls by 60–70%.

The second risk is scope creep from the 100+ stamp types defined in the full ontology (§Research Insight 10). The mitigation is strict adherence to the phased stamp rollout: 20 stamps in Phase 1, 38 combat stamps in Phase 2, room and atmosphere stamps in Phase 3, social stamps in Phase 4. No stamp ships without a validated template and a validated LLM prompt.

The third risk is COPPA compliance complexity. The mitigation is the zero-data-by-default architecture designed in from day one: no personal information collection, hashed IDs, no usernames, no profiles, IP anonymization, no cookies[^302^]. Retrofitting privacy protections onto a system that already collects data is technically difficult and legally hazardous — COPPA compliance must be architectural, not additive.

The 12-month timeline assumes a team of 6–10 engineers with expertise in game development, LLM integration, and children's UX. The critical path is Phase 1: if the core stamp-to-game loop is not magical by month 3, subsequent phases add features to a broken foundation. The milestone gates are non-negotiable — each phase must meet its exit criteria before the next begins. The result, delivered at month 12, is a platform where a five-year-old places stamps on a canvas and watches their imagination become a game they can play, share, and remix.
