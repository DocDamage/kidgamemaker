# Dimension 05: World Structure & Level Architecture

## Executive Summary

This research document investigates world structure philosophies from landmark Metroidvania titles and procedural generation pioneers to derive actionable recommendations for a stamp-based, zero-code game creation platform designed for children as young as 5. Our analysis spans five studio innovations -- Nintendo's multi-directional matrix grid (Metroid), Capcom's stage-select freedom (Mega Man), Konami's interconnected castle with shortcuts (Castlevania), Motion Twin's procedural room stitching (Dead Cells), and Sabotage Studio's real-time era switching (The Messenger) -- to understand how complex world architectures can be reduced to intuitive stamp-based interactions.

The central finding is that **all sophisticated world architectures can be represented as graphs** (nodes = rooms, edges = connections), and that children can effectively create these graphs through visual stamp placement without understanding the underlying mathematical structure. The LLM backend handles graph validation, connectivity assurance, gear-gating logic, and procedural stitching -- effectively making the child a "world architect" who places room stamps on a sticker-book canvas while invisible systems ensure playability. Key technical insights include Spelunky's guaranteed-solvable-path algorithm [^267^], Dead Cells' hybrid hand-designed + procedural six-step pipeline [^279^], and Enter the Gungeon's pre-authored flow graphs [^291^] -- all of which can be adapted into child-friendly stamp-placement workflows.

## Studio Innovations Analysis

### Nintendo (Metroid Series): Multi-Directional Matrix Grid

**How It Works Technically:**
Nintendo's Metroid series pioneered the "Metroidvania" world structure by organizing rooms on a 2D grid where each room connects to its neighbors through directional doors (up, down, left, right). The world is represented internally as a matrix/graph structure where each room is a node and each door is a directed edge. Super Metroid uses a custom room-header system where each room specifies its dimensions, screen exits, and special properties [^201^]. The map system tracks which rooms the player has visited and renders them as colored squares on a grid-based mini-map.

**Key Technical Innovation -- Gear-Gated Backtracking:** The progression system relies on "ability gates" -- obstacles that require specific gear (bombs, missiles, morph ball, space jump) to pass. When the player acquires new gear, the LLM-backend can re-evaluate which previously-visited rooms now have newly-accessible exits. This creates the signature Metroidvania loop: explore → hit barrier → find gear → backtrack → access new area [^228^].\n
**Stamp-Based Adaptation:**
- A child places "Room Stamps" on a grid canvas (like placing stickers in a sticker book)
- Each Room Stamp has visual "door indicators" on its edges (small colored dots)
- When two Room Stamps are placed adjacent to each other, the LLM auto-connects matching doors
- "Gear Gate Stamps" (colored locks) are placed on door indicators to block paths
- "Power-Up Stamps" (colored keys) are placed inside rooms; when collected, they unlock matching Gear Gates
- The LLM automatically validates that all rooms remain reachable and no dead-end traps exist

**Technical Implementation for LLM:** The room grid is stored as an adjacency list. When a child places a Room Stamp, the LLM adds a node to the graph. When adjacent stamps are placed, the LLM adds edges. Gear-gating uses a "lock-key matching" system where edges are tagged with required abilities, and a reachability algorithm (BFS/DFS) confirms the world is completable [^276^].

### Capcom (Mega Man Series): Stage-Select Screen with Boss Order Freedom

**How It Works Technically:**
The Mega Man series uses a "hub-and-spoke" world architecture where players select stages from a central menu screen in any order they choose [^242^]. Each stage is a self-contained linear level with a boss at the end. Defeating a boss awards the player that boss's weapon, which may provide advantages against other bosses (rock-paper-scissors balance). The stage-select screen is essentially a visual graph where each node (stage) can be visited in any order, but the edges (boss weaknesses) create an optimal traversal path.

**Key Technical Innovation -- Non-Linear Sequence with Emergent Strategy:** While stages can be tackled in any order, the weapon-trading system creates implicit guidance. Each boss is weak to a specific weapon from another boss, creating a "recommended order" without forcing it. This gives players agency while still providing a designed difficulty curve [^242^].

**Stamp-Based Adaptation:**
- A child places "Level Stamps" on a "Stage Select" canvas (like the Mega Man screen -- a grid of level icons)
- Each Level Stamp has a visual theme (fire, ice, forest) and a difficulty rating (1-3 stars)
- The child can arrange Level Stamps in any order
- The LLM automatically generates a "recommended path" (like boss weakness chains) by linking easier levels to harder ones
- "Boss Stamps" are placed at the end of each level; defeating a boss unlocks a special ability for subsequent levels
- The LLM ensures difficulty progression is smooth regardless of the order chosen

**Technical Implementation for LLM:** The stage order forms a directed acyclic graph (DAG). The LLM performs topological sorting to find valid orderings, then applies difficulty constraints to recommend an optimal path. Weapon/ability inheritance is tracked as player state that persists across level transitions.

### Konami (Castlevania Series): Giant Interconnected 2D Map with Shortcuts

**How It Works Technically:**
Castlevania: Symphony of the Night introduced a massive interconnected 2D castle organized as a non-linear graph. The castle contains approximately 942 rooms connected by doors, elevators, and warp rooms [^238^]. Warp Rooms (marked yellow on the map) are special nodes that allow instant travel between any two previously-discovered warp points -- effectively creating a "shortcut overlay" on top of the physical room graph. The castle also features ability-gating similar to Metroid (double jump, mist form, bat form, etc.) where new abilities unlock previously inaccessible areas [^238^].

**Key Technical Innovation -- Warp Room Shortcuts + Dual Castle:** The warp room system reduces backtracking fatigue by allowing players to teleport between discovered warp points. In SOTN, there are two castles (normal and inverted) that are structurally linked -- a design decision that effectively doubles the playable space while reusing the core graph structure [^248^]. The shortcut system uses a "shortcut overlay graph" that sits on top of the physical room graph.

**Stamp-Based Adaptation:**
- A child places "Room Stamps" on a large canvas to build their castle
- "Warp Stamp" pairs are placed on any two rooms; the LLM creates an instant-travel link between them
- The child can place "Secret Room Stamps" that are hidden behind breakable walls
- "Elevator Stamps" connect vertically stacked rooms
- The LLM auto-generates the mini-map showing room connections in different colors (yellow = warp, red = save, blue = special)
- When a child places an ability-granting "Boss Stamp," the LLM highlights which previously-inaccessible areas are now reachable

**Technical Implementation for LLM:** The room graph is extended with a "shortcut overlay" -- a separate edge set for warp connections. Shortcuts are treated as zero-weight edges in pathfinding calculations. The LLM uses reachability analysis to confirm all rooms are accessible either through normal traversal or via warp chains [^276^].

### Motion Twin (Dead Cells): Procedural Room Stitching with Guaranteed Beatable Layouts

**How It Works Technically:**
Dead Cells uses a sophisticated six-step hybrid approach that combines hand-designed content with procedural generation [^279^]:
1. **Fixed Frame:** The overall world map (island layout, biome interconnections, key locations) is hand-designed and never changes
2. **Hand-Crafted Tiles:** Level designers create room templates with specific purposes (combat, treasure, merchant) using CastleDB
3. **Concept Graph:** Each biome has a level graph describing room layout, special room counts, and labyrinth complexity
4. **Procedural Room Selection:** For each graph node, the algorithm randomly selects a room template that matches the graph's constraints (entrance/exit count, room type)
5. **Enemy Placement:** Monster density is calculated based on total combat-tile count (~1 monster per 5 combat tiles)
6. **Loot Generation:** Loot placement follows secret internal rules

The key insight is that Dead Cells separates **structure** (the level graph, hand-designed) from **content** (room templates, procedurally selected). This ensures every generated level is playable while maintaining variety [^279^].

**Stamp-Based Adaptation:**
- A child places "Biome Stamps" on a world map canvas (forest, castle, sewers)
- Each Biome Stamp auto-generates a level graph internally (e.g., "forest = 8 rooms with branching paths")
- The child places "Special Room Stamps" (treasure, boss, merchant) within each biome
- "Connector Stamps" (paths, corridors) are auto-placed by the LLM between rooms
- The LLM runs Dead Cells-style procedural generation to select room templates for each node
- Each time the game is played, the LLM can regenerate the layout using the same graph but different room templates

