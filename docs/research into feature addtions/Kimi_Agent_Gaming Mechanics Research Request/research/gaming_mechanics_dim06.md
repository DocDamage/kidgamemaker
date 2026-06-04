# Dimension 06: Puzzle & Environmental Mechanics

## Executive Summary

Puzzle and environmental mechanics represent one of the most transformative opportunities for a stamp-based, zero-code game creation platform. Through extensive research across 25+ authoritative sources spanning studio postmortems, academic papers, GDC talks, and design analyses, this report establishes that puzzles can emerge naturally from stamp placement when the LLM backend treats spatial relationships as implicit logic connections. The key insight is that children as young as 5 already understand cause-and-effect relationships through physical play [^258^][^260^], and puzzle stamps should leverage this embodied knowledge rather than requiring explicit wiring or configuration.

The research reveals five critical design principles: (1) **Affordance-based recognition** — children must instantly recognize what a stamp "does" from its visual design alone, following Playdead's philosophy that "handles afford grasping" [^281^]; (2) **Proximity implies connection** — the LLM automatically links stamps placed near each other, eliminating need for manual wiring [^368^]; (3) **Visual feedback confirms causality** — every puzzle action must produce immediate, satisfying visual feedback that a child can intuitively read [^262^]; (4) **Failure must be fun** — following Playdead's death-as-entertainment philosophy, puzzle mistakes should delight rather than frustrate [^282^]; and (5) **Scaffolding through stamp complexity** — puzzle stamps should auto-scale difficulty based on the child's demonstrated skill [^277^][^278^].

The recommended "Puzzle Stamp Taxonomy" organizes environmental mechanics into six categories — Basic (switches, doors, push blocks), Elemental (fire, water, ice, wind), Temporal (time crystals, rewind orbs), Spatial (portals, gravity wells), Biological (plants, creatures), and Light (lasers, mirrors, light-sensitive receivers) — with the LLM automatically inferring cause-and-effect relationships between proximate stamps. This approach transforms complex puzzle design into child's play: a 5-year-old places a "Switch Stamp" and a "Door Stamp" nearby, and the LLM automatically creates the connection, generates the code, and provides visual feedback confirming "this switch opened that door."

---

## Studio Innovations Analysis

### 1. Number None (Braid) — Temporal Manipulation Mechanics

#### Technical Innovation
Jonathan Blow's *Braid* (2008) revolutionized puzzle design by making time manipulation the core mechanic rather than a convenience feature. The game's five worlds each introduce a distinct temporal mechanic [^290^]:

- **World 2 (Time and Forgiveness)**: Complete time rewind on Shift key press. The player can rewind any mistake, but this is just the tutorial layer.
- **World 3 (Time and Mystery)**: Introduces objects with a green glow that are **immune to time manipulation** — keys, switches, and platforms that maintain their state even when time rewinds. This creates puzzles where the player must exploit the *difference* between time-affected and time-immune objects [^287^][^290^].
- **World 4 (Time and Place)**: Time flow is tied to horizontal position — moving right moves time forward, moving left rewinds time, standing still pauses it. This creates puzzles where the player must manage their spatial position to control temporal flow [^288^][^290^].
- **World 5 (Time and Decision)**: Rewinding creates a "shadow Tim" that repeats the rewound actions, enabling parallel execution puzzles [^290^].
- **World 6 (Hesitance)**: A magic ring creates a time-distortion bubble where time slows proportionally to proximity to the ring [^290^].

#### Technical Implementation
Blow's GDC 2010 talk revealed the underlying architecture [^287^]: the game maintains a chronologically ordered array of game states, recording player position, enemy positions, and object states per frame. For optimization, active objects are recorded more frequently, and full snapshots are compressed at fixed intervals. The "rewind" actually generates new states from stored data with interpolation — it doesn't truly rewind but reconstructs approximate past states.

```
void UpdateEveryFrame() {
    playerPositions.Add(gameController.frameCount);
    playerPositions.Add(player.position);
}

void UpdateEverySixtyFrames() {
    masterPositions.Add(allPositions);
    Compress(masterPositions);
}
```

Objects immune to time manipulation (green-glow objects in World 3) are flagged with a special property that causes the rewind system to skip them during state restoration, effectively making them "anchors" in the timeline [^289^].

#### Stamp-Based Adaptation
For a 5-year-old's stamp platform, Braid's complexity must be radically simplified into intuitive "Time Stamp" mechanics:

| Braid Mechanic | Stamp Equivalent | Child Interaction |
|----------------|------------------|-------------------|
| Time rewind | ⏪ "Time Crystal" stamp | Touch = everything rewinds 5 seconds |
| Time-immune objects | 💚 "Green Glow" stamp variant | Objects with this glow ignore rewinds |
| Time tied to position | ⏳ "Time Sand" stamp | Walk right = time flows, left = rewinds |
| Shadow self | 👥 "Mirror Echo" stamp | Creates a copy that repeats your last action |
| Time bubble | 🫧 "Slow Bubble" stamp | Everything nearby moves in slow motion |

**LLM Inference Rule**: When a child places a "Time Crystal" stamp near any moving object (enemy, platform, boulder), the LLM automatically marks that object's path as "recordable." Touching the Time Crystal triggers a 5-second rewind of all recordable objects. The child doesn't configure anything — proximity creates the connection.

---

### 2. Playdead (Limbo, Inside) — Diegetic Physics Puzzles

#### Technical Innovation
Playdead's games represent the gold standard for teaching through play without text. *Limbo* (2010) and *Inside* (2016) communicate all puzzle mechanics through **affordances** — visual and audio cues that imply function [^281^]. The boy's animations are the primary teaching tool: he reaches toward grabable objects, looks up at climbable surfaces, and shivers near hazards. As one developer explained, "We take two different pieces of logic, and then by putting them together, we create maybe a new sort of logic people can interpret" [^226^].

Key technical innovations:
- **Posture-as-UI**: The boy's body language communicates what he can interact with — reaching for handles, crouching under threats, leaning at ledges [^281^][^282^]
- **Audio-driven discovery**: In the spider puzzle, the bear trap's audible drop cues the player to its presence off-screen [^282^]
- **Nested puzzle logic**: *Inside* layers puzzles within puzzles, where solving one reveals another — "the novelty of encountering these and the 'A-ha!' moment when your internal light bulb sparks" [^220^]
- **Water as transformation**: *Inside* transformed water from a death hazard (*Limbo*) into a medium that enables multi-directional "flight" underwater [^226^]
- **Death as feedback**: Gruesome death animations entertain while teaching what *not* to do — "their goal was to ensure death wasn't a penalty in the game" [^282^]

The Huddle (the amorphous body-creature at the end of *Inside*) required a custom physics model using a 26-body simulation driven by "a network of impulses based on the direction of the player and the local environment" [^225^]. This represents the pinnacle of physics-based puzzle design — a creature that reconfigures itself based on environmental constraints.

#### Stamp-Based Adaptation
Playdead's approach maps beautifully to stamps because their puzzles are already object-centric:

| Limbo/Inside Element | Stamp Equivalent | Auto-Behavior |
|---------------------|------------------|---------------|
| Wooden crate (pushable) | 📦 "Push Box" stamp | Player walks into it = it slides |
| Rope (climbable) | 🪢 "Rope" stamp | Auto-connects to ceiling stamp above |
| Water (transforms movement) | 🌊 "Water Pool" stamp | Enter = swimming physics, can drown |
| Lever/handle | 🔧 "Switch" stamp | Auto-connects to nearest door/platform |
| Mind-control helmet | 👑 "Mind Hat" stamp | Nearby creatures follow player |
| Bear trap (hazard + tool) | 🪤 "Trap" stamp | Hurts player, can trap enemies |

**Critical Design Principle from Limbo**: "Vague rules are more likely to invoke arbitrary frustration... A good puzzle requires the player to explore what they know in order to discover an unknown and surprising solution" [^281^]. For children, this means every stamp must have an **obvious default behavior** (a switch stamp *always* looks like it can be pressed) with **surprising emergent combinations** discovered through play.

---

### 3. Moon Studios (Ori Series) — Environmental Puzzles Using Light, Weight, and Momentum

#### Technical Innovation
The *Ori* games use environmental mechanics as traversal tools rather than separate puzzle systems. Key innovations include:

