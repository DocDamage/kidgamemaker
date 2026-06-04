# Chapter 4: Companions, Pets & Multiplayer

> *"Every hero needs a friend."* — This chapter captures the full spectrum of companionship in games, from a loyal cat warrior to a swarm of obedient Pikmin, from AI buddy pathfinding to local drop-in co-op. Every system is designed so a 5-year-old can summon, befriend, and command allies through stamps, taps, and simple gestures. The LLM handles all AI behavior trees, squad coordination algorithms, and co-op session management — invisibly weaving friendship into gameplay.

---

## 4.1 Companion Systems

These features provide the player with persistent AI allies who fight, heal, and assist throughout their adventure. Each companion system brings a distinct personality and mechanical identity, turning solitary platforming into shared journeys.

#### Familiar Companion System

- **Source Game:** *Castlevania: Symphony of the Night* (Faerie, Bat, Ghost, Demon, Sword Familiar)
- **Description:** A floating companion creature follows the player and provides context-sensitive assistance. Five familiar types offer distinct personalities and abilities: the **Faerie** auto-heals when the player's HP drops below 25% and cures status ailments with a tiny hammer; the **Bat** shoots seeking fireballs at nearby enemies; the **Ghost** latches onto enemies to drain HP and transfer it to the player; the **Demon** casts area-of-effect spells independently; the **Sword Familiar** physically attacks nearby enemies and eventually becomes so powerful it can be wielded as a weapon. Familiars level up as the player defeats enemies, growing stronger and unlocking new abilities over time.
- **Kid UX:** The child opens a **Familiar** stamp palette and stamps a familiar orb onto the player character. The familiar immediately appears and begins following with a cute bobbing animation. Tapping the familiar toggles it on/off with a happy/sad face animation. Familiar type is selected via sticker picker with expressive icons: a faerie with a wand, a bat with flame, a ghost with a heart, a demon with horns, a sword with wings. The familiar's level is shown as small stars below it — defeating enemies fills the star meter. Familiars never die permanently; they simply retreat when overwhelmed and return after a short rest.
- **LLM Automation:** Handles all familiar AI behavior trees per type (attack radius, heal triggers at HP thresholds, pathfinding to stay near player, spell casting cooldowns), manages familiar stat scaling (familiar levels up as player defeats enemies, gaining +HP, +damage, and reduced cooldowns), auto-triggers context-sensitive abilities (faerie uses hammer when player is petrified, bat fires when enemy enters range), handles familiar rendering as an overlay sprite that follows the player with smooth interpolation, and manages the Sword Familiar's unique progression into a wieldable weapon at max level.
- **JSON Contract Extension:**
```json
{
  "familiars": [{
    "id": "faerie",
    "behaviorType": "healerSupport",
    "triggerConditions": [
      {"type": "hpBelow", "threshold": 0.25, "action": "usePotion"},
      {"type": "statusAilment", "action": "useCureHammer"}
    ],
    "attackRadius": 100,
    "levelScaling": {"maxLevel": 99, "expPerKill": 1, "hpPerLevel": 2, "damagePerLevel": 1}
  }]
}
```

#### Helper Characters (Enemy Conversion)

- **Source Game:** *Kirby Super Star / Star Allies* (Helper Heart system)
- **Description:** Enemies can be converted into helper allies that follow the player and attack other enemies using the same abilities they had as foes. A fire-breathing enemy becomes a fire-breathing ally. A sword-wielding enemy becomes a sword-wielding partner. This system transforms the enemy roster into a recruitment pool — every defeated foe is a potential friend. Supports up to 3 helpers following the player simultaneously, creating a small adventuring party.
- **Kid UX:** The child stamps a **Helper Heart** item. When the player touches it, the nearest enemy transforms into a helper with a shower of hearts and sparkles. The helper wears a small crown to show it's friendly. A **"Join!"** bubble appears over the helper for a second player to tap for drop-in co-op. Helpers follow the player automatically and attack enemies on sight. Tapping a helper opens a simple command wheel: "Stay," "Follow," "Attack" — three big icons. The helper limit of 3 is shown as heart slots at the top of the screen.
- **LLM Automation:** Converts enemy AI to ally AI (targets switch from player to other enemies), implements follow behavior with pathfinding that avoids hazards and stays within screen bounds, manages helper attacks using the same ability definitions the enemy had, handles player drop-in/drop-out by converting helper control to player 2 input, manages the 3-helper limit (newest conversion replaces oldest if at cap), and generates the helper crown visual overlay to distinguish allies from enemies.
- **JSON Contract Extension:**
```json
{
  "helpers": [{
    "type": "ally",
    "ability": "fireBreath",
    "behavior": "followAndAttack",
    "maxHelpers": 3,
    "visualCrown": true,
    "convertFromEnemy": true
  }]
}
```

#### Spirit Companion Summon

- **Source Game:** *Elden Ring* (Spirit Ashes — wolves, jellyfish, mimic tear, skeletons)
- **Description:** Consumable **Friend Crystal** items summon AI-controlled ally spirits to fight alongside the player. Different spirits have radically different behaviors: **Wolves** swarm enemies in packs, flanking and overwhelming. **Jellyfish** floats overhead and rains poison down on foes. **Skeletons** revive once after dying, creating relentless pressure. **Birds** dive-bomb from above. **Golems** tank damage and draw enemy attention. Each summon costs one Friend Crystal and lasts for a timed duration (typically 30 seconds) or until the spirit's HP is depleted.
- **Kid UX:** The child stamps a **Friend Crystal** on the canvas. Tapping it opens a companion picker: wolf, bird, ghost, or robot (cartoon stamps with expressive faces). The LLM auto-assigns AI behavior per type. In play, a **"Call Friend"** button with the selected companion's portrait summons the ally for a limited time. The companion auto-fights and follows the player. A sparkle poof animation plays on summon, and a gentle fade with heart particles plays when the summon expires. Friend Crystals are collected as pickups throughout levels — shown as glowing crystals in the element color matching the spirit type.
- **LLM Automation:** Selects and applies AI behavior profile per companion type (wolf = swarm melee with pack coordination, jellyfish = ranged poison from above, skeleton = melee with one revive, bird = dive attack pattern), manages summon duration countdown and despawn on expiry, handles companion targeting and pathfinding with obstacle avoidance, plays despawn animation on expiry, limits max active companions (typically 1-3 depending on crystal tier), auto-balances companion stats to be helpful but not carry the fight (typically 30-50% of player damage output), and manages crystal inventory consumption per summon.
- **JSON Contract Extension:**
```json
{
  "spiritCompanions": [{
    "id": "sparkyWolf",
    "type": "wolf",
    "aiProfile": "swarmMelee",
    "summonCost": {"item": "friendCrystal", "amount": 1},
    "duration": 30,
    "cooldown": 60,
    "stats": {"hp": 50, "damage": 8, "speed": 120},
    "revives": 0,
    "summonVfx": "crystalBurst",
    "despawnVfx": "sparkleFade"
  }]
}
```

#### Palico Cat Companion

- **Source Game:** *Monster Hunter* series (Palicoes — cat warriors with gadgets and armor)
- **Description:** A fully customizable cat companion that assists in combat, healing, trapping, and gathering. The Palico wears equipable armor and wields a tiny weapon, both visible on its sprite. Its **Gadget** determines its primary support role: **Vigorwasp Spray** heals the player when HP is low, **Flashfly Cage** blinds enemies, **Shield Spire** draws enemy aggro, **Plunderblade** steals items from monsters, **Coral Orchestra** plays buff-granting songs, **Meowlotov Cocktail** throws explosive jars. The Palico levels up independently, gaining HP and damage as it fights alongside the player.
- **Kid UX:** The child stamps a **Palico** (cute cartoon cat warrior) next to the player start point. Tapping the Palico opens a **customization screen**: big armor slot icons (head, body, weapon), a **Gadget** selection grid with illustrated cards (healing horn, flash bomb, trap net), and a **personality picker** (brave, cautious, friendly). The Palico's armor updates on the sprite instantly when equipped. During play, the Palico follows the player, fights with small attack animations, and auto-uses its gadget when conditions are met (healing when player is hurt, flashing when enemies cluster). Level-up is celebrated with a "Level Up!" pop and a new star on the Palico's badge.
- **LLM Automation:** Handles Palico AI (engages enemies at medium range, retreats at low HP, uses gadget on cooldown or trigger condition), manages Palico equipment stats (armor = damage reduction, weapon = attack power), handles gadget abilities (healing radius, flash blind duration, trap placement), tracks Palico experience and leveling curve, generates appropriate combat animations per equipped weapon type (sword slashes, boomerang throws, drum bashes), and manages Palico knockdown recovery (Palico retreats when defeated, then revives after a cooldown rather than dying permanently).
- **JSON Contract Extension:**
```json
{
  "palico": {
    "level": 5,
    "equipment": {"weapon": "palicoSword", "armor": "palicoBoneSet"},
    "gadget": {"id": "vigorwasp", "type": "heal", "cooldown": 30, "trigger": "playerHpBelow50Percent"},
    "supportMoves": ["heal", "trap", "flash"],
    "personality": "brave",
    "aiRange": 150,
    "reviveCooldown": 60
  }
}
```

