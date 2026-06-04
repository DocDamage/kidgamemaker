## Dimension 03: Progression & RPG Systems

### Executive Summary

This research report examines RPG progression systems from five landmark side-scrolling action game studios and derives visual, stamp-based adaptations suitable for children as young as 5 years old. The core challenge is transforming complex stat management---XP bars, inventory screens, drop rates, and gear builds---into an entirely visual and tactile experience that requires zero reading ability.

The key insight from this research is that **the most successful visual progression systems communicate power through immediate, irreversible visual change** [^187^][^179^]. Spyro the Dragon's Sparx companion changes color to indicate health without any HUD numbers [^187^]. Celeste teaches players that Madeline's hair color indicates dash availability---a visual state system that requires zero text [^179^]. Kirby's copy abilities transform his entire visual appearance to communicate new powers [^152^]. These precedents demonstrate that children can understand complex progression systems when they are encoded visually rather than numerically.

Across the five studios analyzed, several patterns emerge: (1) **equipment can be reduced to "outfit stamps" that overlay on character stamps**, following Wonder Boy III's transformation-based gear system where each form has visually distinct equipment [^54^][^53^]; (2) **gear-gating works through color-coded lock-and-key stamp relationships**, directly inspired by Metroid's ability-gated world design where colored doors indicate required abilities [^63^]; (3) **food/item stamps can boost characters through visual size or aura changes**, modeled on River City Ransom's shop system where consumable items provide immediate stat boosts [^13^][^16^]; and (4) **XP/leveling can be communicated through particle intensity, size growth, and aura evolution**, building on Vanillaware's approach in Odin Sphere where Phozon absorption creates visible character transformation [^76^][^78^].

### Studio Innovations Analysis

---

#### Konami (Castlevania: Symphony of the Night / Aria of Sorrow / Dawn of Sorrow)

**How It Works Technically:**

Konami's "Igavania" titles layer full RPG systems over 2D side-scrolling exploration. In Symphony of the Night, Alucard has six core stats (STR, CON, INT, LCK, ATT, DEF) that govern combat effectiveness [^11^]. Equipment follows a standard RPG slot system: right hand (weapon), left hand (shield or second weapon), head, body, cloak, and two accessory slots [^11^]. Each equipment piece modifies stats with visible numeric changes (e.g., "DEF+5" or "STR+10") [^11^]. The Tactical Soul System introduced in Aria of Sorrow and refined in Dawn of Sorrow categorizes powers into four color-coded types: red Bullet souls (attacks), blue Guardian souls (continuous effects), yellow Enchant souls (passive buffs), and grey Ability souls (permanent upgrades like double-jump) [^93^][^96^]. Drop rates are governed by the LCK stat using the formula: `Actual Drop Rate = Base Rate * (LCK / 100)`, capped at 50% for common drops and 25% for rare drops [^12^][^14^].

**Stamp-Based Adaptation:**

For a 5-year-old, the entire inventory system collapses into a **"Character Stamp" with attachable "Outfit Stamps"** that visually overlay. Rather than reading "DEF+5," the child sees their character stamp grow small armor pieces. The soul system becomes **"Power Stamps" that orbit the character stamp**---red for attacks, blue for shields, yellow for passive buffs. When the child places a "Bat Soul Stamp" near their character, the character gains a bat transformation ability that is visually obvious. The concept of drop rates is eliminated entirely: defeating enemy stamps simply has a chance to spawn their associated Power Stamp, with no numbers visible.

**Key Technical Insight:** Symphony of the Night's RPG elements were explicitly added because director Koji Igarashi felt earlier Castlevania games were "too challenging for average players" [^17^]. The leveling system and equipment were accessibility features---making them visual rather than numeric continues that design philosophy.

---

#### Sega/Core Design (Wonder Boy III: The Dragon's Trap / Wonder Boy in Monster World)

**How It Works Technically:**

Wonder Boy III introduced a **persistent town hub with interconnected shops, hospitals, and transformation rooms** as the backbone of its progression system [^62^]. After defeating each boss dragon, Wonder Boy transforms into a new form (Lizard-Man, Mouse-Man, Piranha-Man, Lion-Man, Hawk-Man), each with different base stats and abilities [^54^][^59^]. Equipment comes in three tiers---weapons, shields, and armor---with each piece having Attack Power (AP) and Defense Power (DP) values [^53^]. A unique "Charm Point" (CP) system gates equipment access: shops display items with "?" until the player has sufficient CP, which comes from equipped gear and Charm Stones [^62^]. Dragon Mail allows walking in lava; the Thunder Saber shatters gold bricks---these are ability-gated progression mechanics [^53^]. The game uses a currency (gold) dropped by enemies to purchase gear in shops.

**Stamp-Based Adaptation:**

The town hub becomes a **"Hub Stamp" that children place on their canvas**---when placed, it automatically connects to other stamps with visual paths. Each **"Shop Stamp" has a colored border** matching the transformation type required to use it (mouse-colored border for Mouse-Man gear). The transformation system becomes **"Form Stamps" that the child collects after defeating boss stamps**---placing a Lion-Man Form Stamp on the character stamp visually transforms the character into a lion. Equipment becomes **"Gear Stamps" that stack visually** on the character: placing a Sword Stamp adds a sword image to the character's hand. The CP system is entirely visual: each Gear Stamp has 1-3 star symbols indicating "coolness," and Shop Stamps show 1-3 star outlines matching which Gear Stamps can be used there.

**Key Technical Insight:** Wonder Boy III's transformation system is essentially a **visual ability-gating system**: each form's unique appearance immediately communicates what that form can do. Mouse-Man looks small and can fit through mouse blocks; Hawk-Man has wings and can fly. This visual-to-function mapping is exactly what young children need.

---

#### Nintendo (Metroid Series)

**How It Works Technically:**

Metroid pioneered **ability-gated progression** ("gear-gating") where the world opens up based on acquired abilities [^63^]. Samus's upgrades---Ice Beam, Morph Ball, Bombs, Power Bombs, Grapple Beam, Screw Attack, Space Jump---each unlock specific environmental interactions [^77^][^83^]. The world is designed as a directed acyclic graph where nodes (biomes) connect through gates requiring specific abilities [^63^]. Metroid Dread formalized "developer-intended sequence breaks" where skilled players can bypass intended paths, with hidden alternative paths rewarding exploration [^136^][^131^]. The gating is visually communicated through colored doors: red doors require missiles, green doors require super missiles, yellow doors require power bombs, and ice-themed obstacles require the Ice Beam [^77^].

**Stamp-Based Adaptation:**

