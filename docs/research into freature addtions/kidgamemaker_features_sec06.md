# 6. Items, Crafting & Economy

Every adventure needs treasures to find, materials to gather, recipes to discover, and rewards to spend. This chapter covers the complete item ecosystem of KidGameMaker — from the coins that spill from defeated enemies to the complex crafting systems that turn raw materials into powerful gear. Drawing from the loot-driven satisfaction of Monster Hunter, the methodical inventory management of Resident Evil, the Praise-gathering restoration of Okami, and the discovery-driven cooking of Zelda, these systems transform collection into a core pillar of the play experience. Every feature is designed so that a 5-year-old can engage through stamps, taps, and drag gestures while the LLM handles all numeric balancing, recipe validation, and inventory state management invisibly.

---

## 6.1 Currency & Collection Systems

Currency is the language of reward. These features establish multiple collectible resource types that motivate exploration, mark progression, and feed into crafting and shop economies.

### Multi-Type Currency System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Mario (Coins), Sonic (Rings), Zelda (Rupees), Dark Souls (Souls) |
| **Description** | A flexible currency system supporting multiple coin types with different visual identities and value tiers. Copper coins are common (1 unit), silver coins are uncommon (5 units), gold coins are rare (10 units), and special star pieces or gems function as premium collectibles. Currency is dropped by enemies, found in breakable objects, hidden in secret areas, and awarded for quest completion. |
| **Kid UX** | The child stamps **Coin** and **Gem** items throughout their level. A tap on a coin stamp cycles through visual variants: copper penny, silver coin, gold coin, red ruby, blue sapphire, green emerald, purple amethyst. Each has a distinctive sparkle effect. During play, coins bounce when dropped and home toward the player when approached. The HUD shows a large coin icon with the total count in big, friendly numbers. Currency is collected automatically on proximity — no need to press a button. |
| **LLM Automation** | Manages currency inventory per player with support for multiple currency types, handles drop physics (bounce on spawn, magnetic homing when player is near), calculates currency values from defeated enemies and destroyed objects, manages HUD display with large readable numbers, and auto-balances currency distribution throughout the level so the player always feels rewarded but never overwhelmed. |
| **JSON Contract Extension** | `currency: { types: { copper: 1, silver: 5, gold: 10, ruby: 50, sapphire: 50, emerald: 50 }, currentTotals{}, dropSources[], magneticRadius }` |

### Currency Loss on Death (Recovery Run)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dark Souls (Bloodstains), Hollow Knight (Shade), Shovel Knight |
| **Description** | When the player is defeated, all collected currency is dropped at the death location as a glowing orb. The player respawns at the last checkpoint and must return to the death location to reclaim their lost wealth. Dying again before reclaiming the first orb permanently loses the first drop. This creates palpable tension and a "one more try" motivation loop. |
| **Kid UX** | When the hero falls, a large **"Ghost Me"** (a cute translucent ghost version of the hero) appears at the death spot, holding all the lost coins. The hero respawns at the last campfire. The ghost waves cheerfully and hops to guide the player back. A pulsing arrow at the screen edge points toward the ghost's location. Touching the ghost causes it to merge back into the hero with a happy sparkle and coin-restored chime. If the hero falls before reaching the ghost, the ghost disappears with a sad but gentle poof — no harsh penalty message, just an opportunity to find more coins. |
| **LLM Automation** | Tracks per-session currency total, spawns the ghost entity at death coordinates carrying the dropped amount, handles collision detection for reclamation, manages the "one chance" rule (first ghost disappears if the player dies again), ensures the ghost never spawns in an impossible-to-reach location, auto-adjusts drop amounts based on level design, and fades out permanently lost currency with a gentle effect rather than a punishing message. |
| **JSON Contract Extension** | `deathRecovery: { ghostEntity, carriesCurrency, currencyAmount, position, state, retrievalTrigger, directionIndicator }` |

### Link Chain Score Multiplier

| Attribute | Detail |
|-----------|--------|
| **Source Game** | NiGHTS into Dreams |
| **Description** | When the player collects items (coins, rings, gems) in rapid succession, a "Link Chain" counter builds up. The higher the chain, the bigger the score multiplier that applies to all subsequent collections. A glowing trail connects recently collected items. If too much time passes between collections, the chain breaks and the accumulated bonus points are cashed out in a celebratory burst. This creates rhythmic, risk-reward tension around collection patterns. |
| **Kid UX** | The child enables **Link Chains** with a single toggle in level settings. During play, collected items connect with a sparkly trail that grows brighter as the chain increases. A big number shows the current chain count: "Chain: 5!" When the chain breaks, a celebratory **"BONUS!"** popup displays the multiplied score with confetti. The child can stamp **"Chain Item"** clusters in curved paths to create natural chain routes through their level, encouraging the player to collect quickly. |
| **LLM Automation** | Implements the chain timer (decays over ~2 seconds without a new collection), tracks the chain counter, computes the multiplier formula (1.5x at 5 chain, 2x at 10, 3x at 20, 5x at 50), draws the visual connecting trail between collected items, handles the chain break event with bonus calculation and popup celebration, and auto-suggests optimal item cluster placements for chain routes during level design. |
| **JSON Contract Extension** | `linkChain: { enabled, chainDecaySeconds, multiplierTiers[], visualTrail, breakFx }` |

