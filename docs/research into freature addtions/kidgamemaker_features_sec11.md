# Chapter 11: Special Systems & Minigames

> **"The best games are not just one game — they are a hundred games wearing a single game's clothes."**
>
> This chapter documents the alternative modes, bonus stages, and special one-off mechanics that add variety, surprise, and depth to KidGameMaker. These are the features that children discover unexpectedly — the bonus stage that appears after collecting 100 coins, the card game they can play during loading screens, the time-travel mechanic that blows their minds. Every feature here is designed to spark joy and expand what a "kid-friendly game creator" can mean.

---

## 11.1 Competitive & Creative Minigames

### Turf War Paint Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Turf War Paint Mode |
| **Source Game** | Splatoon 1/2/3 (Nintendo, 2015-2022) — Turf War |
| **Description** | A game mode where two teams compete to cover the most terrain with their color of paint by shooting it from paint weapons. At the end of a timed match, a dramatic reveal sequence expands each team's paint coverage, and the winner is declared by percentage. Kid-friendly weapons include paint rollers, paint brushes, and splatter shots. |
| **Kid UX** | The child selects "Paint Battle!" from the mode menu. They pick a paint roller (big and satisfying) and a team color (pink vs. blue). The level loads and the child gleefully rolls paint across the floor, covering every surface. Their character can transform into a "swim form" to move quickly through their own paint. When time runs out, the screen dramatically fills with each team's color expanding from the edges — "Pink Team: 62%! Blue Team: 38%! Pink Team wins!" Confetti everywhere. |
| **LLM Automation** | Backend: (1) Paint coverage tracked as 2D texture overlay per team with per-cell percentage; (2) Weapon-specific paint patterns: roller = wide path, brush = fast sweep, shot = splash radius; (3) Swim-form collision detection allows fast movement only on own-paint surfaces; (4) Dramatic reveal sequence: paint coverage expands from edges with bar-boundary synchronized music; (5) Score calculation: percentage coverage per team with sub-percent precision; (6) Auto-balancing: if one team is AI-controlled, subtle rubber-banding ensures competitive but fair match. |
| **JSON Contract Extension** | `{"turf_war": {"team_colors": {"team1": "#FF69B4", "team2": "#4169E1"}, "duration_seconds": "180", "paint_coverage": [["float"]], "weapons": [{"type": "roller|brush|shot", "paint_width": "int", "paint_rate": "float"}], "reveal_animation": "gradual_fill_from_edges"}}` |

---

### Tableturf Battle Card Game

| Field | Details |
|-------|---------|
| **Feature Name** | Tableturf Battle Card Game |
| **Source Game** | Splatoon 3 (Nintendo, 2022) — Tableturf Battle |
| **Description** | A grid-based territory card game where players place ink-pattern cards on a board to claim the most squares. Cards have different shapes (like Tetris pieces covered in ink) and special abilities. Twelve turns, simultaneous placement, special attacks that ink over opponent territory. 150+ collectible cards. |
| **Kid UX** | The child opens their card collection — 150 colorful cards with ink patterns and cute creature artwork. They build a 15-card deck by dragging favorites into a deck slot. During play, 4 cards are in hand. The child taps a card shaped like an L, then taps where to place it on the 15×15 grid — the L-shape fills with their color. The opponent does the same simultaneously. When the special meter fills, the child unleashes a "Special Attack" that splatters ink over the opponent's territory. Most squares at turn 12 wins. |
| **LLM Automation** | Backend: (1) Card shape validation: placement must touch own-ink edge; (2) Simultaneous turn resolution: both placements processed, overlap resolved (lower card number wins); (3) Special point generation per placement; (4) 12-turn game flow management; (5) Win determination by ink square count; (6) Card rarity system: common/uncommon/rare/legendary with 150+ unique designs; (7) Deck-building advisor suggests synergistic card combinations; (8) Tournament mode with bracket progression. |
| **JSON Contract Extension** | `{"tableturf": {"board_size": {"w": "15", "h": "15"}, "deck_size": "15", "hand_size": "4", "cards": [{"card_id": "int", "pattern": [["int"]], "ink_value": "int", "special_cost": "int"}], "turn": "int(1-12)", "special_points": "int", "ink_coverage": {"player1": "int", "player2": "int"}}}` |

---

### Salmon Run Co-op Horde Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Salmon Run Co-op Horde Mode |
| **Source Game** | Splatoon 2/3 — Salmon Run |
| **Description** | A wave-based cooperative mode where up to 4 players (or AI teammates) defend a central basket from waves of approaching enemies. Players defeat special boss enemies that drop golden eggs, which must be carried back to the basket. Three waves with escalating difficulty. Kid-friendly with silly enemies and egg-collecting mechanics. |
| **Kid UX** | The child taps "Team Up!" and is matched with 3 AI partners (or friends in Family Circle). Wave 1 begins: "Collect 8 Golden Eggs!" Silly fish-like enemies waddle from the water's edge. The child defeats a big boss enemy — it explodes into 3 golden eggs. The child runs over, picks one up (it wiggles!), and carries it back to the basket. "7 more to go!" After wave 3, the escape helicopter arrives and everyone celebrates. |
| **LLM Automation** | Backend: (1) Wave spawning logic with escalating enemy count and types per wave; (2) Golden egg tracking: quota per wave, collection state, basket delivery validation; (3) Boss enemy AI with unique attack patterns per boss type; (4) Egg carrying physics: slows player movement, drops on damage; (5) Team AI: partners assist with egg collection, call for help, revive downed players; (6) Hazard level scaling based on team performance; (7) Escape sequence generation for successful wave 3 completion. |
| **JSON Contract Extension** | `{"salmon_run": {"waves": "3", "current_wave": "int(1-3)", "golden_egg_quota": "int", "collected": "int", "boss_spawns": [{"type": "string", "timer": "float"}], "hazard_level": "int", "team_size": "int(1-4)"}}` |

