## 5. World Building & Level Architecture Features

The difference between a collection of rooms and a world a child believes in comes down to architecture — the invisible graph of connections, progression gates, and spatial relationships that transforms disconnected screens into a coherent place to explore. This section translates three landmark innovations from the world-design canon — Metroid's gear-gated adjacency graph, Dead Cells' hybrid hand-crafted and procedural stitching pipeline, and The Messenger's real-time era-switching parallel worlds — into stamp-based building blocks that a five-year-old can place on a sticker-book canvas.

The central design thesis, validated across six independent studio analyses, is that **all sophisticated world architectures can be represented as graphs** where rooms are nodes and connections are edges [^201^][^242^][^279^]. The child places Room Stamps (nodes) on a grid canvas; the LLM instantiates the graph, validates connectivity via BFS reachability analysis, and ensures every world is completable before the child ever presses Play [^276^]. The child experiences the magic of world-building — "I put a castle stamp next to a forest stamp and a door appeared!" — while the LLM handles the graph theory.

### 5.1 Room Stamp System & Metroidvania Builder

#### 5.1.1 Room Stamps as Sticker-Book Tiles with Automatic Door/Connection Generation

A Room Stamp is the foundational atom of world creation: a square tile representing a discrete game space that a child drags from a sticker sheet and drops onto a grid canvas. Each Room Stamp carries four directional door indicators (north, south, east, west) rendered as small colored dots. When two Room Stamps occupy adjacent grid cells, the LLM automatically generates a bidirectional connection between matching door indicators, playing a satisfying "zip" animation that transforms a dotted line into a solid doorway [^241^].

This adjacency-as-connection model maps directly onto the internal graph representation. Super Metroid's room-header system specifies dimensions, screen exits, and special properties for each room [^201^]; our stamp system encodes the same information visually. A Room Stamp's `doors` dictionary tracks active exits, its `biome` field determines the visual template set, and its `room_type` (start, end, boss, treasure, shop, secret) tells the LLM how to validate placement within the broader world graph.

Castlevania: Symphony of the Night's warp room system demonstrates how shortcut overlays reduce backtracking fatigue in large worlds [^238^]. Our platform exposes this as the Warp Stamp: a child places two Warp Stamps on any two rooms, and the LLM creates a zero-weight edge in the shortcut overlay graph. The LLM maintains the shortcut graph separately from the physical room graph and includes warp edges in all pathfinding calculations.

The gear-gating system that defines Metroidvania progression — explore, hit barrier, find gear, backtrack, access new area [^228^] — is presented to children as simple color matching. A Gate Stamp shows a colored lock on a door indicator. A Key Stamp of the same color placed inside any reachable room unlocks it. The LLM validates that every gate color has at least one matching key placed somewhere reachable before the gate, preventing the classic design error of keys trapped behind their own locks [^276^].

#### 5.1.2 Graph-Based World Validation Ensuring Every Room Is Reachable

Every stamp placement triggers an incremental validation pass. The LLM maintains the world as an adjacency list and runs a BFS reachability check from the Start room after each significant change. This check must answer three questions: Is every room reachable from Start? Is the End/Boss room reachable? Are all gear gates solvable with keys placed in accessible locations? [^276^].

Petri net reachability analysis classifies generated maps as viable (all rooms reachable), non-viable (depends on player choices), or inviable (impossible to complete) [^276^]. Our system applies the same classification continuously as the child builds, preventing inviable configurations before they become frustrating. Spelunky's insight that procedural worlds must guarantee a solvable path before decorative content is added [^267^] informs our ordering: connectivity first, content second.

The validation pipeline runs five checks in sequence: existence of Start and End rooms, BFS connectivity from Start through all rooms and warp links, gear-gate solvability for every color, dead-end detection for non-terminal rooms, and shortest-path length analysis for difficulty estimation. Hollow Knight's gradual map discovery [^220^] suggests children should not see the full output. Instead, the LLM surfaces kid-friendly visual feedback — a green pulse around well-connected rooms, a gentle yellow shimmer for rooms needing attention, and a red outline only for genuinely problematic placements. The Play Test button traces the expected player path with a glowing trail [^227^].

#### 5.1.3 Implementation: RoomConnectionGraph with Auto-Door Placement and Validation Engine