### Praise / Power-Up Orb Collection

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Okami |
| **Description** | Restoring nature and helping the world earns Praise — golden orbs that magnetize toward the player with a satisfying chime. Blooming wilted flowers, feeding animals, reviving dead trees, and clearing cursed zones all generate Praise. Collecting enough Praise allows the player to upgrade their attributes: more health, more ink for brush techniques, larger inventory, or stronger attacks. |
| **Kid UX** | The child stamps **"Wilted Flower"** clusters, **"Hungry Animal"** sprites, and **"Dead Tree"** objects throughout their level. When the player uses the Bloom brush technique on a wilted flower, it bursts open and golden Praise orbs float out, magnetizing toward the player with a bright chime. Feeding an animal generates a heart burst and Praise orbs. Collecting enough orbs triggers a **"LEVEL UP!"** banner. A simple upgrade screen shows four big icons: Heart (more health), Ink Bottle (more brush uses), Bag (more inventory), Star (stronger attack). The child (as player) taps one to upgrade. |
| **LLM Automation** | Tracks Praise total across the save file, manages upgrade thresholds (each upgrade costs progressively more), applies attribute increases on upgrade selection, spawns Praise orbs from restoration events (bloom, feed, revive), handles orb magnetization physics, generates the upgrade UI with clear iconography, and ensures Praise income scales appropriately with level design. |
| **JSON Contract Extension** | `praiseSystem: { currentPraise, upgradeCosts{ health, ink, purse, attack }, praiseSources{ bloomFlower, feedAnimal, reviveTree } }` |

### Seven Emeralds / Star Piece Transformation

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Sonic the Hedgehog 3 & Knuckles |
| **Description** | Seven special gems are hidden throughout the level. Collecting all seven transforms the player character into a glowing, invincible super form with enhanced speed, a sparkly aura trail, and the ability to destroy any enemy on contact. The super form lasts for a timed duration with a visible energy meter that drains gradually. Hidden emerald locations can be placed via stamp anywhere in the level. |
| **Kid UX** | The child stamps the **7 Emerald** stamps in hidden locations (inside question blocks, behind secret walls, at the end of difficult platforming challenges). During play, collecting an emerald plays a distinctive chime and the emerald takes its place in a HUD circle — an empty slot fills with color. Collecting all seven triggers a spectacular transformation sequence: the character glows golden, a sparkly aura trail follows every movement, the music shifts to an epic theme, and enemies are destroyed simply by touching them. A rainbow energy meter drains slowly; when empty, the character returns to normal with a gentle fade. |
| **LLM Automation** | Tracks emerald collection state across all seven positions, triggers the transformation sequence when the seventh is collected (invincibility, aura particles, speed boost, music change), implements the countdown timer with visual energy meter, handles super-jump and enemy-destruction-on-contact logic, restores normal form when time expires, and ensures emeralds are placed in locations that are challenging but reachable. |
| **JSON Contract Extension** | `collectibles: { emeraldSet: { count: 7, transformTo, duration, effects, drainRate } }` |

---

## 6.2 Crafting & Recipe Discovery

Discovery is the soul of crafting. These features let children combine materials into new items, with the joy of experimentation rewarded by surprising outcomes.

### Crafting Recipe Discovery

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dragon Quest Builders 1 & 2 / Monster Hunter |
| **Description** | The player collects raw material items throughout levels (wood, stone, mushroom, crystal, iron, herb). At **Crafting Stations**, they can combine two or three materials to create new items. The first time a valid combination is tried, the recipe is "discovered" and permanently added to their **Recipe Book**. Discovery is half the fun — experimenting with combinations yields surprises. Invalid combinations produce a playful "Poof!" dust cloud with no penalty. |
| **Kid UX** | The child stamps **Material Nodes** throughout their level: tree stamps yield wood, rock stamps yield stone, glowing crystal stamps yield crystal shards, mushroom stamps yield mushrooms. They also stamp **Crafting Station** objects (workbenches, anvils, cauldrons). During play, materials are collected automatically on touch. At a crafting station, the player sees their collected materials as large, draggable stickers. They drag 2-3 materials into the crafting slots. Valid combinations produce a new item with a fanfare sparkle. Invalid combinations show a cute "Poof!" puff of dust and a gentle giggle sound. No materials are lost on failure. The **Recipe Book** auto-populates with discovered combinations shown as ingredient pictures + arrow + result picture. |
| **LLM Automation** | Manages the recipe database (hundreds of valid combinations), validates player crafting attempts against known recipes, generates discovered items with appropriate properties, unlocks recipes in the Recipe Book UI with ingredient pictograms, implements the "Poof!" failure feedback with no material loss, auto-suggests hint recipes based on materials available in the current level, and scales crafted item power relative to level difficulty. |
| **JSON Contract Extension** | `craftingSystem: { materials[], stationType, discoveryMode, recipeBook, invalidFeedback, maxIngredients, hintSystem }` |

### Crafting Recipe Examples

The following table illustrates sample recipes that children discover through experimentation:

| Ingredient A | + | Ingredient B | (+ | Ingredient C) | = | Result | Effect |
|-------------|---|-------------|---|-----------------|---|--------|--------|
| Wood | + | Wood | | | = | Wooden Plank | Building material |
| Wood | + | Stone | | | = | Stone Axe | Weapon (+2 damage) |
| Stone | + | Crystal | | | = | Magic Gem | Socket gem (elemental power) |
| Mushroom | + | Herb | | | = | Healing Potion | Restores 3 hearts |
| Herb | + | Herb | + | Flower | = | Super Potion | Restores all hearts |
| Iron | + | Wood | | | = | Iron Sword | Weapon (+5 damage) |
| Iron | + | Crystal | + | Magic Gem | = | Enchanted Sword | Weapon (+8 damage, elemental) |
| Feather | + | Wood | | | = | Arrow | Ammunition for bow |
| String | + | Stick | | | = | Fishing Rod | Enables fishing minigame |