Gear-gating becomes **"Lock Stamps" and "Key Stamps" with matching colors and symbols**. A red gate stamp blocks a path; the child needs a red Key Stamp (e.g., "Fire Power Stamp") to open it. The system is entirely visual: **Lock Stamps have a large icon showing what's needed**---a flame icon for fire gates, a wing icon for flight gates, a water icon for swim gates. Key Stamps have matching icons. When a child places a Key Stamp on their Character Stamp, the character visually gains that property (flames appear around them, wings sprout, etc.). The LLM backend tracks which gates are passable based on which Key Stamps are attached to the character.

The color-coding system follows this mapping:
- **Red locks** = Need attack power (any weapon stamp)
- **Blue locks** = Need ice/water ability (Ice Power Stamp)
- **Green locks** = Need transformation ability (Form Stamp)
- **Yellow locks** = Need explosive ability (Bomb Power Stamp)
- **Purple locks** = Need flight ability (Wing Power Stamp)

**Key Technical Insight:** Metroid Dread's approach of intentionally designing sequence breaks demonstrates that gear-gating should be **permissive rather than rigid**---the LLM can allow creative solutions where children combine stamps in unexpected ways [^136^]. If a child places a "Giant Stamp" that makes their character large, they could potentially break through weak gates without the intended key.

---

#### Vanillaware (Odin Sphere / Muramasa: The Demon Blade)

**How It Works Technically:**

Vanillaware's games feature deep RPG systems wrapped in hand-painted 2D visuals. Odin Sphere: Leifthrasir uses a **Phozon-based skill tree system** where each character has nearly 200 unique skills and abilities [^79^]. Skills are unlocked using Phozons (collected from defeated enemies), while abilities use Ability Points earned through leveling up [^78^]. The game streamlines leveling so characters and Psypher weapons level together [^76^]. Food plays a critical role: eating provides both healing and EXP [^76^]. In Muramasa: The Demon Blade, the system revolves around **forging blades using Spirit (gained from eating food) and Souls (gained from killing enemies)** [^129^]. Each blade has a Soul Rating that depletes with use and recovers when unequipped, forcing weapon rotation [^129^]. Blades have Strength and Vitality requirements, and equipping multiple blades stacks their passive abilities [^129^].

**Stamp-Based Adaptation:**

The skill tree becomes a **"Power Tree Stamp"---a visual tree diagram that the child fills in** by placing collected "Phozon Stamps" (glowing orbs) into empty slots. Each filled slot unlocks a new "Skill Stamp" that can be placed on the character. The food system becomes **"Food Stamps" that the child drags onto their Character Stamp**---the character visually changes (gets bigger, glows brighter) and the food stamp transforms into Spirit particles. Blade forging becomes **"Weapon Stamp" collection** where combining a "Spirit Stamp" (gained from eating) with a "Soul Stamp" (gained from defeating enemies) creates a new Weapon Stamp. The Soul Rating system is communicated through color: weapons start bright silver and gradually darken as they're used, signaling the child to switch.

The visual power communication in Vanillaware games is exemplary: **characters visually transform when powered up**, with aura effects, weapon glow, and particle trails making strength obvious without numbers. A child's character stamp could use the same approach: powered-up characters emit particles, have colored auras, and their weapon stamps glow.

---

#### Technos Japan (River City Ransom)

**How It Works Technically:**

River City Ransom is an open-world beat 'em up where **stat progression comes entirely from consumable items purchased at shops** [^16^]. Enemies drop money, which players use to buy: (1) healing items, (2) technique books that teach new moves, (3) equipment (like Texas Boots), and (4) food that permanently boosts stats [^20^][^13^]. Stats include Punch (P), Kick (K), Weapon (WN), Throw (TH), Agility (AG), Defense (D), and Strength (SG) [^13^]. Each food item provides specific stat boosts: Rock Candy boosts Punch, Fudge Bars boost Kick, Jaw Breakers boost Weapon, and so on [^13^]. The cost-efficiency analysis reveals that cheaper items often provide better value per dollar, creating interesting economic decisions [^13^]. The game has no traditional leveling system---all progression comes through shopping and consumption.

**Stamp-Based Adaptation:**

River City Ransom's system maps perfectly to stamps: **"Shop Stamps" placed on the canvas become interactive storefronts**. When a child's character stamp approaches a Shop Stamp, it opens a menu of "Food Stamps" and "Gear Stamps" they can purchase with collected "Coin Stamps." Each Food Stamp has a visual effect: placing a "Candy Stamp" on the Character Stamp makes the character's fists glow slightly bigger (punch boost). Placing a "Boots Stamp" adds boots to the character's feet and increases their movement speed visually. There are no visible stats---the child learns that "this food makes you punchier" because the character's punches become visually larger after eating candy stamps.

The technique book system becomes **"Move Stamps" that the child places on their Character Stamp to learn new abilities**---a "Jump Kick Move Stamp" shows a small icon of the move, and after placing it, the character can perform that move. The entire system is tactile: collect coin stamps by defeating enemy stamps, spend them at shop stamps, buy food/move stamps, place them on your character stamp, see immediate visual results.

---

### Key Findings

1. **Visual state changes are universally understood across ages.** Spyro's Sparx communicates health through a simple color progression: gold (full) -> blue -> green -> gone [^187^][^189^]. This pattern works for any status indicator.

2. **Color-coding is the most reliable cross-cultural communication method for gating.** Metroid's colored door system has persisted across decades because it requires zero reading ability---red doors need missiles, green doors need super missiles [^77^].

3. **Food-based progression is more intuitive than abstract XP bars.** River City Ransom and Muramasa both use food for progression because eating = getting stronger is a universally understood concept for children [^13^][^128^].

4. **Transformation communicates abilities better than stat sheets.** Wonder Boy III's form changes (Lizard-Man, Mouse-Man, Hawk-Man) instantly communicate what each form can do [^54^]. A child knows Hawk-Man can fly without reading anything.

5. **Overcharge mechanics add emergent depth.** Hollow Knight's charm overcharge system---where equipping beyond capacity deals extra damage to the player---shows how simple rules create interesting decisions [^172^]. A stamp system could allow "super-powerful" combinations with trade-off visuals (character turns red, shakes).

6. **Tactile collection creates emotional attachment.** Kirby's copy ability system works because the player physically inhales and swallows enemies to gain powers---there's a direct physical action connecting cause and effect [^152^]. Stamp-based progression should similarly require physical placement actions.

7. **Visual feedback should be immediate and irreversible.** Celeste teaches players through immediate visual feedback: Madeline's hair turns blue when she dashes and red when the dash is available again [^179^]. Every stamp placement should trigger an immediate, visible change.

