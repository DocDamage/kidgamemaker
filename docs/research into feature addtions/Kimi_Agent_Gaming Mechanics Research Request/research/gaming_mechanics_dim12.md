## Dimension 12: Roguelike Elements, Replayability & Meta-Progression

### Executive Summary

This research report investigates how roguelike mechanics and meta-progression systems can be ethically adapted for a stamp-based, zero-code game creation platform designed for children as young as 5. Drawing from 25+ independent research queries across authoritative sources including GDC materials, academic papers, game postmortems, and official documentation, this report provides a comprehensive analysis of how to drive long-term engagement without resorting to exploitative practices.

The core finding is that **meta-progression for children must be grounded in Self-Determination Theory (SDT)** -- fulfilling the three innate psychological needs of autonomy (choice), competence (mastery), and relatedness (connection) [^632^]. When children feel intrinsically motivated to create, they return not because of fear of missing out (FOMO) or addiction mechanics, but because creation itself is joyful. The research shows that predatory systems like FIFA Ultimate Team's loot boxes and Roblox's chance-based merchandising can cause real psychological harm to children, including gambling-like behaviors, excessive spending, and gaming disorder [^642^][^595^]. Our platform must actively reject these approaches.

Instead, this report proposes a **"Creator Journey" meta-progression system** that rewards creation itself. Children earn "Creator XP" by placing stamps, completing daily creation challenges, and exploring new stamp combinations. New stamp packs unlock through creative achievements ("Make a game with 5 different enemies"), not time gates or payments. Daily challenges inspire new creative directions rather than demanding login. The "Creator Hub" grows visually as children progress -- adding decorations, new themes, and personalization options. This approach mirrors the ethical, open-ended design philosophy of Sago Mini ("no rules, no time limits, no points") [^637^] while incorporating the satisfying progression loops that make games like Hades [^623^], Dead Cells [^544^], and Rogue Legacy [^599^] so engaging for older audiences.

### Studio Innovations Analysis

#### Motion Twin (Dead Cells): The Roguevania Progression Model

**How It Works:** Dead Cells combines roguelike permadeath with Metroidvania-style permanent ability unlocks. Players collect "cells" during runs which persist after death and can be spent on permanent upgrades including: health flask charges, gold reserves, random starting weapons, and most importantly -- Runes that grant new traversal abilities (vine climbing, teleportation, wall-jumping) [^544^]. These Runes unlock entirely new biomes, creating a sense of genuine progression. The game also features a daily challenge mode (Challenger's Rune) where all players compete on the same procedurally-generated seed [^544^].

**Technical Implementation:** Dead Cells uses a hybrid approach: hand-crafted room templates stitched together procedurally. Each biome has a pool of pre-designed rooms that are connected via graph algorithms, ensuring valid paths from entrance to exit [^596^]. The seed system ensures reproducibility -- the same 8-character seed always generates the same level, loot, and enemy placements [^596^].

**Stamp-Based Adaptation - "Creation Runs":**
Instead of combat runs, children go on "Creation Expeditions." Each day, a new "Mystery Island" is procedurally generated using a daily seed (ensuring all children see the same layout). The island contains hidden stamp "fragments" -- discovering them adds new stamps to the child's collection. This mirrors Dead Cells' exploration-reward loop but replaces combat with discovery and creation.

The "permanent upgrades" become "Creator Tools" -- quality-of-life features that unlock gradually: undo/redo, copy-paste stamps, color palette customization, and eventually "Magic Brushes" that transform groups of stamps. These aren't power-ups that make the child "better" at creating -- they're tools that expand what's possible, similar to how Dead Cells' Runes expand where you can go.

#### Red Hook Studios (Darkest Dungeon): The Growing Hub Model

**How It Works:** In Darkest Dungeon, players upgrade the "Hamlet" -- a town that serves as their base between dungeon runs. Key buildings include the Stage Coach (recruits heroes), the Blacksmith (upgrades weapons/armor), the Guild (trains hero abilities), the Sanitarium (treats afflictions), and the Tavern/Abbey (reduces stress) [^564^]. Each upgrade requires resources gathered during runs and permanently improves the player's capabilities. Town Events add variety -- random occurrences that might bring extra recruits, temporary facility closures, or special bonuses [^564^].

**Technical Implementation:** The Hamlet is essentially a persistent skill tree with visual representation. Each building has multiple upgrade tiers requiring specific resources. The system creates long-term goals beyond individual dungeon runs -- even a failed run contributes if it gathered resources.

**Stamp-Based Adaptation - "Creator Village":**
Children have a personal "Creator Village" that grows as they create. Starting with a simple treehouse, they add new buildings: a "Stamp Garden" (displays collected stamps), a "Challenge Tower" (daily creation challenges), a "Gallery" (showcases their best games), a "Friends Plaza" (shares creations with family), and a "Treasure Chest" (stores rewards).

Each building upgrades visually as children create more games. The "Stamp Garden" sprouts more flowers as stamps are collected. The "Challenge Tower" grows taller as daily challenges are completed. This creates a tangible, visual representation of creative progress -- children can see their village grow, making every creative act feel meaningful.

Town Events become "Surprise Days" -- special occasions where a new character visits the village offering a unique challenge or gift. These are not time-limited (no FOMO) -- they trigger based on creation milestones, not calendar dates.

#### Nintendo (Animal Crossing): Daily Discovery Without Pressure

**How It Works:** Animal Crossing: New Horizons uses a real-time clock where content unfolds gradually. Each day brings: new fossils to dig up, rotating stock at Nook's Cranny, seasonal events, visiting NPCs (like K.K. Slider, Gulliver), and Nook Miles tasks that refresh daily [^626^]. The key psychological insight is that **limited daily content creates anticipation rather than obligation** -- players look forward to tomorrow's discoveries, not dread missing them.

**Technical Implementation:** The game uses the system clock to determine daily content rotations. Nook Miles+ tasks are procedurally selected from a pool each day. Special visitors follow schedules with some randomness. Seasonal content is date-locked but never expires -- it returns next year.

**Stamp-Based Adaptation - "Daily Surprises":**
Each day, children find 2-3 "mystery stamps" hidden in their Creator Village -- new stamps they haven't seen before. These are always discovery-based (finding them is fun) and never time-limited (if a child doesn't log in for a week, the stamps accumulate). A "Daily Discovery" section highlights what's new: "Today you found a PIRATE SHIP stamp! Try making a pirate game!"

This mirrors Animal Crossing's daily rotation but removes all pressure. There's no "daily streak" to maintain. Missing days doesn't penalize -- it just means more surprises waiting when they return. The "Nook Miles" equivalent is "Creator Badges" -- achievements for trying new things: "First Game with Water," "Made a Game with 10 Stamps," "Created a Maze."

#### Mojang (Minecraft): Creation as Its Own Reward

**How It Works:** Minecraft Creative Mode gives players infinite resources, flight, invulnerability, and access to all blocks [^567^]. There are no goals, no scores, no unlocks -- the motivation is purely intrinsic. Players build because building is satisfying. The game supports this with: instant block placement/destruction, a comprehensive inventory of all items, and the ability to share creations with others.

**Technical Implementation:** Creative Mode works by setting a flag that disables hunger/health systems, enables flight, and grants unlimited block access. The inventory becomes a searchable catalog of all available items. World saves persist locally or on servers.

**Stamp-Based Adaptation - "Free Play Mode":**
The platform always has a "Free Play" area where every stamp ever collected is available -- no restrictions. This is the child's always-open sandbox. Meta-progression exists in the surrounding structure (unlocking new stamps, village growth, challenges) but never gates the core creative experience. Even a brand-new player can create freely with their starter stamps.

The key insight from Minecraft is that **creation itself is intrinsically motivating** when the tools are good and the process is joyful [^632^]. Our platform's job is to expand the palette of available tools (stamps) while ensuring the core creative act always feels rewarding on its own.

#### Hades / Supergiant Games: Narrative Meta-Progression

**How It Works:** Hades features the "Mirror of Night" -- a meta-progression system where players spend "Darkness" (collected during runs) on permanent stat upgrades [^623^]. What makes Hades special is how meta-progression ties into narrative: each death advances the story through new dialogue with NPCs. The player isn't just upgrading stats -- they're building relationships and uncovering lore. The Mirror offers branching choices (red vs. green upgrades) that can be swapped freely, allowing experimentation [^623^].

**Technical Implementation:** The Mirror is a persistent data structure tracking Darkness spent and upgrades unlocked. The "Chthonic Key" system gates which upgrades are available, creating a secondary progression layer. The ability to refund all Darkness with a single key encourages experimentation [^623^].

**Stamp-Based Adaptation - "Story of Creation":**
As children create games, they unlock story segments featuring a cast of friendly characters who react to their creations. A robot companion comments on mechanical stamps: "Wow, you used 5 gears in that game! You're becoming a real engineer!" A fairy character celebrates artistic choices: "Those flowers you placed are so beautiful!"

This "narrative progression" provides emotional rewards without gameplay advantages. The characters become friends who celebrate the child's creativity. Like Hades' NPC relationships, these conversations evolve based on what the child creates, making each return feel like visiting friends who are excited to see what you've made.

#### Super Mario Maker: Gradual Tool Unveiling

**How It Works:** Super Mario Maker originally unlocked its 60+ level creation tools over 9 days of play [^579^]. Players had to use each new tool in a level and then wait for the next day's delivery. While controversial among adult players, this gradual unveiling prevents overwhelm for newcomers. Story Mode in Mario Maker 2 adds unlockable power-ups earned by completing Nintendo-designed levels [^577^].

**Technical Implementation:** The unlock system uses a simple timer: after 5 minutes of creation activity, the next batch of tools is queued for "delivery tomorrow" (next calendar day) [^579^]. The system tracks which tools have been placed at least once to encourage experimentation.

**Stamp-Based Adaptation - "Stamp Deliveries":**
New stamp packs arrive as "gifts" from the Creator Village characters -- not as time gates, but as earned rewards. When a child consistently uses certain stamp types, new related stamps "arrive": using many animal stamps unlocks more animals; building water-themed games unlocks sea creature stamps.

Unlike Mario Maker's forced waiting, our system is responsive: if a child shows interest in a theme, new stamps arrive quickly (within the same session). The gating is based on engagement patterns, not calendar dates. A child who loves space stamps gets more space stamps -- not in 9 days, but after placing their 10th space stamp.

#### Scribblenauts: Merit-Based Exploration Rewards

**How It Works:** Scribblenauts features 76+ "Merits" -- achievements for creative experimentation [^576^]. Merits reward players for trying new things: writing completely new objects, combining items in unusual ways, solving puzzles without weapons, riding animals, putting out fires, etc. Each Merit awards "Ollars" (currency) and celebrates creative thinking.