### Monster Part Breaking & Collection

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Monster Hunter series |
| **Description** | Large enemies and bosses have breakable body parts — head, wings, tail, claws. Dealing enough concentrated damage to a specific part causes it to break, changing the monster's behavior and adding extra reward materials to the collection pool. Severed tails become interactable objects on the ground that can be carved for unique materials. |
| **Kid UX** | The child stamps a **Big Monster** on the canvas. Tapping the monster shows dotted outlines around breakable parts: head, wings, tail, each with a small colored HP bar. During play, hitting a specific part depletes its individual HP bar. When a part's bar empties, a dramatic break animation plays — the tail falls off with a satisfying crack, horn chips fly, wing membrane tears. Broken parts change the monster's attack patterns (no tail = no tail whip attack). The severed tail lies on the ground as a glowing, carveable object that yields unique "Tail Material" for crafting. |
| **LLM Automation** | Tracks per-part damage thresholds independently from overall monster HP, triggers break animations and visual effects at thresholds, modifies monster moveset when parts break (e.g., broken tail disables tail swipe attack), spawns severed parts as carveable objects on the ground, adds part-break materials to the reward pool, and generates appropriate hit effects when specific parts are targeted. |
| **JSON Contract Extension** | `monsterParts: [{ id, breakThreshold, severable, behaviorChange }], partBreakRewards: { tail: [materials], head: [materials], wings: [materials] }` |

### Synthesis Workshop (Advanced Crafting)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Kingdom Hearts series |
| **Description** | A dedicated crafting station for combining collected materials into powerful equipment and special items. The synthesis list shows possible combinations with question marks for undiscovered recipes. Successfully synthesizing an item plays a brief "crafting" animation with hammer strikes and sparkles. Synthesized items grant permanent upgrades — better swords, faster boots, bigger health bars. |
| **Kid UX** | The child stamps a **Workshop** station (anvil with tools and a glowing book). During play, the player opens the workshop to see a **Recipe Book** with known recipes and **"???"** slots for unknown ones. Tapping a recipe shows required materials as picture icons. If materials are available, a **"Make It!"** button glows green. Tapping it plays a fun hammering animation (2-3 strikes with sparkles) and the new item pops out. The child can stamp **Material Chests** throughout their level containing metal scraps, glowing dust, monster drops, and rare gems. |
| **LLM Automation** | Manages the recipe database (known and unknown), validates material availability for selected recipes, generates the crafting animation sequence, applies equipment upgrades to the player character (stat changes, visual changes to character sprite), tracks discovered vs. undiscovered recipes, suggests recipes based on current materials, and scales recipe outcomes to level progression. |
| **JSON Contract Extension** | `synthesisWorkshop: { materials[], recipeBook, craftingAnimation, upgrades[], discoveryMode, suggestionSystem }` |

### NPC Town Builder Requests

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dragon Quest Builders 1 & 2 |
| **Description** | Friendly NPCs placed in the level display "Wish Bubbles" showing what they want the player to build. A knight wants an "Armory Room" (chest + weapons), a chef wants a "Kitchen" (pot + table), a farmer wants a "Farm" (dirt + seeds). Completing their request makes them happy, causes them to move into the room, and grants a unique reward. |
| **Kid UX** | The child stamps **NPC** characters and taps each to pick a type: knight, chef, farmer, shopkeeper. Each NPC shows a thought bubble with a simple picture of what they want (a sword icon for the knight, a pot icon for the chef). The child builds rooms using the Smart Room Recognition system. When the room matches the NPC's wish, the bubble turns into floating hearts, the NPC walks to their new room, and a **gift box** appears as a reward. The NPC then performs appropriate idle animations in their room (the chef stirs a pot, the knight polishes a sword). |
| **LLM Automation** | Matches built rooms to NPC wishes by validating room type against request requirements, triggers the wish-completion event (heart particles, NPC pathing to room, gift spawn), generates appropriate rewards per NPC type (knight = weapon upgrade, chef = cooking recipe, farmer = crop seeds), manages NPC daily routines (sleep at night, work in their room during day), and creates new requests as previous ones are fulfilled to create a progression chain. |
| **JSON Contract Extension** | `npcRequests: { npcTypes[], wishFormat, roomMatch, rewards{}, requestChain }` |

---

## 6.3 Cooking & Food Systems

Food is joy. These features transform ingredient gathering into a delightful culinary minigame where timing, combination, and creativity produce dishes with magical effects.

### Cooking Pot / BBQ Mini-Game

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Monster Hunter series / Dragon Quest Builders |
| **Description** | A timing-based cooking minigame where the player cooks raw ingredients on a spit or in a pot. Timing determines quality: undercooked gives less effect, perfectly cooked gives maximum benefit, and burnt gives nothing. The classic "So Tasty!" celebration plays on a perfect cook. Different food types (meat, fish, vegetables) produce different stat-boosting dishes. |
| **Kid UX** | The child stamps a **BBQ Spit** or **Cooking Pot** in their level. The player drags up to 3 food ingredients (meat, fish, mushrooms, herbs, berries) into the cooking slots. A cooking mini-game starts: meat rotates on a spit while a color meter fills from blue (raw) through yellow (perfect) to red (burnt). The player taps when the color is in the golden zone. **"So Tasty!"** confetti bursts on perfect timing. Different food combinations produce different dishes shown as cute food art: Meat + Herb = "Healing Steak" (restores HP), Fish + Mushroom = "Smart Soup" (boosts magic), Berry + Berry = "Sweet Tart" (boosts speed). |
| **LLM Automation** | Manages the timing window calculation (perfect zone occupies the middle 30% of the cook duration, good zone the middle 60%, raw and burnt occupy the outer 20% each), plays appropriate result animations, applies the corresponding buff to the player based on food type and cook quality, manages ingredient consumption, tracks discovered food recipes, and generates the "So Tasty!" confetti burst on perfect cooks. |
| **JSON Contract Extension** | `cooking: { timingZones{ undercooked, perfect, burnt }, recipes[], animationTriggers, buffEffects }` |

