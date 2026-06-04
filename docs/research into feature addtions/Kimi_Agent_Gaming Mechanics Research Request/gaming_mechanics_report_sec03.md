## 3. Progression & RPG Features

Traditional RPGs overwhelm young players with numeric stat sheets, inventory grids, and abstract experience points. Symphony of the Night tracks six core stats plus equipment modifiers like "DEF+5" and "STR+10" [^11^] — meaningless to a five-year-old. The challenge is not simplifying these numbers but eliminating them entirely, replacing every quantitative system with an immediately visible qualitative change. The precedents are convincing: Spyro's Sparx communicates health through a color progression from gold to blue to green to gone [^187^], Celeste teaches dash availability through Madeline's hair shifting from red to blue [^179^], and Kirby's copy abilities transform his entire silhouette to signal new powers [^152^]. Children understand progression when it is worn on the outside.

### 3.1 Visual Progression System (No Numbers)

#### 3.1.1 XP Communicated Through Character Stamp Size Growth, Color Intensity, Particle Aura

The Four Visual Growth Signals replace every numeric indicator in a conventional RPG. A character stamp begins small, pale, and unadorned. Each enemy stamp defeated triggers a minute but visible change — a slight enlargement, a saturation increase, a faint particle aura. The child never sees a number, never reads a bar, never opens a status screen.

| Traditional RPG Indicator | Stamp-Based Visual Replacement | What the Child Sees |
|---|---|---|
| XP Bar / Level Number | **Size Growth** — character stamp scales up with each defeat | "My hero got bigger!" |
| Stat Points (STR, DEF) | **Color Intensity** — base sprite shifts from pale to deeply saturated | "My hero looks brighter!" |
| HP Bar | **Companion Orb** — small orb follows character, green → yellow → red [^187^] | "My spark buddy looks worried!" |
| Equipment Tier | **Outline Glow** — border shifts bronze → silver → gold → platinum | "My hero has a shiny gold ring!" |
| Aura/Buff Effects | **Particle Density** — glowing specks increase through 5 tiers | "My hero is covered in sparkles!" |

The level-up moment is designed for maximum emotional impact without displaying text. When a particle tier threshold is crossed — at 3, 6, 10, and 15 cumulative defeats — the character stamp performs a Pokemon-style evolution animation: it pulses, briefly doubles in scale, emits a burst of celebration particles, then settles at a new permanent base size [^155^]. This single animation encodes everything a level-up normally communicates through a scrolling column of numeric increments.

The underlying system tracks only visual state properties. There is no `level` integer exposed to the player. The `VisualProgressionSystem` stores base scale, glow intensity, particle count, and outline tier — all values consumed by the renderer, never shown in the UI.