---

### Blue Sphere Bonus Stage

| Field | Details |
|-------|---------|
| **Feature Name** | Blue Sphere Bonus Stage |
| **Source Game** | Sonic the Hedgehog 3 & Knuckles (Sega, 1994) — Special Stage |
| **Description** | A pseudo-3D bonus stage where the player runs across a spherical checkerboard surface, collecting blue spheres and avoiding red ones. Touching a blue sphere turns it into a red sphere, making navigation increasingly treacherous. A ring counter serves as a timer — collecting rings extends the stage. Kid-friendly with bright colors and bouncy physics. |
| **Kid UX** | The child collects 50 rings in a level and a "BONUS!" portal appears. They enter and find themselves running on a giant colorful sphere. Blue spheres are scattered everywhere — the child runs into them and they pop with a satisfying chime, turning red. "Collect all blue spheres!" The child strategizes, planning routes that don't trap them behind red spheres. When all blues are collected, a huge fanfare plays and they win a Chaos Emerald. |
| **LLM Automation** | Backend: (1) Spherical surface mapping: 2D player movement projected onto 3D sphere; (2) Sphere state management: blue → red on contact, with state validation; (3) Ring counter as timer: depletes over time, collecting rings refills; (4) Win condition: all blue spheres collected without touching red; (5) Lose condition: touch red sphere or ring counter reaches zero; (6) Progressive difficulty: larger spheres, more red spheres, faster ring depletion across stages; (7) Emerald reward system: 7 emeralds total, each from a harder stage. |
| **JSON Contract Extension** | `{"blue_sphere": {"sphere_radius": "float", "blue_spheres": [{"x": "float", "y": "float", "collected": "boolean"}], "red_spheres": [{"x": "float", "y": "float"}], "ring_counter": "int", "win_condition": "all_blue_collected", "emerald_reward": "int(1-7)"}}` |

---

### Score Attack Time Trial

| Field | Details |
|-------|---------|
| **Feature Name** | Score Attack Time Trial |
| **Source Game** | Sonic (Time Attack), NiGHTS into Dreams (score chaining) |
| **Description** | A speed-run mode where children race through a level as fast as possible while maintaining combo multipliers. Time and score are tracked simultaneously. A ghost replay of the child's best run plays alongside them, providing self-competition. Rankings go from D to S++ with generous thresholds for kids. |
| **Kid UX** | The child taps "Time Attack!" on their favorite level. A 3-2-1 countdown, then GO! The child races through, collecting coins for speed boosts. Their best ghost — a translucent sparkly version of their character — runs the optimal path beside them. "Can I beat my ghost?" They cross the finish line. "New Record! 45 seconds! Rank: A+!" The ghost celebrates with them, not against them. |
| **LLM Automation** | Backend: (1) Millisecond-precise timer with lap-split tracking; (2) Ghost replay system: records and plays back child's best input log as translucent character; (3) Combo multiplier: collecting items in rapid succession builds score multiplier (decays after 2 seconds without collection); (4) Rank calculation: D/C/B/A/S/S++ thresholds calibrated for children's typical completion times; (5) Personal leaderboard: tracks best time, best score, and best combo per level; (6) Ghost improvement: ghost gets slightly faster with each of child's improvements, never impossibly ahead. |
| **JSON Contract Extension** | `{"time_trial": {"best_time_seconds": "float", "current_time": "float", "combo_multiplier": "float", "rank": "D|C|B|A|S|S++", "ghost_replay": {"enabled": "boolean", "ghost_input_log": [{"timestamp": "float", "action": "string"}]}, "personal_leaderboard": [{"date": "string", "time": "float", "score": "int"}]}}` |

---

### Card Battle Collectible Game

| Field | Details |
|-------|---------|
| **Feature Name** | Card Battle Collectible Game |
| **Source Game** | Final Fantasy VIII Triple Triad, Kingdom Hearts Chain of Memories |
| **Description** | A simplified collectible card battle system using a 3×3 grid. Players place numbered cards on the grid; when a card is placed adjacent to an opponent's card with a higher number on the touching edge, the opponent's card flips to the player's color. The player with the most cards at the end wins. |
| **Kid UX** | The child opens their card binder — 50 cards with cute monster artwork and numbers on each edge (top, bottom, left, right). They pick 5 cards for a quick battle. The 3×3 grid appears. The child places a card with 8 on top in the center. The opponent places a card below it with 7 on top — 8 beats 7, so the opponent's card FLIPS to the child's color! "I got your card!" After all 9 grid slots are filled, most cards wins. |
| **LLM Automation** | Backend: (1) 3×3 grid state management with ownership tracking; (2) Adjacency comparison: when a card is placed, compare touching edges with adjacent opponent cards, flip if higher; (3) Card collection system: 100+ cards with 4 edge values each (1-10); (4) Special card abilities: some cards have elemental bonuses or combo flips; (5) AI opponent with 3 difficulty levels; (6) Card pack opening animation with rarity glow effects; (7) Trading system within Family Circle. |
| **JSON Contract Extension** | `{"card_battle": {"grid": [[{"card_id": "string", "owner": "player1|player2|null"}]], "player_deck": [{"card_id": "string", "top": "int(1-10)", "bottom": "int(1-10)", "left": "int(1-10)", "right": "int(1-10)", "element": "fire|water|earth|wind|null"}], "flip_rules": "higher_wins", "special_abilities": "boolean"}}` |