### Portable Cooking (Ingredient Mixing)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda: Tears of the Kingdom |
| **Description** | A placeable cooking device where the player combines ingredients to create dishes with various buff effects — health restoration, temporary attack boost, speed increase, cold resistance, or stealth enhancement. The output dish is determined by ingredient attributes, not rigid recipes, enabling creative experimentation. |
| **Kid UX** | The child stamps a **Cooking Pot** object. During play, the player approaches it and a "Cook!" button appears. Up to 5 ingredients are selected from the ingredient palette by tapping. A brief stirring animation plays (2 seconds) with rising steam particles colored by the ingredients. Then a dish pops out as a floating item with sparkles. A **Food Journal** auto-records every dish created with its ingredient list and effect, shown as cute food illustrations. The child can stamp **Ingredient Plants** and **Meat Sources** throughout the level. |
| **LLM Automation** | Implements the ingredient attribute database (each ingredient has health, stamina, attack, defense, speed, stealth, and resistance values), calculates output dish properties from the sum and interaction of ingredient attributes, manages the cooking animation state, handles ingredient consumption, auto-balances healing values against level damage patterns, and populates the Food Journal with discovered dishes. |
| **JSON Contract Extension** | `cooking: { potPosition, recipes{ ingredients[], output, hearts, buffType, buffDuration }, foodJournal[] }` |

### Cooking Dish Effect Types

| Dish Effect | Visual Icon | Ingredient Source | Duration |
|-------------|-------------|-------------------|----------|
| Heal Hearts | Red heart | Meats, mushrooms, herbs | Instant |
| Attack Boost | Orange sword | Spicy peppers, meat | 30 seconds |
| Defense Boost | Blue shield | Tough vegetables, shellfish | 30 seconds |
| Speed Boost | Green boot | Swift herbs, caffeine plants | 20 seconds |
| Cold Resistance | White snowflake | Warm spices, fatty meats | 60 seconds |
| Stealth Boost | Purple eye | Silent herbs, ghost mushrooms | 30 seconds |

---

## 6.4 Consumables & Healing

Health management creates meaningful decisions. These features provide various healing and restoration mechanics that balance scarcity, convenience, and strategic depth for young players.

### Flask Healing System (Limited Restores)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dark Souls (Estus Flask) / Elden Ring (Flask of Crimson Tears) |
| **Description** | A healing item with a fixed number of uses per rest. Drinking the flask restores a portion of HP but consumes one charge. Charges are only replenished by resting at a checkpoint. This creates gentle strategic tension around when to heal without being punishing for children. |
| **Kid UX** | The child stamps a **Potion Bottle** on the hero or enables it globally. A simple number picker sets charges from 1-5 (default 3). During play, a **"Drink"** button appears in the corner with a bottle icon and charge count (e.g., "3/3"). Single-tap to drink. A glug-glug drinking animation plays with rising green sparkle numbers showing HP restored. The bottle icon shows a red X when empty. Charges refill automatically when touching a checkpoint. The child can stamp **Potion Refill** pickups that add one charge when collected. |
| **LLM Automation** | Tracks charges per rest cycle, handles heal amount calculation (auto-balanced to restore approximately 50% of max HP per use), prevents overhealing beyond max HP, plays drink animation and heal VFX with floating +HP numbers, replenishes charges on checkpoint touch, auto-balances heal amount based on total player HP and level difficulty, and manages the empty/full visual state of the flask UI. |
| **JSON Contract Extension** | `healingFlask: { maxCharges, currentCharges, healAmount, healType, replenishOn, useAnimation, cooldown }` |

### Custom Mix Buff Flask

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Elden Ring (Flask of Wondrous Physick) |
| **Description** | A special flask where the player combines two found "crystal tear" items before resting. Each tear provides a distinct timed buff — increased damage, faster movement, HP regeneration, damage negation, etc. Mixing two different tears creates a hybrid buff cocktail. The effect lasts for a fixed duration after consumption. |
| **Kid UX** | The child stamps a **Mixing Bottle** and **Crystal Tear** pickups throughout their level. Crystal tears are color-coded: red tear = power up, blue tear = speed up, green tear = heal over time, yellow tear = shield. At the mixing bottle, the player drags two tears into the slots. The mixed bottle glows with both colors. During play, tapping the bottle drinks the mix — the hero glows with swirling dual colors. A shrinking colored ring around the player shows remaining buff time. When the ring disappears, the buff fades with a gentle chime. |
| **LLM Automation** | Manages discovered tear inventory, calculates combined buff effects based on tear compatibility (additive for same-type, multiplicative for different-type), applies timed status effects on consumption, stacks visual aura per buff type, auto-balances buff magnitudes for kid-friendly gameplay, and displays remaining buff time as a shrinking colored ring around the player sprite. |
| **JSON Contract Extension** | `customMixFlask: { slotCount: 2, currentMix[{ tearId, effect, duration }], duration, cooldown, visualAura, timeRemainingRing }` |

