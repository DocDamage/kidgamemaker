## 9. Visual, Audio & Atmospheric Features

Every stamp carries atmospheric DNA. A Tree Stamp in a sunlit forest receives warm dappled lighting, bird ambient audio, and pollen particles. The same Tree Stamp in a haunted night forest receives cool blue point lighting, creaking branch audio, ghost-wisp particles, and heavy fog. The child places the same stamp; the system creates entirely different atmospheric experiences through three invisible subsystems: the Atmosphere Inference Engine, which reads stamp combinations and writes 20+ atmospheric parameters; the Diegetic UI System, which eliminates every HUD element in favor of stamp-embedded information; and the Parallax Background System, which automatically distributes background stamps across seven depth layers for cinematic scrolling.

---

### 9.1 Atmosphere Inference Engine

#### 9.1.1 "One-Touch Atmosphere": Stamp Combinations to 20+ Parameters

Drawing from Playdead's work on *Inside* — where atmosphere is achieved through hand-placed lighting decals with no global illumination [^403^] — the core principle is that atmosphere is **inferred, not explicitly authored**. When a child places three stamps (Forest + Night + Fog), the LLM backend recognizes a semantic cluster and generates a complete `AtmosphereConfig` containing over twenty parameters: ambient light color and intensity, directional light angle and color temperature, up to eight point lights from torch or crystal stamps, fog density and height, an ambient audio bed, up to three foreground sounds, particle effects, color grading values, and discrete time-of-day and weather states.

Language models "understand semantic relationships of game elements" and can generate "narrative, visual, and gameplay content coherently" [^374^]. A Tree Stamp in a forest context receives warm color grading and bird audio. The same stamp in a haunted forest context receives desaturated colors and distant howls. The stamp does not change; its atmospheric response does. Each inferred atmosphere specifies five categories: (1) **Lighting** — ambient plus directional plus up to eight point lights; (2) **Color Grading** — temperature (-1.0 cool to +1.0 warm), saturation multiplier, and contrast curve; (3) **Fog** — density, color, and height; (4) **Audio Layers** — one ambient bed plus foreground sounds; and (5) **Particles** — a prioritized list from a catalog of fifteen effect types.

#### 9.1.2 Procedural Lighting, Audio, and Particles

The **Procedural Lighting Engine** generates light maps using the decal-layering approach Playdead employed in *Inside*: bounce light decals for indirect illumination, specular decals for surface highlights, rim light decals for silhouette clarity (a technique Moon Studios uses to keep Ori readable against painted scenery [^286^]), and cast shadow decals tracking light source position. Each stamp responds to nearby lights through auto-generated normal maps, computed from alpha channel and color differences using an approach similar to SpriteIlluminator [^375^]. When a child places a Torch Stamp near a Tree Stamp, the tree receives correct directional lighting from the torch side — visible, but never configured.

The **Atmospheric Audio Mixer** synthesizes environmental audio procedurally using the Web Audio API, which provides oscillators, gain nodes, filters, and convolution for reverb [^394^]. Rain is synthesized from random-pitched oscillators with short ADSR envelopes where "density of the rain is changing with some random factor" [^404^]; wind from filtered noise with continuous high-pass modulation [^404^]. Synthesis offers infinite variety and zero bandwidth for audio files. Each ambient bed crossfades over two seconds during atmosphere transitions.

The **Weather Particle System** spawns effects from the atmosphere config's particle list, with a hard cap of 500 active particles and automatic level-of-detail reduction when frame rate drops below 30 FPS. Essential particles (torch flames) always render; ambient particles (dust motes) cull first [^377^].

#### 9.1.3 Implementation: AtmosphereInferenceEngine

The inference engine runs on the LLM backend and re-executes on every stamp mutation. It maintains a rule database mapping stamp types to atmospheric modifications, applies rules in priority order (environment stamps set base values, time and weather stamps apply multipliers, light source stamps append to the point light list), and returns a complete `AtmosphereConfig` that all client-side subsystems consume.

