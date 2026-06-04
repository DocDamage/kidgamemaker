# Dimension Decomposition: Gaming Mechanics for Stamp-Based Zero-Code Game Creator

## Context Summary
- **Target Platform**: Stamp-based, zero-code game creation platform for children as young as 5
- **Core Philosophy**: Children place "stamps" (pre-made game elements) on a canvas; a lightweight LLM generates all underlying code in the background
- **Design Constraints**: Extreme UI simplicity for 5-year-olds, deep backend complexity, zero frontend code exposure
- **Research Foundation**: 28 studios across 5 decades of side-scrolling innovation

## The 12 Research Dimensions

### Dimension 01: Core Platforming Physics
**Scope**: Jump mechanics, momentum, gravity, collision detection, and movement systems derived from the most influential platformers.
**Studios to Research**: Nintendo (SMB sub-pixel physics), Sega/Sonic Team (angular momentum, loops), Celeste (coyote time, corner correction, sub-pixel buffering), id Software (adaptive tile refresh).
**Key Question**: How can complex physics be abstracted into stamp-based placement while maintaining game feel?
**Expected Source Types**: GDC talks, game postmortems, physics engine documentation, accessibility research.

### Dimension 02: Combat & Action Systems
**Scope**: Melee combat, projectile systems, weapon mechanics, combo systems, and enemy encounters.
**Studios to Research**: Capcom (Mega Man weapon stealing, non-linear boss weakness), Konami (Contra 8-directional aiming), Treasure (Gunstar Heroes weapon blending), Inti Creates (MM Zero melee combos), SNK (Metal Slug vehicle hijacking, destructible environments).
**Key Question**: How can combat depth be achieved through stamp combinations rather than button inputs?
**Expected Source Types**: Combat design analyses, frame data studies, input simplification research.

### Dimension 03: Progression & RPG Systems
**Scope**: Experience points, equipment, stats, shops, inventory, and character growth layered onto side-scrolling.
**Studios to Research**: Konami (Castlevania SotN RPG elements), Sega/Core Design (Wonder Boy shops/quests), Nintendo (Metroid gear-gating), Vanillaware (Odin Sphere RPG depth).
**Key Question**: How can RPG progression be made visual and stamp-based for children?
**Expected Source Types**: RPG system design docs, progression psychology, children's learning research.

### Dimension 04: Traversal & Special Movement
**Scope**: Grappling, wall-jumping, dashing, swimming, flying, transformations, and alternative movement modes.
**Studios to Research**: Capcom (Bionic Commando grapple physics), WayForward (Shantae animal transformations), Moon Studios (Ori Bash mechanic), Team Cherry (Hollow Knight dash/charm movement).
**Key Question**: How can special movement abilities be unlocked and assigned via stamp progression?
**Expected Source Types**: Movement design analyses, control scheme research, accessibility studies.

### Dimension 05: World Structure & Level Architecture
**Scope**: Map design philosophies — linear, interconnected (Metroidvania), procedural, hub-based, and stage-select.
**Studios to Research**: Nintendo (Metroid map matrix), Capcom (Mega Man stage-select), Konami (Castlevania interconnected maps), Motion Twin (Dead Cells procedural stitching), Sabotage Studio (Messenger 8-bit/16-bit world switching).
**Key Question**: How can world structures be created by children through stamp-based room/level placement?
**Expected Source Types**: Level design theory, spatial cognition research, procedural generation papers.

### Dimension 06: Puzzle & Environmental Mechanics
**Scope**: Physics puzzles, switch/button systems, time manipulation, environmental hazards, and spatial reasoning challenges.
**Studios to Research**: Number None (Braid temporal manipulation), Playdead (Limbo/Inside diegetic physics puzzles), Moon Studios (Ori environmental puzzles).
**Key Question**: How can puzzle mechanics be made discoverable through stamp placement and natural child intuition?
**Expected Source Types**: Puzzle design theory, child psychology, environmental storytelling research.

### Dimension 07: Co-op, Social & Companion Systems
**Scope**: Multiplayer mechanics, companion AI, shared progression, and social features.
**Studios to Research**: The Behemoth (Castle Crashers co-op brawling), Technōs Japan (Double Dragon/River City Ransom co-op), Nintendo (co-op platforming in modern titles).
**Key Question**: How can co-op and social play be enabled through simple stamp-based invites and shared canvases?
**Expected Source Types**: Multiplayer UX research, children's social play studies, couch co-op design.

### Dimension 08: Visual, Audio & Atmospheric Systems
**Scope**: Lighting, particle effects, sound design, camera systems, and diegetic UI (no HUD).
**Studios to Research**: Playdead (Limbo/Inside diegetic UI), Moon Studios (Ori multi-plane physics + painted backgrounds), Sad Cat Studios (Replaced macro-lighting over pixel art), Vanillaware (hand-painted skeletal puppetry), Sabotage Studio (real-time 8-bit/16-bit rendering shift).
**Key Question**: How can atmospheric depth be achieved through stamp properties without overwhelming young users?
**Expected Source Types**: Visual design theory, audio design, children's sensory processing research.

### Dimension 09: AI, Adaptive Difficulty & Procedural Content
**Scope**: Enemy AI behaviors, dynamic difficulty adjustment, procedural generation, and replayability systems.
**Studios to Research**: Motion Twin (Dead Cells roguevania stitching), Red Hook Studios (Darkest Dungeon affliction/stress system), modern AI in games.
**Key Question**: How can a lightweight LLM generate enemy behaviors and adapt difficulty based on child player skill?
**Expected Source Types**: AI game design, dynamic difficulty research, procedural content generation papers.

### Dimension 10: LLM Integration & Natural Language to Game Logic
**Scope**: How a built-in lightweight LLM can translate stamp placements and natural language into functional game code.
**Studios to Research**: GameGPT, ChatDev, Rosebud.ai, general LLM code generation research.
**Key Question**: What is the optimal architecture for a lightweight LLM to generate game logic from visual stamps and voice/text input from a 5-year-old?
**Expected Source Types**: LLM agent papers, code generation surveys, natural language programming research, edge AI deployment.

### Dimension 11: Accessibility, Assist Modes & Child-First UX
**Scope**: Design patterns that make complex games playable by young children — assist modes, visual cues, simplification layers.
**Studios to Research**: Extremely OK Games (Celeste Assist Mode), Moon Studios (Ori accessibility), Nintendo (universal design in modern platformers), general children's UX research.
**Key Question**: What accessibility and assist features are essential for a 5-year-old to create and play games successfully?
**Expected Source Types**: Accessibility guidelines (WCAG), children's UX research, early childhood education literature.

### Dimension 12: Roguelike Elements, Replayability & Meta-Progression
**Scope**: Permadeath alternatives, run-based progression, unlock systems, daily challenges, and long-term engagement.
**Studios to Research**: Motion Twin (Dead Cells roguevania), Red Hook Studios (Darkest Dungeon meta-progression), modern mobile game retention mechanics.
**Key Question**: How can roguelike replayability be adapted for a child's creation platform without frustration?
**Expected Source Types**: Game retention research, children's motivation studies, roguelike design theory.

## Overlap Matrix
- Dimensions 01 & 04 overlap on movement/physics (~35%)
- Dimensions 02 & 09 overlap on enemy AI/combat (~30%)
- Dimensions 03 & 12 overlap on progression systems (~40%)
- Dimensions 05 & 06 overlap on level/puzzle design (~35%)
- Dimensions 08 & 11 overlap on visual accessibility (~30%)
- Dimension 10 overlaps with all others as the enabling technology (~25% each)