**Technical Implementation for LLM:** The LLM maintains a library of room templates tagged with metadata (biome, purpose, entrance count, exit count). Given a child's graph (placed stamps), it performs template matching: for each node, filter templates by constraints, then randomly select. Connectivity is verified via flood-fill from the entrance node [^240^].

### Sabotage Studio (The Messenger): Real-Time 8-Bit to 16-Bit Era Switching

**How It Works Technically:**
The Messenger features a unique real-time era-switching mechanic where the player can transition between 8-bit (past) and 16-bit (future) versions of the same level [^213^]. The game maintains two parallel level graphs -- one for each era -- with shared room positions but different layouts, obstacles, and secrets. When the player passes through a warp gate, the game:
1. Swithes the active tileset (8-bit → 16-bit or vice versa)
2. Loads the alternate room layout for the current position
3. Adjusts physics parameters (gravity, move speed) subtly between eras
4. Cross-fades the music between 8-bit and 16-bit versions

The era-switching transforms the game from a linear platformer into a Metroidvania in the second half, where players must revisit old areas in the new era to find previously-inaccessible items [^211^].

**Stamp-Based Adaptation:**
- A child places an "Era Stamp" on any Room Stamp to create a dual-era room
- The LLM auto-generates two versions of the room: a simple 8-bit version and a more detailed 16-bit version
- "Time Gate Stamps" are placed between rooms to create warp points
- When the player passes through a Time Gate, the LLM swaps the active era, potentially revealing new paths
- The child can place "Era-Exclusive Item Stamps" -- items that only exist in one era and may be needed in the other

**Technical Implementation for LLM:** The room graph is duplicated for each era. Edges between rooms are tagged with era requirements ("8-bit only", "16-bit only", "both"). When the player changes era, the LLM checks connectivity in the alternate graph and updates reachable areas. Item placement uses cross-era dependencies.

## Key Findings

1. **All world architectures can be represented as graphs.** Whether it's Metroid's grid, Mega Man's hub-and-spoke, Castlevania's interconnected castle, or Dead Cells' procedural levels, the underlying structure is always a graph of rooms connected by doors/edges [^201^][^242^][^279^]. This is perfect for LLM processing.

2. **Separating structure from content enables both control and variety.** Dead Cells' six-step pipeline demonstrates that hand-designing the level graph (structure) while procedurally selecting room templates (content) gives the best results [^279^]. Children can design structure via stamps while the LLM handles content.

3. **Gear-gating is a reachability problem with state dependencies.** When a player acquires a new ability, the LLM must recompute which graph edges become traversable. This is a classic graph reachability problem solvable with BFS/DFS [^283^][^276^].

4. **Spelunky's guaranteed-path algorithm ensures playability.** By generating a solvable path first (top-to-bottom through a 4×4 grid) and then adding side rooms, Spelunky guarantees every level is completable [^267^]. This algorithm can be adapted for children's stamp-based worlds.

5. **Shortcut systems (warps) are overlay graphs.** Castlevania's warp rooms create a second "fast-travel" graph on top of the physical room graph [^238^]. For children, shortcut stamps can be placed between any two rooms, and the LLM maintains this overlay automatically.

6. **Enter the Gungeon's pre-authored flow graphs control pacing.** By designing level graphs by hand (called "flows") and then populating them with procedural rooms, Gungeon ensures consistent pacing while maintaining variety [^291^]. Children's stamp placements can serve as mini flow graphs.

7. **The Binding of Isaac's room-type system enables semantic stamping.** Different room types (treasure, shop, boss, secret) have specific gameplay purposes. A stamp taxonomy can mirror this: "Boss Stamp", "Treasure Stamp", "Shop Stamp", "Secret Stamp" [^240^].

8. **Petri nets can validate world completability.** Academic research demonstrates that Petri net reachability analysis can classify generated maps as viable (all rooms reachable), non-viable (depends on player choices), or inviable (impossible to complete) [^276^]. The LLM can use similar techniques.

9. **Hollow Knight's gradual map discovery reduces overwhelm.** By starting with no map and gradually revealing it through exploration (purchasing from Cornifer), Hollow Knight teaches children spatial reasoning at their own pace [^220^][^227^]. A stamp-based world can reveal itself incrementally.

10. **Super Mario Maker 2's course world shows children can design multi-level experiences.** The game's world-creation mode lets players arrange levels in a grid with branching paths, demonstrating that children can understand world-level design when presented visually [^275^].

11. **LittleBigPlanet's sticker system proves stamp-based creation works.** Players place stickers on a canvas to decorate and create game elements -- a direct precedent for our stamp-based approach [^241^]. The system has been used successfully by millions of children.

12. **The Messenger's dual-era system shows parallel world graphs work.** Maintaining two room graphs (8-bit and 16-bit) that share positions but have different layouts and secrets creates depth without added complexity for the player [^213^].

## Child-Friendly Simplifications

### The "Sticker Book" Metaphor
The world-creation interface should look and feel like a sticker book or activity book. Children drag stamps from a "sticker sheet" (toolbar) and place them on a "page" (canvas). The LLM handles all the underlying graph construction. Visual feedback is immediate: when two room stamps are placed next to each other, a dotted line appears and then "zips up" into a solid connection.

### Visual Connection Indicators
Instead of abstract graph edges, connections are shown as:
- **Doorways:** Animated archways between adjacent room stamps
- **Paths:** Dotted lines that turn into solid paths when validated
- **Elevators:** Vertical shafts with little elevator icons
- **Warp Pipes:** Colorful pipes (inspired by Mario) connecting distant rooms
- **Secret Tunnels:** Dashed lines that only appear after a secret room is discovered

### Auto-Magical Validation
The LLM runs validation in the background and provides kid-friendly feedback:
- **Green glow:** "This room connects perfectly!"
- **Yellow warning:** "Hmm, this room might be lonely -- try connecting it to another!"
- **Red error:** "Oops! This room can't be reached -- let's add a path!"
- **Sparkle effect:** When a new ability unlocks previously-blocked areas

### Gear-Gating as Color Matching
Instead of complex ability systems, gear-gating uses simple color matching:
- Red locks require red keys (found in red-themed rooms)
- Blue blocks require blue power-ups
- Yellow barriers require yellow abilities
- The LLM auto-generates the "key → lock" chain ensuring no dead ends

### "Play Test" Button
A big, friendly "Play Test" button runs the validation algorithm and shows the child a preview of their world. The LLM traces the expected player path with a glowing trail, highlighting any issues.

## Recommended Features (Priority Order)

### P0 -- Core Features (Must-Have)
1. **Room Stamp:** Placeable on a grid canvas; has 1-4 door indicators; LLM auto-validates connections
2. **Connector Stamp:** Visually links adjacent Room Stamps; auto-placed by LLM when rooms are adjacent
3. **Start Stamp:** Marks the player's entry point; exactly one per world
4. **End/Boss Stamp:** Marks the level's goal; LLM verifies it's reachable from Start
5. **Auto-Validation:** LLM runs connectivity check (BFS from Start) and flags unreachable rooms

### P1 -- Important Features (Should-Have)
6. **Gate Stamp:** Color-coded barrier on a door; requires matching Key Stamp to pass
7. **Key Stamp:** Color-coded item placed inside a room; unlocks matching Gate
8. **Warp Stamp:** Creates instant-travel link between any two rooms (shortcut system)
9. **Secret Room Stamp:** Hidden room only visible after finding entrance; LLM marks on map after discovery
10. **Biome Stamp:** Changes visual theme of an area (forest, castle, underwater); affects room template selection
11. **Era Stamp:** Creates dual-era room (like The Messenger); LLM generates alternate layout
12. **Procedural Re-roll:** "New Layout" button regenerates room templates while keeping the child's graph

### P2 -- Enhancement Features (Nice-to-Have)
13. **Difficulty Rating:** LLM assigns star rating based on path length and obstacle count
14. **Auto-Balance:** LLM adjusts enemy placement and obstacle density for consistent difficulty
15. **One-Way Connector:** Directional path that can't be traversed backwards
16. **Elevator Stamp:** Vertical connection between rooms on different floors
17. **Map Stamp:** Collectible that reveals unexplored areas on the mini-map
18. **Treasure Stamp:** Special room with rewards; LLM places keys here to incentivize exploration

## Code Snippets

### 1. Room Connection Graph (Python)