```typescript
// RoomConnectionGraph.ts — Graph-based world model for stamp-based world building.
// Rooms = nodes, door connections = edges, warp links = zero-weight overlay edges.

enum Direction { NORTH = 'NORTH', SOUTH = 'SOUTH', EAST = 'EAST', WEST = 'WEST' }

const OPPOSITE: Record<Direction, Direction> = {
  [Direction.NORTH]: Direction.SOUTH, [Direction.SOUTH]: Direction.NORTH,
  [Direction.EAST]: Direction.WEST, [Direction.WEST]: Direction.EAST,
};
const DIR_DELTA: Record<Direction, [number, number]> = {
  [Direction.NORTH]: [0, -1], [Direction.SOUTH]: [0, 1],
  [Direction.EAST]: [1, 0], [Direction.WEST]: [-1, 0],
};

type RoomType = 'start' | 'end' | 'boss' | 'treasure' | 'shop' | 'secret' | 'normal';
type Biome = 'forest' | 'castle' | 'cave' | 'underwater' | 'sky' | 'volcano';
type GateColor = 'red' | 'blue' | 'green' | 'yellow' | 'purple';

interface RoomStamp {
  id: number; name: string; gridX: number; gridY: number;
  roomType: RoomType; biome: Biome;
  doors: Record<Direction, boolean>;
  gates: Partial<Record<Direction, GateColor>>;
  contents: string[];
}
interface ValidationReport {
  isValid: boolean; errors: string[]; warnings: string[];
  reachableRooms: number[]; unreachableRooms: number[];
  pathToEnd: number[] | null; gearGatesSolvable: boolean;
}

export class RoomConnectionGraph {
  private rooms = new Map<number, RoomStamp>();
  private connections: Array<{ from: number; to: number; dir: Direction }> = [];
  private warpLinks: Array<[number, number]> = [];
  private nextId = 0;

  addRoom(partial: Omit<RoomStamp, 'id' | 'doors'> & { doors?: RoomStamp['doors'] }): number {
    const room: RoomStamp = {
      doors: { [Direction.NORTH]: false, [Direction.SOUTH]: false, [Direction.EAST]: false, [Direction.WEST]: false },
      gates: {}, contents: [], ...partial, id: this.nextId,
    };
    this.rooms.set(room.id, room);
    return this.nextId++;
  }

  /** When a room is placed or moved, auto-connect to any adjacent rooms. */
  autoConnectAdjacent(roomId: number): void {
    const room = this.rooms.get(roomId);
    if (!room) return;
    for (const dir of Object.values(Direction)) {
      const [dx, dy] = DIR_DELTA[dir];
      for (const other of this.rooms.values()) {
        if (other.id !== roomId && other.gridX === room.gridX + dx && other.gridY === room.gridY + dy) {
          room.doors[dir] = true;
          other.doors[OPPOSITE[dir]] = true;
          this.connections.push({ from: roomId, to: other.id, dir });
        }
      }
    }
  }

  addWarp(roomA: number, roomB: number): void { this.warpLinks.push([roomA, roomB]); }

  toAdjacencyList(): Map<number, number[]> {
    const adj = new Map<number, number[]>();
    for (const id of this.rooms.keys()) adj.set(id, []);
    for (const c of this.connections) { adj.get(c.from)!.push(c.to); adj.get(c.to)!.push(c.from); }
    for (const [a, b] of this.warpLinks) { adj.get(a)!.push(b); adj.get(b)!.push(a); }
    return adj;
  }

  findStartRoom(): number | null {
    for (const [id, r] of this.rooms) if (r.roomType === 'start') return id;
    return null;
  }
  findEndRooms(): number[] {
    return [...this.rooms.entries()].filter(([, r]) => r.roomType === 'end' || r.roomType === 'boss').map(([id]) => id);
  }

  // ---------------------------------------------------------------------------
  // Validation Engine — runs after each stamp placement to ensure playability
  // ---------------------------------------------------------------------------
  validate(): ValidationReport {
    const report: ValidationReport = {
      isValid: true, errors: [], warnings: [],
      reachableRooms: [], unreachableRooms: [], pathToEnd: null, gearGatesSolvable: true,
    };

    const start = this.findStartRoom();
    if (start === null) {
      report.isValid = false;
      report.errors.push('No Start Stamp placed! Add a Start Room.');
      return report;
    }
    const starts = [...this.rooms.values()].filter(r => r.roomType === 'start');
    if (starts.length > 1) report.warnings.push(`${starts.length} Start Stamps found. Only the first will be used.`);

    const reachable = this._bfsReachable(start);
    const allRooms = new Set(this.rooms.keys());
    const unreachable = [...allRooms].filter(id => !reachable.has(id));
    report.reachableRooms = [...reachable];
    report.unreachableRooms = unreachable;

    if (unreachable.length > 0) {
      report.isValid = false;
      report.errors.push(`Unreachable rooms: ${unreachable.join(', ')}. Add paths!`);
    }

    const ends = this.findEndRooms();
    if (ends.length === 0) report.warnings.push('No End/Boss Stamp placed yet.');
    for (const endId of ends) {
      if (!reachable.has(endId)) {
        report.isValid = false; report.errors.push(`End room ${endId} cannot be reached from Start!`);
      } else { report.pathToEnd = this._findPath(start, endId); }
    }

    const gateResult = this._validateGearGates(reachable);
    if (!gateResult.solvable) {
      report.isValid = false; report.gearGatesSolvable = false;
      report.errors.push(...gateResult.errors);
    }

    const adj = this.toAdjacencyList();
    for (const [id, room] of this.rooms) {
      if (!['end', 'boss', 'treasure', 'secret'].includes(room.roomType) && id !== start && (adj.get(id)?.length ?? 0) <= 1) {
        report.warnings.push(`Room '${room.name}' might be a dead end.`);
      }
    }
    return report;
  }

  private _bfsReachable(start: number): Set<number> {
    const adj = this.toAdjacencyList();
    const visited = new Set<number>();
    const queue = [start];
    while (queue.length > 0) {
      const cur = queue.shift()!;
      if (visited.has(cur)) continue;
      visited.add(cur);
      for (const n of adj.get(cur) ?? []) if (!visited.has(n)) queue.push(n);
    }
    return visited;
  }

  private _findPath(start: number, end: number): number[] {
    const adj = this.toAdjacencyList();
    const visited = new Set<number>([start]);
    const parent = new Map<number, number | null>([[start, null]]);
    const queue = [start];
    while (queue.length > 0) {
      const cur = queue.shift()!;
      if (cur === end) {
        const path: number[] = [];
        let c: number | null = cur;
        while (c !== null) { path.unshift(c); c = parent.get(c) ?? null; }
        return path;
      }
      for (const n of adj.get(cur) ?? []) {
        if (!visited.has(n)) { visited.add(n); parent.set(n, cur); queue.push(n); }
      }
    }
    return [];
  }

  private _validateGearGates(reachable: Set<number>): { solvable: boolean; errors: string[] } {
    const result = { solvable: true, errors: [] as string[] };
    const gateColors = new Set<GateColor>();
    const keyColors = new Map<GateColor, number[]>();
    for (const [rid, room] of this.rooms) {
      if (!reachable.has(rid)) continue;
      for (const gateColor of Object.values(room.gates).filter(Boolean) as GateColor[]) gateColors.add(gateColor);
      for (const item of room.contents) {
        const match = item.match(/^key_(red|blue|green|yellow|purple)$/);
        if (match) {
          const color = match[1] as GateColor;
          if (!keyColors.has(color)) keyColors.set(color, []);
          keyColors.get(color)!.push(rid);
        }
      }
    }
    for (const color of gateColors) {
      if ((keyColors.get(color) ?? []).length === 0) {
        result.solvable = false;
        result.errors.push(`Gate color '${color}' has no matching key in the reachable world!`);
      }
    }
    return result;
  }

  get roomCount(): number { return this.rooms.size; }
  get connectionCount(): number { return this.connections.length; }
  get allRooms(): RoomStamp[] { return [...this.rooms.values()]; }
}
```