### Herb Combining System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil series |
| **Description** | Three herb colors create different healing effects through simple combination: Green Herb heals, Green + Green = full heal, Green + Red = full heal + max HP boost, Green + Blue = heal + poison cure, and the legendary Green + Red + Blue = full heal + max boost + poison cure + damage reduction. The color-coded system is intuitive and the combinations feel like magical alchemy. |
| **Kid UX** | The child stamps **Herb** items: green leaf, red flower, blue berry. In the inventory screen, dragging one herb onto another triggers a combination animation — colored sparkles mix together and a new item appears with a distinct icon. G+G = "Big Green Herb" (big heal). G+R = "Rainbow Herb" (super heal + max HP boost). G+B = "Cleanse Herb" (heal + cure poison). G+R+B = "Ultimate Herb" (all effects + temporary defense boost). The result icons use clear color combinations so the child can deduce recipes through experimentation. |
| **LLM Automation** | Maintains the herb combination recipe table, validates drag-to-combine interactions, plays the combination sparkle animation, applies correct healing values and status effects when the combined herb is used, updates inventory (removes ingredients, adds result), and tracks discovered herb combinations in the Recipe Book. |
| **JSON Contract Extension** | `herbRecipes: [{ ingredients[], result, heal, cures[], maxHpBoost, defenseUp }]` |

### Rally Health Regain (Aggressive Healing)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Bloodborne |
| **Description** | When the player takes damage, a portion of lost HP becomes "faded" (shown in orange on the health bar) instead of being permanently lost. Dealing damage to enemies within a short window recovers the faded HP. This encourages aggressive play — taking a hit then fighting back to heal. |
| **Kid UX** | When the hero is hit, lost HP shows as **orange chunks** on the health bar instead of disappearing entirely. A small clock icon appears next to the bar. Hitting enemies fills the orange chunks back to red with each successful attack. The orange chunks gradually fade to black if the player doesn't attack within ~4 seconds. No stamps needed — it's an automatic game mechanic that rewards brave play. The child can stamp a **"Rally Badge"** to enable or disable the system per level. |
| **LLM Automation** | Splits damage into "permanent loss" and "faded/rallyable" portions (50/50 split for kid-friendliness), displays faded HP in distinct orange color, starts the rally timer on damage taken, calculates HP recovery per damage dealt to enemies (e.g., 30% of damage dealt = HP recovered), gradually fades rallyable HP to permanent loss if the timer expires, and shows rally recovery amount as floating green text on each successful hit. |
| **JSON Contract Extension** | `rallySystem: { enabled, rallyPercent, rallyWindowSeconds, fadeColor, permanentColor, timerVisual }` |

---

## 6.5 Equipment & Upgrades

Progression feels tangible when it changes how the player looks and fights. These features create visible, meaningful equipment systems that reward effort with power.

### Equipment Slot System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania: Symphony of the Night |
| **Description** | A five-slot equipment system: Right Hand (weapon), Left Hand (shield or second weapon), Head (helmet/hat), Body (armor), and Accessory (ring, amulet, scarf). Each slot accepts one item. Equipment changes the character's visible appearance and modifies core stats (strength, defense, magic, luck). Set bonuses reward matching equipment pieces. |
| **Kid UX** | The child stamps **equipment items** throughout their level: sword stamps, shield stamps, helmet stamps, armor stamps, accessory stamps. When the player opens the equipment screen, they see a cute **body outline** with five glowing drop zones. Dragging a "Sword" stamp onto the right hand slot equips it — the character sprite updates instantly to show the sword. Dragging a "Knight Helmet" onto the head slot changes the character's head appearance. Matching sets (e.g., all Knight equipment) produce a golden glow and bonus stat popup. |
| **LLM Automation** | Computes aggregate stats from all equipped items, handles equipment-exclusive interactions (certain shields boost certain swords), manages resistance calculations (fire armor reduces fire damage), auto-generates stat tooltips as simple icon+number displays, tracks set bonus eligibility, and updates the player sprite composite to reflect all equipped gear visually. |
| **JSON Contract Extension** | `equipmentSlots: { rightHand, leftHand, head, body, accessory }, equippedItems[], setBonuses[], statAggregates }` |

### Weapon Upgrade Tiers

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dark Souls / Hollow Knight |
| **Description** | Weapons improve through discrete tiers using collected materials. Each tier increases damage by a meaningful amount and changes the weapon's visual appearance (wooden -> iron -> steel -> gold -> crystal). Higher tiers require rarer materials found in harder areas. The upgrade path creates long-term progression goals. |
| **Kid UX** | The child stamps an **Upgrade Anvil** (cartoon anvil with sparkles). Tapping it opens a tier picker showing 1-5 stars. The LLM auto-generates visual upgrade progression — a wooden sword at 1 star gains iron bands at 2 stars, becomes steel at 3 stars, gold at 4 stars, and crystal at 5 stars. The child stamps **Material Tokens** (colored gems) on the canvas as collectible pickups. In play, touching the anvil with enough tokens upgrades the hero's weapon with a spectacular power-up animation (sparkles, power chord sound, sprite flash). |
| **LLM Automation** | Manages material inventory, calculates upgrade eligibility (tokens needed per tier), applies stat increases per tier, changes weapon sprite and visual effects on upgrade, plays satisfying upgrade animation, auto-balances material spawn rates per area difficulty, persists upgrades across sessions, and generates appropriate tier names (Rusty, Iron, Steel, Golden, Legendary). |
| **JSON Contract Extension** | `upgradeSystem: { type: weapon, tiers[{ tier, damage, materialsNeeded, visual }], currentTier, materialsInventory }` |