**Technical Implementation:** Merits are tracked via an achievement system that monitors gameplay events: object types spawned, completion methods, combinations tried, etc. Some Merits are hidden (surprise achievements), while others have clear descriptions that hint at what's possible [^576^].

**Stamp-Based Adaptation - "Creator Merits":**
A merit system specifically rewards creative experimentation:
- "First Steps" -- Place your first stamp
- "Storyteller" -- Create a game with 5 different stamp types
- "Architect" -- Build a structure with 10+ stamps
- "Mixer" -- Use stamps from 3 different themes in one game
- "Tester" -- Playtest your game 5 times
- "Sharer's Delight" -- Share a game with a family member

Merits are always positive (no penalties) and encourage exploration of the platform's creative possibilities. They award "Sparkles" (cosmetic currency) for decorating the Creator Village -- never gameplay advantages.

#### Sago Mini: Open-Ended Play Philosophy

**How It Works:** Sago Mini games have no rules, no time limits, no points, and no in-app purchases for subscribers [^637^][^633^]. The design philosophy centers on "open-ended play" where children explore at their own pace, tell their own stories, and engage with charming characters [^633^]. Weekly playtesting with real children ensures the games produce "belly laughs" [^640^].

**Technical Implementation:** Sago Mini games use a "toy-like" interaction model: touch-responsive objects, physics-based reactions, and emergent combinations. There are no win/lose states, no score counters, and no progression gates. Characters respond emotionally to interactions, creating narrative through play [^633^].

**Stamp-Based Adaptation - "Play-First Design":**
The platform's core philosophy aligns with Sago Mini: creation should feel like play, not work. All stamps are playful -- they animate, make sounds, and interact with each other. A placed "dragon" stamp breathes fire when tapped, a "cloud" stamp rains when touched, a "car" stamp drives when pushed.

There are no "fail states" in creation. If a child places stamps that don't work together, the LLM backend suggests gentle alternatives: "That dragon looks lonely! Try adding a treasure for it to guard!" The platform celebrates every creation, no matter how simple.

#### Media Molecule (Dreams/LittleBigPlanet): Community Creation Showcase

**How It Works:** Dreams for PS4 allows players to create games, art, music, and animations using powerful tools [^645^]. The "DreamSurfing" mode lets players browse and play others' creations [^645^]. "Prize Bubbles" in levels unlock new assets for creators [^645^]. "Community Jam" hosts themed contests where creators compete and vote [^645^]. However, Dreams faced criticism for lacking creator monetization and exposure tools [^644^].

**Technical Implementation:** Dreams uses an "imp" cursor for interaction, with modes for Assembly (stamping pre-made assets), Sculpting (3D modeling), and Sound creation. Gadgets provide game logic through visual scripting. The "Dreamiverse" is a content server hosting all creations [^645^].

**Stamp-Based Adaptation - "Gallery of Wonders":**
A curated showcase of games created by the community (other children, with parental consent). Children can play others' games and "collect" stamps they see -- adding those stamps to their own collection. This creates a virtuous cycle: playing inspires new creation, which others then play.

Weekly "Theme Jams" provide creative prompts: "Make a game about SPACE!" or "Create something with WATER stamps!" Participation awards a special badge, but there are no winners or losers -- every entry is celebrated and showcased.

### Key Findings

1. **Self-Determination Theory (SDT) is the ethical foundation for child engagement.** Research consistently shows that fulfilling children's innate needs for autonomy (choice), competence (mastery), and relatedness (connection) produces healthy, sustainable engagement [^632^][^634^]. Platforms that rely on extrinsic motivators alone (rewards, punishments) undermine intrinsic motivation and can cause children to view creative activities as chores [^634^].

2. **Meta-progression should expand creative possibility, not player power.** Games like Hades and Dead Cells use meta-progression to unlock new areas and abilities [^623^][^544^]. For a creation platform, this translates to unlocking new stamp types, tools, and themes -- not making the child "better" at creating, but giving them more creative options.

3. **Daily content should be delightful, not demanding.** Animal Crossing's daily rotations create anticipation, but missing a day causes no penalty [^626^]. This is the ethical model for daily engagement. Contrast this with Clash of Clans, where players feel compelled to log in to protect their bases from attack -- this creates stress and has been linked to gaming addiction [^646^].

4. **Predatory monetization in children's games causes measurable harm.** Studies link loot boxes to problem gambling behaviors in adolescents [^595^]. Roblox's chance-based merchandising (mystery boxes, spin wheels) has been criticized as "de facto gambling" targeting children [^595^]. FIFA Ultimate Team's pack-opening mechanics exploit the "near miss effect" to drive spending [^643^]. Our platform must completely avoid these systems.

5. **Procedural generation can create infinite content from stamp combinations.** Wave Function Collapse (WFC) algorithms can generate valid game levels from stamp sets by ensuring spatial consistency [^596^]. Daily challenges can use seeded procedural generation to give all children the same "daily puzzle" while maintaining variety over time [^605^].

6. **Gradual unlocking prevents overwhelm and maintains engagement.** Super Mario Maker's controversial 9-day unlock schedule had a valid psychological basis: too many choices overwhelm children [^579^]. However, the gating mechanism should respond to engagement, not calendar dates. When a child shows interest in a stamp type, new related stamps should unlock quickly.

7. **Narrative progression provides emotional rewards without gameplay advantages.** Hades' story unfolds through repeated play, giving emotional meaning to each attempt [^625^]. A cast of friendly characters who react to children's creations provides intrinsic motivation without any addictive mechanics.

8. **Creation itself is the most powerful reward.** Minecraft's Creative Mode proves that infinite resources and no goals can sustain engagement indefinitely when the tools are satisfying to use [^567^]. The platform's job is to expand the creative palette, not impose artificial scarcity.

9. **Open-ended play without rules or scores produces creative confidence.** Sago Mini's philosophy of "no rules, no time limits, no points" allows children to explore freely and develop storytelling skills [^633^]. The platform should always have a "Free Play" mode with no objectives.

10. **Ethical design for children prioritizes well-being over engagement metrics.** COPPA compliance requires minimizing data collection, providing parental controls, and ensuring safety by default [^580^][^545^]. The ethical framework demands celebrating progress without manufacturing FOMO, using delight to reinforce learning (not manipulation), and designing with parents rather than against them [^545^].

### Child-Friendly Simplifications

#### Simplifying Dead Cells' "Run" Concept
Instead of combat runs with permadeath, children go on "Discovery Adventures." Each adventure is a pre-made challenge (like "Help the bunny find its carrots") where they place stamps to solve a puzzle. Completing the adventure earns "Sparkles" for their village. There's no failure -- only different outcomes. If the bunny doesn't find all carrots, it still finds some, and the child earns partial rewards.

#### Simplifying Darkest Dungeon's "Town Upgrades"
The "Creator Village" grows automatically as children create. No complex resource management -- the village simply becomes more beautiful and populated. New buildings appear when milestones are reached: the "Gallery" appears after creating 5 games, the "Challenge Tower" after completing 3 daily challenges. Each new building is a celebration with confetti, music, and a friendly character moving in.

#### Simplifying Hades' "Mirror Upgrades"
Instead of stat upgrades, children unlock "Creative Powers" -- new abilities that make creating more fun: "Rainbow Brush" (paint stamps any color), "Stamp Copy" (duplicate any stamp), "Magic Wand" (transform stamps into related ones). These are purely creative tools, not power-ups. A child with Rainbow Brush isn't "better" at creating -- they just have more color options.

#### Simplifying Animal Crossing's "Daily Tasks"
Daily content appears as surprises, not obligations. A friendly character might say "I found something new! Come see when you're ready!" There are no streaks, no timers, no "log in every day or lose progress." Missing days simply means more surprises waiting. The psychological hook is anticipation ("What will I find next time?") not anxiety ("I must log in today").

#### Simplifying Scribblenauts' "Merits"
Merits become "Smile Stones" -- simple, visual celebrations of trying new things. When a child first places a dragon stamp, a friendly character says "Wow, a dragon! That's amazing!" and a Smile Stone appears in their collection. These are never tied to power or currency -- they're purely mementos of creative exploration.

### Recommended Features

#### Priority 1: Core Meta-Progression

**1. Creator XP & Level System**
- Children earn XP by: placing stamps (+1 XP each), completing games (+10 XP), trying new stamps (+5 XP), sharing games (+20 XP), playing daily challenges (+15 XP)
- Level thresholds increase slowly: Level 2 at 50 XP, Level 3 at 150 XP, Level 4 at 300 XP, etc.
- Leveling up triggers a celebration animation and unlocks a new stamp theme (e.g., Level 2 = Space stamps, Level 3 = Ocean stamps)
- No maximum level -- but progression slows significantly after Level 20 to avoid endless grinding

**2. Stamp Collection & Unlocking**
- Stamp packs organized by themes: Animals, Vehicles, Fantasy, Nature, Buildings, People, Food, Space, Underwater, Robots
- New stamps unlock through CREATION, not time: using 10 animal stamps unlocks the Safari pack; creating a water game unlocks the Ocean pack
- "Mystery Stamps" appear daily in the Creator Village -- 2-3 random stamps that the child hasn't collected yet
- All stamps are always available in Free Play mode once collected

**3. Creator Village (Visual Progress Hub)**
- Central hub that grows with the child's creative journey
- Buildings unlock at milestones: Treehouse (start), Stamp Garden (10 stamps), Gallery (5 games), Challenge Tower (3 challenges), Friends Plaza (first share), Theater (10 games played by others)
- Each building is visually customizable with earned decorations
- The village serves as the main navigation hub -- tap buildings to access features

**4. Daily Creation Challenge**
- A new creative prompt each day: "Make a game with a DRAGON and a CASTLE!" or "Create an underwater adventure!"
- Challenges suggest specific stamps but never require them -- alternatives always work
- Completing a challenge earns a "Challenge Star" (cosmetic) and a bonus Mystery Stamp
- No streak system -- missing challenges causes no penalty
- The same challenge is available for 3 days, so children never miss one due to timing

#### Priority 2: Engagement Systems

**5. Theme Jams (Weekly Events)**
- Weekly creative theme: "Space Week!", "Dinosaur Week!", "Magic Week!"
- Participating by creating a themed game earns a special badge
- All entries appear in a showcase gallery
- No winners or losers -- every participant gets the same reward
- Themes rotate on a predictable schedule so children can look forward to favorites