```typescript
/**
 * VisualProgressionSystem.ts
 * 
 * Handles all visual progression without exposing any numbers to the player.
 * Character stamps grow, glow, and transform based on accumulated XP.
 * Design principle: The renderer sees numbers; the child sees change.
 */

interface StampEntity {
  id: string;
  type: string;
  x: number;
  y: number;
  scale: number;
  tint: number;        // hex color consumed by renderer
  children: StampEntity[];
  metadata: Record<string, any>;
}

interface VisualGrowthState {
  // NO numeric level or XP stored here
  baseScale: number;
  currentGlowIntensity: number;
  auraParticleCount: number;
  outlineTier: 'bronze' | 'silver' | 'gold' | 'platinum';
}

const VISUAL_GROWTH_CONFIG = {
  // Thresholds are invisible to the player
  SCALE_INCREMENT_PER_DEFEAT: 0.02,
  MAX_BASE_SCALE: 1.5,
  GLOW_INCREMENT: 5,           // HSL lightness increase
  PARTICLE_THRESHOLD_GATES: [3, 6, 10, 15],
  OUTLINE_TIERS: ['bronze', 'silver', 'gold', 'platinum'] as const,
};

class VisualProgressionSystem {
  private stampGrowthMap: Map<string, VisualGrowthState> = new Map();
  private defeatCounters: Map<string, number> = new Map();

  /**
   * Called when an enemy stamp is defeated. Updates ONLY visual
   * properties. Never displays a number or increments a visible counter.
   */
  public onEnemyDefeated(heroStampId: string): void {
    const state = this.getOrCreateState(heroStampId);
    const heroStamp = this.resolveStamp(heroStampId);

    const defeatCount = (this.defeatCounters.get(heroStampId) || 0) + 1;
    this.defeatCounters.set(heroStampId, defeatCount);

    // 1. Grow the character slightly toward max scale
    state.baseScale = Math.min(
      state.baseScale + VISUAL_GROWTH_CONFIG.SCALE_INCREMENT_PER_DEFEAT,
      VISUAL_GROWTH_CONFIG.MAX_BASE_SCALE
    );

    // 2. Increase color saturation/brightness
    state.currentGlowIntensity += VISUAL_GROWTH_CONFIG.GLOW_INCREMENT;

    // 3. Check if a new particle tier was reached
    const newParticleTier = this.calculateParticleTier(defeatCount);
    if (newParticleTier > state.auraParticleCount) {
      state.auraParticleCount = newParticleTier;
      this.triggerLevelUpAnimation(heroStamp, state.baseScale);
    }

    // 4. Update outline tier
    state.outlineTier = this.calculateOutlineTier(defeatCount);

    this.applyVisualState(heroStamp, state);
  }

  /**
   * The "level up" flash — dramatic visual signal with NO numbers.
   * Pulse: double size briefly, then settle with elastic easing.
   */
  private triggerLevelUpAnimation(
    heroStamp: StampEntity,
    targetScale: number
  ): void {
    this.animate(heroStamp, {
      scale: targetScale * 2.0,
      duration: 300,
      easing: 'easeOutQuad',
    }).then(() =>
      this.animate(heroStamp, {
        scale: targetScale,
        duration: 500,
        easing: 'easeOutElastic',
      })
    );

    this.spawnParticles(heroStamp.x, heroStamp.y, {
      count: 20,
      colors: [0xFFD700, 0xFF69B4, 0x00FF00],
      duration: 1000,
    });
  }

  private applyVisualState(
    heroStamp: StampEntity,
    state: VisualGrowthState
  ): void {
    heroStamp.scale = state.baseScale;
    const baseColor = this.getBaseColor(heroStamp);
    heroStamp.tint = this.saturateColor(baseColor, state.currentGlowIntensity);
    this.setOutline(heroStamp, state.outlineTier);
    this.updateAuraParticles(heroStamp, state.auraParticleCount);
  }

  private calculateParticleTier(defeatCount: number): number {
    return VISUAL_GROWTH_CONFIG.PARTICLE_THRESHOLD_GATES
      .filter(gate => defeatCount >= gate).length;
  }

  private calculateOutlineTier(
    defeatCount: number
  ): VisualGrowthState['outlineTier'] {
    const tiers = VISUAL_GROWTH_CONFIG.OUTLINE_TIERS;
    return tiers[Math.min(Math.floor(defeatCount / 10), tiers.length - 1)];
  }

  // Renderer integration stubs
  private getOrCreateState(id: string): VisualGrowthState {
    if (!this.stampGrowthMap.has(id)) {
      this.stampGrowthMap.set(id, {
        baseScale: 1.0,
        currentGlowIntensity: 0,
        auraParticleCount: 0,
        outlineTier: 'bronze',
      });
    }
    return this.stampGrowthMap.get(id)!;
  }
  private resolveStamp(id: string): StampEntity { return null as any; }
  private animate(target: any, params: any): Promise<void> { return Promise.resolve(); }
  private spawnParticles(x: number, y: number, cfg: any): void { }
  private getBaseColor(stamp: StampEntity): number { return 0xFFFFFF; }
  private saturateColor(base: number, intensity: number): number { return base; }
  private setOutline(stamp: StampEntity, tier: string): void { }
  private updateAuraParticles(stamp: StampEntity, count: number): void { }
}
```

#### 3.1.2 Outfit Stamps as Paper-Doll Attachments with Immediate Visual Transformation

Wonder Boy III demonstrates that visual change communicates capability better than any stat sheet: Mouse-Man looks small and fits through tiny gaps; Hawk-Man sprouts wings and flies [^54^]. The stamp platform adopts this through a paper-doll attachment system. Every Character Stamp exposes five zones — head, body, left hand, right hand, feet — where Outfit Stamps snap into place.