---

### Fishing Minigame

| Field | Details |
|-------|---------|
| **Feature Name** | Fishing Minigame |
| **Source Game** | Stardew Valley, Terraria, Monster Hunter |
| **Description** | A timing-based fishing mechanic where the child casts a line into water, waits for a bite, then plays a simple timing mini-game to reel the fish in. A moving indicator must be kept inside a success zone by tapping at the right rhythm. Different fishing spots yield different fish rarities. |
| **Kid UX** | The child stamps a "Fishing Spot" in a water area of their level. During play, they stand next to it and tap the action button. A bobber floats on the water... then SPLASH! A bite! A simple bar appears with a moving dot. The child taps to keep the dot in the green zone. "Reel it in!" The dot bounces around — the child taps rhythmically. Success! "You caught a Golden Fish!" It goes into their collection book with a satisfying "ding." |
| **LLM Automation** | Backend: (1) Casting physics: line arc based on tap timing; (2) Bite detection: random wait 2-8 seconds, bite probability based on fishing spot rarity tier; (3) Reeling mini-game: moving dot with physics-based momentum, tap applies upward force; (4) Rarity system: common/uncommon/rare/legendary fish per spot; (5) Collection book tracking with completion percentage; (6) Fish behavior patterns: some fish move the dot slowly, others erratically; (7) Weather and time-of-day influence on available fish types. |
| **JSON Contract Extension** | `{"fishing": {"spots": [{"position": {"x": "float", "y": "float"}, "rarity_tier": "common|uncommon|rare|legendary"}], "minigame": {"green_zone_size": "float", "dot_speed": "float", "success_duration_required": "float"}, "collection_book": [{"fish_id": "string", "name": "string", "rarity": "string", "times_caught": "int"}]}}` |

---

### Cooking Minigame

| Field | Details |
|-------|---------|
| **Feature Name** | Cooking Minigame |
| **Source Game** | Monster Hunter (BBQ Spit), Dragon Quest Builders (Cooking Pot) |
| **Description** | A timing-based cooking mechanic where the child combines ingredients at a cooking station and plays a simple timing game to cook them perfectly. Undercooked gives a small buff, perfect gives a large buff, burnt gives nothing. Different ingredient combinations create different dishes. |
| **Kid UX** | The child stamps a "Cooking Pot" and some "Mushroom" and "Meat" ingredient items. During play, they bring the ingredients to the pot and select them. A cooking animation starts: meat rotates on a spit, and a color meter fills (blue → yellow → red). The child taps when the color is in the golden zone. "So Tasty!" confetti bursts. The cooked dish pops out as a floating item — "Healing Soup" — which restores health when eaten. |
| **LLM Automation** | Backend: (1) Ingredient combination database: 50+ valid recipes from 2-3 ingredient combinations; (2) Timing zones: undercooked (small heal), perfect (full heal + buff), burnt (no effect); (3) Recipe discovery: first-time combinations auto-added to recipe book; (4) Buff effects per dish: healing, attack boost, defense boost, speed boost; (5) Cooking animation choreography with particle effects; (6) Invalid combination handling: playful "Poof!" dust cloud with gentle sound; (7) Master chef tracker: cook every recipe for a Scrapbook achievement. |
| **JSON Contract Extension** | `{"cooking": {"stations": ["cooking_pot", "bbq_spit", "fiery_pan"], "ingredients": ["tomato", "bread", "mushroom", "herb", "pepper", "meat", "berry"], "recipes": [{"ingredients": ["string"], "result": "string", "heal_amount": "int", "buff": "string|null"}], "timing_zones": {"undercooked": ["0", "0.4"], "perfect": ["0.4", "0.7"], "burnt": ["0.7", "1.0"]}, "recipe_book": [{"recipe_id": "string", "discovered": "boolean"}]}}` |

---

### Attraction Flow Rides