### Armor Capsules (Hidden Upgrades)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Mega Man X series |
| **Description** | Hidden capsules scattered throughout levels that permanently upgrade the player's abilities. Foot Parts enable dashing, Body Parts reduce damage taken, Head Parts allow breaking ceiling blocks and improve energy efficiency, and Arm Parts upgrade the charge shot. Each capsule is hidden behind a breakable wall or at the end of an optional challenge path. |
| **Kid UX** | The child stamps **"Dr. Light Capsules"** (glowing tubes with a hologram figure inside) hidden in their level — behind destructible walls, at the top of difficult platforming sections, or underwater. When the player finds and enters a capsule, a celebratory cutscene plays: a body part glows with an upgrade icon (lightning bolt for dash, shield for armor, star for helmet, fist for arm cannon). The player sprite updates to show the new armor piece visually. Each capsule grants a permanent ability that changes how the player traverses the level. |
| **LLM Automation** | Tracks which capsules have been collected per save file, applies permanent ability flags on collection (canDash, damageReductionPercent, canBreakCeilings, canChargeSpecial), updates the player sprite to show progressive armor visual upgrades, ensures capsules require prerequisite exploration abilities (e.g., dash capsule is placed behind a wall that requires dash to reach, creating a chain), and plays the capsule discovery cutscene sequence. |
| **JSON Contract Extension** | `armorCapsules: [{ id, ability, prereq, visual, collected }], abilityFlags: { canDash, canAirDash, canChargeSpecial, damageReduction }` |

### Weapon Skill Swapping (Materia-Style)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Elden Ring (Ashes of War) / Final Fantasy VII (Materia) |
| **Description** | Special combat abilities can be attached to and detached from weapons freely. A "Skill Gem" might add a spinning slash, a charge thrust, a parry, or a magic projectile. The player can experiment with different skill-weapon combinations to find synergies. Skills have cooldowns and visual effects. |
| **Kid UX** | The child stamps **"Skill Gem"** stamps (star-shaped icons in different colors: red for attack skills, blue for defense, green for magic). Dragging a gem onto a weapon "socket" attaches it — the gem glows and the weapon sprite updates to show the new capability. Tapping the skill button in play triggers the move with a cool flash animation. The child can drag different gems onto the same weapon to swap. A "Skill Wheel" UI shows up to 4 equipped skills as large, colorful buttons with icon previews of what they do. |
| **LLM Automation** | Validates gem-weapon compatibility, applies skill parameters to the weapon entity, generates appropriate animation and VFX for each skill combination, manages skill cooldowns, saves current skill loadout, generates skill preview animations when socketed, prevents incompatible combinations gracefully, and auto-balances skill power relative to weapon tier. |
| **JSON Contract Extension** | `weaponSkills: { weaponId, equippedSkill{ skillId, animation, vfx, cooldown, damageMultiplier, hitboxShape }, compatibleSkills[] }` |

### Fragment-Based Permanent Upgrades

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Hollow Knight (Mask Shards / Vessel Fragments) |
| **Description** | Fragment items hidden throughout the world that permanently upgrade stats when enough are collected. Four Heart Pieces combine into one extra max HP. Three Magic Drops combine into one extra magic vessel. Fragments encourage thorough exploration — finding the final piece to complete a set is deeply satisfying. |
| **Kid UX** | The child stamps **"Heart Piece"** stamps (each showing 1/4 of a heart shape) hidden throughout the level — behind difficult jumps, inside secret rooms, at the end of combat challenges. When the hero collects 4 pieces, the LLM auto-combines them into a full heart with a spectacular "DING!" animation and confetti. The HUD shows collected fragments as a pie chart filling up. Heart Pieces increase max HP. Star Pieces increase max magic. Shield Pieces increase defense. The child can see at a glance how close they are to the next upgrade. |
| **LLM Automation** | Tracks fragment collection count per type, detects when the threshold is reached (e.g., 4/4 heart pieces), triggers the combination animation and upgrade, updates max HP/magic/defense, resets the fragment counter with visual carryover, distributes fragment placements to reward exploration, and optionally shows a fragment radar pulse when a specific "Compass Badge" is equipped. |
| **JSON Contract Extension** | `fragmentUpgrades: [{ type, fragmentName, fragmentsNeeded, fragmentsCollected, upgradeAmount, visual, combineAnimation }]` |

---

## 6.6 Inventory Management

What you can carry shapes how you play. These features create satisfying constraints around inventory that make every item choice meaningful.

### Grid Inventory (Tetris-Style)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil series |
| **Description** | Items take up specific shapes on a limited-size grid. The player must rotate and arrange items to fit everything they want to carry. Key items, weapons, ammo, healing herbs, and food all occupy different grid shapes. An "Auto-Arrange" button helps organize, but manual optimization is part of the fun. |
| **Kid UX** | The child stamps an **Inventory Box** or enables the grid on the hero. A grid pops up (6x4 squares). Each collected item becomes a colorful block of specific shape: potion = 1x1 square, sword = 1x2 rectangle, shotgun = L-shaped (2x2 missing one corner), armor = 2x2 square, key = 1x1. Items are dragged to position and double-tapped to rotate 90 degrees. Items that don't fit must be stored in an **Item Box** (accessible from safe rooms). An **"Auto-Sort"** button (robot icon) helps younger children organize. The grid uses bright colors and clear item art so shapes are visually distinct. |
| **LLM Automation** | Validates item placement (no overlaps, within grid bounds), handles rotation of item shapes, enforces capacity limits, manages the auto-arrange algorithm using a simple bin-packing heuristic, tracks which items are in inventory vs. equipped vs. stored, and generates appropriate grid shapes for all item types. |
| **JSON Contract Extension** | `inventoryGrid: { width, height, itemShapes[{ id, shape[][], rotatable }], currentLayout[], itemBox[] }` |