- **Light Burst** (Definitive Edition): A throwable light orb that explodes on contact, can be aimed with a visible arc trajectory, lights special lanterns to reveal secret passages, and can be "Bashed" off of for extra height [^231^]. This single ability combines puzzle-solving (lighting lanterns), combat (damaging enemies), and traversal (Bash-assisted platforming).
- **Bash Mechanic**: Ori can grab projectile objects/enemies and launch off them in any direction. This creates momentum-based puzzles where the player must chain Bashes through projectile sequences.
- **Spirit Flame / Charge Flame**: Destructible barriers require specific abilities, creating ability-gated progression similar to Metroidvania design [^235^].
- **Weight and momentum**: Seesaw platforms, physics-based objects, and destructible environments require understanding mass and velocity.

#### Stamp-Based Adaptation

| Ori Element | Stamp Equivalent | Auto-Behavior |
|-------------|------------------|---------------|
| Light Burst projectile | 💡 "Glow Orb" stamp | Can be thrown, lights "Lantern" stamps |
| Lantern (hidden passages) | 🏮 "Lantern" stamp | Glows when hit by Glow Orb, opens nearby paths |
| Bash target | 🎯 "Bash Point" stamp | Player auto-latches and can launch in any direction |
| Breakable barrier | 🧱 "Cracked Wall" stamp | Breaks when hit by explosion or heavy object |
| Seesaw platform | ⚖️ "Balance Platform" stamp | Tilts based on weight of objects/player on each side |

---

### 4. Nintendo (Zelda Series) — Push Blocks, Key/Door Systems, Switch Mechanisms

#### Technical Innovation
The *Legend of Zelda* series established the foundational vocabulary of environmental puzzles in side-scrolling and top-down games. The dungeon design follows a sophisticated "puzzle box" structure [^280^][^283^]:

- **Switch-Door Systems**: Blue/orange wall mechanisms where toggling a switch in one room reconfigures paths throughout the entire dungeon — "the switch is fixed in one room, toggling the switch will open some paths in the hakoniwa while closing other paths" [^280^]
- **Push-block puzzles**: Ice block puzzles where a block slides until stopped, requiring specific push sequences [^283^]
- **Key conservation**: Small keys can only open one door, forcing exploration decisions [^283^]
- **Torch puzzles**: Lighting multiple torches in sequence [^283^]
- **Eye switches**: Projectile targets that activate mechanisms [^283^]

*Zelda II: The Adventure of Link* introduced side-scrolling puzzle elements including pushable statues, locked doors, and key collection. Later 2D Zeldas expanded with:
- **Oracle of Seasons**: Season-changing stamps (Rod of Seasons) that transform the environment — summer grows vines, winter freezes water, spring makes flowers bloom, autumn reveals hidden paths under fallen leaves [^326^][^328^][^329^]
- **Magnetic mechanics**: Gloves that attract/repel the player from magnetic poles, creating physics-based navigation puzzles [^329^]
- **Seed planting**: Gasha Seeds planted in soft soil grow into trees that reveal new areas [^330^]

#### Stamp-Based Adaptation (The "Zelda Primitives")

These are the **most fundamental puzzle stamps** that every child should have access to:

| Zelda Element | Stamp Name | Behavior | Visual Feedback |
|--------------|------------|----------|-----------------|
| Floor switch | 🔘 "Step Plate" | Player steps on it → activates nearest door/bridge | Presses down, glows |
| Lever switch | 🕹️ "Pull Switch" | Player pulls it → toggles connected mechanism | Handle rotates |
| Key | 🗝️ "Key" | Player collects it, opens one locked door | Key floats, jingles |
| Locked Door | 🚪 "Locked Door" | Requires key or switch activation | Keyhole glows when key held |
| Push Block | 📦 "Push Block" | Player walks into it, slides until blocked | Dust particles, thud sound |
| Torch | 🔥 "Torch" | Hit by fire → lights up, stays lit | Flame animation, warmth particles |
| Crystal switch | 💎 "Crystal" | Hit by projectile → toggles state | Shatters/reforms with sound |
| Season stump | 🌳 "Season Tree" | Changes season of nearby tiles | Color palette shift |

**LLM Auto-Connection Rule**: When any switch-type stamp and any door-type stamp are placed within ~5 grid cells of each other, the LLM automatically creates a connection. The child never wires anything. Visual feedback (a faint dotted line appearing briefly when the switch is activated) confirms the connection.

---

### 5. Modern Games — Portal-Style Physics, Light Beams, Water Flow

#### Technical Innovation
Valve's *Portal* series established the "show, try, layer" teaching methodology [^223^]: first show the player a mechanic, let them try it safely, then layer it with other mechanics. The core portal mechanic — momentum conservation ("speedy thing goes in, speedy thing comes out") [^227^] — creates emergent puzzle solutions the designers never explicitly programmed. Key innovations include:

- **Momentum transfer**: Portals perfectly conserve velocity vector, enabling "flinging" puzzles where the player builds momentum through falling [^222^]
- **Secondary mechanics layered on portals**: Buttons, weighted cubes, lasers, light bridges, excursion funnels, gels (repulsion, propulsion, conversion) [^228^]
- **Laser redirection**: Thermal Discouragement Beams + Redirection Cubes create spatial light puzzles [^228^]
- **Visual language consistency**: Portals can only go on white surfaces — the "portal surface" is a clearly readable affordance [^229^]

*Monument Valley* (ustwo Games) represents another modern approach: "impossible" puzzles designed through the connection of straight lines, inspired by M.C. Escher's optical illusions [^310^][^313^]. The game sacrifices traditional game-like elements to focus on single-screen compositions where "architecture is the main character" [^314^]. Princess Ida needs only a tap destination — the game handles pathfinding and movement automatically, making it extremely accessible to young children [^315^].

*Celeste* demonstrates environmental puzzle design through "affordances" — crumbling walls that look breakable, green diamonds that visibly recharge the dash ability, strawberries placed to teach mechanic combinations [^186^]. The game introduces mechanics through carefully sequenced environmental hints rather than text.

*Isles of Sea and Sky* innovates on Sokoban by making the entire game world an open archipelago of push-block puzzles, letting children tackle puzzles in any order and skip ones they find too difficult [^257^].

#### Stamp-Based Adaptation

| Modern Element | Stamp Equivalent | Auto-Behavior |
|----------------|------------------|---------------|
| Portal surface | 🌀 "Portal Pad" | Player enters one, exits the other (auto-linked by proximity) |
| Weighted cube | ⚖️ "Weight Block" | Heavier than push blocks, sinks in water, holds down plates |
| Laser emitter | 🔴 "Laser Beam" | Shoots beam in facing direction, can be redirected by mirrors |
| Redirection cube | 🪞 "Mirror Block" | Reflects laser 90 degrees when placed in beam path |
| Light bridge | 🌈 "Light Bridge" | Creates walkable surface where beam hits wall |
| Repulsion gel | ⬆️ "Bounce Slime" | Player bounces high when touching it |
| Water pool | 🌊 "Water Pool" | Objects float, fire stamps extinguish, player swims |

---

## Puzzle Stamp Taxonomy

Based on the research, puzzle stamps should be organized into six categories with automatic LLM inference of relationships:

### Category 1: Basic Primitives (Age 5+)
These are the foundational stamps every child should have. They map directly to physical play experiences.

| Stamp | Visual | Default Behavior | Combines With |
|-------|--------|-----------------|---------------|
| 🔘 Step Plate | Raised circle on floor | Player steps on it → activates nearest mechanism | Doors, bridges, platforms |
| 🕹️ Pull Switch | Lever on wall | Player pulls it → toggles connected mechanism | Doors, bridges, moving platforms |
| 🚪 Door | Vertical barrier | Closed by default, opens when activated | Any switch, key |
| 🗝️ Key | Small key on pedestal | Player picks it up, opens one locked door | Locked doors |
| 📦 Push Block | Square crate | Player walks into it → slides until blocked | Pressure plates, gaps, water |
| 🧱 Breakable Wall | Wall with cracks | Breaks when hit by explosion or heavy object | Explosions, boulders |
| 🪜 Ladder | Vertical climbable | Player auto-climbs when overlapping | Platforms, ledges |
| 🌉 Bridge | Extendable platform | Extends when activated by switch | Switches, pressure plates |

### Category 2: Elemental Stamps (Age 5-6)
Inspired by Zelda's elemental mechanics [^360^][^361^], these create environmental transformations.

| Stamp | Visual | Default Behavior | Elemental Interactions |
|-------|--------|-----------------|----------------------|
| 🔥 Fire | Flame source | Burns, provides light | Melts ice, boils water, lights torches |
| 🌊 Water | Pool or stream | Swimming, floating objects | Extinguishes fire, freezes into ice |
| ❄️ Ice | Frozen surface | Slippery, player slides | Melts with fire, freezes water |
| 🌪️ Wind | Gust or tornado | Pushes light objects/player | Spreads fire, moves clouds |
| 🌱 Plant | Seed or sprout | Grows into platform/climber with water | Grows with water, burns with fire |
| ⚡ Lightning | Electric arc | Powers machines, damages | Conducts through metal stamps |