**6. Creator Badges (Achievement System)**
- Simple, positive achievements for trying new things:
  - "Explorer" -- Used stamps from 5 different themes
  - "Architect" -- Created a game with 20+ stamps
  - "Storyteller" -- Added start and end points to a game
  - "Tester" -- Played your own game 5 times
  - "Sharer's Delight" -- Shared a game with family
  - "Helper" -- Completed 10 daily challenges
- Badges appear on the child's profile and can be displayed in their village
- No hidden badges -- all are visible so children can work toward ones they want

**7. Stamp Evolution (Collectible Depth)**
- Stamps can be "leveled up" by using them repeatedly
- Level 1 "Cat" stamp is a simple cat; Level 2 adds a tail animation; Level 3 adds a purring sound
- Evolution is automatic -- no complex systems to manage
- Max level is always 3, preventing endless grinding
- Evolution encourages children to explore their favorite stamps deeply

#### Priority 3: Social & Discovery

**8. Family Gallery**
- Children can share games with family members (parent-approved contacts only)
- Family can leave voice reactions or pre-written positive comments
- Gallery shows games sorted by family member
- No public sharing -- only trusted family contacts

**9. Daily Discovery Seed**
- Each day, a "Discovery Island" is procedurally generated from the day's stamp pool
- All children who play on the same day see the same island layout
- Exploring the island reveals hidden stamps and creative ideas
- Seeds are reproducible -- children can replay favorite days
- Islands are never deleted -- they accumulate in an "Island Journal"

**10. "Inspiration Roulette"**
- A button that randomly selects 3-5 stamps and suggests: "Try making a game with THESE!"
- Always provides stamps the child already owns
- Encourages creative combinations the child might not have considered
- Can be used unlimited times -- no currency or cooldown

### Code Snippets

#### 1. Creator Level Progression System (Python)

```python
"""
Creator Level Progression System
Manages XP calculation, level thresholds, and unlock rewards.
Designed for ethical progression: no grinding, no pay-to-win.
"""
from dataclasses import dataclass, field
from typing import Dict, List, Optional
from enum import Enum
import json
from datetime import datetime, timedelta

class ActivityType(Enum):
    """Types of activities that earn XP."""
    PLACE_STAMP = "place_stamp"
    COMPLETE_GAME = "complete_game"
    TRY_NEW_STAMP = "try_new_stamp"
    SHARE_GAME = "share_game"
    COMPLETE_CHALLENGE = "complete_challenge"
    PLAY_OTHERS_GAME = "play_others_game"
    THEME_JAM_ENTRY = "theme_jam_entry"
    DAILY_LOGIN = "daily_login"  # Small bonus, not the primary driver

@dataclass
class XPReward:
    """Defines XP reward for an activity."""
    activity: ActivityType
    base_xp: int
    description: str
    daily_cap: Optional[int] = None  # Ethical: prevent grinding

# XP reward configuration - generous for creation, capped to prevent addiction
XP_REWARDS: Dict[ActivityType, XPReward] = {
    ActivityType.PLACE_STAMP: XPReward(
        activity=ActivityType.PLACE_STAMP,
        base_xp=1,
        description="Placed a stamp",
        daily_cap=100  # Max 100 stamps per day count toward XP
    ),
    ActivityType.COMPLETE_GAME: XPReward(
        activity=ActivityType.COMPLETE_GAME,
        base_xp=10,
        description="Created a playable game",
        daily_cap=10
    ),
    ActivityType.TRY_NEW_STAMP: XPReward(
        activity=ActivityType.TRY_NEW_STAMP,
        base_xp=5,
        description="First time using a stamp",
        daily_cap=None  # Unlimited discovery rewards
    ),
    ActivityType.SHARE_GAME: XPReward(
        activity=ActivityType.SHARE_GAME,
        base_xp=20,
        description="Shared a game with family",
        daily_cap=5
    ),
    ActivityType.COMPLETE_CHALLENGE: XPReward(
        activity=ActivityType.COMPLETE_CHALLENGE,
        base_xp=15,
        description="Completed a daily challenge",
        daily_cap=1  # One daily challenge = one reward
    ),
    ActivityType.PLAY_OTHERS_GAME: XPReward(
        activity=ActivityType.PLAY_OTHERS_GAME,
        base_xp=3,
        description="Played a family member's game",
        daily_cap=20
    ),
    ActivityType.THEME_JAM_ENTRY: XPReward(
        activity=ActivityType.THEME_JAM_ENTRY,
        base_xp=25,
        description="Entered a Theme Jam",
        daily_cap=1
    ),
    ActivityType.DAILY_LOGIN: XPReward(
        activity=ActivityType.DAILY_LOGIN,
        base_xp=5,
        description="Daily discovery bonus",
        daily_cap=1
    ),
}

def calculate_level_threshold(level: int) -> int:
    """
    Calculate XP needed to reach a level from the previous level.
    Uses a gentle curve that slows progression at higher levels.
    """
    if level <= 1:
        return 0
    if level <= 5:
        return 50 * (level - 1)
    if level <= 10:
        return 200 + 100 * (level - 5)
    if level <= 20:
        return 700 + 200 * (level - 10)
    # Beyond level 20, progression slows significantly
    return 2700 + 500 * (level - 20)

def total_xp_for_level(target_level: int) -> int:
    """Calculate total XP needed to reach a given level."""
    return sum(calculate_level_threshold(l) for l in range(1, target_level + 1))

@dataclass
class LevelUnlock:
    """Defines what unlocks at a specific level."""
    level: int
    unlock_type: str  # "stamp_theme", "tool", "village_building", "feature"
    unlock_id: str
    description: str

# Level unlock configuration - new content every 1-2 levels initially
LEVEL_UNLOCKS: List[LevelUnlock] = [
    LevelUnlock(1, "stamp_theme", "starter", "Starter Stamps: Basic shapes and animals"),
    LevelUnlock(2, "stamp_theme", "space", "Space Theme: Rockets, planets, aliens"),
    LevelUnlock(3, "tool", "undo_redo", "Undo/Redo: Fix mistakes easily"),
    LevelUnlock(4, "stamp_theme", "ocean", "Ocean Theme: Fish, ships, treasure"),
    LevelUnlock(5, "village_building", "stamp_garden", "Stamp Garden: Display your collection"),
    LevelUnlock(6, "stamp_theme", "fantasy", "Fantasy Theme: Dragons, castles, magic"),
    LevelUnlock(7, "tool", "stamp_copy", "Stamp Copy: Duplicate your favorite stamps"),
    LevelUnlock(8, "stamp_theme", "vehicles", "Vehicle Theme: Cars, planes, boats"),
    LevelUnlock(9, "village_building", "gallery", "Gallery: Showcase your best games"),
    LevelUnlock(10, "feature", "theme_jams", "Theme Jams: Join weekly creative events"),
    LevelUnlock(12, "stamp_theme", "dinosaurs", "Dinosaur Theme: T-Rex, Triceratops, fossils"),
    LevelUnlock(14, "tool", "rainbow_brush", "Rainbow Brush: Paint stamps any color"),
    LevelUnlock(15, "stamp_theme", "robots", "Robot Theme: Androids, gears, spaceships"),
    LevelUnlock(17, "village_building", "challenge_tower", "Challenge Tower: Daily puzzles"),
    LevelUnlock(20, "feature", "discovery_island", "Discovery Islands: Daily seeded adventures"),
]

class CreatorProgression:
    """
    Main progression manager for the creator.
    Handles XP tracking, level calculation, and unlock management.
    """
    
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.total_xp = 0
        self.current_level = 1
        self.xp_toward_next = 0
        self.daily_activity_counts: Dict[str, Dict[str, int]] = {}
        self.unlocked_items: set = {"starter"}
        self.badges_earned: set = {}
        self.first_seen_stamps: set = set()
        self.games_created = 0
        self.challenges_completed = 0
        self.last_login_date: Optional[str] = None
        
    def _get_today_key(self) -> str:
        """Get today's date string for daily tracking."""
        return datetime.now().strftime("%Y-%m-%d")
    
    def _check_daily_cap(self, activity: ActivityType) -> bool:
        """Check if the daily XP cap has been reached for an activity."""
        reward = XP_REWARDS[activity]
        if reward.daily_cap is None:
            return True  # No cap
        
        today = self._get_today_key()
        if today not in self.daily_activity_counts:
            self.daily_activity_counts[today] = {}
        
        activity_key = activity.value
        current_count = self.daily_activity_counts[today].get(activity_key, 0)
        
        return current_count < reward.daily_cap
    
    def _increment_activity(self, activity: ActivityType):
        """Track an activity occurrence for daily cap purposes."""
        today = self._get_today_key()
        if today not in self.daily_activity_counts:
            self.daily_activity_counts[today] = {}
        
        activity_key = activity.value
        self.daily_activity_counts[today][activity_key] = \
            self.daily_activity_counts[today].get(activity_key, 0) + 1
    
    def award_xp(self, activity: ActivityType, stamp_type: Optional[str] = None) -> dict:
        """
        Award XP for an activity, respecting daily caps.
        Returns a result dict with XP awarded and any level-ups.
        """
        reward = XP_REWARDS[activity]
        
        # Check daily cap (ethical design: prevent grinding)
        if not self._check_daily_cap(activity):
            return {
                "xp_awarded": 0,
                "reason": "daily_cap_reached",
                "message": f"You've earned all the {reward.description} XP for today! Come back tomorrow!",
                "level_ups": []
            }
        
        # Special handling: TRY_NEW_STAMP only awards for first uses
        if activity == ActivityType.TRY_NEW_STAMP:
            if stamp_type in self.first_seen_stamps:
                return {"xp_awarded": 0, "reason": "already_used", "level_ups": []}
            self.first_seen_stamps.add(stamp_type)
        
        # Award XP
        xp_to_award = reward.base_xp
        self._increment_activity(activity)
        
        # Track specific stats
        if activity == ActivityType.COMPLETE_GAME:
            self.games_created += 1
        elif activity == ActivityType.COMPLETE_CHALLENGE:
            self.challenges_completed += 1
        
        # Apply XP and check for level-ups
        level_ups = self._add_xp(xp_to_award)
        
        return {
            "xp_awarded": xp_to_award,
            "total_xp": self.total_xp,
            "current_level": self.current_level,
            "level_ups": level_ups,
            "message": f"+{xp_to_award} XP! {reward.description}"
        }
    
    def _add_xp(self, amount: int) -> List[dict]:
        """Add XP and process any level-ups. Returns list of level-up events."""
        level_ups = []
        self.total_xp += amount
        self.xp_toward_next += amount
        
        # Check for multiple level-ups
        while True:
            threshold = calculate_level_threshold(self.current_level + 1)
            if self.xp_toward_next >= threshold:
                self.xp_toward_next -= threshold
                self.current_level += 1
                
                # Get unlocks for this level
                unlocks = [u for u in LEVEL_UNLOCKS if u.level == self.current_level]
                for unlock in unlocks:
                    self.unlocked_items.add(unlock.unlock_id)
                
                level_ups.append({
                    "new_level": self.current_level,
                    "unlocks": [
                        {"type": u.unlock_type, "id": u.unlock_id, "desc": u.description}
                        for u in unlocks
                    ]
                })
            else:
                break
        
        return level_ups
    
    def get_progress(self) -> dict:
        """Get current progress information for the UI."""
        next_threshold = calculate_level_threshold(self.current_level + 1)
        return {
            "level": self.current_level,
            "total_xp": self.total_xp,
            "xp_toward_next": self.xp_toward_next,
            "xp_needed_for_next": next_threshold,
            "progress_percent": (self.xp_toward_next / next_threshold * 100) if next_threshold > 0 else 100,
            "unlocked_themes": list(self.unlocked_items),
            "games_created": self.games_created,
            "challenges_completed": self.challenges_completed,
            "next_unlocks": [
                {"level": u.level, "desc": u.description}
                for u in LEVEL_UNLOCKS
                if u.level > self.current_level
            ][:3]  # Show next 3 unlocks
        }
    
    def to_json(self) -> str:
        """Serialize to JSON for storage."""
        data = {
            "user_id": self.user_id,
            "total_xp": self.total_xp,
            "current_level": self.current_level,
            "xp_toward_next": self.xp_toward_next,
            "daily_activity_counts": self.daily_activity_counts,
            "unlocked_items": list(self.unlocked_items),
            "first_seen_stamps": list(self.first_seen_stamps),
            "games_created": self.games_created,
            "challenges_completed": self.challenges_completed,
            "last_login_date": self.last_login_date
        }
        return json.dumps(data, indent=2)
    
    @classmethod
    def from_json(cls, json_str: str) -> "CreatorProgression":
        """Deserialize from JSON."""
        data = json.loads(json_str)
        prog = cls(data["user_id"])
        prog.total_xp = data.get("total_xp", 0)
        prog.current_level = data.get("current_level", 1)
        prog.xp_toward_next = data.get("xp_toward_next", 0)
        prog.daily_activity_counts = data.get("daily_activity_counts", {})
        prog.unlocked_items = set(data.get("unlocked_items", ["starter"]))
        prog.first_seen_stamps = set(data.get("first_seen_stamps", []))
        prog.games_created = data.get("games_created", 0)
        prog.challenges_completed = data.get("challenges_completed", 0)
        prog.last_login_date = data.get("last_login_date")
        return prog


# Example usage:
def demo_progression():
    """Demonstrate the progression system."""
    player = CreatorProgression("child_001")
    
    # Child places some stamps
    for i in range(5):
        result = player.award_xp(ActivityType.PLACE_STAMP)
        print(result["message"])
    
    # Child creates their first game
    result = player.award_xp(ActivityType.COMPLETE_GAME)
    print(f"Game created! {result}")
    
    # Child tries a new stamp type
    result = player.award_xp(ActivityType.TRY_NEW_STAMP, stamp_type="dragon")
    print(f"New stamp! {result}")
    
    # Check progress
    progress = player.get_progress()
    print(f"\nCurrent Level: {progress['level']}")
    print(f"XP: {progress['xp_toward_next']}/{progress['xp_needed_for_next']}")
    print(f"Progress: {progress['progress_percent']:.1f}%")
    print(f"Next unlocks: {progress['next_unlocks']}")
    
    return player

if __name__ == "__main__":
    demo_progression()
```