### Item Box (Shared Storage)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil / Castlevania |
| **Description** | A shared storage system accessible from any safe room or designated checkpoint. Items placed in the Item Box are available at all other Item Box locations, creating a network of shared inventory. This lets the player store excess items without losing them, reducing the pressure of inventory constraints. |
| **Kid UX** | The child stamps an **Item Box** inside safe rooms (a colorful chest with a glowing lid). Tapping the box opens the storage screen, split into "Inventory" and "Box" sections. Dragging items between sections transfers them. A large number shows box capacity (e.g., "12/20"). Items in the box appear at every other Item Box the player finds, creating a magical sense of connected storage. The box lid opens with a satisfying creak and sparkle when accessed. |
| **LLM Automation** | Manages the shared Item Box inventory as a global save variable, handles item transfer between inventory and box, enforces box capacity limits, ensures item availability at all linked box locations, syncs box state across all access points, and generates appropriate open/close animations. |
| **JSON Contract Extension** | `itemBox: { sharedInventory[], capacity, currentCount, linkedLocations[], accessPoints[] }` |

---

## 6.7 Shops & Economy

Commerce creates worldbuilding. These features establish NPC merchants, quest-based rewards, and economic loops that make the game world feel inhabited and purposeful.

### NPC Merchant System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania (Librarian) / Monster Hunter (Item Shop) / Shovel Knight (Chester) |
| **Description** | A friendly NPC merchant who buys and sells items. The player can sell collected treasures, gems, and duplicate items for currency, then purchase healing items, equipment, weapon skills, or key items. Shop inventory expands as the player progresses through the game, creating a sense of the world's economy growing alongside the player. |
| **Kid UX** | The child stamps a **Shopkeeper** NPC onto their canvas (a friendly character behind a counter). Tapping the shopkeeper opens a shop screen split into **"Buy"** and **"Sell"**. Items appear as big stamps with price tags in coin icons. The player drags items from their inventory to the "Sell" side to get gold coins. Then drags desired items from the "Buy" side to purchase. The gold coin counter updates in real-time. Unaffordable items are grayed out with a small lock icon. A "Special Deal!" bubble occasionally appears over random items with a discount. The shopkeeper has expressive reactions — happy when buying, thoughtful when selling. |
| **LLM Automation** | Manages the merchant's inventory and pricing per level progression, validates purchase transactions (sufficient funds, inventory space), calculates sell values (typically 25-50% of buy price), manages shop inventory unlocking (new items appear after certain progression flags like defeating a boss or reaching a new area), tracks merchant relationship level (discounts for repeat business), generates shopkeeper dialogue, restocks shops between level visits, and handles "sold out" state for limited-stock items. |
| **JSON Contract Extension** | `merchant: { shopkeeperId, inventory[{ itemId, buyPrice, sellPrice, stock, unlockCondition }], currency, playerBalance, discountRate, restockOn }` |

### Quest Board System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania: Portrait of Ruin / Monster Hunter |
| **Description** | NPCs and bulletin boards offer optional quests with specific objectives: defeat X enemies, find an item, bloom all flowers in an area, defeat a specific boss without taking damage. Completing quests rewards unique items, Praise, currency, or unlocks new stamps. Quests provide structured goals that guide exploration and reward mastery. |
| **Kid UX** | The child stamps a **Quest Board** (big wooden sign with colorful paper notices pinned to it) or a **Villager NPC** with a "!" bubble. Tapping it shows 2-3 quest cards with fun icons: "Defeat 5 Bats!" (bat icon x5), "Find the Red Gem!" (ruby icon), "Cook a Meal!" (pot icon). The player accepts a quest by tapping it. A **Quest Tracker** appears at the edge of the screen showing progress ("Bats: 3/5"). Completing a quest auto-triggers a reward burst with fanfare and a checkmark on the quest card. |
| **LLM Automation** | Tracks quest progress (kill counters, item possession checks, area exploration flags, crafting completion), validates completion conditions against quest requirements, triggers reward distribution on completion, manages quest state machine (available -> active -> completed -> turned in), generates new quests procedurally based on level content, displays progress in the Quest Tracker HUD, and manages quest reward scaling. |
| **JSON Contract Extension** | `quests: [{ id, giver, objective{ type, target, count }, reward[], state, progress, trackerPosition }]` |

### Enemy Drop Tables

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania: Symphony of the Night |
| **Description** | Each enemy type has a unique drop table with common, uncommon, and rare items. Defeating an enemy rolls against its drop table to determine what (if anything) is dropped. Drop chance is influenced by the player's Luck stat. Some rare items have very low drop rates, creating exciting "jackpot" moments. |
| **Kid UX** | The child stamps an enemy, then taps a **"treasure bag"** icon that appears above the enemy stamp. A simple 3-slot popup shows: **Common** (big brown bag, 70% chance), **Uncommon** (sparkly blue bag, 25% chance), and **Rare** (rainbow gold bag, 5% chance). The child drags item stamps into each slot to set drops. During play, defeated enemies bounce an item bag that opens with a sparkle to reveal the drop. Rare drops produce a dramatic slow-motion reveal with a golden glow. The player can equip a "Lucky Charm" accessory to increase drop rates (shown as bigger bag icons). |
| **LLM Automation** | Manages RNG roll on enemy defeat (modified by player Luck stat), handles drop physics (item bounces once, then magnetizes toward player), manages drop table definitions per enemy type, tracks drop rate modifiers from equipment and badges, generates appropriate rarity VFX (common = small sparkle, rare = golden glow + slow motion), and ensures drop tables are balanced so rare drops feel special but not frustrating. |
| **JSON Contract Extension** | `dropTables: { enemyId: { common{ itemId, baseChance }, uncommon{ itemId, baseChance }, rare{ itemId, baseChance } }, luckScaling }` |

---

## 6.8 Special Item Systems

Beyond standard consumables and equipment, these features introduce unique item mechanics that create memorable moments and deep crafting interactions.