When a child drags a Helmet Stamp onto their Character Stamp, three things happen simultaneously: the helmet sprite overlays the character's head; the outline color shifts to match the equipment tier (bronze → silver → gold → platinum) [^53^]; and a subtle particle effect activates — fire helmets emit sparks, ice armor releases frost motes, wind boots leave speed-line trails. The child learns "this helmet is good" not because they read a defense value, but because their character looks tougher and the helmet looks shinier.

Auto-swap behavior is critical for young players. If a Character Stamp already wears a helmet and the child places a new one, the old helmet gently pops off and floats to the Pocket area at the canvas edge [^172^]. No error message, no confirmation dialog, no friction. The Pocket has no capacity limit; young collectors should never be punished for gathering.

Food stamps build on the same visual-first philosophy. River City Ransom's consumable-driven progression maps naturally to stamps because eating equals getting stronger is a concept every child understands [^13^]. When a child drags a Candy Stamp onto their Character Stamp, the character flashes pink, performs a chewing animation (a 150ms scale pulse), and gains a faint pink glow for five seconds. The child sees the result immediately: their punches now land with slightly larger visual impact. There is no "+3 Punch" popup — the feedback is in the fist.

The rendering pipeline composites character appearance in strict z-order: base sprite, body outfit, foot outfit, hand outfits, head outfit, then combined particle effects from all equipped items. Each Outfit Stamp carries only visual metadata — overlay sprite path, outline tier string, optional particle effect enum. There are no attack power, defense value, or luck stats in the data model. The child infers strength from visual density: a character wearing four Outfit Stamps with gold outlines and two active particle emitters is clearly powerful, even though no number confirms it.

### 3.2 Gear-Gating via Color-Coded Stamps

#### 3.2.1 Metroid-Inspired Lock-and-Key Progression

Metroid's gear-gating — where colored doors indicate required abilities — reduces entirely to color matching [^63^]. A child does not need to read "Missiles required" when a red lock stamp with a flame icon blocks the path; they need only recognize that their red Fire Power Stamp fits.

| Lock Color & Icon | Required Ability | Power Stamp Visual | Gate Behavior |
|---|---|---|---|
| **Red Flame Lock** | Fire/Attack power | Red aura; small flames around character | Melts ice barriers |
| **Blue Snow Lock** | Ice/Water ability | Blue aura; frost particles drift downward | Freezes water surfaces |
| **Green Leaf Lock** | Nature/Transformation | Green aura; leaves flutter around character | Grows vines up walls |
| **Yellow Star Lock** | Flight ability | Wings sprout from character's back | Reaches high platforms |
| **Purple Crystal Lock** | Special key item | Purple shimmer; rare stamp appearance | Opens secret areas |

When a child attaches a Power Stamp to their Character Stamp, the character immediately gains the corresponding visual aura. Approaching a matching Lock Stamp causes it to flash, play a chime, and dissolve into particles. Approaching a non-matching lock causes it to shake while a faded ghost image of the required stamp appears above it — a wordless hint telling the child exactly what to find [^63^].

The LLM backend validates reachability after every stamp placement using BFS from the start room. When a child places a Gate Stamp, the system verifies that a matching Key Stamp exists somewhere in the world and that the key is reachable before the gate. If validation fails, the LLM gently nudges by moving the Key Stamp to the nearest valid room with a sparkle effect.

Metroid Dread's philosophy of developer-intended sequence breaks adds an important permissive layer [^136^]. If a child combines stamps creatively — placing a Giant Stamp that makes their character large, then walking through a weak barrier without the intended key — the system allows it. The LLM recognizes emergent solutions and updates the reachable area map. Creative problem-solving is celebrated, not blocked.

#### 3.2.2 Visual Preview Showing Which Gates Each New Key Can Open

When a child acquires a new Key Stamp, all matching Lock Stamps across the explored map pulse in sequence, drawing a visible chain from the key to every gate it opens. This "key insight" animation — inspired by Hollow Knight's map markers that highlight newly accessible areas [^220^] — gives the child a sense of possibility without requiring them to remember every lock they have seen.

The preview also works in reverse. When a child approaches a locked gate they cannot open, the system highlights the path toward the nearest matching key using a subtle ground-trail particle effect. The trail fades after a few seconds to avoid clutter, providing just enough guidance to prevent aimless wandering.

#### 3.2.3 Implementation: GearGateManager with Color Matching and BFS Reachability Validation