8. **Progression can be spatial rather than numerical.** Ori and the Blind Forest's ability tree uses spatial position on a tree diagram to communicate progression paths---no numbers needed [^176^].

9. **Developer-intended sequence breaks reward creativity.** Metroid Dread's design philosophy of allowing and rewarding unexpected solutions should be built into stamp-based progression [^136^]. If a child combines stamps creatively, the LLM should allow it.

10. **Children's games require broader tutorials with multiple learning modes.** Research shows children learn through varied methods---showing pictures, having audio read text, and letting them try immediately [^61^]. A stamp-based progression system should introduce new stamp types one at a time with visual demonstrations.

### Child-Friendly Simplifications

---

#### How XP/Leveling Becomes Visual (No Numbers)

Instead of numeric XP bars, the system uses **The Four Visual Growth Signals**:

| Traditional RPG | Stamp-Based Visual Replacement |
|---|---|
| XP Bar | **Size Growth**: Character stamp slowly grows larger with each enemy defeated |
| Level Number | **Color Intensity**: Character stamp becomes more vibrant/saturated |
| Stat Points | **Particle Aura**: Character gains glowing particles that increase in density |
| HP Bar | **Companion Orb**: A small orb follows the character, changing color (green->yellow->red) |

When a child places their Character Stamp on the canvas, it starts small and pale. As they defeat Enemy Stamps, it gradually grows and brightens. "Leveling up" triggers a dramatic visual transformation: the character pulses with light, briefly doubles in size, then settles at a new, larger base size. This is inspired by Pokemon's evolution animations---the most memorable visual leveling system in gaming [^155^].

#### How Equipment Becomes "Outfit Stamps"

Equipment follows the **paper doll model**: the Character Stamp has designated attachment zones (head, body, hands, feet) where Outfit Stamps can be placed. Each Outfit Stamp:

- **Visually overlays** on the character (a Helmet Stamp adds a helmet image)
- **Changes the character's outline color** to match the equipment tier (bronze->silver->gold outline)
- **Adds a subtle particle effect** (fire helmets emit sparks, ice armor emits frost)
- **Immediately changes one visible behavior** (boots make the character run faster; shields add a blocking animation)

The child never reads stats. They learn that "this helmet stamp makes my character look tougher" because the character visually changes and seems to take less damage.

#### How Gear-Gating Becomes "Color Lock Stamps"

Every gate in the game is a **Lock Stamp with a colored border and a central icon**:

- **Red Flame Lock** = Need fire ability (attach a Fire Power Stamp to character)
- **Blue Snow Lock** = Need ice ability
- **Green Leaf Lock** = Need nature ability
- **Yellow Star Lock** = Need flying ability
- **Purple Crystal Lock** = Need special key item

When the character has the matching ability stamp, the Lock Stamp flashes and opens when they approach. If not, the Lock Stamp shakes and displays a small "need this" ghost image of the required stamp type. There are no words---just color matching and icon recognition.

#### How Shops Become "Shop Stamps"

A **Shop Stamp is a building stamp** placed on the canvas. When a Character Stamp approaches it, the shop opens a visual menu showing available items as Food Stamps, Gear Stamps, or Move Stamps with Coin Stamp price tags. The child drags Coin Stamps (collected from defeated enemies) onto the item stamps they want to buy. Purchased stamps go to their "Pocket" (a small area on the canvas edge).

#### How Quests Become "Quest Chain Stamps"

Inspired by Zelda's trading sequence [^130^][^132^], quests become **visual chains**: an NPC Stamp holds a picture of what they want. When the child gives them the right Item Stamp, they receive a new Item Stamp and the NPC visually celebrates. The quest progression is visible as a **growing chain of connected stamps** on a "Quest Board" area of the canvas.

### Recommended Features

---

| Priority | Feature | Description | Studio Inspiration |
|---|---|---|---|
| P0 | **Growth System** | Character stamps grow in size and glow intensity as they defeat enemies | Pokemon evolution |
| P0 | **Outfit Attachment** | Paper-doll style stamp overlay on character stamps with visual behavior changes | Wonder Boy III equipment |
| P0 | **Color Lock Gates** | Lock stamps with colored borders matching required ability stamps | Metroid colored doors |
| P0 | **Shop Stamps** | Building stamps where coin stamps buy food/gear/move stamps | River City Ransom shops |
| P1 | **Companion Orb** | Floating orb that follows character, color = health state | Spyro's Sparx |
| P1 | **Form Transformation** | Character stamp visually transforms when form stamps are applied | Wonder Boy III transformations |
| P1 | **Power Tree** | Spatial tree diagram filled with phozon/skill stamps | Ori ability tree |
| P1 | **Food Effects** | Food stamps cause immediate visible changes (size, aura, speed) | Muramasa food system |
| P2 | **Weapon Forging** | Combine spirit+soul stamps to create weapon stamps | Muramasa forging |
| P2 | **Quest Chains** | Visual trading sequences connecting NPC stamps | Zelda trading sequence |
| P2 | **Move Learning** | Technique book stamps teach new abilities | River City Ransom techniques |
| P2 | **Overcharge** | Allow powerful stamp combinations with visual warning (red shake) | Hollow Knight overcharm |
| P3 | **Sequence Breaks** | LLM allows creative stamp combinations to bypass intended gates | Metroid Dread |

### Progression Stamp Taxonomy

---

The complete stamp taxonomy for RPG progression includes 8 primary categories with 30+ stamp types:

**CHARACTER STAMPS (Base)**
- `hero_stamp`: The player's character, grows and transforms
- `enemy_stamp`: Defeatable foes that drop rewards
- `boss_stamp`: Powerful enemies that drop key progression items

**OUTFIT STAMPS (Equipment)**
- `helmet_stamp`: Head equipment (adds defense visual)
- `armor_stamp`: Body equipment (adds bulk/outline color)
- `weapon_stamp`: Hand equipment (changes attack visual)
- `boots_stamp`: Foot equipment (increases movement speed)
- `accessory_stamp`: Misc equipment (adds particle effects)

**POWER STAMPS (Abilities)**
- `fire_power_stamp`: Red aura, melts ice locks
- `ice_power_stamp`: Blue aura, freezes water
- `nature_power_stamp`: Green aura, grows plants
- `flight_power_stamp`: Wing visual, reaches high places
- `dash_power_stamp`: Speed lines, crosses gaps
- `shield_power_stamp`: Bubble visual, blocks attacks

**KEY STAMPS (Gear-Gating)**
- `red_key_stamp`: Opens red flame locks
- `blue_key_stamp`: Opens blue snow locks
- `green_key_stamp`: Opens green leaf locks
- `yellow_key_stamp`: Opens yellow star locks
- `master_key_stamp`: Opens all locks (rare)