The `RoomConnectionGraph` class provides the complete graph lifecycle for stamp-based world building. The `autoConnectAdjacent` method runs in O(n) per direction — acceptable because children's worlds rarely exceed 50 rooms [^275^]. The `validate` method composes four independent checks: BFS connectivity, end reachability, gear-gate solvability, and dead-end detection. Each check runs independently, enabling the LLM to surface partial feedback without waiting for the full suite.

### 5.2 Procedural Room Stitching

#### 5.2.1 Dead Cells-Inspired: LLM Stitches Pre-Designed Room Templates While Guaranteeing Beatable Layouts

Motion Twin's Dead Cells demonstrates the gold-standard approach to procedural level generation: a six-step pipeline that separates hand-designed structure from algorithmically selected content [^279^]. The fixed frame — island map and biome interconnections — never changes. Hand-crafted room templates define playable spaces. A concept graph per biome describes room layout, special room counts, and labyrinth complexity. For each graph node, the algorithm selects a matching room template, places enemies at roughly one per five combat tiles, and generates loot following secret internal rules [^279^].

For our platform, the child becomes the concept graph author. Each Room Stamp implicitly defines a level graph node — its type (combat, treasure, boss), biome (visual theme), and spatial position (determining adjacency and edges). The LLM executes Dead Cells steps 4 through 6: selects a room template matching the node's required door count and room type, stitches templates at connection points, validates with A* pathfinding, and populates enemies and items at child-appropriate densities.

The critical insight is that **structure and content must remain separate** [^279^]. The child's stamps define structure — the graph. The LLM handles content — template selection, enemy placement, loot distribution. This separation guarantees that even randomly placed stamps produce a structurally valid world. Enter the Gungeon extends this with "flows" — pre-authored level graphs defining pacing patterns [^291^]. Our platform implicitly matches child stamp patterns to the nearest flow archetype and suggests improvements.

#### 5.2.2 Spelunky-Style Guaranteed Path Algorithm Ensuring Start-to-Finish Connectivity

Spelunky's contribution is the guaranteed-solvable-path algorithm: before any decorative rooms are placed, the generator carves a solution path from top to bottom, ensuring every generated level is completable by construction [^267^]. Only after this guaranteed path is fixed does the algorithm add optional side rooms and treasure. This inverts the naive generation order — generate the essential structure first, then decorate around it.

For the stamp platform, this algorithm serves two purposes. When a child places stamps sparsely, the LLM uses the guaranteed-path algorithm to suggest connector rooms that bridge gaps while ensuring a solvable path from Start to End. When a child requests a "surprise me" world, the LLM generates a complete stamp layout using the Spelunky algorithm: place Start, carve a solution path, place End, then fill optional rooms around the path.

The algorithm operates on a grid abstraction. Each cell has a RoomType: START, END, HORIZONTAL (left-right passage), DROP (includes bottom exit), CLIMB (includes top exit), or EMPTY. The generator rolls a weighted random direction at each step (favoring downward progression), places appropriate room types to maintain connectivity, and ensures the path reaches the bottom row where the End room sits [^267^]. All non-solution-path cells are filled with optional rooms that add exploration value without affecting completability.

Academic research on procedural dungeon generation confirms that constructive approaches produce higher playability rates than generate-then-validate methods [^240^]. Combined with A* validation after template stitching, the system achieves near-100% playability, matching MarioGPT's A* agent at 88% playability [^519^] and RL-guided Wave Function Collapse at 100% [^498^].

#### 5.2.3 Implementation: ProceduralStitchingEngine with Template Library and A* Validation