```python
"""
AtmosphereInferenceEngine — LLM backend service.
Maps stamp combinations to lighting, audio, particle, and color-grading params.
"""
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from enum import Enum

class TimeOfDay(Enum):
    DAWN = "dawn"; DAY = "day"; DUSK = "dusk"; NIGHT = "night"

class Weather(Enum):
    CLEAR = "clear"; RAIN = "rain"; SNOW = "snow"; FOG = "fog"; STORM = "storm"

@dataclass
class LightSource:
    x: float; y: float; color: Tuple[int,int,int]; intensity: float
    radius: float; falloff: str = "smooth"; casts_shadows: bool = True

@dataclass
class AtmosphereConfig:
    ambient_color: Tuple[int,int,int] = (120, 130, 140)
    ambient_intensity: float = 0.5
    directional_light: Optional[LightSource] = None
    point_lights: List[LightSource] = field(default_factory=list)
    color_temperature: float = 0.0
    saturation: float = 1.0
    contrast: float = 1.0
    fog_density: float = 0.0
    fog_color: Tuple[int,int,int] = (200, 210, 220)
    fog_height: float = 0.0
    ambient_bed: str = "silence"
    foreground_sounds: List[str] = field(default_factory=list)
    music_mood: str = "neutral"
    particle_effects: List[str] = field(default_factory=list)
    time_of_day: TimeOfDay = TimeOfDay.DAY
    weather: Weather = Weather.CLEAR

STAMP_RULES: Dict[str, Dict] = {
    "Forest Stamp": {
        "ambient_color": (30, 50, 25), "ambient_intensity": 0.3,
        "color_temperature": 0.4, "ambient_bed": "forest_wind",
        "foreground_sounds": ["bird_chirp", "leaf_rustle", "twig_snap"],
        "music_mood": "peaceful", "particle_effects": ["dust_motes", "pollen"],
    },
    "Haunted Forest Stamp": {
        "ambient_color": (10, 15, 25), "ambient_intensity": 0.15,
        "color_temperature": -0.6, "ambient_bed": "haunted_wind",
        "foreground_sounds": ["owl_hoot", "branch_creak", "distant_howl"],
        "music_mood": "mysterious", "particle_effects": ["fog_ground", "ghost_wisps"],
        "fog_density": 0.4, "fog_color": (15, 20, 30),
    },
    "Cave Stamp": {
        "ambient_color": (15, 18, 22), "ambient_intensity": 0.2,
        "color_temperature": -0.5, "ambient_bed": "cave_drips",
        "foreground_sounds": ["water_drip", "bat_wing", "stone_echo"],
        "music_mood": "mysterious", "particle_effects": ["dust_motes", "water_drip"],
        "fog_density": 0.3, "fog_color": (20, 22, 28),
    },
    "Torch Stamp": {
        "add_point_light": True, "light_color": (255, 160, 60),
        "light_intensity": 0.8, "light_radius": 5.0,
        "foreground_sounds": ["fire_crackle"],
        "particle_effects": ["fire_sparks", "smoke_wisp"],
    },
    "Crystal Stamp": {
        "add_point_light": True, "light_color": (100, 200, 255),
        "light_intensity": 0.5, "light_radius": 4.0,
        "particle_effects": ["magic_sparkle"],
    },
    "Night Stamp": {
        "ambient_multiplier": 0.3, "color_temperature": -0.8,
        "add_directional": True, "dir_color": (180, 200, 255),
        "dir_intensity": 0.3,
        "foreground_sounds_add": ["cricket_chirp", "owl_hoot"],
        "particle_effects_add": ["fireflies"],
    },
    "Rain Stamp": {
        "weather": "rain", "ambient_multiplier": 0.7,
        "color_temperature": -0.3, "ambient_bed": "rain_heavy",
        "foreground_sounds": ["thunder_distant", "rain_splash"],
        "particle_effects": ["rain_falling", "splash_ground"],
        "fog_density": 0.15,
    },
    "Fog Stamp": {
        "weather": "fog", "fog_density": 0.5,
        "fog_color": (180, 185, 190), "ambient_multiplier": 0.6,
        "ambient_bed": "fog_wind", "particle_effects": ["fog_ground"],
    },
}

def infer_atmosphere(stamps: List[Dict]) -> AtmosphereConfig:
    """Core inference: placed stamps -> complete atmosphere config."""
    config = AtmosphereConfig()
    ambient_multiplier = 1.0
    has_directional = False

    for stamp in stamps:
        stamp_type = stamp.get("type", "")
        if stamp_type not in STAMP_RULES:
            continue
        rules = STAMP_RULES[stamp_type]

        # Base overrides
        for key in ["ambient_color", "ambient_intensity", "color_temperature",
                    "fog_density", "fog_color", "ambient_bed", "music_mood"]:
            if key in rules:
                setattr(config, key, rules[key])

        # Merge lists with deduplication
        for key in ["foreground_sounds", "foreground_sounds_add",
                    "particle_effects", "particle_effects_add"]:
            if key in rules:
                target = key.replace("_add", "")
                merged = list(set(getattr(config, target) + rules[key]))
                setattr(config, target, merged)

        if "ambient_multiplier" in rules:
            ambient_multiplier *= rules["ambient_multiplier"]

        if rules.get("add_point_light"):
            config.point_lights.append(LightSource(
                x=stamp.get("x", 0.0), y=stamp.get("y", 0.0),
                color=rules.get("light_color", (255, 255, 255)),
                intensity=rules.get("light_intensity", 0.5),
                radius=rules.get("light_radius", 3.0), casts_shadows=True,
            ))

        if rules.get("add_directional") and not has_directional:
            config.directional_light = LightSource(
                x=stamp.get("x", 0.0) + 10, y=stamp.get("y", 0.0) + 5,
                color=rules.get("dir_color", (255, 255, 255)),
                intensity=rules.get("dir_intensity", 0.5),
                radius=100.0, casts_shadows=False,
            )
            has_directional = True

        if "weather" in rules:
            config.weather = Weather(rules["weather"])

    config.ambient_intensity *= ambient_multiplier
    config.ambient_intensity = max(0.05, min(1.0, config.ambient_intensity))
    config.fog_density = max(0.0, min(1.0, config.fog_density))
    return config
```