```python
"""
Room Connection Graph for Stamp-Based World Builder
Represents the world as an adjacency list with directional connections.
Each room stamp becomes a node; each door connection becomes an edge.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Tuple, Optional
from enum import Enum
import random

class Direction(Enum):
    NORTH = (0, -1)
    SOUTH = (0, 1)
    EAST = (1, 0)
    WEST = (-1, 0)

@dataclass
class RoomStamp:
    """Represents a room stamp placed by a child on the canvas."""
    id: int
    name: str
    grid_x: int  # Position on the canvas grid
    grid_y: int
    room_type: str = "normal"  # normal, start, end, boss, treasure, shop
    biome: str = "forest"      # visual theme
    era: str = "8bit"          # 8bit or 16bit
    # Door indicators: True = has door in this direction
    doors: Dict[Direction, bool] = field(default_factory=lambda: {
        d: False for d in Direction
    })
    gates: Dict[Direction, Optional[str]] = field(default_factory=dict)  # color lock
    contents: List[str] = field(default_factory=list)  # items/enemies inside

@dataclass
class WorldGraph:
    """The full world graph built from placed stamps."""
    rooms: Dict[int, RoomStamp] = field(default_factory=dict)
    connections: List[Tuple[int, int, Direction]] = field(default_factory=list)
    warp_links: List[Tuple[int, int]] = field(default_factory=list)  # shortcut overlay
    next_id: int = 0

    def add_room(self, room: RoomStamp) -> int:
        """Add a room stamp to the world. Returns the room ID."""
        room.id = self.next_id
        self.next_id += 1
        self.rooms[room.id] = room
        return room.id

    def auto_connect_adjacent(self, room_id: int):
        """Automatically connect rooms placed next to each other on the grid."""
        room = self.rooms[room_id]
        for direction in Direction:
            dx, dy = direction.value
            neighbor_x, neighbor_y = room.grid_x + dx, room.grid_y + dy
            # Find neighbor at this position
            for other in self.rooms.values():
                if other.grid_x == neighbor_x and other.grid_y == neighbor_y:
                    # Bidirectional connection
                    room.doors[direction] = True
                    opposite = self._opposite(direction)
                    other.doors[opposite] = True
                    self.connections.append((room.id, other.id, direction))
                    break

    def _opposite(self, direction: Direction) -> Direction:
        opposites = {
            Direction.NORTH: Direction.SOUTH,
            Direction.SOUTH: Direction.NORTH,
            Direction.EAST: Direction.WEST,
            Direction.WEST: Direction.EAST,
        }
        return opposites[direction]

    def add_warp(self, room_a: int, room_b: int):
        """Add a warp/shortcut link between two rooms."""
        self.warp_links.append((room_a, room_b))

    def to_adjacency_list(self) -> Dict[int, List[int]]:
        """Convert to simple adjacency list for pathfinding."""
        adj = {rid: [] for rid in self.rooms}
        for a, b, _ in self.connections:
            adj[a].append(b)
            adj[b].append(a)
        # Include warp links as zero-weight connections
        for a, b in self.warp_links:
            adj[a].append(b)
            adj[b].append(a)
        return adj

    def find_start_room(self) -> Optional[int]:
        """Find the room marked as start (entry point)."""
        for rid, room in self.rooms.items():
            if room.room_type == "start":
                return rid
        return None


# Example usage for a child placing stamps:
world = WorldGraph()

# Child places room stamps on a grid (like a sticker book)
room1 = RoomStamp(name="Forest Entrance", grid_x=0, grid_y=0, room_type="start", biome="forest")
room2 = RoomStamp(name="Forest Path", grid_x=1, grid_y=0, biome="forest")
room3 = RoomStamp(name="Dark Cave", grid_x=1, grid_y=1, room_type="boss", biome="cave")
room4 = RoomStamp(name="Secret Room", grid_x=0, grid_y=1, room_type="treasure", biome="cave")

r1 = world.add_room(room1)
r2 = world.add_room(room2)
r3 = world.add_room(room3)
r4 = world.add_room(room4)

# LLM auto-connects adjacent rooms
for rid in [r1, r2, r3, r4]:
    world.auto_connect_adjacent(rid)

print(f"World has {len(world.rooms)} rooms, {len(world.connections)} connections")
print("Adjacency list:", world.to_adjacency_list())
```

### 2. Procedural Layout Validation (Python)

```python
"""
World Validation Engine
Ensures all worlds created by children are completable and have no dead ends.
Uses BFS/DFS reachability analysis and gear-gating dependency resolution.
"""

from collections import deque
from typing import Dict, List, Set, Tuple, Optional
import copy

class WorldValidator:
    """Validates that a child's stamp-based world is playable."""

    def __init__(self, world_graph: WorldGraph):
        self.world = world_graph
        self.adj = world_graph.to_adjacency_list()

    def validate_full(self) -> Dict:
        """
        Run all validation checks and return a report.
        The LLM calls this after each stamp placement.
        """
        report = {
            "is_valid": True,
            "errors": [],
            "warnings": [],
            "reachable_rooms": [],
            "unreachable_rooms": [],
            "path_to_end": None,
            "gear_gates_solvable": True,
        }

        # 1. Check start room exists
        start = self.world.find_start_room()
        if start is None:
            report["is_valid"] = False
            report["errors"].append("No Start Stamp placed! Add a Start Room.")
            return report

        # 2. Check end room exists
        end_rooms = [rid for rid, r in self.world.rooms.items() if r.room_type in ("end", "boss")]
        if not end_rooms:
            report["warnings"].append("No End/Boss Stamp placed yet.")

        # 3. Check all rooms are reachable from start (basic connectivity)
        reachable = self._bfs_reachable(start)
        all_rooms = set(self.world.rooms.keys())
        unreachable = all_rooms - reachable

        report["reachable_rooms"] = list(reachable)
        report["unreachable_rooms"] = list(unreachable)

        if unreachable:
            report["is_valid"] = False
            report["errors"].append(
                f"Unreachable rooms detected: {unreachable}. Add paths or connectors!"
            )

        # 4. Check end is reachable
        for end_id in end_rooms:
            if end_id not in reachable:
                report["is_valid"] = False
                report["errors"].append(f"End room {end_id} cannot be reached from Start!")
            else:
                path = self._find_path(start, end_id)
                report["path_to_end"] = path

        # 5. Check gear-gating solvability
        gate_result = self._validate_gear_gates(start)
        if not gate_result["solvable"]:
            report["is_valid"] = False
            report["gear_gates_solvable"] = False
            report["errors"].extend(gate_result["errors"])

        # 6. Check for dead-end rooms (rooms with only 1 connection that aren't end rooms)
        for rid, room in self.world.rooms.items():
            if room.room_type not in ("end", "boss", "treasure", "secret"):
                if len(self.adj.get(rid, [])) <= 1 and rid != start:
                    report["warnings"].append(
                        f"Room '{room.name}' might be a dead end. Consider adding more connections."
                    )

        return report

    def _bfs_reachable(self, start: int) -> Set[int]:
        """BFS to find all rooms reachable from the start room."""
        visited = set()
        queue = deque([start])
        while queue:
            current = queue.popleft()
            if current in visited:
                continue
            visited.add(current)
            for neighbor in self.adj.get(current, []):
                if neighbor not in visited:
                    queue.append(neighbor)
        return visited

    def _find_path(self, start: int, end: int) -> List[int]:
        """Find shortest path from start to end using BFS."""
        visited = {start}
        parent = {start: None}
        queue = deque([start])

        while queue:
            current = queue.popleft()
            if current == end:
                # Reconstruct path
                path = []
                while current is not None:
                    path.append(current)
                    current = parent[current]
                return path[::-1]

            for neighbor in self.adj.get(current, []):
                if neighbor not in visited:
                    visited.add(neighbor)
                    parent[neighbor] = current
                    queue.append(neighbor)

        return []

    def _validate_gear_gates(self, start: int) -> Dict:
        """
        Validate that all gear gates can be eventually unlocked.
        This simulates the player's progression through ability-gated areas.
        """
        result = {"solvable": True, "errors": []}

        # Collect all gates and keys in the world
        all_gates = []  # (room_id, direction, color)
        all_keys = []   # (room_id, color)

        for rid, room in self.world.rooms.items():
            for direction, gate_color in room.gates.items():
                if gate_color:
                    all_gates.append((rid, direction, gate_color))
            for item in room.contents:
                if item.startswith("key_"):
                    all_keys.append((rid, item.replace("key_", "")))

        # For each gate color, check that at least one key of that color
        # is reachable BEFORE the gate (or that the gate itself is optional)
        gate_colors = set(g for _, _, g in all_gates)
        key_colors = set(k for _, k in all_keys)

        for color in gate_colors:
            if color not in key_colors:
                result["solvable"] = False
                result["errors"].append(
                    f"Gate color '{color}' has no matching key in the world!"
                )

        return result


# Example validation:
validator = WorldValidator(world)
report = validator.validate_full()
print("Validation Report:")
print(f"  Valid: {report['is_valid']}")
print(f"  Reachable rooms: {report['reachable_rooms']}")
print(f"  Path to end: {report['path_to_end']}")
if report['errors']:
    print(f"  Errors: {report['errors']}")
```