### Trap Crafting & Deployment

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Monster Hunter series |
| **Description** | Players can craft and deploy traps that immobilize enemies — Pitfall Traps sink monsters into the ground, Shock Traps paralyze with electricity, and Tranq Bombs put enemies to sleep. Traps are essential for capturing monsters alive (which yields bonus rewards) and creating tactical advantages in combat. |
| **Kid UX** | The child stamps **Trap Blueprints** at crafting stations: "Pitfall Trap" requires a Net + Trap Tool, "Shock Trap" requires a Thunderbug + Trap Tool. Crafted traps appear as items in inventory. The child stamps **Trap Placement Zones** on the ground. During play, the player places a trap by tapping the zone — it becomes hidden until triggered. When a monster walks over it: Pitfall = monster sinks into the ground, immobilized for 10 seconds; Shock = monster twitches with electricity, stunned for 8 seconds. A **"Capture!"** icon appears when the monster is weak enough + trapped. |
| **LLM Automation** | Handles trap trigger detection (enemy proximity and step-on validation), applies immobilization or paralysis status with appropriate duration, manages trap visibility state (hidden until triggered, then visible during effect), tracks monster HP threshold for capture eligibility (typically below 20%), handles capture rewards vs. slay rewards, and manages trap inventory and crafting recipe validation. |
| **JSON Contract Extension** | `trapTypes: [{ id, duration, effect, trigger, craftingRecipe }], captureMechanic: { hpThreshold, requiresTrap, bonusRewards }` |

### Collectible Stamps & Album

| Attribute | Detail |
|-----------|--------|
| **Source Game** | NiGHTS into Dreams / Animal Crossing |
| **Description** | Special decorative stamps that the player collects throughout their adventures. Each collectible stamp features artwork of an enemy, item, location, or character encountered in the game. Collected stamps fill a **Collector's Album** organized by category. Completing album pages grants bonus rewards and bragging rights. |
| **Kid UX** | Every time the player defeats a new enemy type, discovers a new item, or visits a new location for the first time, a **"New Stamp!"** popup appears with a beautiful illustration. The player taps to add it to their Collector's Album — a digital scrapbook organized into pages: "Enemies," "Items," "Places," "Friends." Each page shows empty slots for undiscovered stamps as gray outlines. Completing a full page produces a **"Page Complete!** celebration with a special reward (new costume color, bonus currency, or exclusive stamp). The album is accessible from the main menu and becomes a visual diary of the player's journey. |
| **LLM Automation** | Tracks first-time discoveries per save file, generates collectible stamp artwork from entity sprites (auto-composed into decorative borders), manages album page organization and completion detection, triggers page-complete celebrations and rewards, saves album state persistently, and generates album reward tiers (bronze for 25% complete, silver for 50%, gold for 100%). |
| **JSON Contract Extension** | `collectibleAlbum: { categories[], stamps[{ id, category, unlocked, artwork }], completionProgress, pageRewards[], totalCollected }` |

### Key Item & Door Matching

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil / Zelda |
| **Description** | Progression requires finding specific key items and using them at matching environmental objects. Keys are color-coded and shape-coded to their doors: a Red Diamond Key opens a Red Diamond Door, a Blue Circle Key opens a Blue Circle Door. The visual matching makes the system intuitive for children while creating satisfying lock-and-key puzzles. |
| **Kid UX** | The child stamps a **Key Door** with a colored/shaped keyhole: a red diamond shape, a blue circle, a gold star. They then stamp the matching **Key** item somewhere else in the level. The key item shows the same colored shape icon. When the player finds the key and brings it to the door, the shapes snap together with a satisfying "click" sound and the door opens with a sparkle. The child can create multi-key puzzles by stamping several doors and scattering their keys throughout the level. |
| **LLM Automation** | Validates key-door matching by color and shape, handles key consumption on use (optional — some keys are reusable), manages puzzle state for multi-key sequences, checks solution correctness, triggers open animations on successful match, and ensures keys are placed in locations reachable without the key they're meant to open (no soft-lock validation). |
| **JSON Contract Extension** | `keyItems: [{ id, shape, color, consumable, reusable }], keyDoors: [{ id, requiredKey, state }]` |

---

## 6.9 Economy & Item System Comparison

| Feature Category | Key Source Games | Feature Count | Core Kid Interaction |
|-----------------|-----------------|---------------|---------------------|
| Currency & Collection | Mario, Sonic, Dark Souls, Okami | 4 | Collect on proximity, recovery runs |
| Crafting & Discovery | DQ Builders, Monster Hunter, KH | 4 | Drag materials to combine |
| Cooking & Food | Monster Hunter, Zelda | 2 | Timing-based minigame, ingredient mixing |
| Consumables & Healing | Dark Souls, Resident Evil, Bloodborne | 4 | Tap to use, drag to combine herbs |
| Equipment & Upgrades | Castlevania, Mega Man X, Dark Souls | 5 | Drag to equip, find capsules |
| Inventory Management | Resident Evil | 2 | Drag shapes on grid, shared storage |
| Shops & Economy | Castlevania, MH, Shovel Knight | 3 | Buy/sell with shopkeeper |
| Special Item Systems | Monster Hunter, RE, Zelda | 3 | Deploy traps, match keys |
| **TOTAL** | | **~31 features** | |

The items, crafting, and economy systems in KidGameMaker transform collection from a passive activity into an active adventure. Every coin collected, every recipe discovered, every dish cooked, and every weapon upgraded represents a meaningful choice made by the player — or a thoughtful design decision by the child creator. The LLM's invisible hand ensures that economies stay balanced, that crafting combinations always produce satisfying results, and that inventory management never becomes frustrating. The result is a rich ecosystem of rewards where every player feels like a master chef, a legendary blacksmith, and a treasure hunter all at once.