| Field | Details |
|-------|---------|
| **Feature Name** | Attraction Flow Rides |
| **Source Game** | Kingdom Hearts 3 (Disney attraction rides as combat sequences) |
| **Description** | Themed on-rails shooter sequences where the player's character rides through a spectacular scripted scene — a roller coaster through space, a pirate ship battle, a carousel of lights — while tapping to shoot at targets. These are "set piece" experiences that showcase what KidGameMaker levels can become. |
| **Kid UX** | The child stamps an "Attraction Entrance" in their level. During play, the character jumps in and the perspective shifts: they're now riding a roller coaster through a neon-lit city! Targets appear — balloons, bells, stars — and the child taps them to shoot. The coaster loops and dives automatically while the child focuses on aiming. At the end, a massive firework display and a score tally: "You hit 45/50 targets! Amazing!" The child cheers and wants to ride again. |
| **LLM Automation** | Backend: (1) On-rails camera path following a pre-defined spline curve; (2) Target spawning system: targets appear at scripted positions along the path with difficulty-appropriate timing; (3) Hit detection with generous hitboxes and visual feedback; (4) Score tracking: hits, misses, combo streaks; (5) Rank assignment at ride end based on hit percentage; (6) Spline path editor: children can draw ride paths with their finger; (7) Themed scenery auto-generated along the path (city, jungle, space, ocean); (8) End-of-ride spectacle: fireworks, confetti, slow-motion final target. |
| **JSON Contract Extension** | `{"attraction_ride": {"theme": "roller_coaster|pirate_ship|carousel|space_shooter", "camera_path": [{"x": "float", "y": "float", "z": "float", "rotation": "float"}], "targets": [{"position": {"x": "float", "y": "float"}, "type": "string", "spawn_time": "float"}], "score": {"hits": "int", "misses": "int", "combo_best": "int"}, "rank": "D|C|B|A|S"}}` |

---

### Boss Rush Tower

| Field | Details |
|-------|---------|
| **Feature Name** | Boss Rush Tower |
| **Source Game** | Mega Man Boss Rush, Castlevania Boss Rush, Hollow Knight Pantheon |
| **Description** | A challenge mode where the player fights multiple bosses back-to-back with limited healing between fights. Bosses are fought in sequence on different "floors" of a tower. A timer tracks speed. The child can select which bosses to include from those they've placed in their levels. |
| **Kid UX** | The child stamps a "Boss Tower" in their world. Entering it shows all the bosses they've created, each on a different floor. They select five favorites. An elevator takes them to floor 1: "Goblin King!" Fight! After each boss, a single healing flower briefly blooms. Floor 2: "Shadow Knight!" Floor 3: "Dragon Pup!" At the top, a golden crown badge appears: "Boss Master!" The child flexes and wants to try again faster. |
| **LLM Automation** | Backend: (1) Boss sequence queue management with health carry-over between fights; (2) Limited healing: 1-2 healing items placed between fights, amount scales with boss count; (3) Inter-boss elevator transition animation with floor counter; (4) Timer tracking for speed-run leaderboards; (5) Boss selection UI showing all created bosses with difficulty ratings; (6) Victory card generation with stats: time, damage taken, healing used, boss count; (7) Difficulty scaling: subsequent NG+ cycles add boss attack patterns. |
| **JSON Contract Extension** | `{"boss_rush": {"selected_bosses": [{"boss_id": "string", "floor": "int"}], "heal_between_fights": "int", "timer_enabled": "boolean", "victory_card": {"time_seconds": "float", "damage_taken": "int", "bosses_defeated": "int"}}}` |

---

## 11.2 Special One-Off Mechanics

### Ink Painting Terrain Transformation

| Field | Details |
|-------|---------|
| **Feature Name** | Ink Painting Terrain Transformation |
| **Source Game** | Splatoon (Nintendo) — core ink mechanic |
| **Description** | A stamp-based mechanic where shooting "ink" onto terrain temporarily transforms its properties. The player's ink color makes surfaces bouncy, slippery, or sticky depending on the ink type. Enemies slow down when walking on enemy ink. This mechanic can be layered into any KidGameMaker level for dynamic terrain modification. |
| **Kid UX** | The child stamps "Bouncy Ink" in their palette. During play, shooting it onto normal ground makes that patch glow pink and bouncy. The child shoots a line of bouncy ink across a pit and jumps across it like a trampoline. Their friend shoots "Slippery Ink" (blue) and slides across it at high speed. The terrain becomes a canvas for creative traversal. |
| **LLM Automation** | Backend: (1) Ink overlay texture system: 2D grid tracks ink type and intensity per cell; (2) Terrain modifier application: bouncy ink adds spring physics, slippery ink reduces friction to 0.1, sticky ink increases traction and wall-cling; (3) Ink decay: non-player ink fades over 30 seconds; (4) Cross-ink interaction: opposing inks neutralize on contact creating a "splat" particle burst; (5) Performance optimization: ink grid rendered as composite texture, not individual particles; (6) Ink weapon types: splatter (area), roller (path), charger (line), brush (wide sweep). |
| **JSON Contract Extension** | `{"ink_terrain": {"ink_types": [{"type": "bouncy|slippery|sticky", "color": "string", "physics_effect": "string"}], "grid_resolution": "int", "decay_time_seconds": "30", "weapon_types": ["splatter|roller|charger|brush"], "cross_ink_interaction": "neutralize"}}` |

---

### Celestial Brush Drawing