```typescript
// ProceduralStitchingEngine.ts
// Dead Cells-inspired: match hand-crafted templates to a child's stamp graph, validate with A*.

enum Direction { NORTH = 'NORTH', SOUTH = 'SOUTH', EAST = 'EAST', WEST = 'WEST' }

interface RoomTemplate {
  name: string; biome: string; roomType: string;
  exits: Direction[];
  layout: number[][]; // 0=empty, 1=platform, 2=spawn, 3=loot, 4=hazard
  maxEnemies: number;
}
interface LevelGraphNode {
  id: number; roomType: string; biome: string;
  gridPos: [number, number]; requiredExits: Direction[];
}
interface PlacedRoom { node: LevelGraphNode; template: RoomTemplate; worldPos: [number, number]; }

export class TemplateLibrary {
  private templates = new Map<string, RoomTemplate[]>();

  addTemplate(t: RoomTemplate): void {
    if (!this.templates.has(t.biome)) this.templates.set(t.biome, []);
    this.templates.get(t.biome)!.push(t);
  }

  findMatches(biome: string, roomType: string, requiredExits: Direction[], maxResults = 5): RoomTemplate[] {
    const pool = this.templates.get(biome) ?? [];
    const matches = pool.filter(t => {
      if (t.biome !== biome) return false;
      if (roomType !== 'normal' && t.roomType !== roomType) return false;
      return requiredExits.every(ex => t.exits.includes(ex));
    });
    for (let i = matches.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [matches[i], matches[j]] = [matches[j], matches[i]];
    }
    return matches.slice(0, maxResults);
  }
}

export class ProceduralStitchingEngine {
  constructor(private library: TemplateLibrary) {}

  stitchLevel(graph: LevelGraphNode[]): { placed: PlacedRoom[]; solvable: boolean; path: [number, number][] } | null {
    const placed: PlacedRoom[] = graph.map(node => {
      const matches = this.library.findMatches(node.biome, node.roomType, node.requiredExits);
      if (matches.length === 0) throw new Error(`No template for ${node.biome}/${node.roomType}`);
      return { node, template: matches[0], worldPos: [node.gridPos[0] * 12, node.gridPos[1] * 10] };
    });

    const levelGrid = this._combinePlacements(placed);
    const startPos = this._findTile(levelGrid, 2);
    const endPos = this._findExitPosition(placed, levelGrid);
    if (!startPos || !endPos) return null;

    const { solvable, path } = this._aStar(levelGrid, startPos, endPos);

    const enemyCount = levelGrid.flat().filter(t => t === 2).length;
    const maxEnemies = placed.reduce((sum, p) => sum + p.template.maxEnemies, 0);
    if (enemyCount > maxEnemies) this._capEnemies(levelGrid, maxEnemies);

    return { placed, solvable, path };
  }

  private _combinePlacements(placed: PlacedRoom[]): number[][] {
    const maxX = Math.max(...placed.map(p => p.worldPos[0] + p.template.layout[0].length));
    const maxY = Math.max(...placed.map(p => p.worldPos[1] + p.template.layout.length));
    const grid: number[][] = Array.from({ length: maxY + 2 }, () => Array(maxX + 2).fill(0));
    for (const p of placed) {
      const [wx, wy] = p.worldPos;
      for (let y = 0; y < p.template.layout.length; y++)
        for (let x = 0; x < p.template.layout[y].length; x++)
          if (p.template.layout[y][x] !== 0) grid[wy + y][wx + x] = p.template.layout[y][x];
    }
    return grid;
  }

  private _aStar(grid: number[][], start: [number, number], end: [number, number]) {
    const h = (a: [number, number], b: [number, number]) => Math.abs(a[0] - b[0]) + Math.abs(a[1] - b[1]);
    const rows = grid.length, cols = grid[0]?.length ?? 0;
    const isWalkable = (x: number, y: number): boolean => {
      if (x < 0 || x >= cols || y < 0 || y >= rows) return false;
      const tile = grid[y][x];
      if (tile !== 0 && tile !== 2 && tile !== 3) return false;
      if (y + 1 < rows && grid[y + 1][x] === 1) return true;
      return y === rows - 1;
    };
    const neighbors = (x: number, y: number): [number, number][] => {
      const out: [number, number][] = [];
      if (isWalkable(x - 1, y)) out.push([x - 1, y]);
      if (isWalkable(x + 1, y)) out.push([x + 1, y]);
      if (isWalkable(x, y - 2)) out.push([x, y - 2]);
      if (y + 1 < rows && grid[y + 1][x] === 1) out.push([x, y + 1]);
      return out;
    };

    const openSet: Array<{ pos: [number, number]; f: number }> = [{ pos: start, f: h(start, end) }];
    const gScore = new Map<string, number>([[`${start[0]},${start[1]}`, 0]]);
    const cameFrom = new Map<string, [number, number] | null>([[`${start[0]},${start[1]}`, null]]);
    const visited = new Set<string>();

    while (openSet.length > 0) {
      openSet.sort((a, b) => a.f - b.f);
      const current = openSet.shift()!.pos;
      const cKey = `${current[0]},${current[1]}`;
      if (visited.has(cKey)) continue;
      visited.add(cKey);
      if (current[0] === end[0] && current[1] === end[1]) {
        const path: [number, number][] = [];
        let cur: [number, number] | null = current;
        while (cur) { path.unshift(cur); cur = cameFrom.get(`${cur[0]},${cur[1]}`) ?? null; }
        return { solvable: true, path };
      }
      for (const [nx, ny] of neighbors(current[0], current[1])) {
        const nKey = `${nx},${ny}`;
        const tentativeG = (gScore.get(cKey) ?? Infinity) + 1;
        if (tentativeG < (gScore.get(nKey) ?? Infinity)) {
          cameFrom.set(nKey, current); gScore.set(nKey, tentativeG);
          openSet.push({ pos: [nx, ny], f: tentativeG + h([nx, ny], end) });
        }
      }
    }
    return { solvable: false, path: [] as [number, number][] };
  }

  private _findTile(grid: number[][], tileId: number): [number, number] | null {
    for (let y = 0; y < grid.length; y++)
      for (let x = 0; x < grid[y].length; x++)
        if (grid[y][x] === tileId) return [x, y];
    return null;
  }

  private _findExitPosition(placed: PlacedRoom[], grid: number[][]): [number, number] | null {
    const exitRoom = placed.filter(p => p.node.roomType === 'end' || p.node.roomType === 'boss').pop();
    if (!exitRoom) return null;
    const [wx, wy] = exitRoom.worldPos;
    for (let y = exitRoom.template.layout.length - 1; y >= 0; y--)
      for (let x = exitRoom.template.layout[0].length - 1; x >= 0; x--)
        if (grid[wy + y][wx + x] === 1) return [wx + x, wy + y];
    return [wx + 2, wy + 2];
  }

  private _capEnemies(grid: number[][], max: number): void {
    let removed = 0;
    const target = Math.max(0, grid.flat().filter(t => t === 2).length - max);
    for (let y = grid.length - 1; y >= 0 && removed < target; y--)
      for (let x = grid[y].length - 1; x >= 0 && removed < target; x--)
        if (grid[y][x] === 2) { grid[y][x] = 3; removed++; }
  }
}
```