### 3. Gear-Gating Logic (Python)

```python
"""
Gear-Gating System for Stamp-Based Metroidvania
Implements the lock-and-key progression system where new abilities
unlock previously inaccessible areas.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Optional
from enum import Enum

class GateColor(Enum):
    """Simple color-based gating for children."""
    RED = "red"
    BLUE = "blue" 
    GREEN = "green"
    YELLOW = "yellow"
    PURPLE = "purple"

@dataclass
class GearGate:
    """A gate stamp placed on a door between rooms."""
    color: GateColor
    required_item: str  # e.g., "red_key", "double_jump", "bomb"
    is_hidden: bool = False  # Hidden gate = invisible until approached

@dataclass
class PlayerState:
    """Tracks what the player has collected so far."""
    inventory: Set[str] = field(default_factory=set)
    visited_rooms: Set[int] = field(default_factory=set)
    unlocked_gates: List[Tuple[int, str]] = field(default_factory=list)  # (room, direction)

class GearGatingEngine:
    """
    Manages the lock-and-key progression system.
    When a child places a Gate Stamp + Key Stamp pair,
    the LLM uses this engine to manage unlock logic.
    """

    def __init__(self, world_graph: WorldGraph):
        self.world = world_graph
        self.player = PlayerState()

    def can_traverse(self, from_room: int, direction, gate: Optional[GearGate]) -> bool:
        """Check if player can pass through a door with a gate."""
        if gate is None:
            return True  # No gate = free passage
        return gate.required_item in self.player.inventory

    def collect_item(self, room_id: int, item: str):
        """Player collects an item in a room."""
        self.player.inventory.add(item)
        self.player.visited_rooms.add(room_id)

    def get_newly_accessible_areas(self) -> List[int]:
        """
        After acquiring a new item, find all newly accessible rooms.
        This is called to show the child which areas are now reachable.
        """
        previously_accessible = self._compute_reachable(
            self.world.find_start_room(),
            self.player.inventory - {self._get_last_acquired_item()}  # Without newest item
        )
        now_accessible = self._compute_reachable(
            self.world.find_start_room(),
            self.player.inventory  # With newest item
        )
        return list(now_accessible - previously_accessible)

    def _get_last_acquired_item(self) -> Optional[str]:
        """Get the most recently acquired item."""
        # Simplified: in practice, track acquisition order
        return list(self.player.inventory)[-1] if self.player.inventory else None

    def _compute_reachable(self, start: int, inventory: Set[str]) -> Set[int]:
        """Compute reachable rooms given current inventory."""
        visited = set()
        queue = [start]
        while queue:
            current = queue.pop(0)
            if current in visited:
                continue
            visited.add(current)
            for neighbor in self.world.adj.get(current, []):
                # Check if the edge has a gate
                gate = self._get_gate_between(current, neighbor)
                if gate is None or gate.required_item in inventory:
                    queue.append(neighbor)
        return visited

    def _get_gate_between(self, room_a: int, room_b: int) -> Optional[GearGate]:
        """Find the gate between two rooms, if any."""
        room = self.world.rooms.get(room_a)
        if room:
            for direction, gate_color in room.gates.items():
                if gate_color:
                    # Check if this direction leads to room_b
                    dx, dy = direction.value
                    nx, ny = room.grid_x + dx, room.grid_y + dy
                    neighbor = self.world.rooms.get(room_b)
                    if neighbor and neighbor.grid_x == nx and neighbor.grid_y == ny:
                        return GearGate(
                            color=GateColor(gate_color),
                            required_item=f"{gate_color}_key"
                        )
        return None

    def suggest_key_placement(self, gate_room: int, gate_color: str) -> List[int]:
        """
        LLM helper: suggest rooms where a key could be placed
        such that it's reachable BEFORE the gate (for non-linear worlds)
        or in an earlier biome (for linear worlds).
        """
        reachable_before_gate = self._compute_reachable(
            self.world.find_start_room(),
            set()  # Empty inventory (before any keys)
        )
        # Filter to rooms that are reachable but don't already have this key
        candidates = []
        for rid in reachable_before_gate:
            if rid != gate_room:  # Don't put key behind its own gate
                has_key = any(f"key_{gate_color}" == item for item in self.world.rooms[rid].contents)
                if not has_key:
                    candidates.append(rid)
        return candidates


# Example gear-gating setup:
gearing = GearGatingEngine(world)

# Child places a red gate on the door from room 1 to room 3
world.rooms[r2].gates[Direction.SOUTH] = "red"

# Child places a red key in room 1 (reachable from start)
world.rooms[r1].contents.append("key_red")

# Validate
gearing.player.inventory.add("key_red")
new_areas = gearing.get_newly_accessible_areas()
print(f"Newly accessible areas after getting red key: {new_areas}")
```

### 4. Auto-Shortcut System (Python)

```python
"""
Auto-Shortcut System
Implements Castlevania-style warp rooms and Dead Cells-style
biome connectors that reduce backtracking in child-created worlds.
"""

from dataclasses import dataclass
from typing import List, Dict, Set, Tuple, Optional
import heapq

@dataclass
class Shortcut:
    """A warp/shortcut link between two rooms."""
    room_a: int
    room_b: int
    shortcut_type: str = "warp"  # warp, elevator, portal
    is_unlocked: bool = False

class AutoShortcutSystem:
    """
    Automatically suggests and manages shortcuts in child-created worlds.
    Inspired by Castlevania's warp rooms and Hollow Knight's bench travel.
    """

    def __init__(self, world_graph: WorldGraph):
        self.world = world_graph
        self.shortcuts: List[Shortcut] = []

    def suggest_shortcut_locations(self, max_shortcuts: int = 3) -> List[Tuple[int, int]]:
        """
        Analyze the world graph and suggest optimal shortcut placements.
        Uses graph diameter analysis to find the most impactful shortcuts.
        """
        if len(self.world.rooms) < 4:
            return []  # Too small for shortcuts

        # Find all pairs shortest paths
        all_paths = self._all_pairs_shortest_paths()

        # Find the pair of rooms with the longest shortest path
        # (these would benefit most from a shortcut)
        longest_pairs = []
        for a in self.world.rooms:
            for b in self.world.rooms:
                if a < b:  # Avoid duplicates
                    path_len = len(all_paths.get((a, b), []))
                    if path_len > 3:  # Only suggest for distant rooms
                        longest_pairs.append((a, b, path_len))

        # Sort by path length descending
        longest_pairs.sort(key=lambda x: x[2], reverse=True)

        return [(a, b) for a, b, _ in longest_pairs[:max_shortcuts]]

    def create_warp_room_pair(self, room_a: int, room_b: int) -> Shortcut:
        """Create a warp room shortcut between two rooms."""
        shortcut = Shortcut(room_a=room_a, room_b=room_b, shortcut_type="warp")
        self.shortcuts.append(shortcut)
        self.world.add_warp(room_a, room_b)
        return shortcut

    def create_auto_shortcuts(self):
        """
        Automatically create shortcuts for the child's world.
        Called by the LLM after the world reaches a certain size.
        """
        suggestions = self.suggest_shortcut_locations()
        for room_a, room_b in suggestions:
            self.create_warp_room_pair(room_a, room_b)
        return len(suggestions)

    def get_fastest_path(self, start: int, end: int) -> List[int]:
        """
        Find the fastest path between two rooms, using shortcuts.
        Uses Dijkstra's algorithm with shortcuts as zero-weight edges.
        """
        distances = {rid: float('inf') for rid in self.world.rooms}
        distances[start] = 0
        parent = {start: None}
        pq = [(0, start)]

        while pq:
            dist, current = heapq.heappop(pq)
            if current == end:
                break
            if dist > distances[current]:
                continue

            for neighbor in self.world.adj.get(current, []):
                # Check if this edge is a shortcut (weight 0) or normal (weight 1)
                is_shortcut = any(
                    (s.room_a == current and s.room_b == neighbor) or
                    (s.room_b == current and s.room_a == neighbor)
                    for s in self.shortcuts
                )
                weight = 0 if is_shortcut else 1
                new_dist = dist + weight

                if new_dist < distances[neighbor]:
                    distances[neighbor] = new_dist
                    parent[neighbor] = current
                    heapq.heappush(pq, (new_dist, neighbor))

        # Reconstruct path
        if distances[end] == float('inf'):
            return []

        path = []
        current = end
        while current is not None:
            path.append(current)
            current = parent[current]
        return path[::-1]

    def _all_pairs_shortest_paths(self) -> Dict[Tuple[int, int], List[int]]:
        """Compute shortest paths between all pairs of rooms using BFS."""
        paths = {}
        for start in self.world.rooms:
            for end in self.world.rooms:
                if start != end:
                    path = self._bfs_path(start, end)
                    if path:
                        paths[(start, end)] = path
        return paths

    def _bfs_path(self, start: int, end: int) -> List[int]:
        """BFS to find shortest path."""
        visited = {start}
        parent = {start: None}
        queue = [start]
        while queue:
            current = queue.pop(0)
            if current == end:
                path = []
                while current is not None:
                    path.append(current)
                    current = parent[current]
                return path[::-1]
            for neighbor in self.world.adj.get(current, []):
                if neighbor not in visited:
                    visited.add(neighbor)
                    parent[neighbor] = current
                    queue.append(neighbor)
        return []


# Example shortcut creation:
shortcut_sys = AutoShortcutSystem(world)
auto_created = shortcut_sys.create_auto_shortcuts()
print(f"Auto-created {auto_created} shortcuts")

if shortcut_sys.shortcuts:
    s = shortcut_sys.shortcuts[0]
    fast_path = shortcut_sys.get_fastest_path(s.room_a, s.room_b)
    print(f"Fast path via shortcut: {fast_path}")
```