| Field | Details |
|-------|---------|
| **Feature Name** | Celestial Brush Drawing |
| **Source Game** | Okami (Clover Studio/Capcom, 2006) — Celestial Brush |
| **Description** | A drawing mechanic where the player can pause time and draw strokes on the screen to perform miracles. Straight lines slash through enemies and obstacles. Circles around wilted plants make them bloom. Filled circles become bombs. Spirals create wind. Horizontal lines slow time. The screen takes on a parchment texture while drawing. |
| **Kid UX** | The child holds the "Brush" button and the screen freezes, turning into a beautiful ink-wash parchment. They draw a straight line across an enemy — SLASH! — ink cuts through it. They draw a circle around a dead flower — BLOOM! — it bursts into color. They draw a big filled circle — BOOM! — it becomes a cherry bomb that explodes after 3 seconds. Drawing feels like real magic. |
| **LLM Automation** | Backend: (1) Real-time stroke recognition: straight line vs. circle vs. spiral vs. horizontal line with tolerance thresholds; (2) Stroke-to-effect mapping: straight line = slash damage along path, circle = bloom/revive, filled circle = bomb spawn, spiral = wind force, horizontal line = slow time; (3) Intersection detection: what entities does the stroke pass through; (4) Ink meter consumption per technique (regenerates over time); (5) Parchment overlay shader with ink-wash aesthetic; (6) Unlocked technique tracking: child discovers brush powers progressively; (7) Screen freeze with smooth time-dilation transition. |
| **JSON Contract Extension** | `{"celestial_brush": {"techniques": [{"id": "power_slash", "stroke": "straight_line", "ink_cost": "1", "effect": "damage_line_intersect"}, {"id": "bloom", "stroke": "circle", "ink_cost": "1", "effect": "revive_plant"}, {"id": "cherry_bomb", "stroke": "filled_circle", "ink_cost": "3", "effect": "explosion"}, {"id": "galestorm", "stroke": "spiral", "ink_cost": "2", "effect": "wind_push"}], "ink_meter": {"max": "10", "current": "int", "regen_rate": "1 per 2s"}, "stroke_tolerance": "float"}}` |

---

### Time Travel Era Doors

| Field | Details |
|-------|---------|
| **Feature Name** | Time Travel Era Doors |
| **Source Game** | Chrono Trigger (Square, 1995) — time travel to 65M BC, 600 AD, 1000 AD, 2300 AD |
| **Description** | Special "Era Doors" transport the player between different versions of the same level set in different time periods. Each era has different terrain, enemies, and available items. Changes made in one era affect others: planting a tree in the past creates a forest in the present, defeating a boss in the past changes the future. |
| **Kid UX** | The child stamps an "Era Door" and picks the destination: "Long Long Ago" (prehistoric with dinosaurs), "Olden Days" (medieval with castles), "Right Now" (modern with cities), or "Far Future" (sci-fi with robots). They build each era version of the level in separate tabs. During play, the child plants a tree in the past, takes the Era Door to the present, and sees a full-grown forest! "I changed time!" Their mind is blown. |
| **LLM Automation** | Backend: (1) Era state management: parallel level data stores for each time period; (2) Time-ripple causality system: changes in past eras propagate to future eras via rule engine (tree planted in past → forest in present); (3) Era door transition: warp with time-vortex visual effect; (4) Era-appropriate visual filters: prehistoric = warm sepia, medieval = painterly, future = neon grid overlay; (5) Cross-era puzzle tracking: which changes have been made, which effects are visible; (6) Era-appropriate enemy and stamp substitution: dinosaur → knight → robot for the same encounter slot. |
| **JSON Contract Extension** | `{"time_travel": {"eras": ["prehistoric", "medieval", "present", "future"], "causality_rules": [{"cause": {"era": "prehistoric", "action": "plant_tree", "position": {"x": "float", "y": "float"}}, "effect": {"era": "present", "action": "spawn_forest", "position": {"x": "float", "y": "float"}}}], "era_filters": {"prehistoric": "warm_sepia", "medieval": "painterly", "future": "neon_grid"}, "door_transition": "time_vortex"}}` |

---

### Inverted Mirror World

| Field | Details |
|-------|---------|
| **Feature Name** | Inverted Mirror World |
| **Source Game** | Castlevania: Symphony of the Night (Konami, 1997) — Inverted Castle |
| **Description** | After completing a level or world, an "upside-down" mirror version unlocks where gravity is flipped (ceiling becomes floor). The level layout is identical but gravity pulls upward, making every jump, enemy placement, and platform feel completely different. New exclusive items and harder enemy variants appear only in the inverted version. |
| **Kid UX** | The child defeats the final boss. A magical mirror portal appears with a "?" symbol. They enter and — WHOOSH! — the entire world flips upside-down. The ground they walked on is now the ceiling. They fall "up" toward it. "Whoa! Everything is backwards!" The same castle they explored is now a topsy-turvy challenge. A chest that was on the floor is now on the ceiling. The child cackles with delight at the disorienting fun. |
| **LLM Automation** | Backend: (1) Gravity inversion: Y-axis gravity multiplied by -1, all floor collisions become ceiling collisions; (2) Level geometry auto-flip: all stamp Y-coordinates mirrored around level center line; (3) Enemy AI adjustment: patrolling enemies adapt to inverted gravity, projectile trajectories recalculated; (4) Exclusive inverted-item placement: 3-5 bonus items placed in locations only accessible with inverted gravity; (5) Visual flip transition: screen rotates 180 degrees with vortex effect; (6) Completion tracking: separate completion percentage for normal and inverted versions; (7) Both versions contribute to total 100% completion. |
| **JSON Contract Extension** | `{"inverted_world": {"gravity_multiplier": "-1", "auto_flip_geometry": "boolean", "exclusive_items": [{"item_id": "string", "inverted_position": {"x": "float", "y": "float"}}], "transition_animation": "180_rotate_vortex", "completion_separate": "boolean"}}` |