**FOOD STAMPS (Consumables)**
- `candy_stamp`: Small punch boost (fists glow)
- `potion_stamp`: Heals companion orb to green
- `fruit_stamp`: Small speed boost (character smiles)
- `feast_stamp`: Large all-stats boost (character pulses)

**SHOP STAMPS (Commerce)**
- `general_shop_stamp`: Sells food and basic gear
- `weapon_shop_stamp`: Sells weapon stamps
- `armor_shop_stamp`: Sells outfit stamps
- `magic_shop_stamp`: Sells power stamps

**FORM STAMPS (Transformations)**
- `lizard_form_stamp`: Breathes fire, small size
- `mouse_form_stamp`: Fits small gaps, wall climb
- `fish_form_stamp`: Swims freely
- `bird_form_stamp`: Flies freely
- `lion_form_stamp`: Strong attacks, large size

**QUEST STAMPS (Objectives)**
- `npc_stamp`: Holds picture of wanted item
- `reward_stamp`: Given by NPCs upon completion
- `chain_stamp`: Connects quest steps visually

### Code Snippets

---

#### Visual XP/Growth System (TypeScript)

```typescript
/**
 * VisualProgressionSystem.ts
 * 
 * Handles all visual progression without exposing any numbers.
 * Character stamps grow, glow, and transform based on accumulated XP.
 */

interface StampEntity {
  id: string;
  type: string;
  x: number;
  y: number;
  scale: number;
  tint: number; // hex color
  children: StampEntity[];
  metadata: Record<string, any>;
}

interface VisualGrowthState {
  // NO numeric level or XP is stored
  // Only visual state properties
  baseScale: number;
  currentGlowIntensity: number;
  auraParticleCount: number;
  outlineTier: 'bronze' | 'silver' | 'gold' | 'platinum';
}

const VISUAL_GROWTH_CONFIG = {
  // XP thresholds are invisible to the player
  // They trigger visual changes only
  SCALE_INCREMENT_PER_DEFEAT: 0.02,
  MAX_BASE_SCALE: 1.5,
  GLOW_INCREMENT: 5, // added to color brightness
  PARTICLE_THRESHOLD_GATES: [3, 6, 10, 15], // defeats needed for each particle tier
  OUTLINE_TIERS: ['bronze', 'silver', 'gold', 'platinum'] as const,
};

class VisualProgressionSystem {
  private stampGrowthMap: Map<string, VisualGrowthState> = new Map();

  /**
   * Called when an enemy stamp is defeated.
   * Updates ONLY visual properties of the hero stamp.
   */
  public onEnemyDefeated(heroStampId: string): void {
    const state = this.getOrCreateState(heroStampId);
    const heroStamp = this.getStamp(heroStampId);
    
    // 1. Grow the character slightly
    state.baseScale = Math.min(
      state.baseScale + VISUAL_GROWTH_CONFIG.SCALE_INCREMENT_PER_DEFEAT,
      VISUAL_GROWTH_CONFIG.MAX_BASE_SCALE
    );
    
    // 2. Increase glow/saturation
    state.currentGlowIntensity += VISUAL_GROWTH_CONFIG.GLOW_INCREMENT;
    
    // 3. Check if new particle tier reached
    const defeatCount = this.getDefeatCount(heroStampId);
    const newParticleTier = this.calculateParticleTier(defeatCount);
    if (newParticleTier > state.auraParticleCount) {
      state.auraParticleCount = newParticleTier;
      this.triggerLevelUpAnimation(heroStamp);
    }
    
    // 4. Update outline tier based on overall progression
    state.outlineTier = this.calculateOutlineTier(defeatCount);
    
    // Apply all visual changes
    this.applyVisualState(heroStamp, state);
  }

  /**
   * Triggers the "level up" flash animation.
   * Dramatic visual signal with NO numbers displayed.
   */
  private triggerLevelUpAnimation(heroStamp: StampEntity): void {
    // Pulse: double size briefly, then settle
    const originalScale = heroStamp.scale;
    
    // Animation sequence (using any tweening library)
    this.animate(heroStamp, {
      scale: originalScale * 2.0,
      duration: 300,
      easing: 'easeOutQuad',
    }).then(() => {
      return this.animate(heroStamp, {
        scale: originalScale,
        duration: 500,
        easing: 'easeOutElastic',
      });
    });
    
    // Spawn celebration particles
    this.spawnParticles(heroStamp.x, heroStamp.y, {
      count: 20,
      colors: [0xFFD700, 0xFF69B4, 0x00FF00],
      duration: 1000,
    });
  }

  /**
   * Applies the current visual state to the stamp.
   * NO numeric values are rendered.
   */
  private applyVisualState(heroStamp: StampEntity, state: VisualGrowthState): void {
    // Set scale
    heroStamp.scale = state.baseScale;
    
    // Set color tint (more saturated = more powerful)
    const baseColor = this.getBaseColor(heroStamp);
    heroStamp.tint = this.saturateColor(baseColor, state.currentGlowIntensity);
    
    // Set outline
    this.setOutline(heroStamp, state.outlineTier);
    
    // Update aura particles
    this.updateAuraParticles(heroStamp, state.auraParticleCount);
  }

  private calculateParticleTier(defeatCount: number): number {
    let tier = 0;
    for (const gate of VISUAL_GROWTH_CONFIG.PARTICLE_THRESHOLD_GATES) {
      if (defeatCount >= gate) tier++;
    }
    return tier;
  }

  private calculateOutlineTier(defeatCount: number): VisualGrowthState['outlineTier'] {
    const tiers = VISUAL_GROWTH_CONFIG.OUTLINE_TIERS;
    const index = Math.min(
      Math.floor(defeatCount / 10),
      tiers.length - 1
    );
    return tiers[index];
  }
}
```

#### Stamp-Based Inventory System (Python)