#### 2. Ethical Daily Challenge Generator (Python)

```python
"""
Ethical Daily Challenge Generator
Creates child-friendly creation prompts without addiction mechanics.
No streaks, no FOMO, no time pressure. Just creative inspiration.
"""
import random
import hashlib
from datetime import datetime, timedelta
from dataclasses import dataclass
from typing import List, Dict, Optional, Set
from enum import Enum

class ChallengeCategory(Enum):
    """Types of daily challenges."""
    THEME = "theme"           # Create around a theme
    STAMP_COMBO = "stamp_combo"  # Use specific stamp combinations
    STORY = "story"           # Tell a specific type of story
    MECHANIC = "mechanic"     # Try a game mechanic
    EXPLORATION = "exploration"  # Explore and discover

@dataclass
class ChallengeTemplate:
    """Template for generating daily challenges."""
    category: ChallengeCategory
    template: str
    required_stamps: List[str]
    alternative_stamps: List[str]  # Always provide alternatives
    difficulty: str  # "easy", "medium" -- never "hard" for 5-year-olds
    suggested_count: int  # How many stamps to aim for (gentle guidance)

# Challenge template library -- hundreds of combinations
CHALLENGE_TEMPLATES: List[ChallengeTemplate] = [
    # Theme challenges
    ChallengeTemplate(
        category=ChallengeCategory.THEME,
        template="Create a game about SPACE! Put astronauts on the moon!",
        required_stamps=["rocket", "star"],
        alternative_stamps=["planet", "alien", "comet"],
        difficulty="easy",
        suggested_count=8
    ),
    ChallengeTemplate(
        category=ChallengeCategory.THEME,
        template="Make an UNDERWATER adventure with fish and treasure!",
        required_stamps=["fish", "water"],
        alternative_stamps=["shark", "treasure_chest", "coral", "submarine"],
        difficulty="easy",
        suggested_count=10
    ),
    ChallengeTemplate(
        category=ChallengeCategory.THEME,
        template="Build a CASTLE for a king and queen!",
        required_stamps=["castle", "crown"],
        alternative_stamps=["knight", "dragon", "flag", "throne"],
        difficulty="easy",
        suggested_count=10
    ),
    ChallengeTemplate(
        category=ChallengeCategory.THEME,
        template="Make a SAFARI with lots of animals!",
        required_stamps=["lion", "tree"],
        alternative_stamps=["elephant", "giraffe", "monkey", "zebra"],
        difficulty="easy",
        suggested_count=12
    ),
    ChallengeTemplate(
        category=ChallengeCategory.THEME,
        template="Create a PIRATE island with ships and treasure!",
        required_stamps=["ship", "island"],
        alternative_stamps=["pirate", "parrot", "treasure_map", "palm_tree"],
        difficulty="easy",
        suggested_count=10
    ),
    
    # Stamp combo challenges
    ChallengeTemplate(
        category=ChallengeCategory.STAMP_COMBO,
        template="Put a DRAGON and a PRINCESS in the same game!",
        required_stamps=["dragon", "princess"],
        alternative_stamps=["castle", "knight", "fire", "crown"],
        difficulty="easy",
        suggested_count=6
    ),
    ChallengeTemplate(
        category=ChallengeCategory.STAMP_COMBO,
        template="Make a game with a CAT and a FISH BOWL!",
        required_stamps=["cat", "fish_bowl"],
        alternative_stamps=["house", "mouse", "milk", "yarn"],
        difficulty="easy",
        suggested_count=6
    ),
    ChallengeTemplate(
        category=ChallengeCategory.STAMP_COMBO,
        template="Create something with a ROBOT and a FACTORY!",
        required_stamps=["robot", "factory"],
        alternative_stamps=["gear", "conveyor", "box", "rocket"],
        difficulty="medium",
        suggested_count=10
    ),
    
    # Story challenges
    ChallengeTemplate(
        category=ChallengeCategory.STORY,
        template="Tell a story about a BUNNY looking for CARROTS!",
        required_stamps=["bunny", "carrot"],
        alternative_stamps=["garden", "basket", "fence", "sun"],
        difficulty="easy",
        suggested_count=8
    ),
    ChallengeTemplate(
        category=ChallengeCategory.STORY,
        template="Make a story about a TRAIN going on an adventure!",
        required_stamps=["train", "track"],
        alternative_stamps=["tunnel", "mountain", "bridge", "station"],
        difficulty="easy",
        suggested_count=10
    ),
    ChallengeTemplate(
        category=ChallengeCategory.STORY,
        template="Create a story where a BIRD flies to a RAINBOW!",
        required_stamps=["bird", "rainbow"],
        alternative_stamps=["cloud", "sun", "star", "nest"],
        difficulty="easy",
        suggested_count=8
    ),
    
    # Mechanic challenges (introduce game concepts gently)
    ChallengeTemplate(
        category=ChallengeCategory.MECHANIC,
        template="Make a MAZE where someone has to find the exit!",
        required_stamps=["wall", "start_flag"],
        alternative_stamps=["treasure", "key", "door", "character"],
        difficulty="medium",
        suggested_count=15
    ),
    ChallengeTemplate(
        category=ChallengeCategory.MECHANIC,
        template="Create a game with a START and a FINISH line!",
        required_stamps=["start_line", "finish_line"],
        alternative_stamps=["flag", "character", "trophy", "cheer"],
        difficulty="easy",
        suggested_count=8
    ),
    ChallengeTemplate(
        category=ChallengeCategory.MECHANIC,
        template="Make a HIDE AND SEEK game! Hide something for a friend to find!",
        required_stamps=["character", "bush"],
        alternative_stamps=["tree", "house", "treasure", "question_mark"],
        difficulty="easy",
        suggested_count=10
    ),
    
    # Exploration challenges
    ChallengeTemplate(
        category=ChallengeCategory.EXPLORATION,
        template="Make the BIGGEST game you can! Use LOTS of stamps!",
        required_stamps=[],
        alternative_stamps=[],
        difficulty="easy",
        suggested_count=25
    ),
    ChallengeTemplate(
        category=ChallengeCategory.EXPLORATION,
        template="Try making a game with ONLY animal stamps!",
        required_stamps=[],
        alternative_stamps=[],
        difficulty="medium",
        suggested_count=10
    ),
    ChallengeTemplate(
        category=ChallengeCategory.EXPLORATION,
        template="Create a game using stamps you've NEVER used before!",
        required_stamps=[],
        alternative_stamps=[],
        difficulty="easy",
        suggested_count=5
    ),
]

class DailyChallengeGenerator:
    """
    Generates daily creation challenges that inspire without pressuring.
    
    Key ethical principles:
    1. No streaks or consecutive-day requirements
    2. Challenges available for 3 days (no FOMO)
    3. Alternatives always provided for missing stamps
    4. Difficulty never exceeds "medium" for 5-year-olds
    5. No competitive elements -- personal creation only
    """
    
    def __init__(self, seed: Optional[str] = None):
        self.seed = seed or datetime.now().strftime("%Y-%m-%d")
        self.rng = random.Random(self.seed)
        
    def generate_daily_challenge(
        self,
        available_stamps: Set[str],
        completed_challenges: Set[str],
        child_age: int = 5
    ) -> dict:
        """
        Generate a daily challenge appropriate for the child.
        
        Args:
            available_stamps: Set of stamps the child has unlocked
            completed_challenges: Set of challenge IDs already completed
            child_age: Age of the child (affects difficulty selection)
        
        Returns:
            Challenge dict with prompt, requirements, and alternatives
        """
        # Filter to age-appropriate difficulty
        max_difficulty = "easy" if child_age <= 5 else "medium"
        eligible = [t for t in CHALLENGE_TEMPLATES 
                    if t.difficulty <= max_difficulty]
        
        # Prefer challenges the child hasn't completed recently
        # Use a hash of the template to create a challenge ID
        def get_challenge_id(template: ChallengeTemplate) -> str:
            return hashlib.md5(template.template.encode()).hexdigest()[:8]
        
        uncompleted = [t for t in eligible 
                       if get_challenge_id(t) not in completed_challenges]
        
        # If many uncompleted, prefer those; otherwise allow repeats
        candidates = uncompleted if len(uncompleted) >= 5 else eligible
        
        # Seed-based selection ensures all children see the same challenge
        # on the same day (community feeling) while varying day-to-day
        challenge = self.rng.choice(candidates)
        challenge_id = get_challenge_id(challenge)
        
        # Build the challenge response
        return {
            "challenge_id": challenge_id,
            "date": self.seed,
            "available_until": (datetime.strptime(self.seed, "%Y-%m-%d") 
                              + timedelta(days=3)).strftime("%Y-%m-%d"),
            "category": challenge.category.value,
            "prompt": challenge.template,
            "suggested_stamp_count": challenge.suggested_count,
            "required_stamps": challenge.required_stamps,
            "alternative_stamps": challenge.alternative_stamps,
            "difficulty": challenge.difficulty,
            "rewards": {
                "xp_bonus": 15,
                "mystery_stamp_reward": True,
                "badge_if_first_in_category": True
            },
            # Ethical: No streak bonus, no time pressure, no exclusive rewards
            "streak_info": None,
            "time_limit": None,
            "exclusive_reward": False
        }
    
    def generate_weekly_theme(self) -> dict:
        """Generate a Theme Jam theme for the week."""
        themes = [
            "Space Week!",
            "Dinosaur Week!",
            "Under the Sea!",
            "Magic and Wizards!",
            "Robots and Future!",
            "Jungle Safari!",
            "Pirate Adventure!",
            "Superheroes!",
            "Fairy Tale Week!",
            "Building and Construction!",
            "Music and Dance!",
            "Sports Week!",
            "Winter Wonderland!",
            "Spring Garden!",
            "Autumn Leaves!",
            "Summer Beach!"
        ]
        
        # Use the week number as seed for consistent weekly themes
        week_seed = datetime.now().isocalendar()[1]
        rng = random.Random(f"{datetime.now().year}-week-{week_seed}")
        theme = rng.choice(themes)
        
        return {
            "theme": theme,
            "week_number": week_seed,
            "starts": self._week_start().strftime("%Y-%m-%d"),
            "ends": (self._week_start() + timedelta(days=7)).strftime("%Y-%m-%d"),
            "participation_reward": "Theme Jam Badge",
            "no_winners": True,  # Everyone gets the same reward
            "reward_description": "You get a special badge just for joining!"
        }
    
    def _week_start(self) -> datetime:
        """Get the Monday of the current week."""
        today = datetime.now()
        return today - timedelta(days=today.weekday())
    
    def generate_discovery_island_seed(self) -> str:
        """
        Generate a daily seed for the Discovery Island.
        All children using the platform on the same day get the same seed,
        creating a shared experience while maintaining privacy.
        """
        return hashlib.sha256(f"discovery_{self.seed}".encode()).hexdigest()[:16]


# Example usage:
def demo_daily_challenge():
    """Demonstrate daily challenge generation."""
    generator = DailyChallengeGenerator()
    
    # Simulate a child with some stamps
    child_stamps = {"rocket", "star", "fish", "cat", "dragon", "castle", 
                     "bunny", "carrot", "train", "bird", "wall", "tree"}
    completed = set()
    
    challenge = generator.generate_daily_challenge(child_stamps, completed)
    
    print("=== DAILY CREATION CHALLENGE ===")
    print(f"Prompt: {challenge['prompt']}")
    print(f"Available until: {challenge['available_until']} (3 days)")
    print(f"Difficulty: {challenge['difficulty']}")
    print(f"Try using: {challenge['required_stamps']}")
    print(f"Or instead: {challenge['alternative_stamps']}")
    print(f"Suggested stamps to place: {challenge['suggested_stamp_count']}")
    print(f"XP Reward: {challenge['rewards']['xp_bonus']}")
    print(f"Time limit: {challenge['time_limit']} (none!)")
    print(f"Streak bonus: {challenge['streak_info']} (none!)")
    
    # Weekly theme
    weekly = generator.generate_weekly_theme()
    print(f"\n=== THIS WEEK'S THEME ===")
    print(f"Theme: {weekly['theme']}")
    print(f"Reward: {weekly['reward_description']}")

if __name__ == "__main__":
    demo_daily_challenge()
```