---

### Recall Time Rewind

| Field | Details |
|-------|---------|
| **Feature Name** | Recall Time Rewind |
| **Source Game** | Zelda: Tears of the Kingdom (Nintendo, 2023) — Recall ability |
| **Description** | The player can select a moving object and reverse its trajectory backward along its recent path. A falling boulder can be ridden back upward. A thrown enemy projectile can be sent back at the attacker. The path is visualized as a dotted line, and the object glows purple during rewind. |
| **Kid UX** | A boulder falls from a cliff. The child taps the "Rewind" button, then taps the boulder. It glows purple and a dotted line traces its fall path. The child holds the rewind button and watches the boulder float back UP the cliff, following the exact path it fell. The child rides on top, reaching a secret area at the top! "I rode a rock back in time!" |
| **LLM Automation** | Backend: (1) Position history recording for all movable objects: last 10 seconds at 60fps; (2) Reverse trajectory interpolation: object moves backward along recorded path at player-controlled speed; (3) Collision handling during rewind: player can stand on/ride rewinding objects; (4) Visual trail rendering: dotted line shows full path, purple glow on active target; (5) Rewind duration cap: max 10 seconds to prevent exploits; (6) Valid target filtering: only objects with recorded movement can be rewound (static objects excluded); (7) Audio: reverse-playback sound effect synchronized to rewind speed. |
| **JSON Contract Extension** | `{"recall": {"target_object": "string", "history_duration_seconds": "10", "rewind_speed": "float(0.5-3.0)", "visual_trail": "dotted_line", "glow_color": "#9B30FF", "max_rewind_seconds": "10", "rideable_during_rewind": "boolean"}}` |

---

### Ascend Phase-Through

| Field | Details |
|-------|---------|
| **Feature Name** | Ascend Phase-Through |
| **Source Game** | Zelda: Tears of the Kingdom (Nintendo, 2023) — Ascend ability |
| **Description** | The player can phase upward through any ceiling or solid overhang, emerging on top. This allows vertical traversal through otherwise solid terrain, creating shortcuts and secret discovery opportunities. A green glow and upward arrow indicate valid Ascend surfaces. |
| **Kid UX** | The child is in a cave and sees a treasure chest on a high ledge above, but there's no way up. An upward arrow appears near the ceiling. The child taps "Ascend" — their character glows green and phases straight up through the rock! They emerge on top of the cliff, right next to the treasure. "I walked through the ceiling!" |
| **LLM Automation** | Backend: (1) Ascend validation: raycast upward from player to detect ceiling within range (max 64px); (2) Ceiling thickness check: must be within valid thickness range (not too thick); (3) Smooth vertical interpolation through the surface with green glow trail; (4) Landing position validation: ensure emergence point is safe (no hazards, solid ground); (5) Ascend availability indicator: upward arrow appears when under valid surface; (6) Cooldown: 2-second cooldown between Ascend uses to prevent spam; (7) Visual effect: green phase distortion shader during transit. |
| **JSON Contract Extension** | `{"ascend": {"max_range": "64", "max_thickness": "32", "valid_surfaces": ["ceiling", "overhang", "platform"], "visual_effect": "green_phase", "cooldown_seconds": "2", "indicator_arrow": "boolean"}}` |

---

### Morph Vehicle Building

| Field | Details |
|-------|---------|
| **Feature Name** | Morph Vehicle Building |
| **Source Game** | Zelda: Tears of the Kingdom — Ultrahand ability |
| **Description** | A tool that allows children to grab almost any object in the world, rotate it freely, and attach it to other objects. Build vehicles, bridges, catapults, flying machines — anything that physics allows. Objects are connected with visible green "glue" bonds and behave as a single physics body. |
| **Kid UX** | The child taps "Build Mode." They tap a wooden crate — it highlights in orange. They drag it, then tap a wheel stamp and attach it to the crate's corner. Tap another wheel, attach to the other corner. Now they have a cart! They place their character on it and push — it rolls down a slope! "I made a car!" They add a fan and it becomes a fan-powered hovercraft. The possibilities feel infinite. |
| **LLM Automation** | Backend: (1) Object selection and highlighting system with orange glow; (2) 2D rotation gizmo for free rotation of grabbed objects; (3) Physics joint creation on "glue": weld joint for rigid attachment, revolute joint for wheels, distance joint for springs; (4) Combined rigid body physics: attached objects calculate shared center of mass; (5) Joint stress visualization: bonds glow red when under strain, break if overstressed; (6) Blueprint save: successful vehicles can be saved as stamps and placed instantly elsewhere; (7) Stability validation: warns if vehicle design is physically unstable. |
| **JSON Contract Extension** | `{"vehicle_building": {"selected_object": "string|null", "attached_objects": [{"object_id": "string", "position": {"x": "float", "y": "float"}, "rotation": "float", "joint_type": "weld|revolute|distance|spring"}], "blueprint_save": "boolean", "stress_visualization": "boolean", "stability_validation": "boolean"}}` |

---

### Digging for Buried Treasures