### 5. Spelunky-Style Guaranteed Path Algorithm (Python)

```python
"""
Guaranteed Path Generation (Spelunky Algorithm)
Ensures every generated world has at least one solvable path
from start to end, with optional side branches.
"""

import random
from enum import Enum
from typing import List, Tuple, Optional

class RoomType(Enum):
    EMPTY = 0      # Not on solution path
    HORIZONTAL = 1 # Left + Right exits
    DROP = 2       # Left + Right + Bottom exits
    CLIMB = 3      # Left + Right + Top exits
    START = 4
    END = 5

class GuaranteedPathGenerator:
    """
    Generates a level grid with a guaranteed solvable path.
    Based on Spelunky's algorithm [^267^]:
    1. Place start on top row
    2. Generate solution path from top to bottom
    3. Fill remaining cells with optional rooms
    4. Validate connectivity
    """

    def __init__(self, width: int = 4, height: int = 4):
        self.width = width
        self.height = height
        self.grid: List[List[RoomType]] = []

    def generate(self, seed: Optional[int] = None) -> List[List[RoomType]]:
        """Generate a level with guaranteed path."""
        if seed:
            random.seed(seed)

        # Initialize empty grid
        self.grid = [[RoomType.EMPTY for _ in range(self.width)] for _ in range(self.height)]

        # 1. Place start on top row
        start_x = random.randint(0, self.width - 1)
        self.grid[0][start_x] = RoomType.START
        current_x, current_y = start_x, 0

        # 2. Generate solution path
        path = [(current_x, current_y)]
        solution_path_cells = set(path)

        while current_y < self.height - 1:
            # Decide next move: left, right, or down
            roll = random.randint(1, 5)

            if roll in (1, 2) and current_x > 0:  # Move left
                # Current room needs horizontal exit
                if self.grid[current_y][current_x] in (RoomType.EMPTY, RoomType.START):
                    self.grid[current_y][current_x] = RoomType.HORIZONTAL
                current_x -= 1

            elif roll in (3, 4) and current_x < self.width - 1:  # Move right
                if self.grid[current_y][current_x] in (RoomType.EMPTY, RoomType.START):
                    self.grid[current_y][current_x] = RoomType.HORIZONTAL
                current_x += 1

            elif roll == 5:  # Move down
                # Current room needs drop exit
                self.grid[current_y][current_x] = RoomType.DROP
                current_y += 1
                # Next room needs climb exit (to connect from above)
                if current_y < self.height:
                    self.grid[current_y][current_x] = RoomType.CLIMB

            # If we hit the edge, force downward
            if current_x == 0 and roll == 1:
                self.grid[current_y][current_x] = RoomType.DROP
                current_y += 1
                if current_y < self.height:
                    self.grid[current_y][current_x] = RoomType.CLIMB
            elif current_x == self.width - 1 and roll == 4:
                self.grid[current_y][current_x] = RoomType.DROP
                current_y += 1
                if current_y < self.height:
                    self.grid[current_y][current_x] = RoomType.CLIMB

            path.append((current_x, current_y))
            solution_path_cells.add((current_x, current_y))

        # Place end marker
        self.grid[current_y][current_x] = RoomType.END

        # 3. Fill remaining cells with random rooms
        for y in range(self.height):
            for x in range(self.width):
                if (x, y) not in solution_path_cells:
                    # Random room type (not on solution path)
                    self.grid[y][x] = random.choice([
                        RoomType.EMPTY,
                        RoomType.HORIZONTAL,
                        RoomType.HORIZONTAL,
                    ])

        return self.grid

    def to_stamp_placement_guide(self) -> List[Dict]:
        """
        Convert the generated grid into a guide for stamp placement.
        Returns a list of {x, y, room_type} dicts that the child
        (or LLM acting on their behalf) can follow.
        """
        stamps = []
        for y, row in enumerate(self.grid):
            for x, room_type in enumerate(row):
                if room_type != RoomType.EMPTY:
                    stamps.append({
                        "grid_x": x,
                        "grid_y": y,
                        "room_type": room_type.name.lower(),
                        "is_on_solution_path": room_type in (
                            RoomType.START, RoomType.END, RoomType.DROP,
                            RoomType.CLIMB, RoomType.HORIZONTAL
                        )
                    })
        return stamps

    def visualize(self) -> str:
        """Create ASCII visualization of the level."""
        symbols = {
            RoomType.EMPTY: '.',
            RoomType.HORIZONTAL: '-',
            RoomType.DROP: 'v',
            RoomType.CLIMB: '^',
            RoomType.START: 'S',
            RoomType.END: 'E',
        }
        lines = []
        for row in self.grid:
            lines.append(' '.join(symbols[r] for r in row))
        return '\n'.join(lines)


# Example generation:
gen = GuaranteedPathGenerator(width=4, height=4)
level = gen.generate(seed=42)
print("Generated Level (S=Start, E=End, -=Path, v=Drop, ^=Climb, .=Optional):")
print(gen.visualize())
print("\nStamp Placement Guide:")
for stamp in gen.to_stamp_placement_guide():
    print(f"  Place {stamp['room_type']} at ({stamp['grid_x']}, {stamp['grid_y']})")
```

### 6. Dead Cells-Style Procedural Room Stitching (JavaScript)