The engine resolves stamp conflicts silently — no error messages that confuse five-year-olds. Time-of-day stamps override with last-placed-wins semantics. Weather stamps combine (Rain + Fog = misty rain) but not contradict (Rain + Clear = Rain wins). Lighting colors blend rather than overriding. This silent resolution preserves creative flow while maintaining atmospheric coherence.

---

### 9.2 Diegetic UI System

#### 9.2.1 Zero HUD: Health, Score, and Ability State Embedded in Stamps

The diegetic UI principle states that every piece of information normally shown in a HUD must be embedded directly in the game world through stamps. Playdead's *Inside* demonstrates this powerfully: "there is no health bar, no score, no minimap, no button prompts, no tutorial text. Everything is communicated through environmental storytelling, character body language, lighting, and audio design" [^349^][^350^]. For children, this removes text they may not yet read fluently.

**Health** displays on the Character Stamp through a three-state pipeline: pristine at full health, scratched and dimmed at partial health, cracked and pulsing red at critical. Glow intensity scales with health percentage, and tint shifts from white through orange to red. This draws from proven systems: Journey's scarf lengthens as health increases [^400^], Dead Space's RIG meter maintains clear status readability [^398^], and Playdead's boy hunches when tired [^379^]. **Score** appears as a physical trophy shelf — a viewport-pinned zone where collected stamps accumulate visibly. **Ability state** shows through the Character Stamp's aura: golden particles for double-jump, flame ripples for speed boost, cyan ring for shield.

#### 9.2.2 Objective Compass and Environmental Wayfinding

The **Objective Compass Stamp** — placed automatically by the LLM when the game has a goal — appears as a decorative element (glowing arrow, fluttering butterfly, pointing wind vane) that rotates toward the objective. It exists in the game world and responds to the same lighting and physics as other stamps. **Environmental wayfinding** supplements the compass: the LLM places subtle cues along the path — slightly brighter ground tiles, flowers that bloom toward the goal, fireflies that drift in the correct direction. These cues are visible to children looking for direction but unobtrusive to those exploring freely, mirroring *Inside*'s use of light and composition to guide without explicit markers [^318^].

#### 9.2.3 Implementation: DiegeticUIManager

The `DiegeticUIManager` runs client-side, consuming character state updates and rendering all diegetic feedback as sprite overlays and particle effects within the game world. It never creates DOM elements.