| Field | Details |
|-------|---------|
| **Feature Name** | Digging for Buried Treasures |
| **Source Game** | Okami (Clover Studio, 2006) — digging mechanic |
| **Description** | Special "soft ground" patches scattered throughout levels that the player can dig at to uncover hidden items, currency, or secrets. Dig spots have subtle visual cues (slightly raised dirt mound with tiny sparkles) that observant players notice. Treasure contents are randomized per spot. |
| **Kid UX** | The child spots a slightly raised dirt patch with a tiny sparkle. They stand on it and press the "Dig" action. Their character burrows into the ground with a puff of dirt, then pops back up holding a shiny treasure! "I found a Ruby Gem!" The dirt patch flattens after digging. Some spots respawn after a level restart, others are one-time discoveries. |
| **LLM Automation** | Backend: (1) Dig spot placement validation: only on walkable terrain, not inside walls; (2) Loot table system per spot: common (70%: coins), uncommon (20%: gems), rare (8%: equipment), legendary (2%: special stamp); (3) Dig animation: burrow → underground pause → emerge with item; (4) Visual cue system: subtle sparkle when player is within 100px of undug spot; (5) Respawn logic: some spots respawn on level re-entry, others are permanently consumed; (6) Treasure magnetization: found items gently float toward player; (7) Dig spot density limiter: max 3 per screen to prevent clutter. |
| **JSON Contract Extension** | `{"dig_spots": [{"spot_id": "string", "position": {"x": "float", "y": "float"}, "loot_table": [{"item_id": "string", "weight": "float"}], "visual_cue_radius": "100", "respawn": "boolean", "dug": "boolean"}]}` |

---

### Gummi Block Vehicle Builder

| Field | Details |
|-------|---------|
| **Feature Name** | Gummi Block Vehicle Builder |
| **Source Game** | Kingdom Hearts (Square Enix, 2002) — Gummi Ship builder |
| **Description** | A snap-together vehicle construction system using colorful block pieces on a grid. Different block types provide different functions: cockpit (required), engine (speed), wing (handling), armor (defense), weapon (attack power). The built vehicle flies through a bonus shooting segment between platforming levels. |
| **Kid UX** | Between levels, the child enters the "Vehicle Garage." They see a grid canvas and a palette of colorful blocks — red cockpit, blue engines, yellow wings, green lasers. They stamp blocks onto the grid, snapping together a funny-looking spaceship. A cute robot guide gives a thumbs-up: "Looks ready to fly!" They launch into a 30-second bonus shooting segment, blasting asteroids and collecting stars. The vehicle's stats are determined by its block composition — more engines = faster, more wings = better turning. |
| **LLM Automation** | Backend: (1) Grid-based block placement with snap-to-grid behavior; (2) Vehicle validation: must contain at least 1 cockpit and 1 engine; (3) Stat computation from block composition: speed from engines, handling from wings, defense from armor, offense from weapons; (4) Procedural vehicle sprite generation from block layout; (5) Bonus shooting segment: auto-scroll with enemy wave generation scaled to vehicle stats; (6) Block unlocking: new block types discovered through level progression; (7) Blueprint save/load: favorite designs stored as stamps. |
| **JSON Contract Extension** | `{"gummi_builder": {"block_types": ["cockpit", "engine", "wing", "armor", "weapon_laser", "shield", "special"], "grid_size": ["10", "10"], "validation_rules": ["has_cockpit", "has_engine"], "stat_computation": "block_aggregate", "shooting_segment": {"duration": "30", "difficulty_scale": "vehicle_stats"}}}` |

---

### Phozon Absorption Growth

| Field | Details |
|-------|---------|
| **Feature Name** | Phozon Absorption Growth |
| **Source Game** | Odin Sphere (Vanillaware, 2007) — Phozon absorption system |
| **Description** | Defeated enemies release floating "Power Orbs" that the player absorbs by touching. Collecting enough orbs causes the character to visibly grow larger — a visual size increase with a slight stat boost. Collected orbs can also be spent at "Growth Shrines" to unlock skill tree nodes (more health, stronger attacks, faster movement). |
| **Kid UX** | The child defeats a slime enemy. It pops into 5 pretty floating orbs that home toward the player with a chime. The orbs are absorbed and a small "Growth" meter fills. After absorbing 20 orbs — POOF! — the character grows slightly bigger with a celebratory flash! "I'm bigger!" At a Growth Shrine, the child spends 50 orbs to unlock a glowing node: "+1 Heart!" The character now has more maximum health. Growth feels tangible and exciting. |
| **LLM Automation** | Backend: (1) Orb release on enemy defeat: quantity scales with enemy difficulty; (2) Orb homing physics: gentle acceleration toward player within pickup radius; (3) Growth state tracking: size scaling (1.0x → 1.3x max), stat modifiers per growth tier; (4) Skill tree generation: branching paths for health/attack/speed/special upgrades; (5) Orb spending validation at Growth Shrines; (6) Growth persistence across levels; (7) Visual feedback: character sprite scales smoothly, aura glow intensifies with growth level. |
| **JSON Contract Extension** | `{"phozon_growth": {"orb_source": "enemy_defeat", "orb_behavior": "homing_float", "growth_tiers": [{"orbs_required": "int", "size_multiplier": "float", "stat_bonus": "string"}], "skill_tree_nodes": [{"node_id": "string", "cost_orbs": "int", "effect": "string"}], "shrine_type": "growth_shrine", "persistence": "profile_wide"}}` |

---

### Sphere Grid Skill Board