The `GearGateManager` unifies lock-key matching, player state tracking, and LLM-validated reachability. It maintains the gate registry, evaluates player inventory against lock requirements, and computes newly accessible areas whenever player state changes.

```typescript
/**
 * GearGateManager.ts
 * 
 * Lock/Key system using color-coded and icon-matched stamps.
 * Zero text, zero numbers — pure visual matching backed by
 * BFS reachability validation to ensure child-created worlds
 * are always solvable.
 */

enum LockType {
  FIRE = 'fire',       // Red flame locks
  ICE = 'ice',         // Blue snow locks
  NATURE = 'nature',   // Green leaf locks
  FLIGHT = 'flight',   // Yellow star locks
  MASTER = 'master',   // Opens all (very rare)
}

interface LockStamp {
  id: string;
  lockType: LockType;
  visualIcon: string;       // e.g., "flame_icon", "snow_icon"
  borderColor: string;      // hex color
  isOpen: boolean;
  connectedTo: string[];    // IDs of stamps behind the lock
  roomId: string;
}

interface KeyStamp {
  id: string;
  opensLockType: LockType;
  keyVisual: string;
}

interface PowerStamp {
  id: string;
  powerType: Omit<LockType, 'MASTER'>;
  visualAura: string;
}

interface PlayerInventory {
  heroStampId: string;
  keyStamps: KeyStamp[];
  powerStamps: PowerStamp[];
}

class GearGateManager {
  private locks: Map<string, LockStamp> = new Map();
  private worldGraph: Map<string, string[]> = new Map(); // adjacency list

  /** Master key opens everything; power stamps act as keys for matching locks. */
  public canOpenLock(player: PlayerInventory, lockId: string): boolean {
    const lock = this.locks.get(lockId);
    if (!lock || lock.isOpen) return true;

    if (player.keyStamps.some(k => k.opensLockType === LockType.MASTER))
      return true;
    if (player.keyStamps.some(k => k.opensLockType === lock.lockType))
      return true;
    if (player.powerStamps.some(
      p => p.powerType === this.lockTypeToPowerType(lock.lockType)
    )) return true;

    return false;
  }

  /** Attempt to open a lock. Visual feedback on success or rejection. */
  public attemptOpen(player: PlayerInventory, lockId: string): boolean {
    if (!this.canOpenLock(player, lockId)) {
      this.playRejectAnimation(lockId);
      return false;
    }

    const lock = this.locks.get(lockId)!;
    lock.isOpen = true;
    this.playOpenAnimation(lockId);

    for (const connectedId of lock.connectedTo) {
      this.revealStamp(connectedId);
    }
    return true;
  }

  /**
   * LLM REACHABILITY VALIDATION
   * 
   * After every stamp placement, BFS from the start room ensures all
   * locks have reachable matching keys. If a gate color exists but no
   * key of that color is reachable before it, the LLM flags the issue.
   */
  public validateKeyGateOrdering(
    startRoomId: string
  ): { valid: boolean; unreachableGates: string[] } {
    const visited = new Set<string>();
    const queue = [startRoomId];
    const collectedKeys = new Set<LockType>();
    const unreachableGates: string[] = [];

    while (queue.length > 0) {
      const currentRoom = queue.shift()!;
      if (visited.has(currentRoom)) continue;
      visited.add(currentRoom);

      this.findKeysInRoom(currentRoom)
        .forEach(k => collectedKeys.add(k));

      const neighbors = this.worldGraph.get(currentRoom) || [];
      for (const neighbor of neighbors) {
        const gate = this.findGateBetween(currentRoom, neighbor);
        if (gate && !gate.isOpen) {
          const requiredType = this.lockTypeToPowerType(gate.lockType)
            || gate.lockType;
          if (!collectedKeys.has(gate.lockType) &&
              !collectedKeys.has(requiredType as LockType)) {
            unreachableGates.push(gate.id);
            continue;
          }
        }
        if (!visited.has(neighbor)) {
          queue.push(neighbor);
        }
      }
    }

    return { valid: unreachableGates.length === 0, unreachableGates };
  }

  /**
   * After the player acquires a new item, compute newly accessible areas.
   * The frontend highlights these rooms with a pulse animation.
   */
  public getNewlyAccessibleAreas(
    player: PlayerInventory,
    startRoomId: string,
    previouslyAccessible: Set<string>
  ): string[] {
    const nowAccessible = this.computeReachable(startRoomId, player);
    return [...nowAccessible].filter(r => !previouslyAccessible.has(r));
  }

  private computeReachable(
    start: string, player: PlayerInventory
  ): Set<string> {
    const visited = new Set<string>();
    const queue = [start];

    while (queue.length > 0) {
      const current = queue.shift()!;
      if (visited.has(current)) continue;
      visited.add(current);

      for (const neighbor of this.worldGraph.get(current) || []) {
        const gate = this.findGateBetween(current, neighbor);
        if (!gate || this.canOpenLock(player, gate.id)) {
          queue.push(neighbor);
        }
      }
    }
    return visited;
  }

  private lockTypeToPowerType(lock: LockType): PowerStamp['powerType'] | null {
    const map: Record<string, PowerStamp['powerType']> = {
      [LockType.FIRE]: LockType.FIRE,
      [LockType.ICE]: LockType.ICE,
      [LockType.NATURE]: LockType.NATURE,
      [LockType.FLIGHT]: LockType.FLIGHT,
    };
    return map[lock] || null;
  }

  private findKeysInRoom(roomId: string): LockType[] { return []; }
  private findGateBetween(a: string, b: string): LockStamp | undefined { return undefined; }
  private playRejectAnimation(lockId: string): void { }
  private playOpenAnimation(lockId: string): void { }
  private revealStamp(stampId: string): void { }
}
```