#### 3. Stamp Unlock System (TypeScript)

```typescript
/**
 * Stamp Unlock System
 * Manages how children discover and unlock new stamp packs.
 * Unlocks are based on CREATION, not time gates or payments.
 */

interface StampPack {
  id: string;
  name: string;
  theme: string;
  stamps: Stamp[];
  unlockCondition: UnlockCondition;
  isUnlocked: boolean;
}

interface Stamp {
  id: string;
  name: string;
  category: string;
  level: number; // 1-3 for stamp evolution
  animations: string[];
  sounds: string[];
}

interface UnlockCondition {
  type: 'creation_count' | 'theme_usage' | 'specific_stamps' | 'level_reached' | 'challenge_completed' | 'first_login';
  requirement: number;
  description: string; // Child-friendly explanation
  stampsNeeded?: string[];
  theme?: string;
}

interface UnlockEvent {
  packId: string;
  packName: string;
  triggerDescription: string;
  newStamps: Stamp[];
  celebrationType: 'confetti' | 'character_visit' | 'story_moment';
}

/**
 * Stamp packs organized by theme with unlock conditions.
 * All conditions are based on creative activity, never money or time.
 */
const STAMP_PACKS: StampPack[] = [
  {
    id: 'starter',
    name: 'Starter Collection',
    theme: 'basic',
    isUnlocked: true,
    stamps: [
      { id: 'circle', name: 'Circle', category: 'shape', level: 1, animations: ['bounce'], sounds: ['pop'] },
      { id: 'square', name: 'Square', category: 'shape', level: 1, animations: ['bounce'], sounds: ['pop'] },
      { id: 'triangle', name: 'Triangle', category: 'shape', level: 1, animations: ['bounce'], sounds: ['pop'] },
      { id: 'cat', name: 'Cat', category: 'animal', level: 1, animations: ['walk', 'meow'], sounds: ['meow'] },
      { id: 'dog', name: 'Dog', category: 'animal', level: 1, animations: ['walk', 'wag'], sounds: ['woof'] },
      { id: 'tree', name: 'Tree', category: 'nature', level: 1, animations: ['sway'], sounds: ['rustle'] },
      { id: 'sun', name: 'Sun', category: 'nature', level: 1, animations: ['pulse'], sounds: [] },
      { id: 'house', name: 'House', category: 'building', level: 1, animations: [], sounds: [] },
    ],
    unlockCondition: { type: 'first_login', requirement: 1, description: 'Welcome! Here are your first stamps!' }
  },
  {
    id: 'space',
    name: 'Space Adventure',
    theme: 'space',
    isUnlocked: false,
    stamps: [
      { id: 'rocket', name: 'Rocket', category: 'space', level: 1, animations: ['blast_off'], sounds: ['rocket_sound'] },
      { id: 'alien', name: 'Alien', category: 'space', level: 1, animations: ['wave'], sounds: ['alien_greeting'] },
      { id: 'planet', name: 'Planet', category: 'space', level: 1, animations: ['rotate'], sounds: [] },
      { id: 'star', name: 'Star', category: 'space', level: 1, animations: ['twinkle'], sounds: ['chime'] },
      { id: 'comet', name: 'Comet', category: 'space', level: 1, animations: ['shoot'], sounds: ['whoosh'] },
      { id: 'moon', name: 'Moon', category: 'space', level: 1, animations: ['glow'], sounds: [] },
    ],
    unlockCondition: { 
      type: 'creation_count', 
      requirement: 3, 
      description: 'Create 3 games to unlock Space stamps!' 
    }
  },
  {
    id: 'ocean',
    name: 'Ocean World',
    theme: 'ocean',
    isUnlocked: false,
    stamps: [
      { id: 'fish', name: 'Fish', category: 'ocean', level: 1, animations: ['swim'], sounds: ['bubble'] },
      { id: 'shark', name: 'Shark', category: 'ocean', level: 1, animations: ['swim_fast'], sounds: ['chomp'] },
      { id: 'treasure_chest', name: 'Treasure Chest', category: 'ocean', level: 1, animations: ['open'], sounds: ['creak'] },
      { id: 'submarine', name: 'Submarine', category: 'ocean', level: 1, animations: ['dive'], sounds: ['sonar'] },
      { id: 'coral', name: 'Coral', category: 'ocean', level: 1, animations: ['sway'], sounds: [] },
      { id: 'octopus', name: 'Octopus', category: 'ocean', level: 1, animations: ['wiggle'], sounds: [] },
    ],
    unlockCondition: { 
      type: 'theme_usage', 
      requirement: 10, 
      theme: 'water',
      description: 'Use water stamps 10 times to unlock Ocean stamps!' 
    }
  },
  {
    id: 'fantasy',
    name: 'Fantasy Kingdom',
    theme: 'fantasy',
    isUnlocked: false,
    stamps: [
      { id: 'dragon', name: 'Dragon', category: 'fantasy', level: 1, animations: ['fly', 'fire_breath'], sounds: ['roar'] },
      { id: 'castle', name: 'Castle', category: 'fantasy', level: 1, animations: [], sounds: [] },
      { id: 'princess', name: 'Princess', category: 'fantasy', level: 1, animations: ['wave'], sounds: ['giggle'] },
      { id: 'knight', name: 'Knight', category: 'fantasy', level: 1, animations: ['charge'], sounds: ['clang'] },
      { id: 'wizard', name: 'Wizard', category: 'fantasy', level: 1, animations: ['cast_spell'], sounds: ['magic'] },
      { id: 'treasure', name: 'Treasure', category: 'fantasy', level: 1, animations: ['sparkle'], sounds: ['chime'] },
    ],
    unlockCondition: { 
      type: 'specific_stamps', 
      requirement: 2, 
      stampsNeeded: ['house', 'cat'],
      description: 'Use a House and a Cat in the same game to unlock Fantasy stamps!' 
    }
  },
  {
    id: 'vehicles',
    name: 'Vehicle Garage',
    theme: 'vehicles',
    isUnlocked: false,
    stamps: [
      { id: 'car', name: 'Car', category: 'vehicle', level: 1, animations: ['drive'], sounds: ['vroom'] },
      { id: 'airplane', name: 'Airplane', category: 'vehicle', level: 1, animations: ['fly'], sounds: ['engine'] },
      { id: 'boat', name: 'Boat', category: 'vehicle', level: 1, animations: ['sail'], sounds: [] },
      { id: 'train', name: 'Train', category: 'vehicle', level: 1, animations: ['chug'], sounds: ['choo_choo'] },
      { id: 'helicopter', name: 'Helicopter', category: 'vehicle', level: 1, animations: ['hover'], sounds: ['chopper'] },
      { id: 'fire_truck', name: 'Fire Truck', category: 'vehicle', level: 1, animations: ['drive_fast'], sounds: ['siren'] },
    ],
    unlockCondition: { 
      type: 'level_reached', 
      requirement: 8, 
      description: 'Reach Creator Level 8 to unlock Vehicle stamps!' 
    }
  },
];

/**
 * Manages stamp collection, unlocks, and discovery.
 */
class StampCollection {
  private packs: Map<string, StampPack> = new Map();
  private stampUsageCounts: Map<string, number> = new Map();
  private gamesCreated: number = 0;
  private currentLevel: number = 1;
  private challengesCompleted: number = 0;
  private unlockedPackIds: Set<string> = new Set(['starter']);
  private onUnlockCallback?: (event: UnlockEvent) => void;

  constructor() {
    STAMP_PACKS.forEach(pack => this.packs.set(pack.id, { ...pack }));
  }

  /**
   * Check if any stamp packs should be unlocked based on current progress.
   * Call this after any creation activity.
   */
  checkUnlocks(): UnlockEvent[] {
    const events: UnlockEvent[] = [];
    
    for (const pack of this.packs.values()) {
      if (pack.isUnlocked || this.unlockedPackIds.has(pack.id)) {
        continue;
      }
      
      if (this.meetsCondition(pack.unlockCondition)) {
        const event = this.unlockPack(pack);
        events.push(event);
      }
    }
    
    return events;
  }

  private meetsCondition(condition: UnlockCondition): boolean {
    switch (condition.type) {
      case 'first_login':
        return true;
      case 'creation_count':
        return this.gamesCreated >= condition.requirement;
      case 'theme_usage':
        // Count usage of stamps in the specified theme
        if (!condition.theme) return false;
        let themeCount = 0;
        this.stampUsageCounts.forEach((count, stampId) => {
          const stamp = this.findStamp(stampId);
          if (stamp && stamp.category === condition.theme) {
            themeCount += count;
          }
        });
        return themeCount >= condition.requirement;
      case 'specific_stamps':
        return condition.stampsNeeded?.every(s => this.stampUsageCounts.get(s)! > 0) ?? false;
      case 'level_reached':
        return this.currentLevel >= condition.requirement;
      case 'challenge_completed':
        return this.challengesCompleted >= condition.requirement;
      default:
        return false;
    }
  }

  private unlockPack(pack: StampPack): UnlockEvent {
    pack.isUnlocked = true;
    this.unlockedPackIds.add(pack.id);
    
    const event: UnlockEvent = {
      packId: pack.id,
      packName: pack.name,
      triggerDescription: pack.unlockCondition.description,
      newStamps: pack.stamps,
      celebrationType: 'character_visit'
    };
    
    this.onUnlockCallback?.(event);
    return event;
  }

  private findStamp(stampId: string): Stamp | undefined {
    for (const pack of this.packs.values()) {
      const stamp = pack.stamps.find(s => s.id === stampId);
      if (stamp) return stamp;
    }
    return undefined;
  }

  // Public methods called by the game system
  
  recordStampPlaced(stampId: string): void {
    const current = this.stampUsageCounts.get(stampId) || 0;
    this.stampUsageCounts.set(stampId, current + 1);
  }

  recordGameCompleted(): void {
    this.gamesCreated++;
  }

  recordLevelUp(newLevel: number): void {
    this.currentLevel = newLevel;
  }

  recordChallengeCompleted(): void {
    this.challengesCompleted++;
  }

  getUnlockedStamps(): Stamp[] {
    const stamps: Stamp[] = [];
    for (const packId of this.unlockedPackIds) {
      const pack = this.packs.get(packId);
      if (pack) stamps.push(...pack.stamps);
    }
    return stamps;
  }

  getAvailablePacks(): StampPack[] {
    return Array.from(this.packs.values());
  }

  setOnUnlock(callback: (event: UnlockEvent) => void): void {
    this.onUnlockCallback = callback;
  }
}

// Usage example:
// const stamps = new StampCollection();
// stamps.setOnUnlock((event) => showUnlockCelebration(event));
// stamps.recordStampPlaced('house');
// stamps.recordStampPlaced('cat');
// stamps.recordGameCompleted();
// const newUnlocks = stamps.checkUnlocks();
// if (newUnlocks.length > 0) playCelebrationAnimation();

export { StampCollection, STAMP_PACKS };
export type { StampPack, Stamp, UnlockEvent, UnlockCondition };
```