#### Rush Adapter Dog

- **Source Game:** *Mega Man* series (Rush Coil, Rush Jet, Rush Marine, Rush Search)
- **Description:** A robot dog companion that transforms into various utility forms on command, each providing a distinct traversal or puzzle-solving ability. **Rush Coil** becomes a springboard for super-high jumps. **Rush Jet** transforms into a flying platform for aerial sections. **Rush Marine** enables underwater swimming with propeller boost. **Rush Search** digs at soft ground to uncover hidden items. All forms share a single **energy pool** — transforming and using abilities depletes energy, which regenerates slowly over time. This creates a resource-management puzzle: which form to use, and when?
- **Kid UX:** The child stamps a **Robot Dog** companion next to the player. A popup shows four big icons: a spring for Coil, a jet for Jet, a submarine for Marine, a shovel for Search. Tapping an icon transforms the dog with a flash and a mechanical "clank-shwoosh" sound. **Rush Coil** = the dog becomes a bouncy platform the player jumps on. **Rush Jet** = the dog becomes a flying vehicle the player rides. **Rush Marine** = the dog becomes a submersible for underwater sections. **Rush Search** = the dog digs at marked spots, uncovering treasure. An energy meter appears above Rush and depletes with each use — shown as shrinking green blocks. Energy slowly refills when Rush is in dog form.
- **LLM Automation:** Manages Rush energy pool (depletes on transformation and ability use, regenerates at 1 unit per 2 seconds when in base form), handles transformation state machine with collision profile changes per form (spring = bouncy platform physics, jet = flight movement with inertia, marine = underwater buoyancy + dash boost, search = dig spot detection + treasure spawn), auto-detects dig spots for Rush Search (ground patches with subtle visual indicator), and ensures Rush follows the player intelligently when not in active form (pathfinding with slight lag for charm).
- **JSON Contract Extension:**
```json
{
  "rushForms": [
    {"id": "rushCoil", "energyCost": 4, "type": "springboard", "bounceHeight": 300},
    {"id": "rushJet", "energyCost": 2, "type": "vehicle", "speed": 200, "duration": 10},
    {"id": "rushMarine", "energyCost": 2, "type": "underwater", "speed": 150, "boost": true},
    {"id": "rushSearch", "energyCost": 6, "type": "dig", "detectRadius": 100}
  ],
  "rushEnergy": {"max": 28, "current": 28, "regenRate": 1, "regenInBaseFormOnly": true}
}
```

#### Dream Eater Creature Creator

- **Source Game:** *Kingdom Hearts 3D* (Dream Eaters — create creatures via recipes, raise them, they fight alongside you)
- **Description:** The player creates companion creatures by combining **Dream Parts** collected from defeated enemies or found in levels. Each combination produces a unique creature with procedural color variations and personality traits. Creatures level up by fighting alongside the player and learn new abilities at specific level thresholds. They have visible **happiness meters** shown as heart icons, and perform cute idle animations (dancing when happy, sulking when neglected). Feeding them treats increases both happiness and stats. The creature creation system turns companion acquisition into a creative activity — no two Dream Eaters are exactly alike.
- **Kid UX:** The child stamps **Dream Parts** (colored orbs: red = brave, blue = calm, yellow = energetic, green = nurturing) and a **Dream Portal** creation station. During play, combining 2-3 parts at the portal spawns a cute creature with colors matching the input parts and a personality derived from the combination (red + yellow = energetic brave fighter, blue + green = calm nurturing healer). The creature follows the player, helps in combat with auto-attacks, and has a small heart meter showing happiness. Feeding it treat items (stamped or found) makes hearts burst from the creature and its stats increase slightly. The creature's name can be typed or spoken after creation.
- **LLM Automation:** Manages the creature generation algorithm (part combinations map to creature type + color palette + personality trait), implements creature AI (combat assistance with auto-targeting, following behavior with pathfinding, idle animation selection based on happiness), tracks creature XP and leveling with automatic ability unlocks at thresholds, generates procedural creature sprites from part combinations through layered compositing, manages happiness mechanics (happiness decays slowly, feeding restores it, low happiness reduces combat effectiveness), and handles creature ability unlocks as they gain experience.
- **JSON Contract Extension:**
```json
{
  "dreamEater": {
    "parts": ["braveOrb", "calmOrb", "energyOrb", "nurtureOrb"],
    "creationStation": "dreamPortal",
    "combinationCount": [2, 3],
    "traits": ["aggressive", "defensive", "healer", "tricky"],
    "leveling": true,
    "happinessSystem": true,
    "proceduralSprites": true,
    "abilityUnlocks": "levelBased",
    "maxActive": 2
  }
}
```

#### NPC Questline Stamps