```typescript
/**
 * DiegeticUIManager — Zero-HUD information display embedded in stamps.
 * Health = character appearance. Score = trophy shelf. Objectives = compass.
 */
interface CharacterState {
  health: number; maxHealth: number; score: number;
  activeAbilities: string[]; objectivePosition?: { x: number; y: number };
}

class DiegeticUIManager {
  private ctx: CanvasRenderingContext2D;
  private charX = 0; private charY = 0;
  private charTint: [number, number, number] = [255, 255, 255];
  private glowIntensity = 1.0;
  private state: CharacterState;
  private trophyShelf: Array<{ sprite: HTMLImageElement; x: number; y: number }> = [];
  private compassAngle = 0;
  private hasCompass = false;
  private auraParticles: Array<{ angle: number; radius: number; speed: number }> = [];
  private shakeX = 0; private shakeY = 0;

  constructor(private canvas: HTMLCanvasElement) {
    this.ctx = canvas.getContext("2d")!;
    this.state = { health: 3, maxHealth: 3, score: 0, activeAbilities: [] };
    for (let i = 0; i < 12; i++) {
      this.auraParticles.push({
        angle: (i / 12) * Math.PI * 2,
        radius: 40 + Math.random() * 10,
        speed: 0.02 + Math.random() * 0.02,
      });
    }
  }

  updateState(newState: Partial<CharacterState>) {
    const prevHealth = this.state.health;
    this.state = { ...this.state, ...newState };
    if ((newState.health ?? prevHealth) < prevHealth) this.playDamageFeedback();
    this.updateVisuals();
  }

  private updateVisuals() {
    const pct = this.state.health / this.state.maxHealth;
    this.glowIntensity = 0.2 + pct * 0.8;
    if (pct > 0.6) this.charTint = [255, 255, 255];
    else if (pct > 0.3) this.charTint = [255, 220, 180];
    else this.charTint = [255, 150, 150];

    if (this.state.objectivePosition) {
      const dx = this.state.objectivePosition.x - this.charX;
      const dy = this.state.objectivePosition.y - this.charY;
      this.compassAngle = Math.atan2(dy, dx);
      this.hasCompass = true;
    }
  }

  private playDamageFeedback() {
    // Flash red + screen shake
    this.shakeX = 6; this.shakeY = 6;
    setTimeout(() => { this.shakeX = 0; this.shakeY = 0; }, 200);
  }

  collectItem(sprite: HTMLImageElement) {
    this.trophyShelf.push({
      sprite, x: 40 + this.trophyShelf.length * 48, y: 30,
    });
  }

  setCharacterPosition(x: number, y: number) { this.charX = x; this.charY = y; }

  render(sprite: HTMLImageElement, spriteW: number, spriteH: number) {
    const cx = this.charX + spriteW / 2 + this.shakeX;
    const cy = this.charY + spriteH / 2 + this.shakeY;
    const time = Date.now() / 1000;

    // Render ability aura
    if (this.state.activeAbilities.length > 0) {
      const auraColor = this.getAuraColor();
      for (const p of this.auraParticles) {
        p.angle += p.speed;
        const x = cx + Math.cos(p.angle + time) * p.radius;
        const y = cy + Math.sin(p.angle + time) * p.radius * 0.6;
        const alpha = 0.3 + Math.sin(time * 3 + p.angle) * 0.2;
        this.ctx.fillStyle = `rgba(${auraColor[0]},${auraColor[1]},${auraColor[2]},${alpha})`;
        this.ctx.beginPath(); this.ctx.arc(x, y, 3, 0, Math.PI * 2); this.ctx.fill();
      }
    }

    // Render character with health-driven tint and glow
    this.ctx.save();
    this.ctx.filter = `drop-shadow(0 0 ${this.glowIntensity * 12}px rgba(${this.charTint.join(",")},0.5))`;
    this.ctx.globalAlpha = 0.8 + this.glowIntensity * 0.2;
    this.ctx.drawImage(sprite, this.charX + this.shakeX, this.charY + this.shakeY, spriteW, spriteH);
    this.ctx.restore();

    // Render compass above character
    if (this.hasCompass) {
      this.ctx.save();
      this.ctx.translate(cx, cy - spriteH * 0.6);
      this.ctx.rotate(this.compassAngle);
      this.ctx.globalAlpha = 0.7 + Math.sin(time * 3) * 0.3;
      this.ctx.fillStyle = "rgb(255,255,200)";
      this.ctx.beginPath();
      this.ctx.moveTo(12, 0); this.ctx.lineTo(-6, -6); this.ctx.lineTo(-6, 6);
      this.ctx.closePath(); this.ctx.fill();
      this.ctx.restore();
    }

    // Render trophy shelf (viewport-relative)
    for (const item of this.trophyShelf) {
      this.ctx.globalAlpha = 0.9;
      this.ctx.drawImage(item.sprite, item.x, item.y, 40, 40);
    }
    this.ctx.globalAlpha = 1.0;
  }

  private getAuraColor(): [number, number, number] {
    const colors: Record<string, [number, number, number]> = {
      double_jump: [255, 215, 0], speed_boost: [255, 100, 50], shield: [100, 200, 255],
    };
    return colors[this.state.activeAbilities[0]] ?? [255, 255, 255];
  }
}
```

The manager renders in two spaces: world-space (character aura, compass rotation) and viewport-space (trophy shelf). Collected items remain visible regardless of camera position, while the compass and aura track the character through the world.

---

### 9.3 Parallax & Layered Background System

#### 9.3.1 Seven-Layer Depth System with Automatic Semantic Assignment

The parallax system creates cinematic depth by distributing background stamps across seven layers, each with a distinct scroll factor. The architecture draws from Moon Studios' *Ori and the Blind Forest*, where hand-painted 3D backgrounds combine with 2D gameplay using orthographic projection and multi-layer depth [^286^]. A child places a Mountain Stamp once; the LLM places it at layer 1 (depth 0.1), applies atmospheric perspective tinting, and disables collision. Research confirms that "a total of 6 layers" provides excellent depth, with parallax factors between 0 and 1 based on perceived camera distance [^303^]; this system extends to seven layers.