#### 4. Ethical Reward System (Python)

```python
"""
Ethical Reward System for Children's Creation Platform
Implements rewards that celebrate creativity without addictive mechanics.
Based on Self-Determination Theory and COPPA-compliant design.
"""
from dataclasses import dataclass, field
from typing import Optional, List, Dict
from datetime import datetime, timedelta
from enum import Enum
import random

class RewardType(Enum):
    """Types of ethical rewards -- all cosmetic or creative."""
    MYSTERY_STAMP = "mystery_stamp"        # A new stamp for their collection
    SPARKLE = "sparkle"                     # Cosmetic currency for village decoration
    BADGE = "badge"                         # Achievement badge (purely cosmetic)
    VILLAGE_DECORATION = "village_decoration"  # New decoration for their village
    CREATIVE_POWER = "creative_power"       # New creative tool (never a gameplay advantage)
    STORY_MOMENT = "story_moment"           # New dialogue with village characters
    THEME_PACK = "theme_pack"               # Collection of related stamps
    CELEBRATION = "celebration"             # Special animation/sound effect

class RewardCategory(Enum):
    """Category determines how the reward is earned."""
    CREATION = "creation"           # Rewards for creating
    DISCOVERY = "discovery"         # Rewards for trying new things
    CHALLENGE = "challenge"         # Rewards for completing challenges
    MILESTONE = "milestone"         # Rewards for cumulative achievements
    DAILY_SURPRISE = "daily_surprise"  # Random daily gift (no login requirement)

@dataclass
class Reward:
    """A single reward that a child can earn."""
    reward_type: RewardType
    reward_id: str
    name: str
    description: str
    category: RewardCategory
    icon: str
    
    # Ethical safeguards
    is_limited_time: bool = False  # NEVER true for our platform
    requires_payment: bool = False  # ALWAYS false
    can_be_missed: bool = False  # NEVER true -- all rewards eventually available
    promotes_grinding: bool = False  # ALWAYS false

@dataclass
class RewardResult:
    """Result of earning a reward."""
    reward: Reward
    earned_at: datetime
    celebration_message: str
    child_friendly_description: str
    is_first_time: bool

class EthicalRewardSystem:
    """
    Manages all rewards in the platform.
    
    ETHICAL PRINCIPLES:
    1. All rewards celebrate creativity, never exploit psychology
    2. Nothing is missable -- no FOMO
    3. No payment gates -- ever
    4. Rewards expand creative possibility, not player power
    5. Grinding is prevented through daily caps
    6. Random rewards (mystery stamps) are generous and fair
    """
    
    # Pre-defined reward pool
    REWARDS_POOL: List[Reward] = [
        # Mystery stamps (discovery rewards)
        Reward(RewardType.MYSTERY_STAMP, "random_animal", "Mystery Animal", 
               "A surprise animal stamp!", RewardCategory.DISCOVERY, "mystery_box"),
        Reward(RewardType.MYSTERY_STAMP, "random_vehicle", "Mystery Vehicle",
               "A surprise vehicle stamp!", RewardCategory.DISCOVERY, "mystery_box"),
        Reward(RewardType.MYSTERY_STAMP, "random_fantasy", "Mystery Fantasy Stamp",
               "A magical surprise!", RewardCategory.DISCOVERY, "mystery_box"),
        
        # Village decorations
        Reward(RewardType.VILLAGE_DECORATION, "flower_garden", "Flower Garden",
               "Pretty flowers for your village!", RewardCategory.CREATION, "flower"),
        Reward(RewardType.VILLAGE_DECORATION, "rainbow_bridge", "Rainbow Bridge",
               "A colorful bridge!", RewardCategory.MILESTONE, "rainbow"),
        Reward(RewardType.VILLAGE_DECORATION, "fountain", "Sparkle Fountain",
               "A magical fountain!", RewardCategory.MILESTONE, "fountain"),
        Reward(RewardType.VILLAGE_DECORATION, "balloon_arch", "Balloon Arch",
               "Party balloons!", RewardCategory.CREATION, "balloon"),
        
        # Creative powers (tools, not advantages)
        Reward(RewardType.CREATIVE_POWER, "rainbow_brush", "Rainbow Brush",
               "Paint your stamps any color!", RewardCategory.MILESTONE, "paintbrush"),
        Reward(RewardType.CREATIVE_POWER, "stamp_copy", "Stamp Copier",
               "Make copies of any stamp!", RewardCategory.MILESTONE, "copy"),
        Reward(RewardType.CREATIVE_POWER, "resize_tool", "Grow-Shrink Wand",
               "Make stamps bigger or smaller!", RewardCategory.MILESTONE, "wand"),
        
        # Celebrations
        Reward(RewardType.CELEBRATION, "fireworks", "Fireworks Show",
               "A spectacular fireworks display!", RewardCategory.MILESTONE, "firework"),
        Reward(RewardType.CELEBRATION, "confetti_party", "Confetti Party",
               "A shower of colorful confetti!", RewardCategory.CREATION, "confetti"),
        
        # Badges
        Reward(RewardType.BADGE, "first_game", "First Game Creator",
               "You created your very first game!", RewardCategory.MILESTONE, "badge_star"),
        Reward(RewardType.BADGE, "stamp_explorer", "Stamp Explorer",
               "You've used 20 different stamps!", RewardCategory.DISCOVERY, "badge_map"),
        Reward(RewardType.BADGE, "challenge_hero", "Challenge Hero",
               "You completed 10 challenges!", RewardCategory.CHALLENGE, "badge_shield"),
        Reward(RewardType.BADGE, "storyteller", "Storyteller",
               "You created a game with a beginning and end!", RewardCategory.CREATION, "badge_book"),
    ]
    
    def __init__(self):
        self.earned_rewards: Dict[str, datetime] = {}
        self.daily_reward_claimed: Optional[str] = None
        
    def grant_reward(self, reward_id: str, child_name: str = "Creator") -> Optional[RewardResult]:
        """Grant a reward to the child with appropriate celebration."""
        reward = self._find_reward(reward_id)
        if not reward:
            return None
        
        # Check if already earned (for unique rewards)
        is_first = reward_id not in self.earned_rewards
        if not is_first and reward.reward_type in [RewardType.BADGE, RewardType.CREATIVE_POWER]:
            return None  # These are unique
        
        self.earned_rewards[reward_id] = datetime.now()
        
        # Generate child-friendly celebration
        celebration = self._generate_celebration(reward, child_name)
        
        return RewardResult(
            reward=reward,
            earned_at=datetime.now(),
            celebration_message=celebration["message"],
            child_friendly_description=celebration["description"],
            is_first_time=is_first
        )
    
    def get_daily_surprise(self, child_level: int, 
                           already_have_stamps: List[str]) -> Optional[RewardResult]:
        """
        Generate a daily surprise reward.
        This is NOT a daily login bonus -- it's a random discovery
        that children find when they visit their village.
        Missing days doesn't lose anything; rewards accumulate.
        """
        today = datetime.now().strftime("%Y-%m-%d")
        
        # Check if already claimed today (prevents exploit, not addiction)
        if self.daily_reward_claimed == today:
            return None
        
        self.daily_reward_claimed = today
        
        # Choose a reward appropriate for level
        eligible = [r for r in self.REWARDS_POOL 
                    if r.category == RewardCategory.DISCOVERY 
                    or (r.category == RewardCategory.CREATION and child_level >= 3)]
        
        reward = random.choice(eligible)
        
        return self.grant_reward(reward.reward_id)
    
    def get_milestone_rewards(self, games_created: int, 
                               stamps_used: int,
                               challenges_done: int,
                               level: int) -> List[RewardResult]:
        """Check and grant milestone rewards based on cumulative progress."""
        results = []
        
        # Game creation milestones
        if games_created == 1:
            results.append(self.grant_reward("first_game"))
        
        # Stamp exploration milestones
        if stamps_used >= 20:
            results.append(self.grant_reward("stamp_explorer"))
        
        # Challenge milestones
        if challenges_done >= 10:
            results.append(self.grant_reward("challenge_hero"))
        
        # Level-based rewards
        if level == 5:
            results.append(self.grant_reward("rainbow_brush"))
        if level == 10:
            results.append(self.grant_reward("stamp_copy"))
        if level == 15:
            results.append(self.grant_reward("resize_tool"))
        
        return [r for r in results if r is not None]
    
    def _find_reward(self, reward_id: str) -> Optional[Reward]:
        for r in self.REWARDS_POOL:
            if r.reward_id == reward_id:
                return r
        return None
    
    def _generate_celebration(self, reward: Reward, child_name: str) -> dict:
        """Generate a child-friendly celebration message."""
        messages = {
            RewardType.MYSTERY_STAMP: {
                "message": f"Surprise, {child_name}! You found a new stamp!",
                "description": f"You discovered: {reward.name}! Try using it in a game!"
            },
            RewardType.VILLAGE_DECORATION: {
                "message": f"Your village is growing, {child_name}!",
                "description": f"You got: {reward.name}! Tap your village to place it!"
            },
            RewardType.CREATIVE_POWER: {
                "message": f"You're becoming a master creator, {child_name}!",
                "description": f"New power unlocked: {reward.name}! {reward.description}"
            },
            RewardType.BADGE: {
                "message": f"Amazing work, {child_name}!",
                "description": f"You earned the {reward.name} badge! {reward.description}"
            },
            RewardType.CELEBRATION: {
                "message": f"Time to celebrate, {child_name}!",
                "description": f"{reward.name}! Enjoy the show!"
            },
        }
        
        return messages.get(reward.reward_type, {
            "message": f"Great job, {child_name}!",
            "description": f"You got: {reward.name}!"
        })


# Parental controls integration
class ParentalControls:
    """
    Parent-facing controls for managing the child's experience.
    All features are opt-in safety measures, not restrictions on play.
    """
    
    def __init__(self):
        self.daily_time_limit: Optional[int] = None  # minutes, None = unlimited
        self.daily_session_reminders: bool = True  # Gentle "time for a break?" messages
        self.hide_rewards: bool = False  # Option to hide reward notifications
        self.creation_only_mode: bool = False  # Disable discovery island, challenges
        self.share_approved_contacts: List[str] = []  # Family members who can see games
        self.data_collection: bool = False  # Minimal data by default
    
    def get_daily_summary(self, child_activity: dict) -> dict:
        """
        Generate a parent-friendly daily summary.
        Shows what the child created, not metrics or engagement data.
        """
        return {
            "games_created_today": child_activity.get("games_created", 0),
            "stamps_discovered": child_activity.get("new_stamps", []),
            "creative_time_minutes": child_activity.get("active_time", 0),
            "favorite_stamp": child_activity.get("most_used_stamp", "None yet"),
            "challenge_attempted": child_activity.get("tried_challenge", False),
            "suggested_conversation": self._get_conversation_starter(child_activity)
        }
    
    def _get_conversation_starter(self, activity: dict) -> str:
        """Suggest a parent-child conversation about the day's creations."""
        if activity.get("games_created", 0) > 0:
            return "Ask your child to show you the game they made today!"
        if activity.get("new_stamps"):
            return f"Your child discovered a {activity['new_stamps'][0]} stamp! Ask about it!"
        return "No creations today -- maybe create something together!"


# Example usage:
def demo_reward_system():
    """Demonstrate the ethical reward system."""
    rewards = EthicalRewardSystem()
    
    # Child creates their first game
    print("=== CHILD CREATES FIRST GAME ===")
    result = rewards.grant_reward("first_game", child_name="Sam")
    if result:
        print(f"{result.celebration_message}")
        print(f"{result.child_friendly_description}")
    
    # Daily surprise (found in village, not login bonus)
    print("\n=== DAILY SURPRISE ===")
    surprise = rewards.get_daily_surprise(child_level=3, already_have_stamps=[])
    if surprise:
        print(f"{surprise.celebration_message}")
        print(f"{surprise.child_friendly_description}")
    
    # Milestone check
    print("\n=== MILESTONE CHECK ===")
    milestones = rewards.get_milestone_rewards(
        games_created=1, stamps_used=25, challenges_done=12, level=5
    )
    for m in milestones:
        print(f"Milestone: {m.celebration_message}")
    
    # Parent summary
    print("\n=== PARENT DAILY SUMMARY ===")
    controls = ParentalControls()
    summary = controls.get_daily_summary({
        "games_created": 2,
        "new_stamps": ["rocket", "alien"],
        "active_time": 25,
        "most_used_stamp": "dragon",
        "tried_challenge": True
    })
    print(f"Games today: {summary['games_created_today']}")
    print(f"New stamps: {summary['stamps_discovered']}")
    print(f"Talk about: {summary['suggested_conversation']}")

if __name__ == "__main__":
    demo_reward_system()
```