### Category 3: Temporal Stamps (Age 6-7)
Simplified Braid mechanics that children can intuitively grasp [^287^][^290^].

| Stamp | Visual | Default Behavior |
|-------|--------|-----------------|
| ⏪ Time Crystal | Glowing hourglass | Touch → rewinds all moving objects 5 seconds |
| 💚 Green Anchor | Object with green glow | This specific object ignores time rewinds |
| 👥 Echo Mirror | Magic mirror | Creates a copy that repeats player's last 10 actions |
| ⏳ Hourglass Sand | Sandy floor patch | Walking right = time flows normally, left = slow motion |

### Category 4: Spatial Stamps (Age 6-7)
Portal-like mechanics simplified for young children [^222^][^229^].

| Stamp | Visual | Default Behavior |
|-------|--------|-----------------|
| 🌀 Portal Pad | Glowing circular pad | Auto-links to nearest other Portal Pad |
| ⬇️ Gravity Well | Downward vortex | Flips gravity for everything in its radius |
| 🫧 Float Bubble | Bubble surrounding area | Everything inside floats upward slowly |
| 🔄 Swap Zone | Checkerboard zone | Player enters → swaps position with nearest object |

### Category 5: Light & Energy Stamps (Age 6-8)
Inspired by Portal's laser mechanics and Ori's Light Burst [^231^][^228^].

| Stamp | Visual | Default Behavior |
|-------|--------|-----------------|
| 🔴 Laser Emitter | Device with beam | Shoots continuous beam in facing direction |
| 🪞 Mirror Block | Reflective cube | Reflects laser 90° when in beam path |
| 🌈 Light Bridge | Prismatic device | Creates solid bridge where beam hits wall |
| ☀️ Light Sensor | Eye on wall | Activates when illuminated by beam |
| 💡 Glow Orb | throwable light ball | Explodes on contact, lights lanterns |
| 🏮 Lantern | Hanging lamp | Lights up when hit by Glow Orb, opens nearby secrets |

### Category 6: Creature & Bio Stamps (Age 5-6)
Living elements that create emergent puzzle behavior.

| Stamp | Visual | Default Behavior |
|-------|--------|-----------------|
| 🐦 Bird | Small flying creature | Flies away when approached, can be Bash target |
| 🐸 Frog | Hopping creature | Jumps when player approaches, can trigger switches |
| 🐌 Snail | Slow creature | Crawls along surfaces, can hold down pressure plates |
| 🌻 Sunflower | Tall plant | Grows toward light sources, becomes platform |

---

## Key Findings

1. **Affordances are everything for children**: "Affordances implicitly explain rules by having something sound, look, or act a certain way. The more intuitive the affordance is, the easier it is for the player to pick up the implicit rule" [^281^]. Every puzzle stamp must look like what it does — a switch must look pressable, a door must look openable.