The reachability validation runs as a background process after every significant stamp event. For a typical child-created world of 10–20 rooms, BFS completes in under a millisecond — fast enough for real-time visual feedback. The LLM only intervenes when validation fails, suggesting stamp placement through a ghost outline or auto-adjusting if prior suggestions went unheeded.

### 3.3 Shop & Quest Stamp System

#### 3.3.1 Drag-and-Drop Coin Purchasing with Visual Price Tags

River City Ransom's shop system — where consumable items provide immediate permanent stat boosts — translates naturally to stamps because the tactile loop is already physical: collect coin stamps dropped by defeated enemies, carry them to a Shop Stamp, drag them onto the item you want [^16^]. There are no numeric prices. A Sword Stamp's price is displayed as a small stack of coin sprites beneath it — two gold coins and one silver coin — not as the number "55." The child compares visual quantities, not numerals.

Coin stamps come in three visual tiers: bronze (small, dull), silver (medium, shiny), and gold (large, gleaming). The internal value mapping — bronze = 1, silver = 5, gold = 25 — exists only in the backend. A child learns that gold coins are "big and important" without knowing exchange rates. This mirrors how children handle real allowances: they understand relative value without grasping precise numbers.

When a Character Stamp approaches a Shop Stamp within 64 pixels, the shop opens a visual menu. Affordable items render at full brightness with a subtle bounce; unaffordable items render dimmed with gray overlay. The child drags coin stamps from their Pocket onto an item stamp to purchase. If sufficient coins are offered, the coins sparkle and vanish while the item stamp scales up and flies to the Pocket. If insufficient, the coins shake horizontally and a gentle "not quite" sound plays. No text says "You cannot afford this." The feedback is entirely visual and auditory.