### Edge Cases & Mitigations

#### 1. Addiction Prevention

**Edge Case:** Child wants to play for hours continuously, potentially interfering with sleep, school, or physical activity.

**Mitigation:**
- Implement gentle session reminders every 20-30 minutes: "You've been creating for a while! Maybe take a stretch break?" [^545^]
- Parent-configurable daily time limits (default: no limit, but reminders on)
- After 1 hour of active creation, suggest: "Your creations are amazing! Why not take a break and come back tomorrow?"
- NEVER use penalty mechanics (no "energy" system, no "wait or pay" gates)
- The platform is designed around creation, not consumption -- children naturally take breaks when creative energy is spent
- Include a "Quiet Mode" that disables all celebratory animations and sounds for children sensitive to overstimulation [^545^]

**Research Backing:** The WHO added gaming disorder to its disease classification in 2018, and studies show subscription-based gaming is associated with problematic gaming behavior [^551^]. Our platform avoids the structural elements (infinite loops, gambling mechanics, competitive pressure) that correlate with addiction.

#### 2. Frustration from Locked Content

**Edge Case:** Child sees a stamp they want but hasn't met the unlock condition yet, leading to frustration.

**Mitigation:**
- All stamp packs show the EXACT unlock condition: "Create 2 more games to unlock Ocean stamps!" (never vague)
- Unlock conditions are always achievable within 1-2 play sessions
- Free Play mode ALWAYS has starter stamps available -- children can always create
- "Try Before You Buy" -- children can preview locked stamps in the Discovery Island
- If a child attempts to use a locked stamp, a friendly character says: "That's a cool stamp! You can unlock it by [specific action]!"
- No randomized unlocks -- every child knows exactly how to get what they want

#### 3. Parental Controls & Privacy (COPPA Compliance)

**Edge Case:** Parents need to control the experience and protect their child's privacy.

**Mitigation:**
- Minimal data collection by default -- only store creation data locally where possible [^580^]
- Parent dashboard shows creative activity (games made, stamps collected) not behavioral metrics
- Parental controls include: time limits, disable challenges, hide social features, export/delete all data
- No advertising of any kind [^581^]
- No in-app purchases -- the platform is subscription-based with no additional monetization
- All sharing is family-only -- parents approve all contacts [^581^]
- COPPA-compliant consent flow for any data collection beyond local storage [^580^]

#### 4. Equitable Access

**Edge Case:** Children with different abilities, economic backgrounds, or device limitations may have unequal experiences.

**Mitigation:**
- All content unlockable through normal play -- no paid shortcuts
- Platform works offline after initial download -- no internet required for creation
- Large, high-contrast touch targets for motor skill differences [^545^]
- Full audio narration of all text -- supports pre-readers and visual impairments
- Color-blind friendly design (not just color-coded)
- Adjustable animation speed and sound levels for sensory sensitivities
- All daily challenges available for 3 days (accommodates inconsistent device access)
- No "limited time" content that requires specific schedule

#### 5. Comparison and Self-Esteem