```python
"""
StampInventory.py

Visual inventory system with zero numeric display.
Items are stamps that attach to character stamps through drag-and-drop.
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional, Dict

class StampSlot(Enum):
    HEAD = "head"
    BODY = "body"
    HAND_LEFT = "hand_left"
    HAND_RIGHT = "hand_right"
    FEET = "feet"
    ACCESSORY = "accessory"

class VisualEffect(Enum):
    GLOW = "glow"
    SPARKLE = "sparkle"
    FROST = "frost"
    FIRE = "fire"
    WIND = "wind"

@dataclass
class OutfitStamp:
    """An equipment stamp that visually overlays on a character."""
    stamp_id: str
    name: str  # Internal name, not displayed to child
    slot: StampSlot
    visual_overlay: str  # Path to overlay sprite (e.g., "helmet_fire.png")
    outline_color: str  # "bronze", "silver", "gold", "platinum"
    particle_effect: Optional[VisualEffect] = None
    # NO stat numbers stored here
    
    def get_description(self) -> str:
        """Returns visual-only description for hover tooltip.
        NO numbers, NO text stats. Just visual adjectives."""
        descriptions = {
            "bronze": "shiny",
            "silver": "very shiny", 
            "gold": "super shiny",
            "platinum": "extra shiny"
        }
        effect_desc = f" with {self.particle_effect.value}" if self.particle_effect else ""
        return f"{descriptions[self.outline_color]}{effect_desc}"

@dataclass
class CharacterStamp:
    """The player's character stamp with attached outfit stamps."""
    stamp_id: str
    base_sprite: str
    attached_outfits: Dict[StampSlot, Optional[OutfitStamp]] = field(
        default_factory=lambda: {slot: None for slot in StampSlot}
    )
    pocket: List['ItemStamp'] = field(default_factory=list)
    
    def attach_outfit(self, outfit: OutfitStamp) -> bool:
        """Attach an outfit stamp to the appropriate slot.
        Returns True if successful, False if slot occupied."""
        if self.attached_outfits[outfit.slot] is not None:
            # For young children: auto-swap instead of rejecting
            self.detach_outfit(outfit.slot)
        
        self.attached_outfits[outfit.slot] = outfit
        self._update_visual_appearance()
        return True
    
    def detach_outfit(self, slot: StampSlot) -> Optional[OutfitStamp]:
        """Remove an outfit from a slot. Returns the removed outfit."""
        removed = self.attached_outfits[slot]
        self.attached_outfits[slot] = None
        self._update_visual_appearance()
        return removed
    
    def _update_visual_appearance(self):
        """Recompute the character's composite visual from all attached outfits.
        This generates the final rendered sprite without any stat calculation."""
        # Compose overlay sprites in order:
        # 1. Base character sprite
        # 2. Body outfit (if any)
        # 3. Foot outfit (if any) 
        # 4. Hand outfits (if any)
        # 5. Head outfit (if any)
        # 6. Particle effects from all outfits
        pass  # Rendering code depends on engine
    
    def get_visual_power_signals(self) -> Dict[str, any]:
        """Returns visual signals of the character's current power level.
        These are consumed by the rendering system, NOT shown as numbers."""
        attached = [o for o in self.attached_outfits.values() if o is not None]
        
        return {
            "outline_tier": max(
                (o.outline_color for o in attached),
                key=lambda t: ["bronze", "silver", "gold", "platinum"].index(t),
                default=None
            ),
            "particle_effects": [o.particle_effect for o in attached 
                                if o.particle_effect],
            "equipped_count": len(attached),
            # NO attack_power, NO defense_value, NO numeric stats
        }

@dataclass 
class ItemStamp:
    """A consumable item stamp (food, potion, etc.)."""
    stamp_id: str
    item_type: str  # "food", "potion", "key", "material"
    visual_sprite: str
    consumption_effect: str  # Description of what visually happens when used
    
    def use_on(self, character: CharacterStamp) -> bool:
        """Apply this item to a character. Returns True if consumed."""
        # Implementation depends on item type
        if self.item_type == "food":
            return self._apply_food_effect(character)
        elif self.item_type == "potion":
            return self._apply_potion_effect(character)
        return False
    
    def _apply_food_effect(self, character: CharacterStamp) -> bool:
        """Food stamps make the character briefly flash and grow slightly."""
        # Trigger visual "eating" animation
        # Brief 1.1x scale pulse
        # Return True = item is consumed (removed from pocket)
        return True
    
    def _apply_potion_effect(self, character: CharacterStamp) -> bool:
        """Potion stamps restore companion orb to full green."""
        # Trigger healing sparkles
        # Reset companion orb color to green
        return True
```

#### Gear-Gating Logic System (TypeScript)

```typescript
/**
 * GearGatingSystem.ts
 * 
 * Lock/Key system using color-coded and icon-matched stamps.
 * Zero text, zero numbers---pure visual matching.
 */

interface LockStamp {
  id: string;
  lockType: LockType;
  visualIcon: string;  // e.g., "flame_icon", "snow_icon", "wing_icon"
  borderColor: string; // hex color for the lock border
  isOpen: boolean;
  connectedTo: string[]; // IDs of stamps behind the lock
}

interface CharacterStamp {
  id: string;
  attachedPowerStamps: PowerStamp[];
  attachedKeyStamps: KeyStamp[];
}

interface PowerStamp {
  id: string;
  powerType: PowerType;
  visualAura: string;
}

interface KeyStamp {
  id: string;
  opensLockType: LockType;
  keyVisual: string;
}

enum LockType {
  FIRE = 'fire',       // Red flame locks
  ICE = 'ice',          // Blue snow locks  
  NATURE = 'nature',    // Green leaf locks
  FLIGHT = 'flight',    // Yellow star locks
  MASTER = 'master',    // Opens all (very rare)
}

enum PowerType {
  FIRE = 'fire',
  ICE = 'ice',
  NATURE = 'nature',
  FLIGHT = 'flight',
}

class GearGatingSystem {
  private locks: Map<string, LockStamp> = new Map();
  
  /**
   * Check if a character stamp can open a lock stamp.
   * Uses visual matching: does the character have a stamp
   * that matches the lock's color/icon?
   */
  public canOpenLock(
    character: CharacterStamp, 
    lockId: string
  ): boolean {
    const lock = this.locks.get(lockId);
    if (!lock || lock.isOpen) return false;
    
    // Master key opens everything
    const hasMasterKey = character.attachedKeyStamps
      .some(k => k.opensLockType === LockType.MASTER);
    if (hasMasterKey) return true;
    
    // Check for matching key stamp
    const hasMatchingKey = character.attachedKeyStamps
      .some(k => k.opensLockType === lock.lockType);
    if (hasMatchingKey) return true;
    
    // Check for matching power stamp (abilities act as keys)
    const hasMatchingPower = character.attachedPowerStamps
      .some(p => p.powerType === this.lockTypeToPowerType(lock.lockType));
    if (hasMatchingPower) return true;
    
    return false;
  }
  
  /**
   * Opens a lock if the character has the right stamp.
   * Triggers visual opening animation.
   */
  public attemptOpen(
    character: CharacterStamp,
    lockId: string
  ): boolean {
    if (!this.canOpenLock(character, lockId)) {
      // Visual feedback: lock shakes, shows ghost of needed stamp
      this.playRejectAnimation(lockId);
      return false;
    }
    
    // Open the lock!
    const lock = this.locks.get(lockId)!;
    lock.isOpen = true;
    
    // Visual opening animation
    this.playOpenAnimation(lockId);
    
    // Reveal connected stamps (items, paths, etc.)
    for (const connectedId of lock.connectedTo) {
      this.revealStamp(connectedId);
    }
    
    return true;
  }
  
  private playRejectAnimation(lockId: string): void {
    // Lock stamp shakes left/right
    // Ghost image of needed stamp type briefly appears
    // Subtle "bonk" sound
  }
  
  private playOpenAnimation(lockId: string): void {
    // Lock stamp flashes bright
    // Border color pulses
    // Lock overlay sprite shatters/fades
    // "Chime" success sound
    // Particles burst from lock location
  }
  
  private revealStamp(stampId: string): void {
    // Make previously-hidden stamp visible on canvas
    // Scale from 0 to 1 with bounce easing
  }
  
  private lockTypeToPowerType(lockType: LockType): PowerType | null {
    const mapping: Record<string, PowerType> = {
      [LockType.FIRE]: PowerType.FIRE,
      [LockType.ICE]: PowerType.ICE,
      [LockType.NATURE]: PowerType.NATURE,
      [LockType.FLIGHT]: PowerType.FLIGHT,
    };
    return mapping[lockType] || null;
  }
}
```