| Field | Details |
|-------|---------|
| **Feature Name** | Sphere Grid Skill Board |
| **Source Game** | Final Fantasy X (Square, 2001) — Sphere Grid |
| **Description** | After completing each level, the child advances on a colorful grid board. Each node grants a permanent bonus: +1 health, faster speed, new ability unlock, elemental resistance. The child chooses which direction to move, creating a personalized progression path. Multiple characters can share the same board. |
| **Kid UX** | After finishing a level, a big colorful grid appears with the child's character token on their current node. Glowing adjacent nodes show available moves. The child taps a heart-shaped node — their token moves there with a sparkle trail, and they gain +1 max health forever! They can see their whole progression history as a glowing path across the board. "I have 10 hearts now!" |
| **LLM Automation** | Backend: (1) Auto-generated branching board layout with meaningful path choices; (2) Node state tracking per player profile: activated/deactivated; (3) Permanent stat application from activated nodes; (4) Board section unlocking: new sections become available as more levels are completed; (5) Visual path highlighting: shows child's journey across the board; (6) Shared board support: multiple characters on same board create visible competition/collaboration; (7) LLM-generated node descriptions appropriate to child's reading level. |
| **JSON Contract Extension** | `{"sphere_grid": {"board_layout": "auto_generated_branches", "node_types": ["health_up", "speed_up", "ability_unlock", "element_resist", "special"], "moves_per_level": "1", "board_sections_unlock": "level_progress", "shared_board": "boolean", "visual_path_highlight": "glow"}}` |

---

## 11.3 Community & Persistent Systems

### Message Board Signs

| Field | Details |
|-------|---------|
| **Feature Name** | Message Board Signs |
| **Source Game** | Dark Souls (FromSoftware) — soapstone messages |
| **Description** | A community hint system where players leave templated messages on wooden signposts throughout levels. Messages use a safe word-bank system (no free typing) to ensure kid-friendly content. Highly-rated messages appear more frequently. This creates a sense of shared discovery and community wisdom. |
| **Kid UX** | The child is stuck on a tricky jump. They spot a small wooden signpost ahead. Walking up to it reveals: "Try jumping here! — left by SparkleKid7" with 42 thumbs-up. The child tries jumping at that spot and discovers a secret platform! Grateful, they place their own sign after a boss fight: "Use fire attack! — left by Jordan" to help future players. |
| **LLM Automation** | Backend: (1) Template + word-bank system: 100+ safe message templates with fillable slots; (2) Message placement validation: only on signpost stamps, max 1 message per signpost; (3) Rating system: thumbs-up only, no downvotes; (4) Message visibility: highest-rated messages shown by default, new messages mixed in for discovery; (5) Author attribution with kid-safe username; (6) Content filter: AI scan of all word combinations before publication; (7) Context-aware suggestions: "This area has a secret — suggest 'Try looking up!' template." |
| **JSON Contract Extension** | `{"message_boards": {"signposts": [{"signpost_id": "string", "position": {"x": "float", "y": "float"}, "messages": [{"template_id": "string", "filled_words": ["string"], "author": "string", "thumbs_up": "int"}]}], "word_bank": ["string"], "max_messages_per_signpost": "1"}}` |

---

## Feature Summary: Special Systems & Minigames Overview

| Category | Feature | Source Game | Player Count | Session Length |
|----------|---------|-------------|--------------|----------------|
| Competitive | Turf War Paint Mode | Splatoon | 2-4 | 3 min |
| Competitive | Tableturf Card Game | Splatoon 3 | 2 | 5 min |
| Cooperative | Salmon Run Horde | Splatoon 2/3 | 1-4 | 5 min |
| Solo Challenge | Blue Sphere Bonus | Sonic 3&K | 1 | 1-2 min |
| Solo Challenge | Score Attack Time Trial | Sonic / NiGHTS | 1 | 1-3 min |
| Competitive | Card Battle Collectible | FF8 Triple Triad | 2 | 3 min |
| Collection | Fishing Minigame | Stardew / MH | 1 | Variable |
| Crafting | Cooking Minigame | Monster Hunter | 1 | 1 min |
| Spectacle | Attraction Flow Rides | KH3 | 1 | 1-2 min |
| Challenge | Boss Rush Tower | Mega Man / HK | 1 | 5-10 min |
| Special Mechanic | Ink Painting Terrain | Splatoon | Any | Ongoing |
| Special Mechanic | Celestial Brush Drawing | Okami | 1 | Ongoing |
| Special Mechanic | Time Travel Era Doors | Chrono Trigger | 1 | Ongoing |
| Special Mechanic | Inverted Mirror World | Castlevania SotN | 1 | Ongoing |
| Special Mechanic | Recall Time Rewind | Zelda TotK | 1 | Ongoing |
| Special Mechanic | Ascend Phase-Through | Zelda TotK | 1 | Ongoing |
| Special Mechanic | Morph Vehicle Building | Zelda TotK | 1 | Ongoing |
| Collection | Digging for Treasures | Okami | 1 | Variable |
| Vehicle Builder | Gummi Block Builder | Kingdom Hearts | 1 | 2-3 min |
| Progression | Phozon Absorption Growth | Odin Sphere | 1 | Ongoing |
| Progression | Sphere Grid Skill Board | FFX | 1 | Ongoing |
| Community | Message Board Signs | Dark Souls | Any | Ongoing |