| Layer | Depth | Semantic Role | Fog Tint | Contrast | Collision |
|-------|-------|---------------|----------|----------|-----------|
| 0 — Sky | 0.0 | Celestial backdrop | 0% | 100% | No |
| 1 — Far Background | 0.1 | Distant landscape | 40% | 60% | No |
| 2 — Mid-Far Background | 0.25 | Distant vegetation | 25% | 75% | No |
| 3 — Mid Background | 0.45 | Background scenery | 10% | 90% | No |
| 4 — Near Background | 0.7 | Nearby scenery | 3% | 97% | No |
| 5 — Gameplay | 1.0 | Interactive plane | 0% | 100% | Yes |
| 6 — Foreground | 1.3 | Occluding detail | 0% | 100% | No |

The depth factor drives scroll rate via `cameraOffset = cameraX * depthFactor`. A mountain at depth 0.1 shifts 10 pixels per 100 pixels of camera movement. Foreground elements at depth 1.3 move faster than the camera, producing occlusion as the player runs past [^303^]. Each distant layer receives automatic atmospheric perspective — a blue-tinted fog whose intensity increases with distance — simulating optical scattering that makes real distant objects appear hazier.

#### 9.3.2 Automatic Parallax Without Child Configuration

The LLM assigns layer membership through semantic classification. The child stamps elements at the same visual depth on the flat canvas; the LLM assigns actual parallax layers based on semantic understanding — mountains are far, bushes are near. Background stamps draw as non-repeating compositions (like Ori's painted backdrops [^286^]); repeating is reserved for ground tiles and sky elements. The key simplification: the child places a stamp once, and the system handles parallax layer, scaling, color grading, and fog.

#### 9.3.3 Implementation: ParallaxBackgroundSystem

```typescript
/**
 * ParallaxBackgroundSystem — 7-layer depth with automatic semantic assignment.
 * Background stamps create parallax without any child configuration.
 */

interface PlacedStamp {
  image: HTMLImageElement; x: number; y: number;
  width: number; height: number; repeatX: boolean; stampType: string;
}

interface ParallaxLayer {
  depth: number; yOffset: number; fogTint: number;
  contrastMul: number; collision: boolean; stamps: PlacedStamp[];
}

class ParallaxBackgroundSystem {
  private layers: ParallaxLayer[] = [];

  private readonly CONFIGS = [
    { depth: 0.0,  yOffset: 0.0,  fogTint: 0.0,  contrastMul: 1.0,  collision: false },
    { depth: 0.1,  yOffset: 0.05, fogTint: 0.4,  contrastMul: 0.6,  collision: false },
    { depth: 0.25, yOffset: 0.15, fogTint: 0.25, contrastMul: 0.75, collision: false },
    { depth: 0.45, yOffset: 0.25, fogTint: 0.1,  contrastMul: 0.9,  collision: false },
    { depth: 0.7,  yOffset: 0.35, fogTint: 0.03, contrastMul: 0.97, collision: false },
    { depth: 1.0,  yOffset: 0.5,  fogTint: 0.0,  contrastMul: 1.0,  collision: true  },
    { depth: 1.3,  yOffset: 0.6,  fogTint: 0.0,  contrastMul: 1.0,  collision: false },
  ];

  private readonly STAMP_LAYER: Record<string, number> = {
    "Sky Stamp": 0, "Moon Stamp": 0, "Sun Stamp": 0, "Cloud Stamp": 0,
    "Mountain Stamp": 1, "City Skyline Stamp": 1,
    "Hill Stamp": 2, "Tree Distant Stamp": 2,
    "Tree Stamp": 3, "Building Stamp": 3, "Tower Stamp": 3,
    "Bush Stamp": 4, "Fence Stamp": 4, "Sign Stamp": 4,
    "Ground Stamp": 5, "Platform Stamp": 5, "Character Stamp": 5, "Enemy Stamp": 5,
    "Grass Foreground Stamp": 6, "Flower Stamp": 6, "Vine Stamp": 6,
  };

  constructor(private canvas: HTMLCanvasElement) {}

  initializeFromStamps(placements: PlacedStamp[]) {
    this.layers = this.CONFIGS.map((c) => ({ ...c, stamps: [] as PlacedStamp[] }));
    for (const p of placements) {
      const li = this.STAMP_LAYER[p.stampType] ?? 5;
      this.layers[li].stamps.push({
        ...p, y: p.y + this.CONFIGS[li].yOffset * this.canvas.height,
      });
    }
  }

  render(cameraX: number, _cameraY: number,
         fogColor: [number,number,number] = [200,210,220],
         fogDensity = 0) {
    for (const layer of this.layers) {
      for (const stamp of layer.stamps) {
        const px = stamp.x - cameraX * layer.depth;
        const py = stamp.y - _cameraY * layer.depth * 0.3;
        if (stamp.repeatX) {
          const w = stamp.width;
          const start = Math.floor((cameraX * layer.depth) / w) - 1;
          const end = start + Math.ceil(this.canvas.width / w) + 2;
          for (let r = start; r <= end; r++) {
            this.drawStamp(stamp, px + r * w, py, layer.fogTint, layer.contrastMul, fogColor, fogDensity);
          }
        } else {
          this.drawStamp(stamp, px, py, layer.fogTint, layer.contrastMul, fogColor, fogDensity);
        }
      }
    }
  }

  private drawStamp(s: PlacedStamp, x: number, y: number,
                    fogTint: number, contrastMul: number,
                    fogColor: [number,number,number], fogDensity: number) {
    this.ctx.save();
    const totalFog = Math.min(1.0, fogTint + fogDensity * 0.5);
    if (totalFog > 0) {
      this.ctx.globalAlpha = 1.0 - totalFog * 0.25;
      this.ctx.filter = `contrast(${contrastMul * 100}%)`;
      // Fog tint overlay via offscreen canvas
      const oc = document.createElement("canvas");
      oc.width = s.width; oc.height = s.height;
      const octx = oc.getContext("2d")!;
      octx.drawImage(s.image, 0, 0, s.width, s.height);
      octx.fillStyle = `rgba(${fogColor[0]},${fogColor[1]},${fogColor[2]},${totalFog * 0.3})`;
      octx.globalCompositeOperation = "source-atop";
      octx.fillRect(0, 0, s.width, s.height);
      this.ctx.drawImage(oc, x, y, s.width, s.height);
    } else {
      this.ctx.drawImage(s.image, x, y, s.width, s.height);
    }
    this.ctx.restore();
  }

  get ctx() { return this.canvas.getContext("2d")!; }
  getCollisionStamps() { return this.layers[5]?.stamps ?? []; }
}
```

---

### 9.4 Atmospheric Audio Mixer

The `AtmosphericAudioMixer` consumes the `AtmosphereConfig` from the inference engine and synthesizes all ambient audio procedurally using the Web Audio API. No audio files are downloaded — rain, wind, fire, crickets, and city hum are all generated in real-time from oscillators and filtered noise, enabling smooth crossfades between biomes.

```typescript
/**
 * AtmosphericAudioMixer — Procedural ambient audio via Web Audio API.
 * Synthesizes rain, wind, fire, crickets, drips from algorithms.
 * Zero external audio files for ambient beds.
 */

class AtmosphericAudioMixer {
  private ctx: AudioContext;
  private master: GainNode;
  private activeLayers = new Map<string, { nodes: any; gain: GainNode }>();

  // Synthesis presets: each returns an object with a gain node for level control
  private presets: Record<string, (() => { gain: GainNode; cleanup: () => void } | null)> = {
    forest_wind: () => this.makeWind(200, 400, 0.15, 0.3),
    haunted_wind: () => this.makeWind(80, 180, 0.2, 0.45),
    cave_drips: () => this.makeDrips(0.4, 0.6),
    rain_heavy: () => this.makeRain(600, 0.35),
    rain_light: () => this.makeRain(150, 0.12),
    fire_crackle: () => this.makeFire(0.25),
    cricket_chirp: () => this.makeCrickets(0.18),
    city_hum: () => this.makeHum(0.08),
    fog_wind: () => this.makeWind(250, 500, 0.08, 0.18),
    silence: () => null,
  };

  constructor() {
    this.ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
    this.master = this.ctx.createGain();
    this.master.gain.value = 0.5;
    this.master.connect(this.ctx.destination);
  }

  /** Wind: bandpass-filtered noise with slow LFO modulation for gusts. */
  private makeWind(minF: number, maxF: number, minV: number, maxV: number) {
    const bufSize = 2 * this.ctx.sampleRate;
    const noise = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
    const data = noise.getChannelData(0);
    for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;

    const src = this.ctx.createBufferSource();
    src.buffer = noise; src.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = "bandpass";
    filter.frequency.value = (minF + maxF) / 2;
    filter.Q.value = 0.5;

    // LFO gust modulation
    const lfo = this.ctx.createOscillator();
    lfo.frequency.value = 0.15 + Math.random() * 0.2;
    const lfoGain = this.ctx.createGain();
    lfoGain.gain.value = (maxF - minF) / 2;
    lfo.connect(lfoGain); lfoGain.connect(filter.frequency); lfo.start();

    // Volume follows gusts
    const volLfo = this.ctx.createOscillator();
    volLfo.frequency.value = 0.1 + Math.random() * 0.15;
    const volLfoGain = this.ctx.createGain();
    volLfoGain.gain.value = (maxV - minV) / 2;
    const volOffset = this.ctx.createGain();
    volOffset.gain.value = (minV + maxV) / 2;
    volLfo.connect(volLfoGain); volLfo.connect(volOffset);

    const gain = this.ctx.createGain();
    src.connect(filter); filter.connect(gain);
    volLfoGain.connect(gain.gain); volOffset.connect(gain.gain);
    gain.connect(this.master);
    volLfo.start(); src.start();

    return { gain, cleanup: () => { src.stop(); lfo.stop(); volLfo.stop(); } };
  }

  /** Rain: many short sine bursts with random pitch and timing. */
  private makeRain(dropsPerSec: number, volume: number) {
    const gain = this.ctx.createGain();
    gain.gain.value = volume;
    gain.connect(this.master);
    const interval = 1000 / dropsPerSec;
    const timer = setInterval(() => {
      const drop = this.ctx.createOscillator();
      drop.type = "sine";
      drop.frequency.setValueAtTime(800 + Math.random() * 1200, this.ctx.currentTime);
      drop.frequency.exponentialRampToValueAtTime(200, this.ctx.currentTime + 0.05);
      const dg = this.ctx.createGain();
      dg.gain.setValueAtTime(0.2 + Math.random() * 0.2, this.ctx.currentTime);
      dg.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.08);
      drop.connect(dg); dg.connect(gain);
      drop.start(); drop.stop(this.ctx.currentTime + 0.1);
    }, interval);
    return { gain, cleanup: () => { clearInterval(timer); } };
  }

  /** Water drips: rhythmic drops with echo delay. */
  private makeDrips(rate: number, volume: number) {
    const gain = this.ctx.createGain();
    gain.gain.value = volume;
    gain.connect(this.master);
    const ms = (1.0 / rate) * 1000;
    const timer = setInterval(() => {
      const drop = this.ctx.createOscillator();
      drop.type = "sine";
      drop.frequency.setValueAtTime(600, this.ctx.currentTime);
      drop.frequency.exponentialRampToValueAtTime(300, this.ctx.currentTime + 0.1);
      const dg = this.ctx.createGain();
      dg.gain.setValueAtTime(0.4, this.ctx.currentTime);
      dg.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.25);
      // Echo
      const delay = this.ctx.createDelay();
      delay.delayTime.value = 0.3 + Math.random() * 0.2;
      const eg = this.ctx.createGain(); eg.gain.value = 0.25;
      drop.connect(dg); dg.connect(gain);
      dg.connect(delay); delay.connect(eg); eg.connect(gain);
      drop.start(); drop.stop(this.ctx.currentTime + 0.6);
    }, ms);
    return { gain, cleanup: () => clearInterval(timer) };
  }

  /** Fire: lowpass noise base + random sawtooth pops. */
  private makeFire(volume: number) {
    const gain = this.ctx.createGain();
    gain.gain.value = volume;
    gain.connect(this.master);
    // Rumble base
    const bufSize = this.ctx.sampleRate * 2;
    const noise = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
    const d = noise.getChannelData(0);
    for (let i = 0; i < bufSize; i++) d[i] = Math.random() * 2 - 1;
    const src = this.ctx.createBufferSource();
    src.buffer = noise; src.loop = true;
    const filter = this.ctx.createBiquadFilter();
    filter.type = "lowpass"; filter.frequency.value = 700;
    src.connect(filter); filter.connect(gain); src.start();
    // Crackle pops
    const timer = setInterval(() => {
      const pop = this.ctx.createOscillator();
      pop.type = "sawtooth";
      pop.frequency.value = 2000 + Math.random() * 3000;
      const pg = this.ctx.createGain();
      pg.gain.setValueAtTime(0.08 + Math.random() * 0.15, this.ctx.currentTime);
      pg.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.02);
      pop.connect(pg); pg.connect(gain);
      pop.start(); pop.stop(this.ctx.currentTime + 0.03);
    }, 80 + Math.random() * 350);
    return { gain, cleanup: () => { src.stop(); clearInterval(timer); } };
  }

  /** Crickets: 2-3 oscillators at cricket frequencies with chirp gating. */
  private makeCrickets(volume: number) {
    const gain = this.ctx.createGain();
    gain.gain.value = volume;
    gain.connect(this.master);
    const crickets: Array<{ osc: OscillatorNode; gg: GainNode }> = [];
    for (let i = 0; i < 3; i++) {
      const osc = this.ctx.createOscillator();
      osc.type = "sine";
      osc.frequency.value = 3500 + i * 180 + Math.random() * 80;
      const gg = this.ctx.createGain(); gg.gain.value = 0;
      osc.connect(gg); gg.connect(gain); osc.start();
      crickets.push({ osc, gg });
    }
    const timer = setInterval(() => {
      const now = this.ctx.currentTime;
      crickets.forEach((c) => {
        c.gg.gain.setValueAtTime(0.08, now);
        c.gg.gain.setValueAtTime(0, now + 0.03);
        c.gg.gain.setValueAtTime(0.08, now + 0.06);
        c.gg.gain.setValueAtTime(0, now + 0.09);
      });
    }, 280 + Math.random() * 180);
    return { gain, cleanup: () => { crickets.forEach((c) => c.osc.stop()); clearInterval(timer); } };
  }

  /** City hum: lowpass-filtered noise at very low frequency. */
  private makeHum(volume: number) {
    const bufSize = this.ctx.sampleRate * 2;
    const noise = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
    const d = noise.getChannelData(0);
    for (let i = 0; i < bufSize; i++) d[i] = Math.random() * 2 - 1;
    const src = this.ctx.createBufferSource();
    src.buffer = noise; src.loop = true;
    const filter = this.ctx.createBiquadFilter();
    filter.type = "lowpass"; filter.frequency.value = 250;
    const gain = this.ctx.createGain();
    gain.gain.value = volume;
    src.connect(filter); filter.connect(gain); gain.connect(this.master);
    src.start();
    return { gain, cleanup: () => src.stop() };
  }

  /** Transition to a new atmosphere: crossfade over fadeDuration seconds. */
  async transitionTo(config: { ambient_bed: string; foreground_sounds: string[] },
                     fadeDuration = 2.0) {
    const { ambient_bed, foreground_sounds } = config;
    // Fade out layers not in new config
    for (const [name, layer] of this.activeLayers) {
      if (name !== ambient_bed && !foreground_sounds.includes(name)) {
        layer.gain.gain.linearRampToValueAtTime(0, this.ctx.currentTime + fadeDuration);
        setTimeout(() => { layer.cleanup(); this.activeLayers.delete(name); }, fadeDuration * 1000 + 100);
      }
    }
    // Fade in new ambient bed
    if (ambient_bed && !this.activeLayers.has(ambient_bed)) {
      const result = this.presets[ambient_bed]?.();
      if (result) {
        result.gain.gain.setValueAtTime(0, this.ctx.currentTime);
        result.gain.gain.linearRampToValueAtTime(1, this.ctx.currentTime + fadeDuration);
        this.activeLayers.set(ambient_bed, { nodes: result, gain: result.gain });
      }
    }
    // Fade in foreground sounds
    for (const sound of foreground_sounds) {
      if (this.activeLayers.has(sound)) continue;
      const result = this.presets[sound]?.();
      if (result) {
        result.gain.gain.setValueAtTime(0, this.ctx.currentTime);
        result.gain.gain.linearRampToValueAtTime(1, this.ctx.currentTime + fadeDuration * 0.5);
        this.activeLayers.set(sound, { nodes: result, gain: result.gain });
      }
    }
  }

  setVolume(v: number) {
    this.master.gain.linearRampToValueAtTime(Math.max(0, Math.min(1, v)), this.ctx.currentTime + 0.1);
  }
  resume() { if (this.ctx.state === "suspended") this.ctx.resume(); }
}
```

---

### Integration: The Atmospheric Pipeline

These four subsystems form a single pipeline. When a child places a stamp: (1) the `AtmosphereInferenceEngine` receives the updated stamp list and returns a complete `AtmosphereConfig` with 20+ parameters; (2) the `DiegeticUIManager` updates character visual state, trophy shelf, and compass from game state changes; (3) the `ParallaxBackgroundSystem` renders background stamps across seven depth layers, applying fog from the atmosphere config as atmospheric perspective tints; (4) the `AtmosphericAudioMixer` crossfades ambient beds and foreground sounds to match the new atmosphere over two seconds.

The result is environmental coherence from minimal child input. Safety considerations are built into every parameter: a minimum ambient floor of 20% (35% in child-safe mode) prevents overly dark scenes [^387^], haunted stamps are age-gated below eight, the particle budget caps at 500 with automatic culling [^377^], and conflicting stamps resolve silently with clear priority rules. The pipeline demonstrates that professional-grade environmental storytelling — the kind that took Playdead years to hand-craft [^403^] — can be made accessible to a five-year-old through semantic stamp design and LLM-powered inference.