#### Simple Shop System (Python)

```python
"""
ShopSystem.py

Visual shop system using stamp drag-and-drop.
Children drag coin stamps onto item stamps to purchase.
"""

from dataclasses import dataclass
from typing import List, Dict, Callable
from enum import Enum

class CoinTier(Enum):
    """Coin stamps come in visual tiers, not values."""
    BRONZE = "bronze_coin"   # Small coin
    SILVER = "silver_coin"   # Medium coin
    GOLD = "gold_coin"       # Large coin

@dataclass
class ShopStamp:
    """A shop building stamp placed on the canvas."""
    shop_id: str
    shop_name: str  # Internal only
    shop_type: str  # "general", "weapon", "armor", "magic"
    
    def get_visual_sprite(self) -> str:
        return f"shop_{self.shop_type}_building.png"

@dataclass 
class ShopItem:
    """An item available for purchase in a shop."""
    item_stamp_id: str       # The stamp the child receives
    item_visual: str         # Display sprite
    price: Dict[CoinTier, int]  # How many of each coin type
    # Price displayed as coin stamp STACKS, not numbers
    # e.g., 2 gold coins + 3 silver coins shown as actual coin sprites

class ShopTransactionSystem:
    """Handles the visual drag-and-drop purchasing."""
    
    def __init__(self):
        self.shop_inventories: Dict[str, List[ShopItem]] = {}
        self.pending_payments: Dict[str, List[CoinTier]] = {}
    
    def open_shop(self, shop: ShopStamp, player_coins: List[CoinTier]) -> List[ShopItem]:
        """
        Returns items that the player CAN visually afford.
        Items they can't afford are shown ghosted/outlined.
        """
        available = self.shop_inventories.get(shop.shop_id, [])
        
        # Calculate what player can afford (hidden from player)
        player_value = self._calculate_value(player_coins)
        
        result = []
        for item in available:
            item_value = self._calculate_value([
                tier for tier, count in item.price.items() 
                for _ in range(count)
            ])
            result.append((item, player_value >= item_value))
        
        return result
    
    def attempt_purchase(
        self,
        item: ShopItem,
        dragged_coins: List[CoinTier]
    ) -> bool:
        """
        Called when child drags coin stamps onto an item stamp.
        Returns True if purchase succeeds (enough coins).
        """
        offered_value = self._calculate_value(dragged_coins)
        required_value = self._calculate_value([
            tier for tier, count in item.price.items()
            for _ in range(count)
        ])
        
        if offered_value >= required_value:
            # SUCCESS!
            # Visual feedback: coins sparkle and disappear
            # Item stamp bounces and flies to player's pocket
            self._play_purchase_success(item)
            return True
        else:
            # FAILURE
            # Visual feedback: coins shake, red X briefly appears
            # Item stamp subtly shakes 'no'
            self._play_purchase_failure(item)
            return False
    
    def _calculate_value(self, coins: List[CoinTier]) -> int:
        """Internal value calculation. NEVER shown to child."""
        values = {
            CoinTier.BRONZE: 1,
            CoinTier.SILVER: 5,
            CoinTier.GOLD: 25,
        }
        return sum(values[c] for c in coins)
    
    def _play_purchase_success(self, item: ShopItem):
        """Visual and audio feedback for successful purchase."""
        # Coin sparkle animation
        # Item stamp bounce + fly to inventory
        # Happy chime sound
        pass
    
    def _play_purchase_failure(self, item: ShopItem):
        """Visual and audio feedback for insufficient funds."""
        # Coin stamps shake horizontally
        # Brief red flash
        # "Error" buzzer sound (gentle)
        pass
```

#### Food/Item Effect Visual System (TypeScript)