```python
"""
ShopSystem.py

Visual shop system using stamp drag-and-drop.
Children drag coin stamps onto item stamps to purchase.
No numeric prices are ever displayed.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Tuple
from enum import Enum


class CoinTier(Enum):
    """Coin stamps come in visual tiers, not numeric values."""
    BRONZE = "bronze_coin"   # Small, dull
    SILVER = "silver_coin"   # Medium, shiny
    GOLD = "gold_coin"       # Large, gleaming


class ItemType(Enum):
    FOOD = "food"
    WEAPON = "weapon"
    ARMOR = "armor"
    POWER = "power"
    KEY = "key"


@dataclass
class ShopItemStamp:
    """An item available for purchase."""
    item_id: str
    display_name: str            # Internal only
    item_type: ItemType
    visual_sprite: str           # e.g., "sword_fire.png"
    price: Dict[CoinTier, int]   # Backend-only value map
    behavior_hint: str           # Visual effect description

    def get_price_visuals(self) -> List[str]:
        """Return coin sprite names to render beneath the item.
        e.g., ['gold_coin', 'gold_coin', 'silver_coin']"""
        result = []
        for tier, count in self.price.items():
            result.extend([tier.value] * count)
        return result


@dataclass
class ShopTransactionEngine:
    """Handles the visual drag-and-drop purchasing loop."""

    COIN_VALUES: Dict[CoinTier, int] = field(default_factory=lambda: {
        CoinTier.BRONZE: 1,
        CoinTier.SILVER: 5,
        CoinTier.GOLD: 25,
    })

    def evaluate_affordability(
        self,
        item: ShopItemStamp,
        player_coins: List[CoinTier]
    ) -> Tuple[bool, List[CoinTier]]:
        """Return (can_afford, exact_payment_combination)."""
        player_value = sum(self.COIN_VALUES[c] for c in player_coins)
        item_value = sum(
            self.COIN_VALUES[t] * c for t, c in item.price.items()
        )

        if player_value < item_value:
            return False, []

        sorted_coins = sorted(
            player_coins, key=lambda c: self.COIN_VALUES[c], reverse=True
        )
        payment = []
        remaining = item_value
        for coin in sorted_coins:
            if remaining <= 0:
                break
            if self.COIN_VALUES[coin] <= remaining:
                payment.append(coin)
                remaining -= self.COIN_VALUES[coin]

        return True, payment

    def attempt_purchase(
        self,
        item: ShopItemStamp,
        dragged_coins: List[CoinTier],
        player_inventory: List[ShopItemStamp]
    ) -> bool:
        """Called when child drags coin stamps onto an item stamp.
        Returns True on success. All feedback is visual."""
        can_afford, payment = self.evaluate_affordability(item, dragged_coins)

        if can_afford:
            self._play_purchase_success(item, payment)
            player_inventory.append(item)
            return True
        else:
            self._play_purchase_failure(item, dragged_coins)
            return False

    def _play_purchase_success(self, item: ShopItemStamp, payment: List[CoinTier]):
        pass  # Coin sparkle → fade; item bounce → fly to inventory; chime

    def _play_purchase_failure(self, item: ShopItemStamp, offered: List[CoinTier]):
        pass  # Coins shake 200ms; brief red flash; soft "bonk" sound
```

#### 3.3.2 Quest Stamps with Picture-Based Objectives

Zelda's trading sequence — where an NPC holds an item, the player brings a match, and receives a new item — collapses into a purely visual quest system [^130^]. A Quest Stamp is an NPC stamp displaying a thought bubble with a picture of the wanted item. When the child drags the correct Item Stamp onto the NPC, the trade happens automatically: the wanted item disappears, the NPC performs a celebration animation, and a Reward Stamp appears in the Pocket.

Quest chains are visible as a literal chain of connected stamps on a Quest Board area of the canvas. When one quest completes, a new link appears with the next objective picture. The child sees their entire quest history as a growing line of images — no quest log text, no dialog boxes [^132^].

#### 3.3.3 Implementation: QuestStateTracker with Visual State Machine

The `QuestStateTracker` maintains quest progress internally but exposes only visual status. Each quest has three render states: `LOCKED` (grayscale with padlock overlay), `ACTIVE` (full color with bouncing wanted-item bubble), and `COMPLETED` (gold frame with checkmark particle). The child never sees a quest title; they see a picture of a character who wants a picture of an item.