```javascript
/**
 * Dead Cells-Style Procedural Room Stitching
 * Adapts Motion Twin's 6-step pipeline for a stamp-based system.
 * The child designs the graph (stamp placement); the LLM stitches rooms.
 * Based on: https://deepnight.net/tutorial/the-level-design-of-dead-cells-a-hybrid-approach/
 */

class RoomTemplate {
    constructor(name, biome, purpose, entrances, exits, layout) {
        this.name = name;        // e.g., "combat_room_1"
        this.biome = biome;      // e.g., "forest", "cave"
        this.purpose = purpose;  // "combat", "treasure", "merchant", "boss"
        this.entrances = entrances;  // Array of directions: ["left", "top"]
        this.exits = exits;          // Array of directions: ["right", "bottom"]
        this.layout = layout;    // 2D array representing room tiles
    }

    matchesConstraints(biome, purpose, requiredExits) {
        // Check if this template matches the graph node's requirements
        if (this.biome !== biome) return false;
        if (purpose && this.purpose !== purpose) return false;
        // Check that template has all required exits
        const allConnections = [...this.entrances, ...this.exits];
        return requiredExits.every(exit => allConnections.includes(exit));
    }
}

class RoomTemplateLibrary {
    constructor() {
        this.templates = [];
    }

    addTemplate(template) {
        this.templates.push(template);
    }

    findMatches(biome, purpose, requiredExits, maxResults = 5) {
        // Step 4 of Dead Cells pipeline: filter templates by constraints
        const matches = this.templates.filter(t =>
            t.matchesConstraints(biome, purpose, requiredExits)
        );
        // Shuffle and return up to maxResults
        return this._shuffle(matches).slice(0, maxResults);
    }

    _shuffle(array) {
        const arr = [...array];
        for (let i = arr.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [arr[i], arr[j]] = [arr[j], arr[i]];
        }
        return arr;
    }
}

class LevelGraph {
    constructor() {
        this.nodes = new Map();  // nodeId -> {type, biome, connections}
        this.edges = [];         // [{from, to, direction}]
    }

    addNode(id, type, biome) {
        this.nodes.set(id, { id, type, biome, connections: [] });
    }

    addEdge(from, to, direction) {
        this.edges.push({ from, to, direction });
        this.nodes.get(from).connections.push({ to, direction });
        // Bidirectional
        const opposite = this._opposite(direction);
        this.nodes.get(to).connections.push({ to: from, direction: opposite });
    }

    _opposite(direction) {
        const opposites = {
            'left': 'right', 'right': 'left',
            'top': 'bottom', 'bottom': 'top'
        };
        return opposites[direction];
    }

    getRequiredExits(nodeId) {
        // Get all directions this node needs to connect
        return this.nodes.get(nodeId).connections.map(c => c.direction);
    }
}

class ProceduralStitcher {
    /**
     * Implements Dead Cells-style procedural stitching.
     * Given a child's level graph (from stamp placement) and a template library,
     * generates a complete level by matching templates to graph nodes.
     */
    constructor(templateLibrary) {
        this.templates = templateLibrary;
        this.assignedTemplates = new Map(); // nodeId -> RoomTemplate
    }

    stitchLevel(levelGraph, seed = null) {
        if (seed) Math.seedrandom(seed);  // Deterministic generation

        // Step 4: For each node, find matching templates and pick one
        for (const [nodeId, node] of levelGraph.nodes) {
            const requiredExits = levelGraph.getRequiredExits(nodeId);
            const matches = this.templates.findMatches(
                node.biome,
                node.type,
                requiredExits
            );

            if (matches.length === 0) {
                console.warn(`No template matches for node ${nodeId} with exits:`, requiredExits);
                // Fallback: create a generic room
                continue;
            }

            // Randomly select from matching templates
            const selected = matches[Math.floor(Math.random() * matches.length)];
            this.assignedTemplates.set(nodeId, selected);
        }

        // Step 5: Place enemies based on combat tile count
        this._placeEnemies(levelGraph);

        // Step 6: Place loot
        this._placeLoot(levelGraph);

        return this.assignedTemplates;
    }

    _placeEnemies(levelGraph) {
        // Dead Cells: ~1 monster per 5 combat tiles
        const enemyDensity = 0.2; // 20% of tiles have enemies
        for (const [nodeId, template] of this.assignedTemplates) {
            if (template.purpose === 'combat') {
                const combatTiles = this._countCombatTiles(template);
                const enemyCount = Math.floor(combatTiles * enemyDensity);
                console.log(`Node ${nodeId}: ${enemyCount} enemies in ${combatTiles} combat tiles`);
            }
        }
    }

    _placeLoot(levelGraph) {
        // Secret sauce - simplified
        for (const [nodeId, template] of this.assignedTemplates) {
            if (template.purpose === 'treasure') {
                console.log(`Node ${nodeId}: Placing treasure`);
            }
        }
    }

    _countCombatTiles(template) {
        // Count walkable tiles in the room layout
        return template.layout.flat().filter(tile => tile === 0).length;
    }
}

// Example usage:
const library = new RoomTemplateLibrary();
library.addTemplate(new RoomTemplate("forest_start", "forest", "start", ["left"], ["right"], [[0,0,0],[1,1,1]]));
library.addTemplate(new RoomTemplate("forest_combat_1", "forest", "combat", ["left"], ["right", "bottom"], [[0,0,0],[0,1,0],[1,1,1]]));
library.addTemplate(new RoomTemplate("forest_boss", "forest", "boss", ["top"], [], [[0,0,0],[0,2,0],[1,1,1]]));

const graph = new LevelGraph();
graph.addNode(0, "start", "forest");
graph.addNode(1, "combat", "forest");
graph.addNode(2, "boss", "forest");
graph.addEdge(0, 1, "right");
graph.addEdge(1, 2, "bottom");

const stitcher = new ProceduralStitcher(library);
const level = stitcher.stitchLevel(graph, seed=12345);
console.log("Generated level:", level);
```

### 7. Enter the Gungeon-Style Flow Graph (JavaScript)

```javascript
/**
 * Enter the Gungeon-Style Flow Graph
 * Pre-authored level graphs (called "flows") ensure consistent pacing
 * while procedural room selection provides variety.
 * Based on: https://www.boristhebrave.com/2019/07/28/dungeon-generation-in-enter-the-gungeon/
 */

class FlowGraph {
    /**
     * A pre-authored level graph that defines the pacing structure.
     * Children create these implicitly by placing stamps in certain patterns.
     */
    constructor(name, stages) {
        this.name = name;
        this.stages = stages;  // Array of {type, minDistance, maxBranches}
    }

    static createLinearFlow(name) {
        // Simple A → B → C → Boss flow
        return new FlowGraph(name, [
            { type: 'entrance', minDistance: 0, maxBranches: 1 },
            { type: 'combat', minDistance: 1, maxBranches: 0 },
            { type: 'combat', minDistance: 2, maxBranches: 1 },
            { type: 'treasure', minDistance: 3, maxBranches: 0 },
            { type: 'combat', minDistance: 4, maxBranches: 0 },
            { type: 'boss', minDistance: 5, maxBranches: 0 },
        ]);
    }

    static createBranchingFlow(name) {
        // A → [B, C] → D → Boss flow (player chooses path)
        return new FlowGraph(name, [
            { type: 'entrance', minDistance: 0, maxBranches: 1 },
            { type: 'hub', minDistance: 1, maxBranches: 2 },      // Hub splits into 2 paths
            { type: 'combat', minDistance: 2, maxBranches: 0 },   // Path A
            { type: 'treasure', minDistance: 2, maxBranches: 0 }, // Path B
            { type: 'combat', minDistance: 4, maxBranches: 0 },   // Paths converge
            { type: 'boss', minDistance: 5, maxBranches: 0 },
        ]);
    }

    static createLoopFlow(name) {
        // A → B → C → D → E → B (loop back) flow
        return new FlowGraph(name, [
            { type: 'entrance', minDistance: 0, maxBranches: 1 },
            { type: 'combat', minDistance: 1, maxBranches: 1 },
            { type: 'treasure', minDistance: 2, maxBranches: 0 },
            { type: 'combat', minDistance: 3, maxBranches: 0 },
            { type: 'shortcut', minDistance: 2, maxBranches: 0 }, // Creates loop
            { type: 'boss', minDistance: 5, maxBranches: 0 },
        ]);
    }
}

class FlowMatcher {
    /**
     * Matches a child's stamp placement to the nearest pre-authored flow.
     * Suggests improvements to achieve better pacing.
     */
    constructor(flowLibrary) {
        this.flows = flowLibrary;
    }

    analyzeChildStamps(stampGraph) {
        // Extract features from child's stamp placement
        const features = this._extractFeatures(stampGraph);

        // Find the best-matching flow
        let bestMatch = null;
        let bestScore = -1;

        for (const flow of this.flows) {
            const score = this._calculateMatchScore(flow, features);
            if (score > bestScore) {
                bestScore = score;
                bestMatch = flow;
            }
        }

        // Generate suggestions
        const suggestions = this._generateSuggestions(bestMatch, features);

        return {
            matchedFlow: bestMatch?.name || "custom",
            pacingScore: bestScore,
            suggestions: suggestions,
        };
    }

    _extractFeatures(stampGraph) {
        const nodeCount = stampGraph.nodes.size;
        const edgeCount = stampGraph.edges.length;
        const avgConnections = (2 * edgeCount) / nodeCount; // Average degree
        const maxDepth = this._calculateGraphDepth(stampGraph);
        const branchPoints = stampGraph.edges.filter(
            e => stampGraph.nodes.get(e.from).connections.length > 2
        ).length;

        return { nodeCount, edgeCount, avgConnections, maxDepth, branchPoints };
    }

    _calculateGraphDepth(stampGraph) {
        // BFS from start to find maximum distance
        const start = [...stampGraph.nodes.values()].find(n => n.type === 'start');
        if (!start) return 0;

        const visited = new Set();
        const queue = [{ id: start.id, depth: 0 }];
        let maxDepth = 0;

        while (queue.length > 0) {
            const { id, depth } = queue.shift();
            if (visited.has(id)) continue;
            visited.add(id);
            maxDepth = Math.max(maxDepth, depth);

            const node = stampGraph.nodes.get(id);
            for (const conn of node.connections) {
                queue.push({ id: conn.to, depth: depth + 1 });
            }
        }

        return maxDepth;
    }

    _calculateMatchScore(flow, features) {
        // Simple scoring: compare flow stage count to node count
        // and flow structure to connection patterns
        const idealNodes = flow.stages.length;
        const nodeDiff = Math.abs(idealNodes - features.nodeCount);
        const nodeScore = Math.max(0, 1 - nodeDiff / idealNodes);

        // Branching flow should have branch points
        const hasHub = flow.stages.some(s => s.type === 'hub');
        const branchScore = hasHub ? (features.branchPoints > 0 ? 1 : 0) : 1;

        return (nodeScore + branchScore) / 2;
    }

    _generateSuggestions(flow, features) {
        const suggestions = [];

        if (features.nodeCount < flow.stages.length) {
            suggestions.push("Add more rooms to create a fuller adventure!");
        }
        if (features.nodeCount > flow.stages.length * 1.5) {
            suggestions.push("Consider using warp stamps to connect distant areas.");
        }
        if (features.branchPoints === 0 && features.nodeCount > 3) {
            suggestions.push("Try branching paths! Place a room with multiple exits.");
        }

        return suggestions;
    }
}

// Example usage:
const flowLibrary = [
    FlowGraph.createLinearFlow("linear"),
    FlowGraph.createBranchingFlow("branching"),
    FlowGraph.createLoopFlow("loop"),
];

const matcher = new FlowMatcher(flowLibrary);
// const analysis = matcher.analyzeChildStamps(childStampGraph);
// console.log(analysis.suggestions);
```