**Edge Case:** Children compare their creations to others and feel inadequate.

**Mitigation:**
- Gallery showcases show all creations equally -- no "likes" counts or rankings
- Family Gallery is private -- only approved family members see creations
- Characters provide positive reinforcement for ALL creations, regardless of complexity
- "Every creation is amazing" philosophy -- the LLM backend generates encouraging comments
- No public leaderboards, no "most popular" lists
- Children can choose to keep creations private (not even family sees)
- Difficulty is self-selected -- children choose their own challenge level

#### 6. Grinding Prevention

**Edge Case:** Child repeatedly performs the same simple action to farm XP.

**Mitigation:**
- Daily XP caps on repetitive activities (max 100 stamps per day count toward XP) [^598^]
- XP rewards heavily weighted toward VARIETY: trying new stamps earns 5x more XP than placing familiar ones
- "Diminishing returns" -- placing the same stamp 20 times in a row gives 0 XP after the 20th
- Challenge completion rewards are capped at 1 per day
- The system celebrates quality of creative exploration over quantity of actions
- Parental dashboard flags if a child seems to be grinding (repetitive patterns)

#### 7. Content Moderation

**Edge Case:** Children might create content that concerns parents (scary themes, violent combinations).

**Mitigation:**
- All stamps are pre-approved child-friendly content -- no user-generated imagery
- The LLM backend can detect and gently redirect concerning combinations
- Parental notification for unusual stamp combinations (optional)
- No text chat -- all communication is through pre-approved stamps and reactions
- "Report to Parent" button on any creation the child wants to discuss

### Sources

1. [^544^] Dead Cells Wiki - Runes and Upgrades. https://deadcells.fandom.com/wiki/Runes_and_upgrades (Accessed 2025)
2. [^545^] Matthew Larn - "Designing for Kids: Creating an Ethical Framework for Digital Play." https://matthewlarn.medium.com/designing-for-kids-creating-an-ethical-framework-for-digital-play-2fb83088c19b (2025)
3. [^546^] Geek Ireland - "Dead Cells is a roguelike masterpiece." https://geekireland.com/dead-cells-roguelike-masterpiece-review/ (2025-04-08)
4. [^548^] Reddit r/deadcells - "How's the meta progression in this game?" https://www.reddit.com/r/deadcells/comments/13e04vd/hows_the_meta_progression_in_this_game/
5. [^549^] ResetEra - "Permanent progression mechanics in roguelites are awesome." https://www.resetera.com/threads/permanent-progression-mechanics-in-roguelites-are-awesome.43890/page-2 (2018-05-21)
6. [^550^] YouTube - "The Perfection of Dead Cells" by Burr. https://www.youtube.com/watch?v=VI4HEvMxH5U (2023-09-29)
7. [^551^] Frontiers in Digital Health - "Don't Gamble With Children's Rights." https://www.frontiersin.org/journals/digital-health/articles/10.3389/fdgth.2022.822933/full (2022-05-02)
8. [^564^] Wikipedia - "Darkest Dungeon." https://en.wikipedia.org/wiki/Darkest_Dungeon (2014-02-21)
9. [^565^] Hamatti.org - "Meta progression with gradual tutorial in roguelike games." https://notes.hamatti.org/gaming/video-games/meta-progression-with-gradual-tutorial-in-roguelike-games (2024-12-31)
10. [^566^] Game Developer - "The Procession of Progression in Game Design." https://www.gamedeveloper.com/design/the-procession-of-progression-in-game-design (2013-05-23)
11. [^567^] Minecraft Wiki - "Creative (Game Mode)." https://minecraft-archive.fandom.com/wiki/Creative_(Game_Mode))
12. [^575^] Super Mario Maker Course Elements. https://kaizomariomaker.fandom.com/wiki/List_of_Course_Elements_in_Super_Mario_Maker
13. [^576^] Scribblenauts Wiki - "Merits." https://scribblenauts.fandom.com/wiki/Merits
14. [^577^] IGN - "Mario Maker 2 Tips for Builders." https://www.ign.com/wikis/super-mario-maker-2/Mario_Maker_2_Tips_for_Builders,_Level_Creation_Tricks (2019-08-01)
15. [^579^] Ars Technica - "Super Mario Maker's level-creation tools unlock slowly over nine days." https://arstechnica.com/gaming/2015/08/super-mario-makers-level-creation-tools-unlock-slowly-over-nine-days/ (2015-08-12)
16. [^580^] FTC - "Complying with COPPA: Frequently Asked Questions." https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions (2025-07-22)
17. [^581^] IJSES - "Appropriate Gameplay under COPPA and GDPR." http://ijses.com/wp-content/uploads/2025/09/62-IJSES-V9N9.pdf
18. [^594^] KSP Wiki - "Tech Tree." https://kerbal-space-program-2.fandom.com/wiki/Tech_Tree
19. [^595^] ACM - "Child Safety, Monetization, and Moderation on Roblox." https://dl.acm.org/doi/10.1145/3706598.3713170 (2022-12-21)
20. [^596^] Thesis - "Procedural Level Generation in 2D Roguelite Games." https://www.theseus.fi/bitstream/handle/10024/873015/Sepanmaa_Tomi.pdf
21. [^597^] Wikipedia - "Child safety on Roblox." https://en.wikipedia.org/wiki/Child_safety_on_Roblox (2024-12-08)
22. [^598^] Habitica Wiki - "What is Habitica?" https://habitica.fandom.com/wiki/What_is_Habitica%3F
23. [^599^] GameRant - "Roguelite Games With The Best Progression Systems." https://gamerant.com/roguelite-games-with-best-progression-systems/ (2024-06-04)
24. [^600^] Toontown Corporate Clash Wiki - "Gags." https://corporateclash.wiki.gg/wiki/Gags
25. [^601^] Hacker News - Meta-progression discussion. https://news.ycombinator.com/item?id=43657882 (2025-04-11)
26. [^605^] Spelunky Daily Challenge. https://spelunkyworld.com/dailychallenge/
27. [^606^] Rogue Legacy 2 Wiki - "Upgrades." https://rogue-legacy-2.fandom.com/wiki/Upgrades
28. [^607^] Spelunky Wiki - "Daily Challenge Mode." https://spelunky.fandom.com/wiki/Daily_Challenge_Mode_(HD)
29. [^608^] Piknik - Sago Mini family apps. https://playpiknik.com/
30. [^609^] Reddit - "Content-based meta progression is vastly superior." https://www.reddit.com/r/roguelites/comments/1ssorwi/opinion_contentbased_meta_progression_is_vastly/
31. [^610^] ResetEra - "Stat-based meta-progression is starting to ruin roguelites." https://www.resetera.com/threads/im-starting-to-feel-that-stat-based-meta-progression-is-starting-to-ruin-roguelites-generally-speaking.1509337/page-2
32. [^623^] Hades Wiki - "Mirror of Night." https://hades.fandom.com/wiki/Mirror_of_Night
33. [^624^] Ooblets Wiki - "Dance Battle." https://ooblets.fandom.com/wiki/Dance_Battle
34. [^625^] Frostilyte - "Arcana Cards & Meta-Progression in Hades 2." https://frostilyte.ca/2025/04/09/arcana-cards-meta-progression-in-hades-2-have-me-hooked/ (2025-04-09)
36. [^626^] Reddit - "Nook Miles Redeemable DIYs; do they rotate?" https://www.reddit.com/r/AnimalCrossing/comments/fq2sii/nook_miles_redeemable_diys_do_they_rotate/
37. [^631^] ScienceDirect - "The effects of game design on students' creative performance." https://www.sciencedirect.com/science/article/abs/pii/S1871187125002573 (2025)
38. [^632^] University XP - "What is Self-Determination Theory?" https://www.universityxp.com/blog/2021/2/9/what-is-self-determination-theory (2021-02-09)
39. [^633^] Sago Mini - "Letter to Parents." https://sagomini.com/article/sago-mini-letter-to-parents/
40. [^634^] PMC - "The art and science of serious game design." https://pmc.ncbi.nlm.nih.gov/articles/PMC12604561/
41. [^635^] Game Developer - "A Quick Breakdown of Self-Determination Theory." https://www.gamedeveloper.com/design/a-quick-breakdown-of-self-determination-theory (2017-12-04)
42. [^636^] Microsoft Learn - "Minecraft block coding academy." https://learn.microsoft.com/en-us/training/paths/minecraft-block-coding-academy/ (2024-07-26)
43. [^637^] Sago Mini World. https://sagomini.com/world/
44. [^638^] Digital Thriving Playbook - "Self-Determination Theory for Multiplayer Games." https://digitalthrivingplaybook.org/big-idea/self-determination-theory-for-multiplayer-games/ (2025-02-13)
45. [^639^] DiVA Portal - "Applying Self-Determination Theory in Game Design." https://uu.diva-portal.org/smash/get/diva2:1875027/FULLTEXT01.pdf
46. [^640^] Newswire - "Sago Mini World Launch." https://www.newswire.ca/news-releases/spark-imagination-wherever-you-go-with-the-launch-of-sago-mini-world-624300843.html (2017-05-25)
47. [^641^] PR Newswire - "Sago Mini World Launch." https://www.prnewswire.com/news-releases/spark-imagination-wherever-you-go-with-the-launch-of-sago-mini-world-624301304.html (2017-05-25)
48. [^642^] TorHoerman Law - "EA Games Lawsuit For Addiction And Mental Harm." https://www.torhoermanlaw.com/video-game-addiction-lawsuit/ea-games-lawsuit-for-addiction-and-mental-harm/ (2026-04-15)
49. [^643^] ZenCastr - "FIFA - Could it 'kick' start a Gambling Addiction?" https://zencastr.com/z/Jao6qE_H
50. [^644^] The Verge - "PS4 game Dreams is an amazing creation tool with an exposure problem." https://www.theverge.com/2020/2/14/21136244/dreams-ps4-game-creation-tool-exposure-problem-curation-media-molecule (2020-02-14)
51. [^645^] Wikipedia - "Dreams (video game)." https://en.wikipedia.org/wiki/Dreams_(video_game))
52. [^646^] PMC - "Psychological Effects of FIFA, PES, and Clash of Clans Games." https://pmc.ncbi.nlm.nih.gov/articles/PMC10408738/ (2005-08-15)
53. [^647^] SSRN - "Play or Pay to Win: Addiction and Loot Boxes in FIFA Ultimate Team." https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4076951 (2022-04-06)
54. [^648^] GameFAQs - "How do you get free plays in the Nintendo Badge Arcade?" https://gamefaqs.gamespot.com/boards/997614-nintendo-3ds/72799776