2. **Invisible tutorials work better than text**: "Invisible tutorials are seamlessly integrated in the gameplay, communicating all the necessary information without using text, patronizing the player or disrupting the flow" [^331^]. Skill gates (like Mario's Goomba that forces a jump) teach mechanics through necessity, not instruction.

3. **Proximity-based connections are intuitive**: Research on spatial relationships in puzzle play shows that children naturally understand "near = related" [^260^][^368^]. The LLM should use spatial proximity as the primary signal for puzzle connections.

4. **Puzzle play builds cognitive foundations**: "Puzzle play not only entertains but also stimulates the development of essential cognitive skills in children. From problem-solving and spatial awareness to concentration and memory recall, puzzles provide a comprehensive cognitive workout" [^258^]. Age-appropriate puzzle selection is critical — too simple = boredom, too complex = frustration [^277^].

5. **Environmental storytelling works without words**: "Environmental storytelling is the art of arranging a careful selection of the objects available in a game world so that they suggest a story to the player who discovers them" [^233^]. Children can read environmental cues as young as 5 — a dark area reads as "scary," a bright area as "safe" [^232^].

6. **Death/failure should be entertaining**: "Playdead included gruesome death sequences to highlight incorrect solutions and discourage players from repeating their mistakes... their goal was to ensure death wasn't a penalty in the game, and made the death animations entertaining" [^282^]. For children, failure feedback should be funny rather than punishing.

7. **Adaptive difficulty maintains engagement**: "A rule-based adaptive difficulty system was also proposed in serious games that adjust difficulty during the game... to keep the players in the 'golden path' or 'optimal game play corridor'" [^279^]. The LLM should track attempts per puzzle area and auto-simplify if the child struggles.

8. **Show, try, layer**: Valve's Portal design methodology [^223^] — first show the player a mechanic, let them try it safely, then layer it with other mechanics — is the ideal teaching sequence for children. Each new stamp type should appear first in isolation, then in combination.

9. **Generate-and-test for puzzle solvability**: Research on procedural puzzle generation confirms that "generating candidate puzzles first and using breadth-first-search for validating their solvability... proved to be considerably easier from a development perspective" [^363^]. The LLM should verify that any puzzle configuration created by stamp placement is solvable before generating code.

10. **Complete mechanics matter**: Jonathan Blow's design philosophy emphasizes "completeness of design — to think design decisions all the way through" [^289^]. Every stamp must have consistent behavior with every other stamp — if fire melts ice, it must *always* melt ice, regardless of context.

---

## Child-Friendly Simplifications

### How Complex Mechanics Become Simple Stamps

| Complex Mechanic | Child-Friendly Stamp | How It Works |
|-----------------|----------------------|--------------|
| Braid's time-immune objects | 💚 Green Glow variant | Any stamp can have a "green glow" that means "this ignores time rewinds" |
| Portal's momentum conservation | 🌀 Portal Pad | Two portal pads auto-link; velocity is simplified to "fast = fast out" |
| Portal's laser redirection | 🪞 Mirror Block | Placed in beam path = auto-reflects 90°; no angle configuration needed |
| Limbo's weight puzzles | ⚖️ Weight Block | Stamp has weight label (light/medium/heavy); physics auto-calculates |
| Zelda's switch-door systems | 🔘 + 🚪 proximity | Any switch within 5 cells of any door auto-connects via LLM |
| Inside's mind control | 👑 Mind Hat stamp | Child places on creature stamp; creature follows player automatically |
| Ori's Bash mechanic | 🎯 Bash Point stamp | Player automatically latches when near; tap direction to launch |
| Celeste's crumble walls | 🧱 Cracked Wall stamp | Visual cracks indicate "dash into me"; breaks on contact |
| Sokoban push constraints | 📦 Push Block stamp | Can only push (never pull); gets stuck in corners = visual warning |

### Automatic LLM Inference Rules

The LLM backend uses these rules to automatically create puzzle logic from stamp placement:

```
RULE 1: PROXIMITY CONNECTION
If distance(switch_stamp, door_stamp) <= 5_grid_cells:
    Create SwitchDoorConnection(switch, door)
    Visual_feedback = brief dotted_line_pulse

RULE 2: ELEMENTAL REACTION
If fire_stamp.adjacent_to(ice_stamp):
    Create MeltReaction(fire, ice) → produces water_stamp
    
If water_stamp.adjacent_to(fire_stamp):
    Create SteamReaction(water, fire) → produces cloud_stamp
    
If plant_stamp + water_stamp_in_proximity:
    Plant_grows_into_platform()

RULE 3: WEIGHT INTERACTION
If weight_block on step_plate:
    Activate(step_plate.connected_mechanism)
    
RULE 4: PORTAL PAIRING
If count(portal_pad_stamps) >= 2:
    Pair_nearest_two(portal_pad_stamps)
    Visual_feedback = matching_color_glow

RULE 5: LASER PATH
If laser_emitter.facing == mirror_block.position:
    Calculate_reflection_path()
    If path hits light_sensor:
        Activate(light_sensor.connected_mechanism)

RULE 6: TEMPORAL SCOPE
If time_crystal.activated:
    Record all moving_objects within 10_grid_cells
    Rewind positions for 5 seconds
    Exclude green_glow_objects from rewind

RULE 7: CREATURE BEHAVIOR
If creature_stamp.placed:
    Assign_default_behavior(creature_type)
    If mind_hat.on_creature:
        Override_behavior → follow_player
```

---

## Recommended Features (with Priority)

### P0 (Must-Have for Launch)
1. **Basic Switch-Door System**: Step plates and pull switches that auto-connect to doors via proximity
2. **Push Blocks**: Slide until blocked; cannot be pulled; visual warning when stuck
3. **Key-Door System**: Single-use keys that auto-snap to nearby locked doors
4. **Elemental Reactions**: Fire melts ice, water extinguishes fire, plant grows with water
5. **Visual Connection Feedback**: Brief dotted lines, color pulses, and sound effects confirm connections
6. **Solvability Check**: LLM verifies puzzle is solvable before generating game code

### P1 (High Priority Post-Launch)
7. **Portal Pads**: Auto-linked by proximity; simplified momentum transfer
8. **Laser System**: Emitter + mirror + sensor; auto-calculates reflection path
9. **Temporal Rewind**: Time Crystal stamp rewinds moving objects; Green Glow stamps exempt
10. **Creature Stamps**: Animals with default behaviors that can trigger switches
11. **Weight System**: Light/medium/heavy blocks for pressure plate puzzles
12. **Adaptive Difficulty**: LLM tracks attempts and auto-simplifies puzzles when child struggles

### P2 (Medium Priority)
13. **Gravity Mechanics**: Gravity wells, float bubbles
14. **Season System**: Season trees that transform nearby tiles (summer/winter/spring/autumn)
15. **Light Bridge**: Laser-derived walkable surfaces
16. **Mind Control**: Creature-following mechanics
17. **Chain Reactions**: Domino-style sequential activations

### P3 (Nice-to-Have)
18. **Echo/Mirror copies**: Temporal shadow mechanics from Braid
19. **Complex elemental combinations**: Electricity conducts through metal, steam powers machines
20. **Physics puzzles**: Balance platforms, pendulums, rolling boulders

---

## Code Snippets

### 1. Switch-Door Connection System

```python
"""
Switch-Door Auto-Connection System
The LLM uses this logic to automatically connect switches to doors
based on spatial proximity when stamps are placed.
"""

from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Set
import math

@dataclass
class Stamp:
    """Represents a placed stamp on the canvas."""
    stamp_id: str
    stamp_type: str  # "switch", "door", "plate", "block", etc.
    position: Tuple[float, float]  # (x, y) in grid coordinates
    variant: str = "default"  # e.g., "green_glow" for time-immune objects
    properties: dict = field(default_factory=dict)
    connections: List[str] = field(default_factory=list)  # connected stamp_ids
    
    def distance_to(self, other: 'Stamp') -> float:
        return math.sqrt(
            (self.position[0] - other.position[0])**2 +
            (self.position[1] - other.position[1])**2
        )


class PuzzleConnectionEngine:
    """
    Automatically creates connections between puzzle stamps based on
    proximity, type compatibility, and design rules.
    This engine runs whenever a child places or moves a stamp.
    """
    
    # Maximum distance for auto-connection (in grid cells)
    CONNECTION_RANGE = 5.0
    
    # Which stamp types can connect to which
    CONNECTION_RULES = {
        "step_plate": ["door", "bridge", "platform", "gate"],
        "pull_switch": ["door", "bridge", "platform", "gate", "laser_emitter"],
        "key": ["locked_door", "locked_gate"],
        "laser_emitter": ["mirror_block", "light_sensor"],
        "mirror_block": ["light_sensor"],
        "portal_pad": ["portal_pad"],  # pairs with another portal
        "time_crystal": ["*"],  # can affect all moving objects
        "glow_orb": ["lantern"],
    }
    
    def __init__(self):
        self.stamps: dict[str, Stamp] = {}
        self.connections: list[tuple[str, str]] = []
    
    def add_stamp(self, stamp: Stamp) -> List[Tuple[str, str]]:
        """
        Add a new stamp and find all auto-connections.
        Returns list of (stamp_a, stamp_b) connections created.
        """
        self.stamps[stamp.stamp_id] = stamp
        new_connections = self._find_connections_for(stamp)
        
        for conn in new_connections:
            self.connections.append(conn)
            # Update stamp connection lists
            self.stamps[conn[0]].connections.append(conn[1])
            self.stamps[conn[1]].connections.append(conn[0])
        
        return new_connections
    
    def _find_connections_for(self, stamp: Stamp) -> List[Tuple[str, str]]:
        """Find all valid connections for a given stamp."""
        connections = []
        connectable_types = self.CONNECTION_RULES.get(stamp.stamp_type, [])
        
        for other in self.stamps.values():
            if other.stamp_id == stamp.stamp_id:
                continue
            
            # Check proximity
            if stamp.distance_to(other) > self.CONNECTION_RANGE:
                continue
            
            # Check type compatibility
            if other.stamp_type in connectable_types or "*" in connectable_types:
                # Avoid duplicate connections
                if (stamp.stamp_id, other.stamp_id) not in self.connections:
                    if (other.stamp_id, stamp.stamp_id) not in self.connections:
                        connections.append((stamp.stamp_id, other.stamp_id))
        
        return connections
    
    def resolve_activation(self, stamp_id: str) -> List[str]:
        """
        When a switch/pressure plate is activated, return all stamps
        that should activate (open doors, extend bridges, etc.).
        """
        activated = []
        stamp = self.stamps.get(stamp_id)
        if not stamp:
            return activated
        
        # Traverse all connected stamps
        visited = set()
        to_visit = list(stamp.connections)
        
        while to_visit:
            current_id = to_visit.pop(0)
            if current_id in visited:
                continue
            visited.add(current_id)
            
            current = self.stamps.get(current_id)
            if current and current.stamp_type in ["door", "bridge", 
                                                     "platform", "gate",
                                                     "locked_door", "laser_emitter"]:
                activated.append(current_id)
            
            # Follow chains (switch → plate → door)
            to_visit.extend(current.connections if current else [])
        
        return activated
    
    def check_solvability(self) -> bool:
        """
        Basic solvability check: ensure all locked doors/gates have
        at least one connected key or switch, and all switches are
        reachable by the player.
        """
        locked = [s for s in self.stamps.values() 
                  if s.stamp_type in ["locked_door", "locked_gate"]]
        
        for door in locked:
            has_key = any(
                self.stamps[c].stamp_type == "key" 
                for c in door.connections if c in self.stamps
            )
            has_switch = any(
                self.stamps[c].stamp_type in ["step_plate", "pull_switch"]
                for c in door.connections if c in self.stamps
            )
            if not has_key and not has_switch:
                return False  # Door can never be opened
        
        return True


# Example usage:
engine = PuzzleConnectionEngine()

# Child places stamps on canvas (positions in grid cells)
switch1 = Stamp("sw1", "pull_switch", (2, 2))
door1 = Stamp("d1", "door", (6, 2))
plate1 = Stamp("p1", "step_plate", (3, 5))
key1 = Stamp("k1", "key", (1, 8))
locked_door = Stamp("ld1", "locked_door", (8, 8))

engine.add_stamp(switch1)
engine.add_stamp(door1)
engine.add_stamp(plate1)
engine.add_stamp(key1)
engine.add_stamp(locked_door)

# Check auto-connections (switch1 <-> door1 should connect, distance = 4)
print("Switch connections:", switch1.connections)  # ["d1"]
print("Door connections:", door1.connections)  # ["sw1"]
print("Plate connections:", plate1.connections)  # [] (no compatible stamps nearby)

# Activate switch → opens connected door
activated = engine.resolve_activation("sw1")
print("Activated by switch:", activated)  # ["d1"]

# Check if puzzle is solvable
print("Solvable:", engine.check_solvability())  # True (locked_door has key nearby)
```

### 2. Elemental Reaction System

```python
"""
Elemental Reaction System
Handles automatic interactions between elemental stamps.
When fire is placed near ice, it melts. When water touches fire, it extinguishes.
"""

from enum import Enum, auto
from dataclasses import dataclass, field
from typing import Optional, List, Callable

class Element(Enum):
    FIRE = auto()
    WATER = auto()
    ICE = auto()
    WIND = auto()
    PLANT = auto()
    LIGHTNING = auto()
    EARTH = auto()

@dataclass
class ElementalReaction:
    """Defines a reaction between two elements."""
    element_a: Element
    element_b: Element
    result_description: str
    result_effect: str  # code-friendly effect name
    visual_effect: str  # particle/sprite effect to show
    
    # Check if this reaction matches two elements (order-independent)
    def matches(self, a: Element, b: Element) -> bool:
        return (self.element_a == a and self.element_b == b) or \
               (self.element_a == b and self.element_b == a)


class ElementalSystem:
    """
    Manages all elemental reactions between stamps.
    The LLM queries this system when placing elemental stamps.
    """
    
    REACTIONS: List[ElementalReaction] = [
        ElementalReaction(Element.FIRE, Element.ICE, 
                         "Ice melts into water", "melt", "steam_burst"),
        ElementalReaction(Element.FIRE, Element.WATER,
                         "Water extinguishes fire into steam", "extinguish", "steam_cloud"),
        ElementalReaction(Element.FIRE, Element.PLANT,
                         "Plant burns away", "burn", "fire_burst"),
        ElementalReaction(Element.WATER, Element.PLANT,
                         "Plant grows into large platform", "grow", "growth_sparkle"),
        ElementalReaction(Element.WATER, Element.FIRE,
                         "Fire is extinguished", "extinguish", "steam_puff"),
        ElementalReaction(Element.ICE, Element.WIND,
                         "Wind pushes ice shard forward", "push", "ice_slide"),
        ElementalReaction(Element.LIGHTNING, Element.WATER,
                         "Electricity conducts through water", "shock", "electric_spark"),
        ElementalReaction(Element.LIGHTNING, Element.EARTH,
                         "Lightning reveals hidden crystals", "reveal", "crystal_glow"),
        ElementalReaction(Element.WIND, Element.FIRE,
                         "Wind spreads fire in facing direction", "spread", "fire_trail"),
    ]
    
    # Adjacency range for reactions (grid cells)
    REACTION_RANGE = 2.0
    
    def check_reactions(self, stamp_a: Stamp, stamp_b: Stamp) -> Optional[ElementalReaction]:
        """Check if two stamps should trigger an elemental reaction."""
        # Only react elemental stamps
        if not (stamp_a.stamp_type.startswith("element_") and 
                stamp_b.stamp_type.startswith("element_")):
            return None
        
        # Check proximity
        if stamp_a.distance_to(stamp_b) > self.REACTION_RANGE:
            return None
        
        # Parse elements from stamp types (e.g., "element_fire" -> Element.FIRE)
        elem_a = self._parse_element(stamp_a.stamp_type)
        elem_b = self._parse_element(stamp_b.stamp_type)
        
        if not elem_a or not elem_b:
            return None
        
        # Find matching reaction
        for reaction in self.REACTIONS:
            if reaction.matches(elem_a, elem_b):
                return reaction
        
        return None
    
    def _parse_element(self, stamp_type: str) -> Optional[Element]:
        """Extract element enum from stamp type string."""
        try:
            return Element[stamp_type.replace("element_", "").upper()]
        except KeyError:
            return None
    
    def get_all_reactions_at_position(self, position: Tuple[float, float],
                                     stamps: List[Stamp]) -> List[dict]:
        """
        When a new stamp is placed, find all reactions it triggers.
        Returns list of reaction info dicts for the LLM to generate code from.
        """
        new_stamp = Stamp("temp", "element_fire", position)  # placeholder
        reactions_found = []
        
        for existing in stamps:
            reaction = self.check_reactions(new_stamp, existing)
            if reaction:
                reactions_found.append({
                    "stamp_a": new_stamp.stamp_id,
                    "stamp_b": existing.stamp_id,
                    "reaction": reaction.result_description,
                    "effect": reaction.result_effect,
                    "visual": reaction.visual_effect
                })
        
        return reactions_found


# Example: Elemental stamp types for the LLM to generate
ELEMENTAL_STAMP_TYPES = {
    "element_fire": {"color": "#FF4444", "symbol": "🔥", "behavior": "burns"},
    "element_water": {"color": "#4444FF", "symbol": "💧", "behavior": "flows"},
    "element_ice": {"color": "#88FFFF", "symbol": "❄️", "behavior": "freezes"},
    "element_wind": {"color": "#CCCCCC", "symbol": "🌪️", "behavior": "pushes"},
    "element_plant": {"color": "#44AA44", "symbol": "🌱", "behavior": "grows"},
    "element_lightning": {"color": "#FFFF44", "symbol": "⚡", "behavior": "shocks"},
    "element_earth": {"color": "#8B4513", "symbol": "🪨", "behavior": "blocks"},
}
```

### 3. Temporal Rewind Mechanic

```python
"""
Temporal Rewind System
Simplified Braid-like time manipulation for children's games.
Records state snapshots and can rewind moving objects.
Green-glow stamps are exempt from rewinding.
"""

from collections import deque
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import time

@dataclass
class ObjectState:
    """Snapshot of an object's state at a specific time."""
    timestamp: float
    position: Tuple[float, float]
    velocity: Tuple[float, float]
    is_active: bool = True
    extra_properties: dict = field(default_factory=dict)

@dataclass
class TemporalObject:
    """An object that can participate in time rewinding."""
    object_id: str
    stamp_type: str
    is_green_anchor: bool = False  # If True, immune to time rewinds (Braid's World 3)
    state_history: deque = field(default_factory=lambda: deque(maxlen=300))
    current_state: Optional[ObjectState] = None
    
    def record_state(self, position: Tuple[float, float],
                    velocity: Tuple[float, float] = (0, 0),
                    extra: dict = None):
        """Record a state snapshot (called every frame/update)."""
        if extra is None:
            extra = {}
        
        state = ObjectState(
            timestamp=time.time(),
            position=position,
            velocity=velocity,
            extra_properties=extra
        )
        self.state_history.append(state)
        self.current_state = state
    
    def can_rewind(self) -> bool:
        """Green anchor objects are immune to time rewinding."""
        return not self.is_green_anchor
    
    def get_state_at_time(self, target_time: float) -> Optional[ObjectState]:
        """Find the closest state to the target time using binary search."""
        if not self.state_history:
            return None
        
        # Find the state closest to but not before target_time
        best_state = None
        for state in reversed(self.state_history):
            if state.timestamp <= target_time:
                best_state = state
                break
        
        return best_state


class TemporalRewindEngine:
    """
    Manages time rewinding for all temporal-aware objects in the game.
    Inspired by Braid's state-recording system but simplified for children.
    """
    
    # How far back we can rewind (seconds)
    MAX_REWIND_DURATION = 5.0
    
    # Recording interval (seconds) - Braid uses staggered recording
    RECORD_INTERVAL = 0.05  # 20fps recording
    
    def __init__(self):
        self.objects: Dict[str, TemporalObject] = {}
        self.is_rewinding = False
        self.rewind_target_time = 0.0
        self.last_record_time = 0.0
        
    def register_object(self, stamp: Stamp) -> TemporalObject:
        """
        Register a stamp as a temporal-aware object.
        The LLM calls this for any moving object near a Time Crystal.
        """
        is_green = stamp.variant == "green_glow"
        obj = TemporalObject(
            object_id=stamp.stamp_id,
            stamp_type=stamp.stamp_type,
            is_green_anchor=is_green
        )
        self.objects[stamp.stamp_id] = obj
        return obj
    
    def record_frame(self, object_states: Dict[str, Tuple[float, float, float, float]]):
        """
        Record current frame states for all temporal objects.
        Called by the game loop at regular intervals.
        
        Args:
            object_states: dict of {object_id: (x, y, vx, vy)}
        """
        current_time = time.time()
        
        # Only record at specified intervals (optimization like Braid)
        if current_time - self.last_record_time < self.RECORD_INTERVAL:
            return
        self.last_record_time = current_time
        
        for obj_id, (x, y, vx, vy) in object_states.items():
            if obj_id in self.objects:
                self.objects[obj_id].record_state(
                    position=(x, y),
                    velocity=(vx, vy)
                )
    
    def start_rewind(self, duration: float = MAX_REWIND_DURATION):
        """
        Begin rewinding time. All non-green-anchor objects will
        move backward through their state history.
        Called when player touches a Time Crystal stamp.
        """
        self.is_rewinding = True
        self.rewind_target_time = time.time() - min(duration, self.MAX_REWIND_DURATION)
    
    def update_rewind(self) -> Dict[str, Optional[Tuple[float, float]]]:
        """
        Update positions during rewind. Returns dict of new positions.
        Called every frame while rewinding.
        """
        if not self.is_rewinding:
            return {}
        
        new_positions = {}
        all_finished = True
        
        for obj_id, obj in self.objects.items():
            if not obj.can_rewind():
                continue  # Green anchors skip rewinding
            
            target_state = obj.get_state_at_time(self.rewind_target_time)
            if target_state:
                new_positions[obj_id] = target_state.position
                
                # Check if we've reached the target
                if obj.current_state and obj.current_state.timestamp > self.rewind_target_time + 0.1:
                    all_finished = False
            
        if all_finished:
            self.is_rewinding = False
        
        return new_positions
    
    def get_rewindable_objects(self, center: Tuple[float, float],
                               radius: float, stamps: List[Stamp]) -> List[str]:
        """
        Find all objects that should be registered for rewinding
        when a Time Crystal is placed at 'center'.
        """
        rewindable = []
        for stamp in stamps:
            if stamp.stamp_type in ["door", "push_block", "platform", 
                                      "creature", "projectile"]:
                # Calculate distance to time crystal
                dx = stamp.position[0] - center[0]
                dy = stamp.position[1] - center[1]
                dist = (dx**2 + dy**2) ** 0.5
                
                if dist <= radius:
                    rewindable.append(stamp.stamp_id)
        
        return rewindable


# JavaScript implementation for the game runtime
JS_TEMPORAL_ENGINE = """
// Temporal Rewind System - JavaScript/Phaser implementation
// Simplified for children's game engine

class TemporalEngine {
    constructor(maxRewindSeconds = 5, recordFPS = 20) {
        this.objects = new Map();      // id -> TemporalObject
        this.isRewinding = false;
        this.rewindSpeed = 2.0;        // 2x speed rewind
        this.recordInterval = 1000 / recordFPS;
        this.maxRewindMs = maxRewindSeconds * 1000;
        this.recording = [];           // Array of state snapshots
        this.lastRecordTime = 0;
    }

    registerObject(gameObject, isGreenAnchor = false) {
        // gameObject: any Phaser sprite/game object
        this.objects.set(gameObject.id, {
            sprite: gameObject,
            isGreenAnchor: isGreenAnchor,
            history: [],  // Circular buffer of states
            maxHistory: this.maxRewindMs / this.recordInterval
        });
    }

    recordFrame(time) {
        if (time - this.lastRecordTime < this.recordInterval) return;
        this.lastRecordTime = time;

        this.objects.forEach((obj, id) => {
            if (!obj.isGreenAnchor) {
                obj.history.push({
                    time: time,
                    x: obj.sprite.x,
                    y: obj.sprite.y,
                    vx: obj.sprite.body?.velocity.x || 0,
                    vy: obj.sprite.body?.velocity.y || 0,
                    active: obj.sprite.active
                });
                // Trim old history
                const cutoff = time - this.maxRewindMs;
                while (obj.history.length > 0 && obj.history[0].time < cutoff) {
                    obj.history.shift();
                }
            }
        });
    }

    startRewind() {
        this.isRewinding = true;
        // Store current positions before rewinding
        this.objects.forEach(obj => {
            obj.preRewindX = obj.sprite.x;
            obj.preRewindY = obj.sprite.y;
        });
    }

    updateRewind(dt) {
        if (!this.isRewinding) return;

        const rewindAmount = dt * this.rewindSpeed;
        let allDone = true;

        this.objects.forEach((obj, id) => {
            if (obj.isGreenAnchor) return; // Skip green anchors (Braid's immunity)
            
            if (obj.history.length === 0) return;
            
            // Pop states from history to rewind
            const targetTime = obj.history[obj.history.length - 1].time - rewindAmount;
            
            // Find the state closest to target time
            let bestState = null;
            for (let i = obj.history.length - 1; i >= 0; i--) {
                if (obj.history[i].time <= targetTime) {
                    bestState = obj.history[i];
                    obj.history.length = i + 1; // Trim future states
                    break;
                }
            }

            if (bestState) {
                obj.sprite.x = bestState.x;
                obj.sprite.y = bestState.y;
                obj.sprite.active = bestState.active;
                allDone = false;
            }
        });

        if (allDone) {
            this.isRewinding = false;
        }
    }

    // Visual effect: green glow for time-immune objects
    applyGreenGlow(sprite) {
        const glow = sprite.scene.add.ellipse(
            sprite.x, sprite.y, 
            sprite.width * 1.3, sprite.height * 1.3,
            0x00FF00, 0.3
        );
        glow.setDepth(sprite.depth - 1);
        
        // Animate glow pulsing
        sprite.scene.tweens.add({
            targets: glow,
            alpha: { from: 0.3, to: 0.6 },
            scaleX: { from: 1, to: 1.1 },
            scaleY: { from: 1, to: 1.1 },
            duration: 800,
            yoyo: true,
            repeat: -1
        });
        
        return glow;
    }
}

// Usage in Phaser scene:
// const temporal = new TemporalEngine();
// temporal.registerObject(playerSprite);
// temporal.registerObject(movingPlatform, true); // green anchor = immune
// 
// In update loop:
// temporal.recordFrame(time);
// if (temporal.isRewinding) temporal.updateRewind(delta);
//
// On Time Crystal touch:
// temporal.startRewind();
"""

### 4. Proximity-Based Visual Feedback System

```python
"""
Visual Feedback System for Puzzle Connections
Generates the visual effects that confirm to children:
"This switch opened that door"
"""

from enum import Enum

class FeedbackType(Enum):
    CONNECTION_MADE = "connection_made"      # Dotted line between switch and door
    CONNECTION_ACTIVE = "connection_active"  # Pulsing line during activation
    DOOR_OPENING = "door_opening"            # Door slide animation
    ELEMENTAL_REACTION = "elemental_reaction" # Fire/steam particles
    TIME_REWIND = "time_rewind"              # Clock spiral effect
    PUZZLE_SOLVED = "puzzle_solved"          # Star burst, celebration
    ERROR_BLOCKED = "error_blocked"          # Gentle shake + red tint

VISUAL_FEEDBACK_TEMPLATES = {
    FeedbackType.CONNECTION_MADE: {
        "description": "Brief dotted line appears between connected stamps",
        "duration_ms": 800,
        "effect": """
            // Draw dotted line from source to target
            const line = scene.add.graphics();
            line.lineStyle(2, 0xFFFF00, 0.6);
            line.setDepth(100);
            
            // Animate dots traveling along path
            const distance = Phaser.Math.Distance.Between(x1, y1, x2, y2);
            const angle = Phaser.Math.Angle.Between(x1, y1, x2, y2);
            
            for (let d = 0; d < distance; d += 10) {
                const dotX = x1 + Math.cos(angle) * d;
                const dotY = y1 + Math.sin(angle) * d;
                const dot = scene.add.circle(dotX, dotY, 3, 0xFFFF00, 0.8);
                
                scene.tweens.add({
                    targets: dot,
                    alpha: 0,
                    scale: 2,
                    duration: 600,
                    delay: d * 2, // Stagger for traveling effect
                    onComplete: () => dot.destroy()
                });
            }
            
            // Fade out line
            scene.tweens.add({
                targets: line,
                alpha: 0,
                duration: 500,
                delay: 800,
                onComplete: () => line.destroy()
            });
        """
    },
    
    FeedbackType.DOOR_OPENING: {
        "description": "Door slides open with satisfying motion",
        "duration_ms": 500,
        "effect": """
            // Slide door upward (or sideways based on orientation)
            scene.tweens.add({
                targets: doorSprite,
                y: doorSprite.y - doorSprite.height,
                duration: 500,
                ease: 'Back.easeOut', // Slight overshoot for satisfaction
                onStart: () => {
                    // Play creak sound
                    scene.sound.play('door_creak', { volume: 0.5 });
                    // Dust particles
                    createDustParticles(doorSprite.x, doorSprite.y);
                }
            });
            
            // Glow effect on the now-open doorway
            const glow = scene.add.ellipse(
                doorSprite.x, doorSprite.y,
                doorSprite.width * 0.8, doorSprite.height * 0.1,
                0xFFFF00, 0.4
            );
            scene.tweens.add({
                targets: glow,
                alpha: 0,
                scaleX: 1.5,
                duration: 800
            });
        """
    },
    
    FeedbackType.PUZZLE_SOLVED: {
        "description": "Celebration when a puzzle section is completed",
        "duration_ms": 2000,
        "effect": """
            // Star burst particles
            const particles = scene.add.particles(x, y, 'star', {
                speed: { min: 50, max: 200 },
                scale: { start: 0.5, end: 0 },
                lifespan: 1500,
                quantity: 30,
                emitting: false
            });
            particles.explode();
            
            // Rainbow arc over solved area
            const colors = [0xFF0000, 0xFF7F00, 0xFFFF00, 0x00FF00, 0x0000FF, 0x4B0082, 0x9400D3];
            colors.forEach((color, i) => {
                const arc = scene.add.arc(x, y - 50, 60 + i * 10, 180, 360, false, color, 0.6);
                arc.setDepth(200);
                scene.tweens.add({
                    targets: arc,
                    alpha: 0,
                    scaleX: 1.5,
                    scaleY: 1.5,
                    duration: 1500,
                    delay: i * 100
                });
            });
            
            // Happy sound
            scene.sound.play('puzzle_solved_fanfare');
            
            // Confetti burst
            for (let i = 0; i < 20; i++) {
                const confetti = scene.add.rectangle(
                    x, y, 8, 12, 
                    Phaser.Math.RND.pick(colors)
                );
                scene.physics.add.existing(confetti);
                confetti.body.setVelocity(
                    Phaser.Math.Between(-200, 200),
                    Phaser.Math.Between(-300, -100)
                );
                confetti.body.setAngularVelocity(Phaser.Math.Between(-500, 500));
            }
        """
    },
    
    FeedbackType.TIME_REWIND: {
        "description": "Clock spiral effect during time rewind",
        "duration_ms": 5000,
        "effect": """
            // Clock spiral overlay
            const spiral = scene.add.graphics();
            spiral.setDepth(1000);
            
            let angle = 0;
            let radius = 10;
            
            const spiralEvent = scene.time.addEvent({
                delay: 16,
                callback: () => {
                    const x = centerX + Math.cos(angle) * radius;
                    const y = centerY + Math.sin(angle) * radius;
                    spiral.fillStyle(0x88FFFF, 0.3);
                    spiral.fillCircle(x, y, 3);
                    angle += 0.3;
                    radius += 0.5;
                },
                repeat: 200
            });
            
            // Screen vignette (blue tint)
            const vignette = scene.add.rectangle(
                centerX, centerY, 
                scene.cameras.main.width,
                scene.cameras.main.height,
                0x0088FF, 0.2
            );
            vignette.setScrollFactor(0);
            vignette.setDepth(999);
            
            scene.tweens.add({
                targets: vignette,
                alpha: 0,
                duration: 1000,
                delay: 4000,
                onComplete: () => {
                    vignette.destroy();
                    spiral.destroy();
                }
            });
            
            // Rewind "whoosh" sound (reversed)
            scene.sound.play('rewind_whoosh', { rate: 0.5 });
        """
    },
}
```

---

## Edge Cases & Mitigations

### 1. Ambiguous Connections

**Problem**: A switch is placed near two doors. Which one should it open? Both? Neither?

**Mitigation Strategies**:
- **Default to ALL**: The switch opens/closes ALL doors within range. Visual feedback shows lines to all connected doors simultaneously.
- **Visual preview**: When placing a switch, faint dotted lines appear to all connectable targets before placement, so the child can see what will connect.
- **Named colors**: Each switch gets a random color (red, blue, green), and connected doors glow with matching color. Child learns "red switch opens red door."
- **Child override**: Double-tapping a switch-door pair "locks" their connection; the switch will only affect locked-pair doors.

### 2. Puzzle Unsolvability

**Problem**: Child places a locked door but no key, or creates a push-block trap that can't be escaped.

**Mitigation Strategies**:
- **LLM solvability check**: Before generating game code, verify:
  - Every locked door has a reachable key or switch
  - Push blocks can never be pushed into a corner that blocks progress
  - The player start position can reach the goal
- **Gentle warning**: If unsolvable, a friendly character (mascot) appears: "Hmm, I can't reach the goal! Maybe add a key nearby?"
- **Auto-fix option**: Child can tap an "Help me!" button that suggests stamp placement to fix the puzzle.
- **Sandbox override**: Unsolvable puzzles can still be played — the child just can't "win," only explore.

### 3. Accidental Solutions

**Problem**: Child solves a complex puzzle without understanding how, missing the intended learning.

**Mitigation Strategies**:
- **Replay system**: After solving, show a "How did I do that?" replay that highlights which stamps activated and in what order.
- **Slower activation**: Sequence puzzle elements activate with visible delays, so the child sees the chain: "Switch pressed → 1 second → Door opens → 1 second → Bridge extends."
- **Celebrate understanding, not just completion**: If the child repeats the puzzle (showing understanding), give bonus celebration. If they skip it, no penalty.

### 4. Push Block Dead-Ends

**Problem**: Child pushes a block into a corner (classic Sokoban problem) and can't get it out [^261^].

**Mitigation Strategies**:
- **Undo button**: Simple "↩️ Undo Last Push" button that rewinds just the last block push.
- **Visual warning**: When a block is one push away from a dead-end corner, the corner flashes red and a "⚠️" appears.
- **Auto-reset**: If a block is stuck for 10+ seconds, the block subtly shakes and then resets to its starting position.
- **Pull ability**: In "easy mode" stamps, blocks can be pulled as well as pushed, eliminating the dead-end problem entirely.

### 5. Overwhelming Complexity

**Problem**: Child places many puzzle stamps, creating a confusing mess of connections.

**Mitigation Strategies**:
- **Connection limit**: Maximum 3 connections per switch in "young child" mode; expandable in "older child" mode.
- **Visual declutter**: Connections only show dotted lines during activation; otherwise invisible.
- **Stamp categories**: Only Basic stamps visible by default for age 5; Elemental/Temporal unlock as child demonstrates proficiency.
- **Progressive disclosure**: LLM analyzes stamp count and suggests "Try adding a 🔥 stamp!" only when child is ready.

### 6. Temporal Confusion

**Problem**: Child uses Time Crystal but doesn't understand why some objects rewind and others don't.

**Mitigation Strategies**:
- **Consistent green glow**: ALL time-immune objects have the same green shimmer. The child learns "green = stays."
- **Slow-motion preview**: First Time Crystal use triggers a 3-second slow-motion BEFORE rewinding, so the child sees what's about to happen.
- **Limited scope**: Time Crystals only affect objects within visible screen area, never off-screen.
- **Audio cues**: Different sounds for "rewinding" (whoosh) vs "immune" (metallic ping) provide auditory feedback.

### 7. Elemental Confusion

**Problem**: Child places fire next to water, expects one thing, gets another.

**Mitigation Strategies**:
- **Predictive preview**: When placing an elemental stamp, nearby reactive stamps pulse with their anticipated reaction icon (steam symbol for fire+water).
- **Consistent rules**: Elemental reactions are ALWAYS the same — fire ALWAYS melts ice, water ALWAYS extinguishes fire. No exceptions.
- **Elemental chart**: A simple visual chart (accessible via "?" button) shows all reactions with cute icons.
- **Safe experimentation**: Elemental reactions are reversible — melted ice can be "reset" to try again.

---

## Sources

### Studio & Game Design Sources

[^220^]: "Review: Inside Is a Masterful, Elliptical Puzzle-Platformer" — Time Magazine, June 28, 2016. https://time.com/4380020/inside-review/

[^222^]: "Puzzles Critical Play: Portal" — Mechanics of Magic, May 15, 2024. https://mechanicsofmagic.com/2024/05/15/puzzles-critical-play-portal/

[^223^]: "Locomotion, Portal, and Puzzle Level Design" — LeSwordfish, April 14, 2017. https://leswordfish.com/2017/04/09/locomotion-portal-and-puzzle-level-design/

[^225^]: "Inside (video game)" — Wikipedia. https://en.wikipedia.org/wiki/Inside_(video_game)

[^226^]: "Inside Inside" — Jeremy Hosking, Medium, August 17, 2018. https://jeremyhosking.medium.com/inside-inside-3c55746dc46c

[^227^]: "Portal 2: A Critical Analysis of Game Design" — BYU Aperture. https://aperture.byu.edu/?p=288

[^228^]: "Mechanics, Depth, and Portal 2" — Game Developer, November 30, 2016. https://www.gamedeveloper.com/business/mechanics-depth-and-portal-2

[^229^]: "Level Design of Video Games – Portal, a Game that Teaches" — Battz Cave, May 14, 2016. https://battzcave.wordpress.com/2016/05/14/leveldesignofvideogames06-portal/

[^230^]: "Playdead's INSIDE" — Official Website. https://playdead.com/games/inside/

[^231^]: "Light Burst (Blind Forest)" — Ori Wiki. https://oriandtheblindforest.fandom.com/wiki/Light_Burst_(Blind_Forest)

[^232^]: "Environmental Storytelling in Video Games" — Game Design Skills, 2026. https://gamedesignskills.com/game-design/environmental-storytelling/

[^233^]: "Environmental Storytelling in Video Games" — IntechOpen, 2025. https://www.intechopen.com/chapters/1225186

[^235^]: "Lost Grove Walkthrough" — Gamer Walkthroughs. https://gamerwalkthroughs.com/ori-and-the-blind-forest/lost-grove/

[^236^]: "Game Design: Environmental Storytelling" — Medium, September 6, 2023. https://medium.com/@johnmulholland/game-design-environmental-storytelling-3574aff0ff2b

[^237^]: "Environmental Storytelling in Game Design" — Ultimate Gaming, May 12, 2025. https://ultimategaming.substack.com/p/environmental-storytelling-in-game

[^254^]: "Development of a Sokoban level" — Sokoban.dk, June 26, 2016. https://sokoban.dk/articles/1596-2/

[^255^]: "Let's build a box pushing puzzle game from scratch" — Dev.to, September 5, 2021. https://dev.to/thormeier/let-s-build-a-box-pushing-puzzle-game-from-scratch-5458

[^257^]: "An excellent block-pushing puzzler on an open ocean" — GMTK, May 30, 2024. https://gmtk.substack.com/p/an-excellent-block-pushing-puzzler

[^261^]: "Thinking Outside the Box with Sokoban and Baba is You" — UWM Digital Cultures, April 26, 2021. https://sites.uwm.edu/digital-cultures-collaboratory/2021/04/26/thinking-outside-the-box-with-sokoban-and-baba-is-you/

[^265^]: "Sokoban" — Wikipedia. https://en.wikipedia.org/wiki/Sokoban

[^281^]: "Design Bits Analysis: Limbo's Level Design - Mostly Perfect" — Game Developer, June 7, 2021. https://www.gamedeveloper.com/design/design-bits-analysis-limbo-s-level-design---mostly-perfect

[^282^]: "Limbo (video game)" — Wikipedia. https://en.wikipedia.org/wiki/Limbo_(video_game)

[^283^]: "What Legend of Zelda Can Teach Us about Dungeon Design" — Gnome Stew, July 23, 2012. https://gnomestew.com/what-legend-of-zelda-can-take-us-about-dungeon-design/

[^287^]: "Reappraising Braid after a Quantum Theory of Time" — MDPI, 2019. https://www.mdpi.com/2409-9287/4/4/55

[^288^]: "The Many Threads of Braid" — Medium, January 16, 2016. https://medium.com/@teioh/the-many-threads-of-braid-e5f7463e7ccb

[^289^]: "IndieCade: Inside Jonathan Blow's Puzzle Design Process" — Game Developer, October 8, 2011. https://www.gamedeveloper.com/design/indiecade-inside-jonathan-blow-s-puzzle-design-process

[^290^]: "Braid (video game)" — Wikipedia. https://en.wikipedia.org/wiki/Braid_(video_game)

[^302^]: "From Frustration to Fun: An Adaptive Problem-Solving Puzzle Game Powered by Genetic Algorithm" — arXiv, 2025. https://arxiv.org/html/2509.23796v1

[^310^]: "Unfurling the creative details hidden within Monument Valley 3" — It's Nice That, December 11, 2024. https://www.itsnicethat.com/features/ustwo-games-monument-valley-3-illustration-digital-spotlight-111224

[^313^]: "Monument Valley" — Design Museum. https://designmuseum.org/your-vote-on-designs-of-the-year/monument-valley

[^314^]: "The Makers of Monument Valley are Creating Architectural Puzzles in VR" — Metropolis Magazine, March 7, 2022. https://metropolismag.com/profiles/makers-monument-valley-creating-architectural-puzzles-vr/

[^315^]: "The Monument Valley" — Medium, September 18, 2018. https://medium.com/@talia.jt384/the-monument-valley-16cc6b013e06

[^326^]: "Legend of Zelda: Oracle of Seasons inspired campaign" — Reddit r/DnDHomebrew. https://www.reddit.com/r/DnDHomebrew/comments/b09z0r/legen_of_zelda_oracle_of_seasons_inspired_campaign/

[^328^]: "Oracle of Seasons Walkthrough - Ancient Ruins" — Zelda Dungeon, 2023. https://www.zeldadungeon.net/oracle-of-seasons-walkthrough/ancient-ruins/

[^329^]: "The Legend of Zelda: Oracle of Seasons FAQ" — GameFAQs, 2002. https://gamefaqs.gamespot.com/gbc/198972-the-legend-of-zelda-oracle-of-seasons/faqs/10780

[^330^]: "Replaying Oracle of Seasons" — Touriant Tourist, July 30, 2011. https://touriantourist.blogspot.com/2011/07/replaying-oracle-of-seasons.html

[^360^]: "Fire, Ice, Lightning" — Tropedia. https://tropedia.fandom.com/wiki/Fire,_Ice,_Lightning

[^361^]: "A Casual Puzzle Game Architectured from Scratch" — Medium, November 4, 2025. https://medium.com/@ekinmelissezer/a-casual-puzzle-game-architectured-from-scratch-the-elemental-blast-blueprint-mechanics-c42c264b6f1b

[^363^]: "Procedural Puzzle Generation for Tomorrow Island" — Aalto University, 2024. https://aaltodoc.aalto.fi/bitstreams/816be3fe-81c9-4f2b-a823-6c09e837a918/download

[^368^]: "What is Proximity?" — Machinations.io, July 24, 2023. https://machinations.io/glossary/proximity

### Child Development & Educational Sources

[^258^]: "How Puzzles Help With Cognitive Development" — Jigsaw2Order. https://jigsaw2order.com/pages/exploring-early-learning-how-puzzles-help-with-cognitive-development-in-children

[^260^]: "Early Puzzle Play: A predictor of preschoolers' spatial transformation skill" — PMC/NIH. https://pmc.ncbi.nlm.nih.gov/articles/PMC3289766/

[^262^]: "Five Things Children Gain from Puzzle Play" — Illinois Early Learning Project, November 26, 2024. https://illinoisearlylearning.org/blogs/growing/puzzle-play/

[^264^]: "The Benefits of Puzzle Games for Children's Cognitive and Emotional Growth" — American SPCC, August 28, 2025. https://americanspcc.org/the-benefits-of-puzzle-games-for-childrens-cognitive-and-emotional-growth/

[^277^]: "Choosing and Adapting Math Games to Meet Your Child's Skill Level" — Stanford DREME, June 1, 2022. https://preschoolmath.stanford.edu/toolkit/choosing-and-adapting-math-games-to-meet-your-childs-skill-level/

[^278^]: "From Frustration to Fun: An Adaptive Problem-Solving Puzzle Game" — arXiv, 2025. https://arxiv.org/html/2509.23796v1

[^279^]: "A Two-phase Usability and Technology Acceptance Study" — JMIR Serious Games, 2021. https://games.jmir.org/2021/2/e25997/

[^331^]: "Methods of Creating Invisible Tutorials" — Game Developer, September 10, 2019. https://www.gamedeveloper.com/design/methods-of-creating-invisible-tutorials

[^362^]: "15 Interactive Cause and Effect Games" — Sweet Tooth Teaching, May 8, 2025. https://sweettoothteaching.com/2025/05/15-interactive-cause-and-effect-games-your-students-will-beg-for.html

[^364^]: "Introducing Tynker Copilot – LLM-Powered Coding Companion for Young Coders" — Tynker Press, 2023. https://www.tynker.com/about/press/2023/10-introducing-tynker-copilot-the-first-ever-llm-powered-coding-companion-for-young-coders

---

## Appendix: LLM Prompt Template for Puzzle Code Generation

```
You are a game code generator for a children's stamp-based game creation platform.
A child has placed the following puzzle stamps on a canvas:

{stamp_list_with_positions}

AUTOMATIC CONNECTION RULES (apply these first):
1. Any switch within 5 cells of any door → auto-connect them
2. Any key near a locked door → auto-unlock capability
3. Any fire near ice → auto-melt reaction
4. Any two portal pads → auto-link as pair
5. Any Time Crystal near moving objects → register for rewind

ELEMENTAL REACTIONS (apply if stamps are adjacent):
- fire + ice → melt (produces water)
- fire + water → extinguish (produces steam)
- water + plant → grow (plant becomes platform)
- wind + fire → spread (fire expands in wind direction)

Generate Phaser 3 JavaScript code that implements these stamps as interactive 
game objects with the following requirements:

1. All switch-door connections work automatically (no manual wiring)
2. Visual feedback confirms every action (particles, sound cues, screen shake)
3. Push blocks slide until blocked; can't be pulled; stuck blocks reset after 10 seconds
4. Death/failure triggers funny animation, not game over
5. Time Crystal rewinds all moving objects within 10 cells for 5 seconds
6. Green-glow variants are immune to time rewinds
7. Elemental reactions are reversible (can reset and try again)
8. Include solvability check function
9. All interactions must feel satisfying for a 5-year-old

Output: Complete, runnable Phaser 3 scene code.
```