```typescript
/**
 * FoodEffectSystem.ts
 * 
 * Food stamps cause immediate visible changes to character stamps.
 * No stats are modified---only visual properties change.
 */

interface FoodEffect {
  // Visual changes applied when food stamp is consumed
  scaleDelta: number;        // How much character grows (0.1 = 10% bigger)
  glowIncrease: number;      // How much brighter character becomes
  auraDuration: number;      // How long (ms) a particle aura lasts
  auraColor: string;         // Hex color of aura particles
  trailEffect: string | null; // Sprite for movement trail
  
  // Behavior changes ( communicated visually, not as stats)
  speedMultiplier: number;   // Movement speed change (1.0 = normal)
  jumpMultiplier: number;    // Jump height change
}

const FOOD_EFFECTS: Record<string, FoodEffect> = {
  'candy_stamp': {
    scaleDelta: 0.05,
    glowIncrease: 10,
    auraDuration: 5000,
    auraColor: '#FF69B4', // Pink
    trailEffect: 'sparkle_trail.png',
    speedMultiplier: 1.1,
    jumpMultiplier: 1.0,
  },
  'fruit_stamp': {
    scaleDelta: 0.0,
    glowIncrease: 15,
    auraDuration: 8000,
    auraColor: '#00FF00', // Green
    trailEffect: 'leaf_trail.png',
    speedMultiplier: 1.2,
    jumpMultiplier: 1.1,
  },
  'feast_stamp': {
    scaleDelta: 0.15,
    glowIncrease: 25,
    auraDuration: 15000,
    auraColor: '#FFD700', // Gold
    trailEffect: 'star_trail.png',
    speedMultiplier: 1.0,
    jumpMultiplier: 1.2,
  },
  'potion_stamp': {
    scaleDelta: 0.0,
    glowIncrease: 0,
    auraDuration: 2000,
    auraColor: '#00FFFF', // Cyan healing
    trailEffect: 'healing_sparkles.png',
    speedMultiplier: 1.0,
    jumpMultiplier: 1.0,
  },
};

class FoodEffectSystem {
  /**
   * Apply a food stamp to a character stamp.
   * Only visual changes---no stat modification.
   */
  public consumeFood(
    characterStampId: string,
    foodStampType: string
  ): void {
    const effect = FOOD_EFFECTS[foodStampType];
    if (!effect) return;
    
    const character = this.getCharacterStamp(characterStampId);
    
    // 1. Scale change (character grows)
    this.animateScale(character, effect.scaleDelta, 500);
    
    // 2. Glow increase
    this.increaseGlow(character, effect.glowIncrease);
    
    // 3. Aura particles
    if (effect.auraDuration > 0) {
      this.spawnAura(
        character,
        effect.auraColor,
        effect.auraDuration
      );
    }
    
    // 4. Trail effect (movement leaves particles)
    if (effect.trailEffect) {
      this.setTrailEffect(character, effect.trailEffect, effect.auraDuration);
    }
    
    // 5. Eating animation
    this.playEatAnimation(character);
    
    // 6. Behavior changes are communicated through
    // visual feedback only---character moves faster,
    // jumps higher, but NO numbers are shown
  }
  
  private playEatAnimation(character: any): void {
    // Character stamp briefly opens mouth (if applicable)
    // Food stamp shrinks and flies to character's mouth
    // "Chomp" particle burst
    // Satisfied "mmmmm" sound
    
    // Brief scale pulse (chew animation)
    const baseScale = character.scale;
    this.animate(character, { scale: baseScale * 1.1 }, 150)
      .then(() => this.animate(character, { scale: baseScale }, 150));
  }
  
  private spawnAura(
    character: any,
    color: string,
    duration: number
  ): void {
    // Create particle emitter attached to character
    // Particles of given color float upward from character
    // Auto-destroy after duration
  }
}
```

### Edge Cases & Mitigations

---

#### 1. Inventory Overflow
**Problem:** A child keeps collecting outfit stamps and tries to attach multiple to the same slot.

**Mitigation:** Auto-swap system (inspired by Hollow Knight's bench-based equipment changes [^172^]). When a child places a new Helmet Stamp on a character that already has one, the old one automatically pops off and returns to the "Pocket" (inventory area). No error message---just a smooth visual swap. The Pocket has no capacity limit (infinite scroll) to avoid frustrating young collectors.

#### 2. Progression Blocking
**Problem:** A child reaches a gate but doesn't have the required Key Stamp and can't figure out what to do.

**Mitigation:** Triple safety net:
- **Ghost hint:** Lock stamps show a faded image of the needed Key Stamp type [^63^]
- **NPC guidance:** Friendly NPC stamps near blocked areas give visual hints (speech bubble showing the needed stamp)
- **Always-open alternative:** Every lock has at least one alternate path that doesn't require that specific key (Metroid Dread's sequence break philosophy [^136^])

#### 3. Power Imbalance
**Problem:** A child discovers a powerful stamp combination that trivializes all content.

**Mitigation:** Hollow Knight's overcharge approach [^172^]---allow overpowered combinations but add visual warnings. If stamps combine to create excessive power, the character stamp turns red and shakes, signaling "this is a lot of power!" The game doesn't prevent it (preserving creative freedom) but warns the child. The LLM backend can also scale enemy difficulty dynamically based on the child's current stamp loadout.

#### 4. Accidental Consumption
**Problem:** A child accidentally uses a rare food stamp or sells a key stamp.

**Mitigation:** All stamp transactions require **hold-and-confirm**: the child must hold a stamp on the target for 2 seconds before it's consumed. A circular progress ring appears around the stamp filling up---if released early, nothing happens. This prevents accidental usage while remaining simple enough for 5-year-olds (who are already familiar with "press and hold" from touch devices).

#### 5. Lost Progress Confusion
**Problem:** A child places a powerful stamp, removes it, and doesn't understand why they can't pass a gate anymore.