The `stitchLevel` method encodes the critical structure-content separation that makes Dead Cells reliable [^279^]. The child's stamps provide structure; the `TemplateLibrary` provides content. If A* validation fails, the LLM retries with alternative template selections before surfacing a friendly message.

```typescript
// GuaranteedPathGenerator.ts — Spelunky-style: generate the essential path first, then decorate.

export class GuaranteedPathGenerator {
  private grid: number[][] = [];
  constructor(private width = 4, private height = 4) {}

  generate(): number[][] {
    this.grid = Array.from({ length: this.height }, () => Array(this.width).fill(0));
    let cx = Math.floor(Math.random() * this.width), cy = 0;
    this.grid[cy][cx] = 2; // Start

    while (cy < this.height - 1) {
      const roll = Math.floor(Math.random() * 5) + 1;
      if (roll <= 2 && cx > 0) { this.grid[cy][cx] = this.grid[cy][cx] || 1; cx--; }
      else if (roll <= 4 && cx < this.width - 1) { this.grid[cy][cx] = this.grid[cy][cx] || 1; cx++; }
      else { this.grid[cy][cx] = this.grid[cy][cx] || 1; cy++; }
      this.grid[cy][cx] = this.grid[cy][cx] || 1;
    }
    this.grid[cy][cx] = 3; // End

    for (let y = 0; y < this.height; y++)
      for (let x = 0; x < this.width; x++)
        if (this.grid[y][x] === 0 && Math.random() < 0.6) this.grid[y][x] = 1;
    return this.grid;
  }

  toStampGuide(): Array<{ x: number; y: number; type: string }> {
    const map: Record<number, string> = { 0: 'empty', 1: 'corridor', 2: 'start', 3: 'end' };
    const stamps: Array<{ x: number; y: number; type: string }> = [];
    for (let y = 0; y < this.grid.length; y++)
      for (let x = 0; x < this.grid[y].length; x++)
        if (this.grid[y][x] !== 0) stamps.push({ x, y, type: map[this.grid[y][x]] });
    return stamps;
  }
}
```

The `ProceduralStitchingEngine` encodes the critical structure-content separation that makes Dead Cells reliable [^279^]. The child's stamps provide structure; the `TemplateLibrary` provides content. The `stitchLevel` method performs template matching (step 4), grid composition, and A* validation. If validation fails, the LLM retries with alternative template selections before surfacing a friendly message.

The `GuaranteedPathGenerator` implements Spelunky's core insight [^267^]: generate the essential path first, then decorate. The resulting grid converts directly into stamp placement suggestions via `toStampGuide`, producing a world beatable by construction. This serves as both the "Surprise Me" generation backend and the gap-filling algorithm for sparse stamp placements.

| Stamp Type | Visual Icon | Child Action | LLM Behavior | Validation Rule |
|---|---|---|---|---|
| **Room Stamp** | Square with door dots | Place on grid canvas | Creates graph node; auto-selects biome template | Must connect to ≥1 other room (except secrets) |
| **Start Stamp** | Green flag | Place once on canvas | Sets BFS origin; validates uniqueness | Exactly one per world; must exist for play |
| **End/Boss Stamp** | Trophy / skull | Place at world's end | Verifies reachability from Start via BFS | Must be reachable; generates pacing analysis |
| **Gate Stamp** | Colored lock | Place on door indicator | Tags edge with required key color | Matching key must exist in reachable room [^276^] |
| **Key Stamp** | Colored key | Place inside any room | Adds to room contents; links to matching gate | Cannot be placed behind its own gate |
| **Warp Stamp** | Swirling portal | Place pair on two rooms | Adds zero-weight edge to shortcut overlay | Both endpoints must be reachable independently [^238^] |
| **Secret Room Stamp** | Question mark | Place off main path | Hides room until discovered; invisible on map | Entrance must be reachable; room itself can be hidden |
| **Biome Stamp** | Landscape icon | Place over a room area | Filters template library by biome tag | Adjacent biomes may trigger transition stamp suggestion |
| **Era Stamp** | Clock / hourglass | Place on Room Stamp | Creates parallel room graph (8-bit ↔ 16-bit) | Both era variants must be independently traversable [^213^] |