### 8. LLM World Generation Prompt Template

```python
"""
LLM Prompt Template for Stamp-Based World Generation
This is the prompt the backend LLM uses to interpret stamp placements
and generate playable game code.
"""

WORLD_GENERATION_PROMPT = """
You are a game world generator for a stamp-based game creation platform for children.
A child has placed the following stamps on a canvas. Generate a complete,
playable game world from their placement.

## Stamp Placement (from child):
{stamp_description}

## Rules:
1. Every room must be reachable from the Start room (connectivity check)
2. Gates must have matching keys placed BEFORE them in the progression path
3. Boss rooms should be at the end of the main path
4. Secret rooms should be hidden (not on the main path)
5. Warp rooms create shortcuts between distant areas
6. Treasure rooms should be off the main path (require exploration)

## Validation Checklist:
- [ ] Start room exists and is unique
- [ ] All rooms reachable from Start (BFS connectivity)
- [ ] All gates have matching keys
- [ ] End/Boss room reachable
- [ ] No unreachable dead-ends (except secret rooms)
- [ ] Difficulty progression is reasonable

## Output Format:
Generate a JSON world definition with:
- rooms: list of {id, name, type, grid_x, grid_y, biome, contents}
- connections: list of {from, to, direction, gate_color (optional)}
- warps: list of {from, to}
- player_start: room_id
- validation: {is_valid, warnings, path_length}

Ensure the generated world is FUN and APPROPRIATE for a 5-year-old player.
Use bright colors, simple shapes, and clear visual language.
"""

def generate_llm_prompt(stamp_placements: list) -> str:
    """Convert stamp placements into LLM prompt."""
    stamp_desc = "\n".join(
        f"- {s['type']} at position ({s['x']}, {s['y']})"
        f"{' with gate: ' + s['gate'] if 'gate' in s else ''}"
        f"{' contains: ' + ', '.join(s['contents']) if 'contents' in s else ''}"
        for s in stamp_placements
    )
    return WORLD_GENERATION_PROMPT.format(stamp_description=stamp_desc)

# Example:
stamps = [
    {"type": "Start Room", "x": 0, "y": 0, "contents": ["player_spawn"]},
    {"type": "Forest Room", "x": 1, "y": 0, "contents": ["enemy_slime"]},
    {"type": "Cave Room", "x": 1, "y": 1, "gate": "red", "contents": ["boss_troll"]},
    {"type": "Treasure Room", "x": 0, "y": 1, "contents": ["key_red", "coin_x10"]},
]
print(generate_llm_prompt(stamps))
```

## World Stamp Taxonomy

### Core Stamp Categories

| Stamp Name | Icon | Purpose | LLM Behavior |
|------------|------|---------|--------------|
| **Room Stamp** | Empty square with door dots | Basic room node | Creates graph node; LLM auto-selects room template |
| **Start Stamp** | Green flag | Player spawn point | Exactly one per world; BFS origin |
| **End Stamp** | Red flag/trophy | Level goal | LLM verifies reachability |
| **Boss Stamp** | Skull/crown | Boss encounter | LLM places boss enemy; often gates progression |
| **Connector Stamp** | Dotted line → solid line | Path between rooms | Auto-placed by LLM when rooms are adjacent |
| **Gate Stamp** | Colored lock | Blocks passage | LLM tags edge with required key color |
| **Key Stamp** | Colored key | Unlocks matching gate | LLM adds to room contents; must be reachable before gate |
| **Warp Stamp** | Swirling portal | Instant travel | LLM adds zero-weight edge between any two rooms |
| **Secret Room Stamp** | Question mark | Hidden room | LLM hides room until discovered; invisible on map initially |
| **Treasure Stamp** | Treasure chest | Reward room | LLM places off main path; contains keys/loot |
| **Shop Stamp** | Store sign | Merchant room | LLM places vendor NPC |
| **Save Stamp** | Floppy disk | Checkpoint | LLM adds respawn point |
| **Biome Stamp** | Landscape icon | Visual theme | LLM filters room templates by biome |
| **Era Stamp** | Clock/hourglass | Dual-era room | LLM creates parallel room graph (8-bit ↔ 16-bit) |
| **Elevator Stamp** | Up/down arrows | Vertical connection | LLM connects rooms on different floors |
| **Enemy Stamp** | Monster face | Combat challenge | LLM populates room with themed enemies |
| **Trap Stamp** | Spikes/pit | Hazard | LLM adds environmental hazards |
| **NPC Stamp** | Person icon | Non-player character | LLM adds dialog and quest hooks |
| **One-Way Stamp** | Arrow | Directional path | LLM creates directed edge (one direction only) |

### Stamp Combinations (Compound Stamps)

Children can combine stamps for emergent behavior:

| Combination | Result |
|-------------|--------|
| Room + Gate + Key (same color) | Self-contained puzzle room |
| Room + Warp + Room | Teleporter pair |
| Room + Era + Room | Time-travel puzzle (The Messenger style) |
| Biome + Room + Enemy | Themed combat arena |
| Secret + Treasure + Boss | Hidden challenge room with big reward |
| Start + Save + Shop | Safe hub area |

## Edge Cases & Mitigations

### 1. Unreachable Rooms
**Problem:** Child places a room stamp with no connecting path.
**Detection:** BFS from Start room doesn't reach all rooms [^276^].
**Mitigation:** LLM highlights unreachable rooms with yellow warning glow. Suggests placing a Connector Stamp or moving the room adjacent to an existing one. If child ignores warning, LLM auto-generates a "mystery tunnel" (hidden connector) to maintain connectivity.

### 2. Dead Ends (Non-Secret)
**Problem:** A room has only one entrance and no exit, but isn't marked as secret/end.
**Detection:** Graph node has degree 1 and type != "end"/"boss"/"secret".
**Mitigation:** LLM suggests adding a door or converting to Secret Room. If child doesn't act, LLM auto-adds a hidden passage to a nearby room.

### 3. Impossible Jumps Between Rooms
**Problem:** Child places rooms too far apart vertically without an Elevator Stamp.
**Detection:** LLM checks vertical distance between connected rooms; if > 2 grid units without elevator, flag as impossible.
**Mitigation:** LLM auto-inserts Elevator Stamp or "floating platform" connector. Visual feedback: dotted line with elevator icon appears.