- **Source Game:** *Dark Souls* series (Solaire's quest, Siegmeyer's journey, Ranni's epic questline)
- **Description:** An NPC companion that appears in specific locations with dialogue that progresses based on player actions — finding items, defeating bosses, or reaching new areas. NPC companions move between waypoints or landmarks as their quest advances. Some questlines branch based on choices (help the NPC or abandon them). Rewards include unique abilities, rare items, or unlocking new level areas. The questline system turns a simple companion into a narrative journey that unfolds across multiple play sessions.
- **Kid UX:** The child stamps an **NPC Stamp** (cartoon character with a speech bubble). Tapping it opens a **dialogue composer**: the child types or speaks what the NPC says at each stage, and stamps an **Item Gift** to give as a reward. The child stamps numbered **Location Stamps** (1, 2, 3) showing where the NPC moves throughout the level. A **Quest Tracker** appears in the HUD showing the current stage: *"Find the NPC's lost hat!"* with a picture of the hat. Completing the quest triggers a celebratory animation and the reward item spawns. Questlines can span multiple levels — the NPC remembers the player's progress.
- **LLM Automation:** Manages quest state machine (not started → active → progressed → complete → rewarded), triggers NPC movement between waypoints on key events (item collected, boss defeated, area reached), auto-generates dialogue trees from the child's spoken input, handles branching logic (player choices determine which path the quest takes), manages inventory rewards and ability unlocks at quest completion, saves quest progress across all sessions and levels, auto-generates a simple portrait for the NPC based on their stamp appearance, and ensures quest objectives are achievable (validates that required items exist in the level).
- **JSON Contract Extension:**
```json
{
  "npcs": [{
    "id": "blinkyTheGhost",
    "name": "Blinky the Ghost",
    "locations": [
      {"stage": 0, "x": 400, "y": 300, "dialogue": "Have you seen my hat?"},
      {"stage": 1, "x": 1500, "y": 500, "dialogue": "You found it! Here's a Super Jump!"}
    ],
    "questTrigger": {"type": "itemCollected", "itemId": "ghostHat"},
    "reward": {"type": "abilityUnlock", "ability": "superJump"},
    "currentStage": 0,
    "portraitAutoGen": true
  }]
}
```

#### Companion Equipment Sharing

- **Source Game:** *Monster Hunter* (Palico armor/weapon crafting) / *Final Fantasy* (companion gear)
- **Description:** Companion characters can be equipped with their own weapons, armor, and accessories just like the player. A Palico's tiny sword increases its attack damage. Its armor reduces damage taken. Special companion accessories grant unique behaviors: a **Healing Bell** causes the companion to periodically restore player HP, a **Treasure Nose** makes the companion lead the player to hidden items, a **Battle Horn** boosts both characters' attack speed when danger is near. Companion equipment is found as special small-sized item stamps throughout levels.
- **Kid UX:** The child stamps **Companion Gear** items — tiny helmets, small swords, miniature shields, little bells. Tapping a companion opens its **equipment screen** (a smaller version of the player's equipment outline with 3-4 slots). Dragging gear onto the companion updates its sprite immediately: the sword appears in its paw, the helmet on its head, the bell around its neck. Companion gear is visually distinct from player gear (smaller, cuter proportions). A **stats comparison** shows before/after numbers with green arrows for improvements. Finding a new companion weapon in a treasure chest is a genuine moment of excitement.
- **LLM Automation:** Manages companion equipment inventory separate from player inventory, computes companion stats from equipped gear (attack = weapon base + level scaling, defense = armor + helmet, special = accessory passive), handles equipment appearance layering on companion sprites (generates composite visuals for gear combinations), implements accessory-specific behaviors (Healing Bell = periodic HP restore with 30s cooldown, Treasure Nose = proximity-based hidden item detection with sparkle trail, Battle Horn = 15% attack speed buff when enemies within 200px), and auto-balances companion equipment drops to match level difficulty.
- **JSON Contract Extension:**
```json
{
  "companionEquipment": {
    "slots": ["weapon", "armor", "accessory"],
    "items": [
      {"id": "palicoSword", "attack": 8, "slot": "weapon"},
      {"id": "healingBell", "effect": "periodicHeal", "cooldown": 30, "slot": "accessory"},
      {"id": "treasureNose", "effect": "itemRadar", "radius": 150, "slot": "accessory"}
    ],
    "autoBalance": true,
    "visualLayering": true
  }
}
```

---

## 4.2 Pet & Follower Systems

These features focus on creatures that follow the player not for combat, but for friendship, discovery, and emotional connection. Pets don't just help — they make the world feel alive.

#### Animal Feeding & Following

- **Source Game:** *Okami* (feed animals for Praise orbs and friendship)
- **Description:** Various animals roam the game world — dogs, cats, rabbits, birds, deer, monkeys. Feeding them their preferred food type causes them to permanently follow the player, providing minor stat boosts and occasional treasure discovery. Each animal type has distinct preferences: dogs want meat, cats want fish, rabbits want carrots, birds want seeds. Once fed, the animal follows at a distance, plays idle animations, and occasionally digs at spots to uncover hidden items. Follower slots are limited (typically 3), so kids must choose their companions carefully.
- **Kid UX:** The child stamps **Animal** stamps throughout the level: dogs, cats, rabbits, birds, deer. Each animal has a thought bubble showing what food it wants (bone icon for dogs, fish for cats, carrot for rabbits, seed for birds). The child stamps **Food Bag** items. When the player gives the right food, hearts burst above the animal and it starts following the player with a happy hop or wag. Tapping a following animal opens a simple interaction menu: "Pet" (plays cute animation), "Stay" (animal waits here), "Go Home" (animal leaves party). The follower limit is shown as three heart slots in the HUD.
- **LLM Automation:** Manages animal AI states (wander when wild, follow at distance when fed, play idle animations, occasionally dig at treasure spots), tracks which animals have been fed and are following, applies follower bonuses per animal type (dog = +5% attack, cat = +10% luck, rabbit = +5% speed, bird = reveals hidden items), handles animal dig spot detection and treasure spawning, manages follower slot allocation (new follower prompts to dismiss existing one if at cap), and generates unique idle behaviors per animal type.
- **JSON Contract Extension:**
```json
{
  "animals": [
    {"id": "dog", "preferredFood": "meat", "followBonus": {"str": 1}, "special": "digForTreasure"},
    {"id": "cat", "preferredFood": "fish", "followBonus": {"lck": 2}, "special": "findSecretPath"},
    {"id": "rabbit", "preferredFood": "carrot", "followBonus": {"speed": 1.1}, "special": "none"}
  ],
  "followerSlots": {"max": 3, "current": []},
  "feedRange": 50,
  "followDistance": 100
}
```

#### Monster Taming Whistle

- **Source Game:** *Dragon Quest Builders 2* (befriend defeated monsters who then help in town)
- **Description:** After defeating an enemy, there's a chance it drops a **Friendship Token** — a glowing heart that floats from the defeated foe. Collecting this token and delivering it to a **Monster Barn** permanently befriends that enemy type. Befriended monsters become allies: they patrol the level, help fight other enemies, and can be ridden as mounts. Each monster type has a unique ally ability — Slimes bounce and find hidden items, Drackies fly and scout ahead, Golems smash obstacles, Sabrecats provide fast ground travel. Tamed monsters wear a tiny hat to show they're friendly.
- **Kid UX:** The child stamps **Monster Spawners** and a **Monster Barn** building. They can set a **"Tameable"** toggle on any enemy stamp (shown as a small heart icon on the enemy). During play, defeating a tameable enemy sometimes drops a glowing Friendship Token that floats upward. The player touches it to collect. Taking the token to the barn adds that monster type as a permanent friend, shown on a **Tame Board** with portraits of all befriended monsters. A **Call Whistle** item (stamped or earned) lets the player summon one tamed monster to their side. Tamed monsters wear a cute little top hat — the universal symbol of friendship.
- **LLM Automation:** Handles monster defeat detection and Friendship Token drop chance (typically 25-30% per tameable enemy), manages the Monster Barn registry (which types are tamed, their count, their level), implements tamed monster AI (ally behaviors per monster type: slime = bounce + item find, dracky = fly + reveal map, golem = smash barriers, sabrecat = fast mount), handles mount-riding physics for applicable monsters (movement speed increase, jump height changes), generates the cute hat accessory overlay on tamed monster sprites, and manages summon/dismiss via the Call Whistle item with a cooldown.
- **JSON Contract Extension:**
```json
{
  "monsterTaming": {
    "tokenDropChance": 0.3,
    "tameableToggle": true,
    "barnType": "monsterBarn",
    "summonItem": "callWhistle",
    "allyBehaviors": {
      "slime": "findHiddenItems",
      "dracky": "flyScout",
      "golem": "smashObstacles",
      "sabrecat": "fastMount"
    },
    "mountRiding": ["golem", "sabrecat", "greatDragon"],
    "friendlyVisual": "cuteHatOverlay",
    "maxTamedTypes": 10
  }
}
```

#### Soul Absorption Companion

- **Source Game:** *Castlevania: Aria of Sorrow* (Soul system — absorb enemy souls for abilities)
- **Description:** Defeating enemies sometimes releases their **soul** as a floating colored orb. Absorbing the soul grants the player that enemy's ability. Four soul types create distinct mechanical categories: **Bullet Souls** grant active attacks (throw bones, breathe fire, launch projectiles), **Guardian Souls** provide toggle buffs (transform into mist, summon a protective familiar), **Enchanted Souls** give passive stat boosts (increased strength, faster movement, higher luck), and **Ability Souls** grant permanent traversal upgrades (double jump, sliding, breaking walls). Only one Bullet, one Guardian, and up to three Enchanted souls can be active at once — forcing loadout decisions.
- **Kid UX:** The child stamps **Enemy Soul** orbs onto enemy stamps. The enemy gets a colored aura indicating soul type: red for Bullet (attack), blue for Guardian (buff), yellow for Enchanted (passive), silver for Ability (permanent). When the player defeats this enemy in-game, a glowing soul may float out with a "swoosh" sound. Touching it absorbs the ability with a flash. Absorbed souls appear as colorful badges in a **Soul Collection** screen, organized by type in four tabs. Dragging a soul into an active slot equips it. Ability souls auto-equip and are permanent. The soul collection screen shows a completion counter — "23 of 100 souls found!"
- **LLM Automation:** Handles soul drop RNG per enemy (typically 10-20% base chance, modified by luck stat), categorizes souls by type and applies the appropriate behavior (Bullet = active skill button, Guardian = toggle with MP drain, Enchanted = always-on passive modifier, Ability = permanent flag), manages equip limits (1 Bullet, 1 Guardian, 3 Enchanted, unlimited Ability), implements soul-specific attack behaviors and visual effects, tracks collection completion across all sessions, and auto-balances soul drop rates to ensure the player gets a steady stream of new abilities without overwhelming them.
- **JSON Contract Extension:**
```json
{
  "souls": [
    {"id": "skeletonSoul", "type": "bullet", "ability": "throwBone", "dropRate": 0.15, "dropFrom": "skeleton"},
    {"id": "mistSoul", "type": "guardian", "ability": "mistForm", "dropRate": 0.10, "mpDrain": 5}
  ],
  "soulSlots": {"bullet": 1, "guardian": 1, "enchanted": 3, "ability": -1},
  "soulCollection": {"total": 100, "collected": 0, "byType": {"bullet": 0, "guardian": 0, "enchanted": 0, "ability": 0}}
}
```

#### Beast Riding Mount System

- **Source Game:** *Monster Hunter* (mounting monsters) / *Zelda: Breath of the Wild* (horse taming)
- **Description:** Tamed large creatures can be ridden as mounts, dramatically changing traversal speed and capability. A **Sabrecat** runs at 3x player speed and jumps higher. A **Great Bird** flies for short distances, gliding over gaps. A **Golem** walks slowly but is immune to environmental hazards (lava, poison, spikes). A **Dolphin** enables fast underwater travel. Mounts are acquired through the Monster Taming system or found as wild creatures that require calming (feed them their favorite food while approaching slowly). Each mount has a stamina meter that depletes during sprinting or flying.
- **Kid UX:** The child stamps **Mount Spawn Points** in their level — each shows a silhouette of the mount type (cat, bird, golem, dolphin). Tapping the spawn sets the mount type via sticker picker. During play, approaching a mount shows a **"Ride!"** prompt. Tapping it triggers a mounting animation — the character hops on. Mount-specific controls appear: a **sprint button** for the Sabrecat, an **ascend/descend** control for the Great Bird, a **stomp button** for the Golem. The stamina meter appears as shrinking carrots above the mount. Dismounting is a single button tap with a graceful jump-off animation. Mounts wait patiently where dismounted, shown with a small saddle icon.
- **LLM Automation:** Manages mount state (wild, tamed, riding, waiting), implements mount-specific physics (Sabrecat = high ground speed + jump boost, Great Bird = flight with gravity override + glide on descent, Golem = slow speed + hazard immunity + heavy stomp attack, Dolphin = underwater speed boost + surface jumping), handles the mounting/dismounting animation and state transitions, manages stamina depletion and regeneration (stamina drains during sprint/fly, recovers when walking or idle), generates mount-specific composite sprites (character sprite positioned on mount), and handles mount waiting behavior (mount stays at dismount location, can be called with a whistle button within range).
- **JSON Contract Extension:**
```json
{
  "mounts": [
    {"id": "sabrecat", "speed": 3.0, "jumpBoost": 1.5, "stamina": 100, "special": "sprint"},
    {"id": "greatBird", "speed": 1.5, "flight": true, "stamina": 80, "special": "glide"},
    {"id": "golem", "speed": 0.6, "hazardImmunity": true, "stamina": 200, "special": "stomp"},
    {"id": "dolphin", "speed": 2.5, "swimOnly": true, "stamina": 120, "special": "surfaceJump"}
  ],
  "tameMethod": "feedWhileApproaching",
  "dismountJump": true,
  "callWhistleRange": 500
}
```

---

## 4.3 Squad & Swarm Management

These systems give the player control over multiple units simultaneously — throwing, recalling, and directing swarms of small creatures to solve puzzles, carry objects, and overwhelm enemies.

#### Pikmin Squad Management

- **Source Game:** *Pikmin* series (command a squad of up to 100 Pikmin)
- **Description:** The player commands a squad of small, plant-like creatures called **Pikmin**. Three core commands form the entire control scheme: **Throw** — aim and toss individual Pikmin to attack enemies, activate switches, or reach items; **Whistle** — blow a whistle to recall scattered Pikmin to the player's side, with a circular radius that expands the longer the button is held; **Swarm** — send all Pikmin rushing in the facing direction to attack or carry. Pikmin follow in a loose group, bobbing along behind the player. Squad size is shown as a number counter that updates in real-time as Pikmin are thrown, lost, or sprouted.
- **Kid UX:** The child stamps **Pikmin Onions** (the creatures' home bases) and **Pikmin Sprouts** in the ground. Plucking a sprout adds one Pikmin to the squad — shown as a small number increase. The **Throw** button lets the player aim with a directional indicator and tap to toss one Pikmin at a time. The **Whistle** button (big circle icon) expands outward when held — Pikmin within the circle rush back to the player. The **Swarm** button (arrow icon) sends all Pikmin charging forward. Squad count appears as a bold number next to the player portrait. Pikmin are tiny, cute, and die with a sad ghost float — but the Onion sprouts new ones over time.
- **LLM Automation:** Manages squad list with individual Pikmin state (following, thrown, attacking, carrying, dead), implements throw arc and targeting physics (parabolic arc affected by aim direction, auto-targets nearest valid entity in aim cone), handles whistle recall with pathfinding that avoids hazards and reunites scattered Pikmin, manages swarm behavior (all following Pikmin charge forward with collision detection for enemy engagement and item pickup), handles Pikmin death (defeated Pikmin leave a spirit that floats upward, squad count decreases), manages Pikmin sprouting from Onions over time (new Pikmin appear as sprouts that can be plucked), and ensures squad size never exceeds the maximum of 100.
- **JSON Contract Extension:**
```json
{
  "squad": {
    "maxSize": 100,
    "currentPikmin": [{"type": "red", "state": "following"}],
    "commandMode": "throw",
    "throwArc": {"gravity": 300, "maxDistance": 200},
    "whistleRadius": 150,
    "swarmDuration": 3.0,
    "sproutRate": "1_per_10_seconds"
  }
}
```

#### Pikmin Type System

- **Source Game:** *Pikmin* series (Red, Blue, Yellow, Purple, White, Rock, Winged, Ice)
- **Description:** Color-coded Pikmin types each have elemental resistances and unique abilities that make them suited for different tasks. **Red Pikmin** are fireproof and deal 1.5x attack damage — ideal for fighting fire enemies. **Blue Pikmin** are waterproof and can swim — essential for water sections. **Yellow Pikmin** are electricity-proof, can be thrown higher, and conduct electricity to activate circuits. **Purple Pikmin** are heavy (count as 10 for carrying) and stun enemies with ground pounds. **White Pikmin** are fast, poison-resistant, and can find buried treasure. **Rock Pikmin** shatter crystal barriers. **Winged Pikmin** fly over obstacles and carry items through the air. **Ice Pikmin** freeze water surfaces and enemies.
- **Kid UX:** Pikmin sprouts appear in the ground near their matching-colored Onion — red sprouts near the Red Onion, blue near the Blue Onion. Tapping a sprout plucks it, and the Pikmin's color is immediately visible. The HUD shows a breakdown by type: **R:12 B:8 Y:5** — simple color-coded counters. When the player aims a throw, a **type indicator** shows which Pikmin will be thrown next (they're thrown in plucked order). Type-specific interactions are taught through visual feedback: throwing a Red Pikmin into fire shows it walking through unharmed; throwing a Blue Pikmin into water shows it swimming happily while others would drown. Type icons appear as colored dots above each Pikmin for easy identification at a glance.
- **LLM Automation:** Manages Pikmin squad composition and count per type, implements type-specific behaviors and immunities (Red = no fire damage, Blue = swim physics instead of drown, Yellow = higher throw arc + no electric damage, Purple = 10x carry weight + stun on throw impact, White = 1.5x speed + buried item detection radius, Rock = crystal barrier destruction on impact, Winged = flight path for thrown trajectory + aerial carrying, Ice = freeze water surface on contact + slow enemies), handles elemental damage/resistance calculations per type, and auto-suggests type diversity when the child is designing levels (ensuring water sections have Blue sprouts, fire sections have Red sprouts).
- **JSON Contract Extension:**
```json
{
  "pikminTypes": [
    {"color": "red", "immuneTo": "fire", "attackMultiplier": 1.5, "canSwim": false, "special": "highDamage"},
    {"color": "blue", "immuneTo": "water", "attackMultiplier": 1.0, "canSwim": true, "special": "waterTraversal"},
    {"color": "yellow", "immuneTo": "electric", "attackMultiplier": 1.0, "throwHeight": 1.5, "special": "conductElectricity"},
    {"color": "purple", "immuneTo": "wind", "attackMultiplier": 1.2, "carryWeight": 10, "special": "groundStun"},
    {"color": "white", "immuneTo": "poison", "attackMultiplier": 0.8, "speedMultiplier": 1.5, "special": "treasureDetect"},
    {"color": "rock", "immuneTo": "crush", "attackMultiplier": 1.3, "special": "shatterCrystal"},
    {"color": "winged", "immuneTo": "ground", "attackMultiplier": 0.7, "special": "flight"},
    {"color": "ice", "immuneTo": "freeze", "attackMultiplier": 0.7, "special": "freezeEnemiesAndWater"}
  ]
}
```

#### Pikmin Object Carrying

- **Source Game:** *Pikmin* series (multi-unit transport puzzles)
- **Description:** Objects throughout the level (fruit, ship parts, treasures, bridge pieces) require a certain number of Pikmin to carry. When enough Pikmin are thrown at or directed toward a carryable object, they automatically grab it at designated attachment points and begin carrying it toward the nearest Onion or base. Carrying speed scales with Pikmin count — more Pikmin = faster transport. Heavy objects require more Pikmin (Purple Pikmin count as 10). The carrying system turns object transport into a satisfying group activity — a line of Pikmin marching with a giant strawberry is one of gaming's most charming sights.
- **Kid UX:** **Carryable object stamps** show a small number indicating "Pikmin needed" (e.g., a strawberry shows "8" in the corner). When enough Pikmin are thrown at the object, they automatically run to grab points and lift the object with a synchronized heave-ho animation. A **dotted path line** shows the route to the nearest Onion. A progress bar fills as the object nears its destination. The player can whistle to redirect carrying Pikmin mid-route — the dotted line updates dynamically. Objects that require bridge construction show a ghost outline of the completed bridge, and Pikmin carry planks one by one to fill it in. Large objects need more Pikmin, and the HUD shows **"Need 5 more!"** if insufficient Pikmin are assigned.
- **LLM Automation:** Calculates carry weight versus assigned Pikmin strength (each Pikmin = 1 carry unit, Purple = 10), generates carrying formation positions around the object (Pikmin position themselves at grab points), manages pathfinding to the nearest Onion or destination base (recalculates if the route is blocked), handles carrying speed based on Pikmin count ratio (at 100% required = normal speed, at 200% = double speed), manages object delivery and reward spawn at the destination, and auto-validates that carryable objects have valid paths to their destinations (no soft-locks from unreachable objects).
- **JSON Contract Extension:**
```json
{
  "carryObject": {
    "id": "fruit_001",
    "weight": 15,
    "assignedPikmin": 8,
    "destination": "onionBase",
    "progress": 0.6,
    "speedPerPikmin": 5,
    "grabPoints": 8,
    "redirectable": true
  }
}
```

#### Pikmin Onion Base

- **Source Game:** *Pikmin* series (Onion — the creature spawning and healing hub)
- **Description:** The **Onion** is the Pikmin squad's home base — a floating, bulbous creature that sprouts new Pikmin from collected nutrients, heals injured Pikmin, and serves as the destination for carried objects. Each Pikmin color type has its own Onion (Red Onion, Blue Onion, Yellow Onion). When enough carried objects are delivered, the Onion produces new Pikmin sprouts that can be plucked. The Onion follows the player at a height, beacon-like, and can be called to land at specific zones. It provides a safe zone where enemies cannot enter and Pikmin automatically heal.
- **Kid UX:** The child stamps an **Onion** near the level start — it floats gently with a colored glow matching its Pikmin type (red, blue, yellow). Tapping the Onion opens a simple menu: **"Sprout Pikmin"** (converts delivered items into new sprouts), **"Heal"** (recalls injured Pikmin for gradual recovery), and **"Land Here"** (the Onion floats to the tapped location). When objects are delivered, the Onion glows brighter and new sprouts pop from the ground nearby — shown as tiny leaf shoots that wiggle. Plucking a sprout (tap it) adds one Pikmin to the squad with a satisfying "pop!" sound. The Onion's follower count is displayed as a number on its side.
- **LLM Automation:** Manages Onion inventory (nutrients collected from delivered objects), calculates Pikmin sprout generation rate (typically 1 sprout per 3 small objects delivered), handles Pikmin healing over time when near the Onion (1 HP per 2 seconds), processes object deposits and spawns reward items at the Onion's location, manages Onion following behavior (floats above player at offset height, smooth movement), implements the Onion landing/takeoff animation state, creates the safe zone radius around the Onion where enemy AI cannot enter, and auto-distributes sprouts among multiple Onions when multiple Pikmin types are in the squad.
- **JSON Contract Extension:**
```json
{
  "onion": {
    "color": "red",
    "position": {"x": 100, "y": 200},
    "storedNutrients": 45,
    "pikminCapacity": 100,
    "activeSprouts": 12,
    "sproutRate": "1_per_3_objects",
    "healRate": "1hp_per_2sec",
    "safeZoneRadius": 100,
    "followOffset": {"x": 0, "y": -80}
  }
}
```

#### Pikmin Day Cycle Timer

- **Source Game:** *Pikmin* series (sunset time limit — recover all Pikmin before dark)
- **Description:** Each game "day" has a time limit (approximately 10-15 minutes of real time). The sun moves across the sky as a visible arc. As sunset approaches, the sky shifts from blue to orange to deep red. At sunset, any Pikmin not recalled to the Onion are lost — they scatter in panic and cannot survive the night. This creates gentle urgency that encourages strategic planning: kids must balance exploration, combat, carrying, and recall timing. The day cycle is optional and can be disabled for a more relaxed experience.
- **Kid UX:** The **sun position** is shown at the top of the screen as an arc that the sun icon slowly traverses from left (morning) to right (evening). A simple **timer** shows remaining daylight as a shrinking bar. The sky color transitions from bright blue through warm orange to deep red as time passes. A **warning chime** plays at 1 minute remaining. When sunset hits, the screen darkens, a gentle "night falls" message appears, and any Pikmin not at the Onion sadly scatter. A **"Recall All!"** button whistles all Pikmin back to their Onions instantly. The day cycle toggle is a simple sun/moon stamp: tap to enable or disable.
- **LLM Automation:** Manages game time progression (scales real time to game time, typically 10 real minutes = 1 game day), updates sun position along the arc and sky color gradient (blue #4A90D9 → orange #F5A623 → red #D0021B), triggers the sunset warning chime at 60 seconds remaining, handles the end-of-day sequence (screen darkens, lost Pikmin scatter animation, saved Pikmin count displayed), auto-triggers the Recall All function when the panic button is pressed, and manages day-to-day persistence (Pikmin squad carries over, collected items persist, environment resets partially).
- **JSON Contract Extension:**
```json
{
  "dayCycle": {
    "dayLength": 600,
    "currentTime": 0,
    "sunsetWarningAt": 60,
    "skyGradient": ["#4A90D9", "#F5A623", "#D0021B"],
    "optional": true,
    "pikminSurviveNight": false,
    "recallAllButton": true
  }
}
```

---

## 4.4 Buddy & Co-op Systems

These features enable multiple characters to act in concert — whether through AI-controlled buddies with complementary abilities, combo attacks between characters, or true local co-op play.

#### Buddy Character Stamps

- **Source Game:** *Sonic 3 & Knuckles* (Tails flight, Knuckles glide/climb) / *Secret of Mana* (3-player simultaneous)
- **Description:** The player can have an AI partner character with unique traversal abilities that complement the main hero. **Flying Friend** (Tails-style) can fly and carry the player for a short time, reaching high platforms. **Climbing Friend** (Knuckles-style) can glide long distances and climb walls. **Bouncy Friend** can be thrown as a projectile to hit distant switches. **Digging Friend** can burrow through soft dirt blocks. **Strong Friend** can push heavy blocks and break walls. Each buddy type opens different traversal paths, encouraging replay with different companions.
- **Kid UX:** The child stamps a **Buddy Start Point** and picks a buddy type from a sticker row: **Flying Friend** (wings icon), **Climbing Friend** (claws icon), **Bouncy Friend** (spring icon), **Digging Friend** (shovel icon), **Strong Friend** (muscle icon). During play, the buddy follows the player with a slight delay for charm. Context prompts appear automatically: *"Press here to fly!"* appears when near a high ledge with a flying buddy, *"Throw buddy?"* appears near distant switches with a bouncy buddy. The buddy's portrait appears in the corner with their ability icon. Tapping the portrait triggers the buddy's special ability on demand.
- **LLM Automation:** Implements buddy AI (follows player with smooth interpolation and slight lag, avoids hazards automatically, catches up when far behind), handles buddy-specific ability activation (Flying = carry player for 5 seconds, Climbing = wall-climb and glide, Bouncy = thrown projectile physics, Digging = burrow through dirt blocks, Strong = push heavy objects and break weak walls), manages the carry/throw/glide state transitions, generates buddy sprite variants that match the main character's color scheme, and provides context-sensitive prompts based on buddy type plus environment combinations (detects high ledge + flying buddy = show fly prompt).
- **JSON Contract Extension:**
```json
{
  "buddies": [
    {"type": "flying", "ability": "carryPlayer", "duration": 5, "trigger": "contextPrompt"},
    {"type": "climbing", "ability": "wallClimbAndGlide", "glideRatio": 0.5},
    {"type": "bouncy", "ability": "thrownProjectile", "damage": 10, "range": 200},
    {"type": "digging", "ability": "burrowThroughDirt", "speed": 2.0},
    {"type": "strong", "ability": "pushAndBreak", "pushWeight": 100, "breakDamage": 50}
  ],
  "aiBehavior": "followWithLag",
  "contextPrompts": true,
  "maxBuddies": 2
}
```

#### Triple-Tech Fusion Crystals

- **Source Game:** *Chrono Trigger* (Delta Force, Delta Storm, Lifeline, Omega Flare — triple tech combos)
- **Description:** Three characters (the player plus two AI buddies) can combine their powers at a **Fusion Crystal** object to unleash a devastating triple attack. Each combination of character classes produces a unique cinematic attack with combined elemental effects. Fighter + Mage + Healer = **"Lifeline"** (party auto-revive aura with healing beams). Fighter + Ice Mage + Lightning Mage = **"Delta Force"** (a colossal shadow-elemental blast). Fire Mage + Ice Mage + Sword Fighter = **"Delta Storm"** (elemental tornado that damages all enemies). The triple-tech is the ultimate expression of teamwork — three characters becoming one force.
- **Kid UX:** The child stamps three **Buddy Start Points** (Buddy A, Buddy B, Buddy C) and one **Fusion Crystal** in the level. They tap each buddy to pick its type from stickers (Fighter, Mage, Healer, Rogue, each with a distinct color). When playtesting, companions follow the player. Standing near the Fusion Crystal with all three buddies nearby triggers a **"FUSION READY!"** banner. Tapping the crystal initiates the cinematic triple-tech — the screen darkens, the three characters pose together, and the spectacular attack plays with screen-filling particles and a dramatic name announcement. Each unique class combination produces a different attack, encouraging experimentation.
- **LLM Automation:** Calculates valid triple-tech combinations from the three assigned classes using a combo recipe database (30+ unique triple-techs), generates the combo name and visual effect based on element fusion rules (fire + ice = steam explosion, lightning + sword = thunder blade, healing + light = radiant blessing), handles companion AI pathfinding to stay near the player and within fusion crystal range, triggers the cinematic camera sequence (slow-motion character poses, attack animation, screen effects), computes area-of-effect damage or buff application with appropriate scaling (triple-techs deal 5-8x normal damage to justify the setup), and prevents fusion spam with a per-crystal cooldown.
- **JSON Contract Extension:**
```json
{
  "companions": [
    {"id": "buddyA", "class": "fighter", "element": "fire"},
    {"id": "buddyB", "class": "mage", "element": "ice"},
    {"id": "buddyC", "class": "healer", "element": "lightning"}
  ],
  "objects": [{
    "type": "fusionCrystal",
    "autoTriggerRadius": 100,
    "comboResult": "autoCalculated",
    "cinematicDuration": 3.0,
    "cooldown": 30.0,
    "uniqueCombos": 30
  }]
}
```

#### Double-Tech Buddy Combos

- **Source Game:** *Chrono Trigger* (X-Strike, Fire Sword, Ice Sword, Antipode Bomb, Drill Kick)
- **Description:** When two characters with compatible abilities are near each other, they can perform a **combined attack** that triggers automatically or on demand. Fighter + Mage = **"Fire Sword"** (sword swing with a trailing fire wave). Mage + Healer = **"Aura Beam"** (heals all allies in a line). Two Fighters = **"X-Strike"** (crossing slash attack that hits a wide area). The combo triggers when both characters attack near-simultaneously while in proximity, or when the player taps a **"Combo!"** button that appears when conditions are met.
- **Kid UX:** The child stamps two **Buddy Start Points** and picks each buddy's type from stickers. A **thought bubble** appears when placing showing what combo the pair produces: *"Fighter + Mage = Fire Sword!"* with a small preview icon. During play, buddies follow the player. When the player attacks while a buddy is nearby and their combo is off cooldown, a **"COMBO!"** prompt flashes. Tapping it triggers the flashy combo animation with both characters' names and the attack name in big stylized letters. Combo attacks have a 10-second cooldown, shown as a radial fill on the combo button. The combo name and a brief effect description appear in a banner across the screen.
- **LLM Automation:** Maintains a combo compatibility matrix (which class pairs produce which combos — 20+ unique combinations), detects proximity (both characters within 80 pixels) and simultaneous attack timing (attacks within 0.5 seconds of each other), triggers the combo cinematic (brief freeze-frame, combined attack animation, damage application), computes combined damage or healing values with scaling (combo attacks deal 2.5-4x normal damage), generates combo names dynamically from the participating classes (e.g., "Fire Fighter + Ice Mage = Steam Blade"), and handles buddy AI positioning to stay within combo trigger range.
- **JSON Contract Extension:**
```json
{
  "buddyCombos": {
    "pairs": [{
      "classes": ["fighter", "mage"],
      "comboName": "fireSword",
      "trigger": "proximityAttack",
      "chancePercent": 100,
      "cooldown": 10.0,
      "damageMultiplier": 3.0
    }],
    "visualFx": "cinematicFlash",
    "buddyAiRange": 80,
    "autoPrompt": true
  }
}
```

#### Local Co-op Drop-In

- **Source Game:** *Super Mario Maker 2* / *Secret of Mana* (drop-in 2P with screen sharing)
- **Description:** A second player can join the game at any time by tapping a **"Join!"** bubble that appears over a helper character or at the level start. Both players share the same screen (no split-screen), with the camera smoothly tracking a midpoint between both characters. Player 1 controls the hero; Player 2 controls a buddy character with identical abilities. Both players can attack, jump, and use abilities independently. If one player falls behind, they're automatically warped to the leading player. Co-op turns every level into a shared experience.
- **Kid UX:** A **"2P Join"** button is always visible at the edge of the screen. Tapping it opens a character picker with the available buddy types. Player 2 taps their choice and appears with a sparkle at Player 1's location. Each player's character has a colored arrow above their head (P1 = blue, P2 = red). The camera smoothly follows both players — if they separate too far, the screen subtly zooms out. If one player falls in a pit, they respawn on the other player after 2 seconds. Both players can trigger combo attacks together by attacking near-simultaneously. A **"Leave"** button lets Player 2 drop out at any time, converting their character back to AI buddy control.
- **LLM Automation:** Manages co-op session state (drop-in, drop-out, player count), handles camera tracking for two players (calculates midpoint, zooms to keep both visible, enforces minimum and maximum zoom bounds), implements Player 2 input mapping (mirrors Player 1 controls on a second input device), handles the warp-respawn for fallen players (detects pit death, waits 2 seconds, spawns on surviving player with invincibility frames), manages combo attack detection between two human players (more reliable than AI timing), and gracefully converts Player 2's character to AI buddy control on drop-out.
- **JSON Contract Extension:**
```json
{
  "coop": {
    "maxPlayers": 2,
    "dropIn": true,
    "dropOut": true,
    "cameraMode": "sharedTracking",
    "maxPlayerDistance": 400,
    "respawnOnPartner": true,
    "respawnDelay": 2.0,
    "playerColors": ["#4488FF", "#FF4444"],
    "comboBetweenPlayers": true,
    "aiTakeoverOnLeave": true
  }
}
```

#### Dual-Character Switching

- **Source Game:** *Castlevania: Portrait of Ruin* (Jonathan the warrior + Charlotte the spellcaster)
- **Description:** Two playable characters with distinct stats, equipment, and abilities share the same screen, but only one is player-controlled at a time. The other follows as an AI companion with basic auto-attack behavior. Switching is instant — tap the **SWAP** button and control transfers seamlessly. Jonathan is a warrior with high STR, melee attacks, and physical skills. Charlotte is a spellcaster with high INT, ranged magic, and support spells. Both characters have separate HP and MP pools, separate equipment loadouts, and separate skill sets. Some puzzles require both characters' abilities to solve.
- **Kid UX:** The child stamps a **Hero** character and a **Partner** character with distinct class icons. Both appear on screen. A big colorful **"SWAP"** button at the screen edge switches control between them with a flash transition. The partner auto-follows and auto-attacks nearby enemies with a simple AI. The child can drag equipment onto either character's body outline independently — both have their own weapon, armor, and accessory slots. Character portraits in the HUD show HP/MP for both, with the active character highlighted with a golden border. Puzzles that require both characters show **"Need Both!"** indicators — a pressure plate that needs Jonathan's weight plus Charlotte's magic activation, for example.
- **LLM Automation:** Manages partner AI (follows player with configurable distance, auto-attacks enemies within radius, casts spells when enemy in range and MP sufficient), handles HP and MP pools separately per character, manages shared inventory versus character-specific equipment loadouts, triggers combo attacks when both characters attack the same target simultaneously (bonus damage and special effects), handles the instant switch state transfer (camera focus, control input routing, active character flag), and manages dual-character puzzle validation (ensures levels with swap mechanics are solvable).
- **JSON Contract Extension:**
```json
{
  "characters": [
    {"id": "jonathan", "role": "warrior", "stats": {"str": 12, "int": 4}, "equipment": {}},
    {"id": "charlotte", "role": "mage", "stats": {"str": 5, "int": 14}, "equipment": {}}
  ],
  "switchCooldown": 0.5,
  "partnerAI": {"followDist": 80, "attackRadius": 120, "spellTrigger": "enemyInRange"},
  "dualCombos": [{"condition": "bothAttackSameTarget", "bonusDamage": 1.5, "effect": "elementalBurst"}]
}
```

#### AI Buddy Pathfinding

- **Source Game:** *Sonic the Hedgehog* (Tails AI) / *Portrait of Ruin* (partner AI)
- **Description:** The underlying AI system that makes all buddy and companion characters feel alive. Buddies follow the player with a slight, charming lag — they don't teleport to position but run, jump, and navigate obstacles to catch up. The AI avoids hazards (pits, spikes, enemies when low HP), takes shortcuts when possible, and activates context-appropriate abilities (flying over gaps, climbing walls, attacking enemies). Buddy AI has three modes: **Follow** (stay near player), **Attack** (engage enemies aggressively), and **Stay** (hold position). Mode can be toggled via a simple command wheel.
- **Kid UX:** The buddy character simply follows and helps — no complex commands needed. When the player jumps, the buddy jumps shortly after. When the player attacks, the buddy attacks the same target. If the buddy falls behind too far, a quick warp with a sparkle brings them back. Tapping the buddy opens a **command wheel** with three icons: a heart for Follow, a sword for Attack, a flag for Stay. The buddy's current mode is shown as a small icon above their head. The buddy never gets stuck for more than 3 seconds — the LLM ensures reliable pathfinding with automatic warp as fallback. Buddy AI behavior is invisible magic — kids just see a helpful friend who always seems to know what to do.
- **LLM Automation:** Implements A* pathfinding with platforming awareness (the buddy plans jump trajectories, not just flat ground paths), handles hazard avoidance (pits detected via raycast, enemies avoided when buddy HP below 25%), manages follow behavior with smooth acceleration/deceleration and slight intentional lag (0.3-0.5 seconds) for organic feel, handles automatic catch-up warp when buddy is off-screen for more than 3 seconds, implements mode-specific AI (Follow = stay within 100px, Attack = seek and destroy enemies within 200px, Stay = hold position and only attack enemies that approach), and manages buddy animation state mirroring (jump when player jumps, attack when player attacks) with natural timing variation.
- **JSON Contract Extension:**
```json
{
  "buddyAI": {
    "pathfinding": "aStarWithPlatforming",
    "hazardAvoidance": true,
    "followLag": 0.5,
    "catchupWarpDelay": 3.0,
    "modes": {
      "follow": {"targetDist": 100, "engageEnemies": false},
      "attack": {"seekRadius": 200, "engageEnemies": true, "priority": "nearestEnemy"},
      "stay": {"holdPosition": true, "engageEnemiesInRange": 50}
    },
    "autoJump": true,
    "autoAttack": true,
    "lowHpRetreat": 0.25
  }
}
```

#### Co-op Puzzle Pressure Plates

- **Source Game:** *Portal 2* / *Zelda: Four Swords* (cooperative puzzles requiring multiple characters)
- **Description:** Special puzzle elements that require two or more characters to activate simultaneously. **Pressure Plates** must have both players (or the player and their buddy) standing on them at the same time to open doors or trigger events. **Heavy Switches** need the combined weight of the player plus Pikmin or a buddy to depress. **Dual Levers** must be pulled simultaneously by two characters. **Light Beams** need one character to hold a mirror while the other stands on an activation tile. These puzzles naturally encourage co-op play and make having a buddy feel essential rather than optional.
- **Kid UX:** The child stamps **Pressure Plate** pairs that are color-matched (both red, both blue). When one plate is stepped on, it glows halfway; when both are activated, they glow fully and a connecting energy beam appears between them. **Heavy Switches** show a weight number — the player's weight is 1, each Pikmin adds 0.1, and a buddy adds 1. The switch depresses when enough weight is applied. **Dual Levers** show left and right positions with big hand icons. During co-op, each player naturally goes to one lever. Solo players can command their buddy to hold a lever via the command wheel. Puzzle solutions trigger dramatic results: doors slide open, bridges extend, treasures rise from the ground.
- **LLM Automation:** Detects simultaneous activation state for all paired puzzle elements (pressure plates, levers, switches), calculates combined weight for heavy switches (player weight + buddy weight + Pikmin count × 0.1), validates that paired elements are both active before triggering the result, handles the visual connection beam between paired elements (pulses when partially active, solid when fully active), generates appropriate puzzle result animations (door open, bridge extend, treasure rise), ensures co-op puzzles are solvable in single-player mode via buddy command or Pikmin weight, and auto-validates that paired elements have valid paired targets (no orphaned plates or levers).
- **JSON Contract Extension:**
```json
{
  "coopPuzzles": {
    "pressurePlates": [
      {"id": "plateA", "pairId": "redPair", "position": {"x": 100, "y": 300}, "weightRequired": 1},
      {"id": "plateB", "pairId": "redPair", "position": {"x": 500, "y": 300}, "weightRequired": 1}
    ],
    "heavySwitches": [
      {"id": "heavy1", "weightRequired": 2.5, "currentWeight": 0}
    ],
    "dualLevers": [
      {"id": "leverPair1", "leftPosition": {"x": 200, "y": 400}, "rightPosition": {"x": 400, "y": 400}}
    ],
    "result": {"type": "openDoor", "targetId": "puzzleDoor1"}
  }
}
```

#### Companion Revival System

- **Source Game:** *Monster Hunter* (Palico revive vigorwasp) / *Left 4 Dead* (teammate revival)
- **Description:** When a companion's HP reaches zero, they don't die permanently — instead, they enter a **Downed State** where they crawl slowly and cannot attack. The player (or another companion) has 30 seconds to reach the downed companion and hold a **"Revive!"** button to bring them back with 25% HP. If not revived in time, the companion retreats to the last safe point and must be re-summoned or found. This system keeps companions feeling durable while creating dramatic "save your friend!" moments that kids find emotionally engaging.
- **Kid UX:** When a companion's HP hits zero, a dramatic **"Oh no!"** sound plays, the companion falls with a sad animation, and a **countdown timer** (30 seconds) appears above them as a shrinking red circle. The companion crawls slowly toward the player with a *"Help!"* speech bubble. The player runs over and holds the **Revive** button (big heart icon) for 2 seconds — a healing beam connects player to companion, and the companion stands up with 25% HP and a grateful **"Thanks!"** animation. If revival fails, the companion fades with sparkles and reappears at the last checkpoint. The countdown timer creates genuine urgency without being punishing.
- **LLM Automation:** Detects companion HP reaching zero, triggers downed state (disables attacks, reduces movement speed to crawl, enables revive interaction), manages the 30-second countdown timer with visual shrinking circle and escalating warning sounds at 10 seconds, handles the revival interaction (player within 50px + revive button held for 2 seconds = companion restored to 25% HP with invincibility frames), implements retreat behavior if countdown expires (companion fades, respawns at last checkpoint or Onion), prevents permanent companion death (all companions are revivable or respawnable), and manages companion AI during downed state (crawl toward player at 20% normal speed).
- **JSON Contract Extension:**
```json
{
  "companionRevival": {
    "downedDuration": 30,
    "reviveHoldTime": 2.0,
    "reviveHpPercent": 0.25,
    "reviveRange": 50,
    "invincibilityAfterRevive": 3.0,
    "crawlSpeedMultiplier": 0.2,
    "respawnIfNotRevived": true,
    "respawnLocation": "lastCheckpoint"
  }
}
```

---

## 4.5 Living World & Ecosystem

These features create self-sustaining creature populations that evolve, breed, and react to the player's behavior — making the game world feel like a living ecosystem rather than a static stage.

#### Nightopian A-Life Ecosystem

- **Source Game:** *NiGHTS into Dreams* (A-Life system — Nightopian creatures with moods, breeding, evolution)
- **Description:** Small creatures called **Dreamlings** inhabit the level autonomously. They have simple AI-driven lives: wandering, eating found items, sleeping at night, fleeing from danger, and breeding when happy. The player's behavior directly affects their mood — being friendly (feeding, not attacking) makes them happy and they multiply; being aggressive scares them and they hide in burrows. Over multiple playthroughs, the population evolves — colors shift, behaviors adapt, and the ecosystem becomes unique to that player's interaction history. Happy Dreamlings give the player bonus points and sometimes drop helpful items. This system makes every level feel like a living world.
- **Kid UX:** The child stamps **Dreamling Nests** (small burrows in the ground or trees where creatures spawn) and **Dreamling Food** sources (berry bushes, flower patches). During play, cute little creatures wander around with visible mood indicators: **heart bubbles** = happy, **sweat drops** = scared, **Zzz** = sleeping, **music notes** = breeding. Breeding produces baby Dreamlings with mixed parent colors. The ecosystem runs autonomously — the child can observe without interacting. Tapping a Dreamling pets it, increasing happiness. The population is capped at 20 per level to prevent performance issues. A **population meter** in the corner shows current count and average mood.
- **LLM Automation:** Implements each Dreamling's AI state machine (wander when happy, eat when food nearby, sleep during night phases, flee when player attacks or enemies approach, breed when happiness > 0.7 and partner nearby), tracks mood and population across play sessions (persisted per level), handles breeding logic (color blending between parents, trait inheritance with small random mutations), generates evolutionary variations over time (colors shift toward dominant parent hues, behaviors become more docile if player is friendly), implements mood-based player interactions (happy Dreamlings approach player, scared ones flee, neutral ones ignore), manages population cap enforcement (breeding pauses when at maximum), and handles reward drops from happy Dreamlings (bonus points, occasional item drops).
- **JSON Contract Extension:**
```json
{
  "aLifeEcosystem": {
    "creatureName": "dreamling",
    "aiStates": ["wander", "eat", "sleep", "flee", "breed"],
    "moodFactors": ["playerFriendliness", "foodAvailability", "populationDensity", "enemyProximity"],
    "breeding": {"requiresHappiness": 0.7, "colorInheritance": "blend", "mutationChance": 0.1},
    "evolution": "generationalOverSessions",
    "playerRewards": "moodBased",
    "populationCap": 20,
    "foodSources": ["berryBush", "flowerPatch"],
    "sleepSchedule": "nightTime"
  }
}
```

#### Creature Evolution & Breeding Lab

- **Source Game:** *Pokemon* (evolution lines) / *Monster Hunter* (creature breeding)
- **Description:** A dedicated **Breeding Lab** stamp allows the player to combine two companion creatures or tamed monsters to produce offspring with inherited traits. The baby inherits the primary type from Parent A and the secondary ability from Parent B, with a chance of random **mutation** — a completely new trait neither parent had. As creatures gain experience through combat, they **evolve** through visual stages: Stage 1 (baby) → Stage 2 (juvenile) → Stage 3 (adult) → Stage 4 (elder, optional). Each evolution changes the creature's sprite, size, and unlocks a new ability. Evolution is triggered at experience thresholds and celebrated with a transformative animation.
- **Kid UX:** The child stamps a **Breeding Lab** building (cute science lab with heart decorations). Tapping it opens a **pairing screen** showing all available creatures as portrait cards. The child drags two cards into the parent slots. A **prediction preview** shows the likely offspring type and a question mark for potential mutations. Tapping **"Breed!"** starts a short animation — the two creatures dance together, a baby creature hatches from an egg with a mix of both parents' colors. For evolution, creatures gain stars as they fight. At 3 stars, an **"Evolve!"** prompt appears — tapping it triggers the evolution sequence: the creature glows, transforms, and emerges bigger and more impressive. Evolution is irreversible and deeply satisfying.
- **LLM Automation:** Manages the breeding algorithm (primary type from Parent A, secondary ability from Parent B, 15% mutation chance producing a random new trait), handles offspring generation (procedural sprite compositing blending parent colors and features at 50/50 ratio), implements experience tracking per creature with automatic star gain on combat participation, manages evolution triggers at threshold checks (Stage 2 at 3 stars, Stage 3 at 8 stars, Stage 4 at 15 stars), generates evolution transformation animations (glow → sprite swap → particle burst → new form), handles mutation trait assignment from a pool of rare abilities, and manages the breeding cooldown (parents cannot breed again for 5 minutes, shown as a sleeping icon).
- **JSON Contract Extension:**
```json
{
  "breedingLab": {
    "parents": [{"id": "creatureA"}, {"id": "creatureB"}],
    "offspring": {
      "primaryType": "parentA",
      "secondaryAbility": "parentB",
      "mutationChance": 0.15,
      "mutationPool": ["rareFire", "rareIce", "rareLightning", "rareHeal"]
    },
    "evolution": {
      "stages": [
        {"stage": 1, "name": "baby", "starThreshold": 0},
        {"stage": 2, "name": "juvenile", "starThreshold": 3},
        {"stage": 3, "name": "adult", "starThreshold": 8},
        {"stage": 4, "name": "elder", "starThreshold": 15}
      ]
    },
    "breedCooldown": 300
  }
}
```

#### Companion Command Wheel

- **Source Game:** *Final Fantasy XII* (Gambit system simplified) / *Pikmin* (command whistle)
- **Description:** A radial command menu that gives the player direct control over companion and pet behaviors. The wheel appears when the player taps and holds on a companion, displaying context-sensitive commands: **Attack** (target the nearest enemy), **Stay** (hold position), **Follow** (return to following), **Use Ability** (trigger the companion's special skill), **Heal Me** (companion uses healing item if available), **Fetch** (grab a distant item). Commands are represented as large, colorful icons that even pre-readers can understand. The command wheel puts the player in the role of a leader directing their team.
- **Kid UX:** The child **taps and holds** on any companion — a radial **Command Wheel** appears around the companion with 4-6 large icons: a sword for Attack, a flag for Stay, a heart for Follow, a star for Use Ability, a potion for Heal, a hand for Fetch. Releasing the finger on an icon executes the command. The companion responds with a happy acknowledgment animation and a small speech bubble showing the command icon (e.g., a sword bubble = "I'll attack!"). The command wheel only shows actions the companion can actually perform in the current context — if no enemies are near, the Attack icon is dimmed. Commands are learned through experimentation; the LLM tracks which commands a child uses most and puts those icons in the most accessible positions.
- **LLM Automation:** Generates the radial command wheel UI with context-sensitive icon availability (Attack only shown when enemies in range, Heal only when companion has healing ability and player HP < 100%, Fetch only when items in range), handles command execution and companion AI state switching (Attack = seek and destroy nearest enemy, Stay = disable movement and hold position, Follow = resume follow AI, Use Ability = trigger companion's equipped special), manages command acknowledgment (companion plays reaction animation + speech bubble), tracks command usage frequency for UI personalization, and ensures the command wheel appears within 0.2 seconds of tap-and-hold for responsive feel.
- **JSON Contract Extension:**
```json
{
  "commandWheel": {
    "commands": [
      {"id": "attack", "icon": "sword", "context": "enemyInRange"},
      {"id": "stay", "icon": "flag", "context": "always"},
      {"id": "follow", "icon": "heart", "context": "notAlreadyFollowing"},
      {"id": "useAbility", "icon": "star", "context": "abilityOffCooldown"},
      {"id": "heal", "icon": "potion", "context": "playerHpBelow100"},
      {"id": "fetch", "icon": "hand", "context": "itemInRange"}
    ],
    "appearDelay": 0.2,
    "contextSensitive": true,
    "trackUsage": true,
    "acknowledgeAnimation": true
  }
}
```

---

## Comparison Tables

### Companion System Comparison

| System | Source | Role | Combat? | Customizable? | Kid Appeal |
|--------|--------|------|---------|--------------|------------|
| Familiar | *Castlevania* | Passive assist | Limited | Level-up only | High — floating pet |
| Helper (Converted Enemy) | *Kirby* | Active fighter | Yes | Inherits enemy ability | Very High — enemy becomes friend |
| Spirit Summon | *Elden Ring* | Timed ally | Yes | Type selection | High — crystal magic |
| Palico | *Monster Hunter* | Full combat partner | Yes | Full gear + gadget | Very High — customizable cat |
| Rush Adapter | *Mega Man* | Transformation tool | No | Form selection | Very High — robot dog |
| Dream Eater | *Kingdom Hearts 3D* | Created companion | Yes | Full creation system | Very High — make your own |
| Soul Absorption | *Castlevania* | Ability source | Yes | Loadout system | Medium — collection focused |

### Pet & Follower Comparison

| System | Source | Acquired By | Provides | Limit |
|--------|--------|-------------|----------|-------|
| Animal Feeding | *Okami* | Give preferred food | Stat boosts + treasure | 3 slots |
| Monster Taming | *DQ Builders 2* | Friendship token at barn | Combat + mounts | Barn capacity |
| Pikmin Squad | *Pikmin* | Sprout from Onion | Combat + carrying | 100 total |
| Pikmin Types | *Pikmin* | Color-specific Onion | Elemental abilities | Type-distributed |

### Co-op & Combo Comparison

| System | Source | Players | Trigger | Effect |
|--------|--------|---------|---------|--------|
| Buddy Stamps | *Sonic/Secret of Mana* | 1P + AI | Context prompt | Traversal assist |
| Triple-Tech | *Chrono Trigger* | 1P + 2 AI | Fusion Crystal | Cinematic mega-attack |
| Double-Tech | *Chrono Trigger* | 1P + 1 AI | Proximity attack | Combined attack |
| Local Co-op | *Mario Maker 2* | 2P human | Drop-in anytime | Shared screen play |
| Dual-Character | *Portrait of Ruin* | 1P (swappable) + AI | SWAP button | Two distinct playstyles |
| Buddy AI | *Sonic* | 1P + AI | Automatic | Follow + auto-attack |

### Squad Management Comparison

| Feature | Source | Unit Count | Core Commands | Primary Use |
|---------|--------|------------|--------------|-------------|
| Pikmin Squad | *Pikmin* | Up to 100 | Throw, whistle, swarm | Combat + carrying |
| Pikmin Types | *Pikmin* | 8 variants | Type-distributed | Elemental puzzles |
| Pikmin Carry | *Pikmin* | Variable per object | Auto-assign to carry points | Object transport |
| A-Life Ecosystem | *NiGHTS* | Up to 20 | Indirect (mood-based) | Living world simulation |