**Mitigation:** Visual trail system. When a Key Stamp is removed, the lock it previously opened briefly shows a "closing" animation with a particle trail leading back to where the Key Stamp was. This creates a visual association between cause and effect. Additionally, a simple "undo" button (inspired by Monster Train 2's undo feature [^190^]) lets children reverse their last stamp action.

#### 6. Shop Overspending
**Problem:** A child spends all their coins on candy and can't afford essential gear.

**Mitigation:** Shop stamps use visual prioritization---essential items (Key Stamps) have a **golden sparkle animation** that draws attention, while consumable Food Stamps are visually subtler. Additionally, shopkeepers (NPC stamps) have visual speech bubbles suggesting useful purchases based on what the child currently has equipped. The system nudges without forcing.

#### 7. Too Many Stamps on Canvas
**Problem:** The canvas becomes cluttered with hundreds of stamps.

**Mitigation:** Auto-categorization system. When the canvas gets crowded, the system gently suggests organizing by creating "Stamp Piles"---visually grouping similar stamps together (all Food Stamps stack into a picnic basket, all Coin Stamps stack into a treasure chest). The pile shows a number badge ONLY if the child hovers/taps and holds, otherwise it just looks like a themed container.

### Sources

---

[^11^] Castlevania Wiki - Symphony of the Night Inventory. https://castlevania.fandom.com/wiki/Symphony_of_the_Night_Inventory (2026-03-18)

[^12^] Castlevania Wiki - Luck stat mechanics across games. https://castlevania.fandom.com/wiki/Luck (2026-05-22)

[^13^] GameFAQs - Best stat boost items in River City Ransom. https://gamefaqs.gamespot.com/boards/563453-river-city-ransom/51676367 (2009-10-07)

[^14^] Reddit r/castlevania - Drop Rate formula for Symphony of the Night. https://www.reddit.com/r/castlevania/comments/18j8pkm/drop_rate_formula_for_symphony_of_the_night_and/ (Unknown Date)

[^16^] Below the Cut: River City Ransom (NES) RPG analysis. http://allconsolerpgs.blogspot.com/2013/11/below-cut-river-city-ransom-nes.html (2013-11-02)

[^17^] GameFAQs Board - Question regarding Castlevania SOTN starting stats. https://gamefaqs.gamespot.com/boards/196885-castlevania-symphony-of-the-night/80289773?page=2 (2022-12-26)

[^18^] FamiBoards - Symphony of the Night Luck Mode is a game changer. https://famiboards.com/threads/symphony-of-the-night-luck-mode-is-a-game-changer.14906/ (2025-09-04)

[^19^] Wikipedia - Odin Sphere. https://en.wikipedia.org/wiki/Odin_Sphere (2007-04-26)

[^20^] GameGrin - Game Over: River City Ransom. https://www.gamegrin.com/articles/game-over-river-city-ransom/ (2025-01-10)

[^53^] Strafefox - Wonder Boy III Dragon's Trap complete equipment guide. http://www.strafefox.nl/warpzone/wb3b.htm (Unknown Date)

[^54^] RPGClassics - Wonder Boy III transformations. http://tartarus.rpgclassics.com/wonderboy3/trans.shtml (Unknown Date)

[^61^] Black Shell Media - How To Design Games For Kids And Younger Audiences. https://medium.com/black-shell-media/gamedev-thoughts-how-to-design-games-for-kids-and-younger-audiences-1e6e96fd416a (2017-05-25)

[^62^] Sega Retro - Wonder Boy III: The Dragon's Trap. https://segaretro.org/Wonder_Boy_III:_The_Dragon%27s_Trap (2026-06-04)

[^63^] DreamNoid - How to create your own Metroidvania (gear-gating analysis). https://dreamnoid.com/articles/how-to-create-your-own-metroidvania (2023-03-22)

[^75^] OmegaMetroid - Metroid Prime Walkthrough: Beam Combos. https://omegametroid.com/metroid-prime-walkthrough/beam-combos/ (2024-04-01)

[^76^] Polygon - Odin Sphere Leifthrasir beginner's guide. https://www.polygon.com/2016/7/11/12143330/odin-sphere-leifthrasir-beginners-guide/ (2016-07-11)

[^77^] RetroPixel - Samus upgrades in Metroid Fusion. http://metroid.retropixel.net/games/metroid4/items1.php (2014-05-01)

[^78^] Odin Sphere Wiki - Leifthrasir gameplay. https://odinsphere.fandom.com/wiki/Odin_Sphere:_Leifthrasir (2026-03-18)

[^79^] Persona Central - Odin Sphere Leifthrasir Skills & Combat Trailer. https://personacentral.com/odin-sphere-leifthrasir-skills-combat-trailer/ (2017-11-24)

[^83^] Metroid Wiki - Ice Beam. https://www.metroidwiki.org/wiki/Ice_Beam (2024-02-01)

[^87^] Push Square - Spyro Reignited Trilogy: Sparx the Dragonfly Guide. https://www.pushsquare.com/guides/spyro-reignited-trilogy-sparx-the-dragonfly-what-he-does-and-how-to-feed-him-butterflies (2021-08-13)

[^93^] GameFAQs - Castlevania Dawn of Sorrow soul system explanation. https://gamefaqs.gamespot.com/boards/922145-castlevania-dawn-of-sorrow/43551085 (2008-06-08)

[^96^] Wikipedia - Castlevania: Aria of Sorrow (Tactical Soul System). https://en.wikipedia.org/wiki/Castlevania:_Aria_of_Sorrow (2004-07-02)

[^97^] Source Gaming - Holism: Aria of Sorrow's Soul System. https://sourcegaming.info/2018/11/28/holism-aria-of-sorrows-soul-system/ (2018-11-28)

[^128^] Muramasa Wiki - Consumables and food system. https://muramasatdb.fandom.com/wiki/Consumables (2026-03-18)

[^129^] Muramasa Wiki - Weapons and forging system. https://muramasatdb.fandom.com/wiki/Weapons (2026-03-18)

[^130^] GameFAQs - Link's Awakening Trading Sequence FAQ. https://gamefaqs.gamespot.com/gameboy/563277-the-legend-of-zelda-links-awakening/faqs/37454 (2005-10-20)

[^131^] Metroid Wiki - Sequence Breaking (Metroid Dread). https://metroid.fandom.com/wiki/Sequence_Breaking (2018-11-19)

[^132^] IGN - Link's Awakening Trading Sequence Guide. https://www.ign.com/wikis/the-legend-of-zelda-links-awakening-switch/Link's_Awakening_Trading_Sequence_Guide (2024-09-30)

[^136^] BlizzardWatch - Sequence breaking in Metroid Dread. https://blizzardwatch.com/2021/10/20/sequence-breaking-metroid-dread/ (2021-10-20)

[^152^] RetroCide - Evolution of Kirby's copy abilities. https://theretrocide.wordpress.com/2017/07/15/from-gameboy-to-the-super-nintendo-an-evolution-of-kirbys-copy-abilities/ (2017-07-15)

[^155^] Wikipedia - Pokemon. https://en.wikipedia.org/wiki/Pok%C3%A9mon (2001-10-30)

[^168^] Medium - Hollow Knight: A lesson in Game Design. https://dimasgibi.medium.com/hollow-knight-a-lesson-in-game-design-8cc4ff8aa1cd (2023-03-21)

[^172^] U Shall Play - Charm system in Hollow Knight. https://ushallplay.wordpress.com/2022/10/02/charm-system-in-hollow-knight/ (2022-10-21)

[^174^] Yukai Chou - 10 Best Learning Games Kids. https://yukaichou.com/gamification-examples/top-ten-learning-games-kids/ (2026 Ranked)

[^176^] Ori Wiki - Ability Tree. https://oriandtheblindforest.fandom.com/wiki/Ability_Tree_(Ori_and_the_Blind_Forest) (2025-09-01)

[^179^] Casey Jarmes Portfolio - Celeste Level Design Case Study. https://caseyjarmes.wordpress.com/2020/09/15/celeste-level-design-case-study/ (2020-10-26)

[^187^] Spyro Wiki - Sparx the Dragonfly. https://spyro.fandom.com/wiki/Sparx_the_Dragonfly (2026-03-18)

[^189^] Push Square - Spyro Sparx health color system. https://www.pushsquare.com/guides/spyro-reignited-trilogy-sparx-the-dragonfly-what-he-does-and-how-to-feed-him-butterflies (2021-08-13)

[^190^] GamingOnLinux - Monster Train 2 deck-builder review. https://www.gamingonlinux.com/2025/06/monster-train-2-is-a-seriously-incredible-deck-builder/ (2025-06-04)

[^193^] Hades Wiki - Boons system. https://hades.fandom.com/wiki/Boons (2026-05-22)

[^196^] Wikipedia - Hades (video game). https://en.wikipedia.org/wiki/Hades_(video_game) (2018-12-07)