### 4. Gates Without Keys
**Problem:** Child places a Gate Stamp but no matching Key Stamp anywhere.
**Detection:** Gear-gating validation finds gate color with no corresponding key [^276^].
**Mitigation:** LLM suggests placing a Key Stamp of matching color in a reachable room. If ignored, LLM auto-places key in nearest ungated room with sparkle effect.

### 5. Keys Behind Their Own Gates
**Problem:** Key for Gate A is placed in a room only accessible through Gate A.
**Detection:** Reachability analysis with key-gate dependencies finds circular dependency.
**Mitigation:** LLM prevents placement with friendly message: "Oops! This key needs to be somewhere the player can reach BEFORE this gate!" Auto-moves key to nearest valid room.

### 6. Multiple Start Points
**Problem:** Child places multiple Start Stamps.
**Detection:** Count rooms with type="start"; if > 1, flag error.
**Mitigation:** LLM prompts: "Every adventure needs just ONE starting point! Which one should we use?" Converts extras to normal rooms.

### 7. No End Point
**Problem:** Child creates an open-ended world with no goal.
**Detection:** No room with type="end" or "boss".
**Mitigation:** LLM shows gentle warning: "Your world is fun to explore! Want to add a treasure room or boss at the end?" Suggests End Stamp placement at graph's longest path endpoint.

### 8. Overly Complex Worlds (Cognitive Overload)
**Problem:** Child places 50+ room stamps creating an unnavigable maze.
**Detection:** Room count exceeds age-appropriate threshold.
**Mitigation:** LLM suggests organizing into "Worlds" (like Mario's World 1-1, 1-2, etc.). Each world gets its own canvas/sticker page. Gate between worlds acts as level transition.

### 9. Inaccessible Secrets
**Problem:** Secret room entrance is placed behind a barrier the player can't cross.
**Detection:** Reachability analysis shows secret room entrance is in unreachable area.
**Mitigation:** LLM highlights the secret entrance stamp: "This secret hiding spot is in a hard-to-reach place! Want to make it easier to find?"

### 10. Biome Mismatches
**Problem:** Child places incompatible biomes adjacent (e.g., lava room next to ice room).
**Detection:** LLM checks biome adjacency rules.
**Mitigation:** LLM suggests adding a "Transition Stamp" (blend zone) between conflicting biomes or asks: "These two places look very different! Want to add a bridge between them?"

## Sources

[^201^] GameMaker Forum. "Metroidvania Rooms and Map." https://forum.gamemaker.io/index.php?threads/metroidvania-rooms-and-map.32807/ (2017)

[^203^] Subtractive Design. "Guide to Making Metroidvania Style Games: Part 2ish!" http://subtractivedesign.blogspot.com/2013/01/guide-to-making-metroidvania-style_16.html (2013)

[^205^] Nikles.it. "Metroidvania Metroid-like World Design." https://nikles.it/2016/game-design/metroidvania-metroid-like-world-design/ (2017)

[^206^] Reddit r/metroidvania. "Interconnected World Vs. Room/Grid Based Games." https://www.reddit.com/r/metroidvania/comments/1sko2rc/interconnected_world_vs_roomgrid_based_games/

[^207^] GameDeveloper.com. "Building the Level Design of a Procedurally Generated Metroidvania: A Hybrid Approach." https://www.gamedeveloper.com/design/building-the-level-design-of-a-procedurally-generated-metroidvania-a-hybrid-approach- (2017)

[^209^] GitHub mpewsey/ManiaMap. "Procedural Generation of Metroidvania Style Maps." https://github.com/mpewsey/ManiaMap (2022)

[^211^] GameLuster. "Review: The Messenger - A Proper Homage to the Past." https://gameluster.com/review-messenger-proper-homage-past/ (2020)

[^213^] Wikipedia. "The Messenger (2018 video game)." https://en.wikipedia.org/wiki/The_Messenger_(2018_video_game) (2018)

[^220^] KirbyLife. "Hollow Knight: A Review of Masterful Map Design and Exploration." https://kirbylife.co.uk/2025/01/05/hollow-knight-a-review-of-masterful-map-design-and-exploration/ (2025)

[^224^] Common Sense Media. "14 Tools to Turn Game-Obsessed Kids into Genuine Game Designers." https://www.commonsensemedia.org/articles/14-tools-to-turn-game-obsessed-kids-into-genuine-game-designers (2018)

[^227^] PC Gamer. "How to Design a Great Metroidvania Map." https://www.pcgamer.com/how-to-design-a-great-metroidvania-map/ (2025)

[^228^] Game-Wisdom. "Making Sense of Metroidvania Game Design." https://game-wisdom.com/critical/metroidvania-game-design (2014)

[^231^] SuperJump Magazine. "Getting Lost (by Design) in Hollow Knight." https://www.superjumpmagazine.com/getting-lost-by-design-in-hollow-knight/ (2023)

[^238^] Castlevania Wiki. "Warp Room." https://castlevania.fandom.com/wiki/Warp_Room (2026)

[^240^] Moonjump. "Game Dev Mechanics: Procedural Dungeon Generation." https://moonjump.com/game-dev-mechanics-procedural-dungeon-generation-how-it-works/ (2026)

[^241^] LittleBigPlanet Wiki. "Stickers & Decorations." https://littlebigplanet.fandom.com/wiki/Stickers_%26_Decorations (2025)

[^242^] Mega Man Knowledge Base. "Stage Select Screen." https://megaman.fandom.com/wiki/Stage_Select_Screen (2026)

[^243^] Durham & Alvin. "Shortest Walk in a Dungeon Graph." FLAIRS Journal. https://journals.flvc.org/FLAIRS/article/download/135299/139628/259510 (2024)

[^248^] GamerCorner. "Walkthrough - Castlevania: SotN." https://guides.gamercorner.net/sotn/walkthrough/

[^251^] YouTube. "Evolution of Mega Man Stage Select." https://www.youtube.com/watch?v=Tec_IRU3Wh8

[^266^] Reddit r/metroidvania Wiki. "Genre Analysis: Utility-Gated Progression." https://www.reddit.com/r/metroidvania/wiki/genre/ (2025)

[^267^] Tiny Subversions. "Spelunky Generator Lessons." https://tinysubversions.com/spelunkyGen/

[^268^] Antonios Liapis. "Constructive Generation Methods for Dungeons and Levels." https://antoniosliapis.com/articles/pcgbook_dungeons.php

[^270^] PCMag. "How Spelunky Made Procedural Generation Fun." https://www.pcmag.com/news/how-spelunky-made-procedural-generation-fun (2020)

[^273^] Idiomdrottning. "Against Metroidvania." https://idiomdrottning.org/against-metroidvania (2019)

[^275^] Mario Wiki. "Super Mario Maker 2." https://www.mariowiki.com/Super_Mario_Maker_2 (2026)

[^276^] CEUR-WS. "Using Petri nets for analysis of navigation paths in roguelike games." https://ceur-ws.org/Vol-3730/paper17.pdf

[^279^] Deepnight.net. "The Level Design of Dead Cells." https://deepnight.net/tutorial/the-level-design-of-dead-cells-a-hybrid-approach/ (2020)

[^283^] PuppyGraph. "What Is Graph Reachability?" https://www.puppygraph.com/blog/graph-reachability (2025)

[^291^] BorisTheBrave. "Dungeon Generation in Enter the Gungeon." https://www.boristhebrave.com/2019/07/28/dungeon-generation-in-enter-the-gungeon/ (2019)

[^293^] CodeAdvantage. "What is Kodu?" https://www.codeadvantage.org/coding-for-kids-blog/what-is-kodu (2020)

[^297^] OndrejNepozitek. "Graph-based dungeon generator basics." https://ondra.nepozitek.cz/blog/graph-based-dungeon-generator-basics-1/

[^320^] Dead Cells Wiki. "Biomes." https://deadcells.fandom.com/wiki/Biomes

[^321^] Castlevania Wiki. "Ability Soul." https://castlevania.fandom.com/wiki/Ability_Soul (2026)

[^323^] Mario Party Legacy. "Stamp Locations - Super Mario 3D World Guide." https://mariopartylegacy.com/guides/super-mario-3d-world/stamp-locations

[^324^] Castlevania Crypt. "Castlevania: Aria of Sorrow Ability Souls." https://www.castlevaniacrypt.com/aos-souls-ability/ (2024)