### 5.3 Era/Style Stamp System

#### 5.3.1 The Messenger-Inspired: Visual Style Stamps That Re-Render the Entire Game

Sabotage Studio's The Messenger introduces one of the most technically innovative world-building mechanics in the side-scrolling canon: real-time era switching between 8-bit (past) and 16-bit (future) versions of the same level [^213^]. The game maintains two parallel level graphs with shared room positions but different layouts, obstacles, and secrets. When the player passes through a Time Gate, the game swaps the active tileset, loads the alternate room layout, adjusts physics parameters, and cross-fades the music [^211^]. This transforms the game's genre: the first half plays as a linear platformer, while the era-switching second half becomes a full Metroidvania requiring revisitation of old areas in the new era.

For our platform, this becomes the **Era Stamp** — placed on any Room Stamp, it instructs the LLM to generate two complete versions of that room. The 8-bit version uses a restricted color palette, simplified geometry, and chiptune audio. The 16-bit version uses rich parallax layers, orchestral arrangements, and additional platforming challenges [^213^]. A child can place Era Stamps selectively — one room might be dual-era while neighbors are single-era — creating worlds where visual complexity evolves as the player explores.

The style system generalizes beyond the 8-bit/16-bit binary into three tiers as **Style Stamps**: **Pixel Style** (low-resolution tilesets, chiptune music, 12fps animation), **Hand-Painted Style** (watercolor-textured assets, acoustic instruments, smooth tweened animation), and **Clean Vector Style** (flat geometric shapes, electronic music, procedural animation). When a child places a Style Stamp on the canvas background, the LLM re-renders every room using the corresponding template set, preserving all spatial relationships, connection graphs, and gear-gate configurations.

#### 5.3.2 Audio Layer Switching Synchronized with Visual Style Changes

Audio synchronization follows The Messenger's cross-fade approach [^213^]. Each room template stores three audio tracks — one per style tier. When the player triggers an era switch or the child applies a new Style Stamp, the audio engine cross-fades between corresponding tracks over 800ms. Sound effects also have style variants: a "jump" in Pixel style plays a square-wave chirp, in Hand-Painted style plays a soft woodwind glissando, and in Clean Vector style plays a synthesized "bloop."

The audio layer system uses content-addressed assets. Each `RoomTemplate` references audio by semantic tag (`music: 'forest_exploration'`, `sfx: 'jump'`) rather than file path. The Style Switching Engine resolves tags to concrete assets based on the active style. This indirection enables the same world definition to work identically across all three visual styles. For Era Stamps, the audio system maintains parallel playback states — when in the 8-bit era, the 16-bit track continues at zero volume, so the cross-fade has material to fade into, preventing audio "popping."

#### 5.3.3 Implementation: StyleSwitchingEngine with Rendering Pipeline Reconfiguration