```typescript
/**
 * QuestStateTracker.ts
 * 
 * Visual quest system with picture-based objectives.
 * No text dialogs, no quest log — only image-matching
 * and chain-visual progression.
 */

enum QuestStatus {
  LOCKED = 'locked',       // Grayscale, padlock overlay
  ACTIVE = 'active',       // Full color, wanted-item bubble bounces
  COMPLETED = 'completed', // Gold frame, checkmark particle
}

interface QuestStamp {
  questId: string;
  npcVisual: string;           // Sprite path for the NPC
  wantedItemVisual: string;    // Picture of the wanted item
  rewardItem: ItemStampRef;
  status: QuestStatus;
  nextQuestId: string | null;
  requiredPrevious: string | null;
}

interface ItemStampRef {
  itemId: string;
  visualSprite: string;
  itemType: string;
}

interface PlayerPocket {
  items: ItemStampRef[];
  removeItem(visualSprite: string): boolean;
}

class QuestStateTracker {
  private quests: Map<string, QuestStamp> = new Map();
  private completedOrder: string[] = [];

  /** Activate quests whose prerequisites are met. */
  public refreshQuestStates(): string[] {
    const newlyActivated: string[] = [];

    for (const quest of this.quests.values()) {
      if (quest.status === QuestStatus.LOCKED) {
        const prereqMet = !quest.requiredPrevious ||
          this.quests.get(quest.requiredPrevious)?.status === QuestStatus.COMPLETED;
        if (prereqMet) {
          quest.status = QuestStatus.ACTIVE;
          newlyActivated.push(quest.questId);
        }
      }
    }

    return newlyActivated;
  }

  /**
   * Attempt to turn in a quest. The child drags an item stamp
   * onto the NPC stamp — this checks if it matches the picture.
   */
  public attemptTurnIn(
    questId: string,
    offeredItem: ItemStampRef,
    playerPocket: PlayerPocket
  ): { success: boolean; reward: ItemStampRef | null } {
    const quest = this.quests.get(questId);
    if (!quest || quest.status !== QuestStatus.ACTIVE) {
      return { success: false, reward: null };
    }

    // Picture-matching: does the offered item look like the wanted item?
    if (offeredItem.visualSprite !== quest.wantedItemVisual) {
      this.playConfusedAnimation(questId);
      return { success: false, reward: null };
    }

    const removed = playerPocket.removeItem(offeredItem.visualSprite);
    if (!removed) return { success: false, reward: null };

    quest.status = QuestStatus.COMPLETED;
    this.completedOrder.push(questId);
    this.playCelebrationAnimation(questId);
    this.spawnRewardStamp(quest.rewardItem);

    if (quest.nextQuestId) {
      const next = this.quests.get(quest.nextQuestId);
      if (next) {
        next.status = QuestStatus.ACTIVE;
        this.playChainLinkAnimation(questId, quest.nextQuestId);
      }
    }

    return { success: true, reward: quest.rewardItem };
  }

  /** Build the visual quest chain for the Quest Board. */
  public getQuestBoardState(): Array<{
    questId: string;
    npcVisual: string;
    wantedItemVisual: string;
    status: QuestStatus;
    rewardVisual: string;
    chainPosition: number;
  }> {
    return this.completedOrder
      .map((qid, idx) => {
        const q = this.quests.get(qid)!;
        return {
          questId: q.questId,
          npcVisual: q.npcVisual,
          wantedItemVisual: q.wantedItemVisual,
          status: q.status,
          rewardVisual: q.rewardItem.visualSprite,
          chainPosition: idx,
        };
      })
      .concat(
        [...this.quests.values()]
          .filter(q => q.status === QuestStatus.ACTIVE)
          .map(q => ({
            questId: q.questId,
            npcVisual: q.npcVisual,
            wantedItemVisual: q.wantedItemVisual,
            status: q.status,
            rewardVisual: q.rewardItem.visualSprite,
            chainPosition: -1,
          }))
      );
  }

  private playConfusedAnimation(questId: string): void { }
  private playCelebrationAnimation(questId: string): void { }
  private playChainLinkAnimation(fromId: string, toId: string): void { }
  private spawnRewardStamp(reward: ItemStampRef): void { }
}
```

The hold-and-confirm pattern prevents accidental consumption: every stamp transaction — eating food, purchasing items, turning in quests — requires the child to hold the stamp on its target for two seconds. A circular progress ring fills clockwise around the stamp. If released early, nothing happens. This safety mechanism mirrors touch-device patterns children already know from tablets, making it feel familiar rather than restrictive.

The overcharge warning system adds emergent depth without complexity. If a child equips too many powerful stamps — inspired by Hollow Knight's charm overcharge [^172^] — their Character Stamp turns red and shakes. The game does not prevent the combination; it warns visually. A child learns that "red and shaky" means "very powerful, be careful." The LLM backend scales enemy difficulty dynamically based on the current stamp loadout, ensuring the warning carries mechanical meaning.

All progression systems in the stamp platform share a single invariant: **the child should understand everything on screen without reading a word or interpreting a number**. Size communicates strength. Color communicates capability. Particles communicate status. Animation communicates change. These principles — derived from Sparx's health orb, Madeline's hair, Kirby's transformations, and Metroid's colored doors — create an RPG experience fully accessible to a five-year-old while retaining genuine mechanical depth [^187^][^179^][^152^][^63^].