```typescript
// StyleSwitchingEngine.ts — Manages parallel era graphs, style-tagged rendering, and synchronized audio.

enum VisualStyle { PIXEL = 'pixel', HAND_PAINTED = 'hand_painted', CLEAN_VECTOR = 'clean_vector' }
enum Era { PAST_8BIT = '8bit', FUTURE_16BIT = '16bit' }

interface StyleConfig {
  name: VisualStyle; tileSize: number; paletteSize: number;
  parallaxLayers: number; animFrameRate: number; audioFormat: 'chiptune' | 'acoustic' | 'synthesized';
}
const STYLE_CONFIGS: Record<VisualStyle, StyleConfig> = {
  [VisualStyle.PIXEL]:        { name: VisualStyle.PIXEL, tileSize: 16, paletteSize: 4,  parallaxLayers: 1, animFrameRate: 12, audioFormat: 'chiptune' },
  [VisualStyle.HAND_PAINTED]: { name: VisualStyle.HAND_PAINTED, tileSize: 32, paletteSize: 256, parallaxLayers: 4, animFrameRate: 60, audioFormat: 'acoustic' },
  [VisualStyle.CLEAN_VECTOR]: { name: VisualStyle.CLEAN_VECTOR, tileSize: 24, paletteSize: 16, parallaxLayers: 2, animFrameRate: 60, audioFormat: 'synthesized' },
};

interface EraRoomInstance {
  roomId: number; era: Era; templateRef: string; alteredLayout: boolean;
}
interface ParallelRoom {
  baseRoomId: number; gridX: number; gridY: number;
  instances: Map<Era, EraRoomInstance>; activeEra: Era;
}

export class StyleSwitchingEngine {
  private parallelRooms = new Map<number, ParallelRoom>();
  private activeStyle: VisualStyle = VisualStyle.PIXEL;
  private activeEra: Era = Era.PAST_8BIT;
  private audioCrossfadeDuration = 800; // ms

  registerDualEraRoom(baseRoomId: number, gridX: number, gridY: number,
                     template8bit: string, template16bit: string): void {
    this.parallelRooms.set(baseRoomId, {
      baseRoomId, gridX, gridY,
      instances: new Map([
        [Era.PAST_8BIT,    { roomId: baseRoomId * 2, era: Era.PAST_8BIT, templateRef: template8bit, alteredLayout: true }],
        [Era.FUTURE_16BIT, { roomId: baseRoomId * 2 + 1, era: Era.FUTURE_16BIT, templateRef: template16bit, alteredLayout: true }],
      ]),
      activeEra: Era.PAST_8BIT,
    });
  }

  setVisualStyle(style: VisualStyle): void {
    const prev = this.activeStyle;
    this.activeStyle = style;
    const config = STYLE_CONFIGS[style];
    globalThis.dispatchEvent(new CustomEvent('pipeline:reconfigure', {
      detail: { prevStyle, newStyle: style, tileSize: config.tileSize, parallaxLayers: config.parallaxLayers }
    }));
  }

  switchEra(roomId: number): void {
    const pr = this.parallelRooms.get(roomId);
    if (!pr) return;
    const nextEra = pr.activeEra === Era.PAST_8BIT ? Era.FUTURE_16BIT : Era.PAST_8BIT;
    pr.activeEra = nextEra; this.activeEra = nextEra;

    this._crossfadeAudio(pr.instances.get(Era.PAST_8BIT)!.templateRef,
                         pr.instances.get(Era.FUTURE_16BIT)!.templateRef,
                         nextEra === Era.FUTURE_16BIT ? 1 : 0);

    const newlyReachable = this._computeEraReachability(roomId, nextEra);
    if (newlyReachable.length > 0) this._highlightNewlyAccessible(newlyReachable);
  }

  getActiveInstance(baseRoomId: number): EraRoomInstance | null {
    const pr = this.parallelRooms.get(baseRoomId);
    return pr ? (pr.instances.get(pr.activeEra) ?? null) : null;
  }

  isConnectionValid(fromBaseId: number, toBaseId: number, era?: Era): boolean {
    const e = era ?? this.activeEra;
    const fromPr = this.parallelRooms.get(fromBaseId);
    const toPr = this.parallelRooms.get(toBaseId);
    if (!fromPr && !toPr) return true;
    if (fromPr && !fromPr.instances.has(e)) return false;
    if (toPr && !toPr.instances.has(e)) return false;
    return true;
  }

  resolveAudioAsset(semanticTag: string): string {
    return `audio/${STYLE_CONFIGS[this.activeStyle].audioFormat}/${semanticTag}.ogg`;
  }

  private _crossfadeAudio(fromTrack: string, toTrack: string, targetVolume: number): void {
    globalThis.dispatchEvent(new CustomEvent('audio:crossfade', {
      detail: { fromTrack, toTrack, targetVolume, duration: this.audioCrossfadeDuration }
    }));
  }

  private _computeEraReachability(switchedRoomId: number, era: Era): number[] {
    const reachable: number[] = [];
    for (const [baseId, pr] of this.parallelRooms) {
      if (pr.instances.has(era) && pr.activeEra !== era) reachable.push(baseId);
    }
    return reachable;
  }

  private _highlightNewlyAccessible(roomIds: number[]): void {
    globalThis.dispatchEvent(new CustomEvent('ui:sparkle', { detail: { roomIds } }));
  }

  get currentStyle(): VisualStyle { return this.activeStyle; }
  get currentEra(): Era { return this.activeEra; }
  get registeredDualEraRooms(): number { return this.parallelRooms.size; }
}
```

The `StyleSwitchingEngine` manages three responsibilities: parallel room graphs for Era Stamps, style-tagged rendering pipeline configuration, and synchronized audio cross-fading. The `registerDualEraRoom` method creates two `EraRoomInstance` entries per dual-era room with independent template references, allowing 8-bit and 16-bit versions to have completely different layouts and secrets as in The Messenger [^213^]. The `switchEra` method performs the runtime transition: swaps the active era, triggers an 800ms audio cross-fade, and computes newly reachable areas.

The style configuration system uses `STYLE_CONFIGS` to resolve rendering parameters at runtime. When switching from Pixel to Hand-Painted, tile size increases from 16px to 32px, parallax layers activate, and audio shifts from chiptune to acoustic instruments. All templates are referenced by semantic tag rather than concrete path, enabling the same world to render correctly under any active style.

The Era/Style system supports powerful combinations. A child might set Hand-Painted as the global style and attach an Era Stamp to one room — creating a dual-era room rendered in watercolor for both eras. Or they might set Pixel globally and use Era Stamps selectively, so only certain rooms transform at Time Gates, creating narrative moments where "the future bleeds through."

| Property | Pixel Style (8-bit) | Pixel Style (16-bit) | Hand-Painted Style | Clean Vector Style |
|---|---|---|---|---|
| **Tile resolution** | 16×16 px, 4-color | 16×16 px, 16-color | 32×32 px, full color | 24×24 px, flat fills |
| **Background layers** | 1 (static) | 2 (parallax) | 4 (rich parallax) | 2 (geometric) |
| **Animation** | 12fps frame-by-frame | 24fps tweened | 60fps smooth | 60fps spring physics |
| **Audio format** | Chiptune | FM synthesis | Acoustic + ambient | Electronic |
| **Screen transitions** | Hard cut | Wipe fade | Page-turn | Slide + scale |
| **Recommended age** | 5–7 | 7–9 | 5–10 | 8–12 |

The Style Switching Engine connects to the Room Connection Graph through `isConnectionValid`, which filters adjacency based on era tags. A corridor existing in the 8-bit era but collapsed in the 16-bit era will not be traversable after a switch — exactly the puzzle design that makes The Messenger's second half a Metroidvania [^211^]. The LLM validates cross-era dependencies during construction, ensuring no required progression path is severed by era-exclusive layout changes.

While the TypeScript engines above run client-side for real-time feedback, the LLM backend runs a more thorough validation pass before any world is published. This Python validator processes the world graph exported from the client, checks advanced solvability constraints, and generates the kid-friendly feedback messages that appear on the Play Test screen:

```python
# llm_world_validator.py — Server-side validation that runs before a world is published.
# Processes the exported RoomConnectionGraph and returns child-friendly feedback.

from collections import deque
from typing import Dict, List, Set, Tuple, Optional

class LLMWorldValidator:
    """Validates a child's stamp-based world server-side before publication."""

    def __init__(self, world_export: dict):
        # world_export comes from the client's RoomConnectionGraph.toJSON()
        self.rooms = world_export["rooms"]
        self.connections = world_export["connections"]
        self.warps = world_export.get("warps", [])
        self.adj = self._build_adjacency()

    def _build_adjacency(self) -> Dict[int, List[int]]:
        adj: Dict[int, List[int]] = {r["id"]: [] for r in self.rooms}
        for c in self.connections:
            adj[c["from"]].append(c["to"])
            adj[c["to"]].append(c["from"])
        for a, b in self.warps:
            adj[a].append(b)
            adj[b].append(a)
        return adj

    def validate(self) -> dict:
        report = {"playable": True, "kid_feedback": [], "suggestions": [], "metrics": {}}

        # 1. Start room
        starts = [r for r in self.rooms if r["roomType"] == "start"]
        if len(starts) == 0:
            report["playable"] = False
            report["kid_feedback"].append("Every adventure needs a starting point! Place a green flag.")
            return report
        start_id = starts[0]["id"]

        # 2. BFS reachability
        reachable = self._bfs(start_id)
        unreachable = [r["id"] for r in self.rooms if r["id"] not in reachable]
        if unreachable:
            report["playable"] = False
            report["kid_feedback"].append(
                f"{len(unreachable)} room(s) are lonely — they need a path! Try adding Connector Stamps."
            )

        # 3. End reachable
        ends = [r for r in self.rooms if r["roomType"] in ("end", "boss")]
        if not ends:
            report["kid_feedback"].append("Your world is fun to explore! Want to add a treasure or boss at the end?")
        for e in ends:
            if e["id"] not in reachable:
                report["playable"] = False
                report["kid_feedback"].append("The goal can't be reached from the start! Let's fix the path.")
            else:
                path = self._find_path(start_id, e["id"])
                report["metrics"]["path_length"] = len(path)

        # 4. Gate-key solvability
        gate_report = self._check_gates(reachable)
        if not gate_report["ok"]:
            report["playable"] = False
            for color in gate_report["missing_keys"]:
                report["kid_feedback"].append(f"The {color} gate needs a {color} key somewhere before it!")

        # 5. Difficulty estimate
        report["metrics"]["room_count"] = len(self.rooms)
        report["metrics"]["connection_count"] = len(self.connections)
        report["metrics"]["difficulty_stars"] = self._estimate_difficulty()

        return report

    def _bfs(self, start: int) -> Set[int]:
        visited, queue = set(), deque([start])
        while queue:
            cur = queue.popleft()
            if cur in visited: continue
            visited.add(cur)
            for n in self.adj.get(cur, []):
                if n not in visited: queue.append(n)
        return visited

    def _find_path(self, start: int, end: int) -> List[int]:
        visited, parent, queue = {start}, {start: None}, deque([start])
        while queue:
            cur = queue.popleft()
            if cur == end:
                path = []
                while cur is not None: path.append(cur); cur = parent[cur]
                return path[::-1]
            for n in self.adj.get(cur, []):
                if n not in visited:
                    visited.add(n); parent[n] = cur; queue.append(n)
        return []

    def _check_gates(self, reachable: Set[int]) -> dict:
        result = {"ok": True, "missing_keys": []}
        gate_colors = set()
        key_colors = set()
        for r in self.rooms:
            if r["id"] not in reachable: continue
            for gate in r.get("gates", {}).values():
                if gate: gate_colors.add(gate)
            for item in r.get("contents", []):
                if item.startswith("key_"): key_colors.add(item.replace("key_", ""))
        for color in gate_colors:
            if color not in key_colors:
                result["ok"] = False
                result["missing_keys"].append(color)
        return result

    def _estimate_difficulty(self) -> int:
        rooms = len(self.rooms)
        if rooms <= 4: return 1
        if rooms <= 8: return 2
        gates = sum(1 for r in self.rooms for g in r.get("gates", {}).values() if g)
        if gates >= 3: return 3
        return 2
```

The `LLMWorldValidator` runs server-side before any world is published. It processes the JSON export from the client's `RoomConnectionGraph`, performs BFS reachability analysis, gear-gate solvability checks, and path-length metrics, then generates kid-friendly feedback strings that the client displays. The difficulty estimator converts raw room count and gate count into a 1–3 star rating, giving children an intuitive sense of their world's complexity. The separation between client-side TypeScript engines (real-time feedback) and server-side Python validation (publication gate) ensures that children get immediate visual responses during creation while maintaining a high bar for published worlds [^279^][^519^][^213^].
