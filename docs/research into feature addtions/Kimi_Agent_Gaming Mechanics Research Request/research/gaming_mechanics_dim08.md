# Dimension 08: Visual, Audio & Atmospheric Systems

## Research: Atmospheric Depth Through Stamp Properties in Cinematic Side-Scrollers

**Date:** July 2025
**Searches Conducted:** 30+ independent queries across studio techniques, technical implementations, and child-development research
**Sources:** GDC talks, studio postmortems, academic papers, official documentation, engine tutorials

---

### Executive Summary

Cinematic side-scrolling games have achieved extraordinary atmospheric depth by treating every visual and audio element as a storytelling device. From Playdead's complete elimination of UI in *Inside* through hand-placed lighting decals [^403^], to Moon Studios' fusion of 3D painted landscapes with 2D gameplay in *Ori and the Blind Forest* [^286^], to Sad Cat Studios' dynamic 3D lighting on pixel art in *Replaced* [^289^], the industry has developed a rich vocabulary for creating mood without words. These innovations form the foundation for a stamp-based game creation platform where atmospheric DNA is embedded in every stamp and automatically activated by the LLM backend.

This research synthesizes five studio innovations into actionable technical specifications for a zero-code, stamp-based platform designed for children as young as five. The core insight is that atmosphere can be **inferred, not explicitly authored**. When a child places a "Tree Stamp" in a forest context, the LLM determines dappled lighting, bird ambient audio, and warm color grading automatically. The child's only job is to stamp; the platform's job is to create a cohesive, atmospheric world that responds to those stamps intelligently. This approach mirrors Playdead's philosophy of letting the environment communicate everything, extended to a system where the environment is assembled by a child and interpreted by AI.

The recommended architecture consists of three invisible subsystems: a **Procedural Lighting Engine** that generates light maps from stamp semantics (forest = dappled directional + warm ambient; cave = point lights + cool ambient + fog), an **Atmospheric Audio Mixer** that layers ambient beds and foreground sounds based on stamp composition, and a **Parallax Background System** that automatically places background stamps at depth-appropriate layers. Together, these systems ensure every child's game feels professionally atmospheric without requiring any understanding of lighting, audio design, or visual composition.

---

### Studio Innovations Analysis

#### 1. Playdead (Limbo, Inside): Diegetic UI-Less Atmospheric Platforming

**How It Works:**

Playdead's games eliminate every traditional UI element. There is no health bar, no score, no minimap, no button prompts, no tutorial text. Everything is communicated through environmental storytelling, character body language, lighting, and audio design [^349^][^350^].

The technical foundation for *Inside*'s atmosphere is a heavily modified Unity engine where all lighting is achieved through **hand-placed decals** rather than automated global illumination [^403^]. Artist Marek Bogdan explains: "the lighting you see in INSIDE is all about layers of hand-placed decals - there is no global illumination or even automated AO at play here" [^403^]. Each scene receives multiple layers of:
- Bounce light decals (simulated indirect illumination)
- Specular light decals (surface reflections)
- Rim light decals (edge highlighting for silhouette clarity)
- Ambient occlusion decals (soft shadowing in crevices)
- Cast shadow decals (faked shadows that track light source position)

For the iconic torch effect, shadows from the Boy's feet are not real-time shadows at all but "simple shadow decals that track the position of the torch and rotate accordingly around the Boy's feet. They even scale up and down depending on how high the torch is off the ground" [^403^]. This was chosen because standard point-light shadows were too expensive.

The character communicates state through posture alone. The boy hunches when tired, shivers when cold, recoils from danger. Body language substitutes for every UI element [^379^].

**Stamp-Based Adaptation:**

For a child's platform, this philosophy becomes the default: **no UI visible to the child ever**. Health is shown on the character (glow intensity, posture changes, clothing damage). Objectives are shown through environmental cues (a glowing path, a distant landmark, NPC gestures). Score/collectibles are shown as physical changes to the character (Journey's scarf lengthening as health increases [^400^]).

The LLM generates lighting automatically from stamp semantics:
- A "Forest Stamp" triggers: dappled directional light (simulated god-rays), warm ambient (green-brown tint), bird ambient audio, leaf particle effects
- A "Cave Stamp" triggers: point light sources near torch/crystal stamps, cool ambient (blue-gray tint), water drip audio, fog particles
- Each stamp carries atmospheric metadata that the LLM composes into layered decal effects

---

#### 2. Moon Studios (Ori series): Painted 3D Landscapes with 2D Collision Planes

**How It Works:**

Moon Studios achieves the distinctive look of *Ori and the Blind Forest* by combining lush, hand-painted 3D backgrounds with purely 2D gameplay [^286^]. The technique, presented at GDC 2015 by lead animator James Benson, involves:

- **Orthographic camera from the side**: All 3D assets are rendered with an orthographic projection, eliminating perspective cues that would reveal the 3D nature of the assets. "Having less of these details makes it easier to trick you into thinking that you're not looking at a 3d asset" [^286^]
- **100% self-illuminated diffuse**: Ori uses only a diffuse texture with no real-time lighting. This ensures the character reads clearly against detailed backgrounds
- **Silhouette-first design**: Ori is designed as "almost pure black/white" with a focus on silhouette readability. The pure white character is visible against super-detailed backgrounds at all times [^286^]
- **Baked effects**: Motion blur, depth of field, and other expensive effects are pre-baked into sprite atlases rather than computed in real-time
- **Additive multiply masks for fake lighting**: "you can put an additive multiply mask on one side of the character to simulate something like a big moon behind it all over, and if the sprite flips, the light still keeps in that direction" [^286^]

**Stamp-Based Adaptation:**

The parallax system for the stamp platform mirrors Ori's multi-layer approach but automates it:

- **Background stamps** are automatically placed on depth layers (0.1 to 0.9 parallax factor)
- The LLM determines layer placement: distant mountains (layer 0.1), mid-ground trees (layer 0.4), nearby bushes (layer 0.7), foreground grass (layer 1.2)
- Each layer scrolls at `distance = camera.x * parallaxFactor`, creating depth without the child understanding parallax [^303^]
- Background stamps are drawn as "non-repeating" compositions (like Ori's painted backdrops) rather than tiled patterns, giving each scene a unique cinematic quality

The key simplification: the child places a "Mountain Stamp" once, and the LLM handles its placement at the correct parallax layer, appropriate scaling, color grading to match the scene's time of day, and atmospheric fog based on distance.

---

#### 3. Sad Cat Studios (Replaced): Volumetric Fog, Real-Time Dynamic Light on Pixel Art

**How It Works:**

*Replaced* pushes the 2.5D aesthetic by combining classic pixel art sprites with modern 3D rendering techniques. According to the studio's official Xbox blog post, the visual approach centers on [^289^]:

- **Frame-by-frame pixel art animation** rather than 3D models: "Whenever we tried experimenting with 3D models, the result was sub-par and very noisy. We wanted our game's world to be cohesive, so that everything has its distinctive look" [^289^]
- **Dynamic lighting and depth-of-field** applied to pixel art in real-time: "soft dynamic lighting and some absolutely brilliant cinematography. Toss in just the right amount of depth of field" [^288^]
- **Custom camera movement and unique lighting shifts for combat feedback**: "we use custom camera movement and unique lighting shifts to ensure the player feels how vibrant and impactful their actions are" [^289^]
- **Volumetric fog and modern 3D effects** composited with pixel art: "best in class pixel art enhanced by modern depth-of-field, lighting, and cinematic visual effects" [^289^]

The technical implementation likely uses normal maps for 2D sprites, allowing the pixel art to respond to real-time light sources while maintaining its hand-crafted pixel aesthetic [^371^][^375^]. Tools like SpriteIlluminator can auto-generate normal maps from sprite transparency and color data, enabling dynamic lighting without hand-painting normal maps for every frame [^375^].

**Stamp-Based Adaptation:**

For the stamp platform, every stamp includes **auto-generated normal map data** (computed algorithmically from the stamp's alpha channel and color differences, similar to SpriteIlluminator's algorithmic mode [^375^]). When the child places a stamp:

- The LLM determines what light sources are nearby
- Normal map data makes the stamp respond to those lights (a tree stamp near a torch stamp will be lit from the correct side)
- Volumetric fog is applied automatically based on scene context (underwater = heavy blue fog, night forest = light ground fog)
- Depth-of-field blur is applied to background layer stamps automatically

The child never sees or interacts with normal maps, lighting parameters, or fog settings. They place a "Torch Stamp" and the surrounding stamps respond to its light automatically.

---

#### 4. Vanillaware (Odin Sphere, Muramasa): Hand-Painted Skeletal Puppetry

**How It Works:**

Vanillaware's distinctive animation style combines hand-painted artwork with skeletal animation systems, a process they call *tebineri* or "hand-shaping" [^410^]. Key technical aspects:

- **Skeletal animation with hand-painted parts**: Characters are constructed from separate, hand-painted body parts (limbs, torso, head, accessories) that are attached to a bone hierarchy and animated [^353^][^354^]
- **Proprietary tools inspired by Adobe Flash**: The company uses in-house toolsets for animation that allow artists to create characters that "look 3D but are rendered entirely from two-dimensional pixels" [^410^]
- **Part-swapping for variation**: The same skeleton can be reused with different art parts, enabling extensive character variations without re-drawing every animation frame [^353^]
- **Root motion from 3D**: As seen in Ori's similar pipeline, 3D rigged animations are rendered to sprite atlases, allowing root motion data to drive in-engine movement [^286^]

The skeletal approach has significant advantages: "the skill floor to get something good looking is FAR lower in skeletal animation than traditional, plus time required is much less, and you can replace the pieces (or add more) while using the same skeleton and animations and achieve variations that go beyond a simple color swap" [^353^].

**Stamp-Based Adaptation:**

The "Animation Stamp" system for children leverages this principle:

- Each character stamp has a **pre-defined skeleton** with named bones (head, body, left_arm, right_arm, left_leg, right_leg)
- When the LLM determines an animation is needed (walking, jumping, hurt), it maps the animation to the skeleton bones
- The same "Walk Cycle" animation works across all biped character stamps because they share a compatible skeleton structure
- **Part-swapping stamps**: A child can place an "Armor Stamp" on top of a "Knight Stamp", and the LLM composites the armor onto the correct bone positions automatically
- Animations are pre-authored by professional animators but applied procedurally by the LLM based on gameplay context

This means a child places a single "Character Stamp" and the LLM handles: idle breathing animation, walking when moving, hurt reaction when touching an enemy, and victory pose when reaching a goal - all without the child needing to understand animation.

---

#### 5. Sabotage Studio (The Messenger): Real-Time Visual Style Switching

**How It Works:**

*The Messenger* features a dramatic mid-game shift from 8-bit to 16-bit presentation, with the player able to travel between eras via "time warps" - screen tears that transform the world in real-time [^213^][^285^]. The technical implementation:

- **Dual asset sets**: Every game element exists in both 8-bit and 16-bit versions, with the 16-bit versions having more detailed sprites and additional animation frames [^213^]
- **Real-time palette and resolution switching**: The visual transformation happens instantly as the player passes through a warp point
- **Audio style switching**: The soundtrack was "created in Famitracker, meaning it's fully NES-authentic" for the 8-bit era, with distinct 16-bit arrangements for the future era [^215^]. Composer Eric "Rainbowdragoneyes" Brown created each song individually in both styles
- **Level structure changes**: The 16-bit future is not just a visual reskin - "level structure changing, and the art being significantly improved in the latter realm" [^215^]. Layouts alter, platforms move, new paths open

**Stamp-Based Adaptation:**

The "Era/Style Stamp" concept allows children to transform their game's entire visual identity with a single stamp placement:

- An "8-Bit Era Stamp" makes the LLM render all stamps with: limited 4-color palette, hard pixel edges, chiptune audio style, 30fps animation cap
- A "16-Bit Era Stamp" switches to: expanded 16-color palette, soft gradients, synth-driven audio, 60fps smooth animation
- A "Watercolor Era Stamp" could switch to: painterly filtered output, soft audio reverb, animated paper texture overlay
- The child's existing stamps remain in place; only the **rendering pipeline** changes
- Multiple era stamps can coexist in a level (like The Messenger's warp points), creating gameplay where crossing a boundary transforms the visual world

The LLM maintains a mapping from each stamp to its multi-era representations, and the active era stamp determines which variant is rendered.

---

### Key Findings

1. **Hand-placed decals outperform automated lighting for artistic control.** Playdead's decision to manually place every lighting decal rather than use automated solutions was driven by the need for "a painterly look that felt as close as possible to Morten's concepts" and the need to control "modeling (and lighting) detail... depending on distance from the camera and gameplay or narrative focus" [^403^]. For a stamp platform, this means the LLM should place lighting decals with deliberate artistic intent, not generic global illumination.

2. **Silhouette clarity is the foundation of readable character design.** Ori's pure white silhouette against detailed backgrounds ensures readability at all times [^286^]. The stamp platform must maintain character silhouette clarity regardless of atmospheric effects, with automatic rim lighting or character glow when background complexity would otherwise cause readability issues.

3. **Normal maps enable 2D sprites to respond to dynamic lighting.** Tools like SpriteIlluminator can auto-generate normal maps from existing sprite art, enabling dynamic lighting without manual normal map painting [^375^]. The stamp platform should auto-generate normal maps for all stamps from their alpha channels and color data.

4. **Diegetic UI increases immersion but requires clear design language consistency.** Dead Space's RIG health meter works because "the status of the meter is very clear" and consistently presented [^398^]. For children, diegetic health must be even more obvious - using size, color, glow, or companion reactions rather than subtle suit indicators.

5. **Parallax scrolling with 6+ layers creates convincing depth in 2D.** The Unity parallax tutorial demonstrates that "a total of 6 layers" provides excellent depth, with each layer assigned a parallax factor between 0 and 1 based on its perceived distance from the camera [^303^]. Background stamps should automatically map to these depth layers.

6. **Procedural audio synthesis can create infinite variety from simple algorithms.** Rain can be synthesized from "random pitched oscillators with very tiny ADSR events" where "density of the rain is changing with some random factor" [^404^]. Wind can be created from "a noise object that is filtered continuously with a high pass filter object" [^404^]. The stamp platform should synthesize ambient audio procedurally rather than playing static loops, allowing dynamic weather transitions.

7. **The Web Audio API provides sufficient synthesis capabilities for browser-based procedural audio.** Oscillators, gain nodes, filters, and convolution (for reverb) are all available natively in modern browsers [^394^][^392^], enabling a full procedural audio pipeline without external dependencies.

8. **Skeletal animation lowers the skill floor for quality animation while enabling extensive reuse.** Vanillaware's approach of reusing skeletons across different art parts means "you can replace the pieces (or add more) while using the same skeleton and animations and achieve variations that go beyond a simple color swap" [^353^]. Animation stamps should share skeletons across character types.

9. **Visual style switching can be a core gameplay mechanic, not just cosmetic.** The Messenger's era-switching "radically alters the layout and terrain of once-familiar zones" [^285^], making it a puzzle element. Era/style stamps in the platform should potentially alter collision, platform placement, and level layout, not just visuals.

10. **Children's fear responses to darkness are developmental and context-dependent.** The amygdala (fear regulator) is highly developed at birth, but connections to the frontal cortex (emotion regulation) develop through early childhood. "Playing in the dark can feel a lot less scary - and even ride that line between frightening and fun" as children develop [^387^]. The platform must calibrate atmospheric darkness to age-appropriate levels, with automatic "safe scary" boundaries.

11. **Sensory overload prevention requires adjustable intensity thresholds.** Sensory-friendly design for children includes offering "areas of retreat and respite" and adjustable stimuli [^377^]. The platform should include an "atmosphere intensity" setting that limits particle count, audio volume, lighting complexity, and weather effects.

12. **Atmosphere can be procedurally inferred from stamp combinations via LLM.** Research on LLM-driven procedural content generation demonstrates that language models "understand semantic relationships of game elements" and can generate "narrative, visual, and gameplay content coherently" [^374^]. An LLM backend can map stamp combinations to atmospheric parameters (lighting color, audio layers, particle effects) through semantic understanding.

---

### Child-Friendly Simplifications

#### How Each Studio Innovation Becomes Child-Accessible

**Atmospheric Lighting (from Playdead):**
- Child places a "Sun Stamp" -> LLM automatically adds: warm directional light, god-ray decals, warm color grading, bird ambient audio
- Child places a "Moon Stamp" -> LLM adds: cool blue directional light, star particles, cricket ambient audio, darker ambient base
- Child places a "Lamp Stamp" -> LLM adds: point light with warm falloff, moth particles, nearby stamp illumination via normal maps
- The child never adjusts light color, intensity, or position. They place a light stamp, and the world responds.

**Parallax Depth (from Moon Studios):**
- Child places a "Mountain Stamp" -> LLM places it at parallax layer 0.1 (far background), applies atmospheric perspective tinting, disables collision
- Child places a "Bush Stamp" -> LLM places it at layer 0.7 (near background), adds slight sway animation, enables collision
- The child stamps elements at the same "depth" on the canvas; the LLM assigns actual parallax layers based on semantic understanding (mountains are far, bushes are near)

**Dynamic Lighting on Stamps (from Replaced):**
- Every stamp auto-generates a normal map from its transparency and color data on import
- When placed near a light source stamp, the stamp receives correct directional lighting
- The child sees the effect (a tree lit from the correct side by a torch) but never configures lighting
- Fog and depth-of-field are applied automatically based on scene context stamps ("Cave Stamp" adds fog, "Night Stamp" adds bloom to lights)

**Animation (from Vanillaware):**
- Character stamps contain pre-authored skeletons and animation libraries
- The LLM triggers appropriate animations based on gameplay state: walking when moving, jumping when ascending, hurt on enemy contact
- Part-swapping happens automatically: placing a "Hat Stamp" on a character composites it to the head bone
- The child sees smooth, professional animation without any animation tools

**Visual Style (from The Messenger):**
- An "8-Bit Style Stamp" transforms the entire rendering pipeline to limited palette + pixelated edges
- A "Storybook Style Stamp" activates watercolor filters and page textures
- Multiple style stamps can exist in a level, creating visual variety
- The child's stamps remain the same; only how they're rendered changes

#### The "One-Touch Atmosphere" Principle

Every atmospheric change must be achievable with a single stamp placement. If a child wants a spooky forest, they:
1. Place "Forest Stamps" (trees, ground)
2. Place a "Night Stamp" (automatically darkens, adds moon, cricket sounds)
3. Place a "Fog Stamp" (adds ground fog particles, mutes colors)

The LLM composes these into: dark blue ambient light + moon directional light + fog particles + muted color grading + slow cricket ambient audio + occasional owl foreground sounds. Three stamps = complete atmosphere.

---

### Recommended Features

| Priority | Feature | Description | Complexity |
|----------|---------|-------------|------------|
| **P0** | Auto-Lighting Engine | LLM infers light sources from stamp semantics; every stamp responds to nearby lights via auto-generated normal maps | High |
| **P0** | Parallax Background System | Background stamps auto-distribute across 5+ depth layers with appropriate scroll factors | Medium |
| **P0** | Ambient Audio Mixer | Procedural ambient audio (wind, rain, wildlife) synthesized from stamp context; crossfades between biomes | High |
| **P0** | Diegetic Health System | Character appearance changes communicate state (glow, posture, size, companion reactions) | Medium |
| **P1** | Weather Particle System | Rain, snow, fog, leaves particles generated from "Weather Stamp" placement; auto-limited for performance | Medium |
| **P1** | Time-of-Day System | "Time Stamp" cycles through dawn/day/dusk/night with associated lighting, audio, and color grading | Medium |
| **P1** | Era/Style Filter | Visual style stamps transform the rendering pipeline (8-bit, watercolor, pixel art, painterly) | High |
| **P1** | Atmospheric Transitions | Smooth crossfades between atmospheres when player moves between zones (not jarring cuts) | Medium |
| **P2** | Screen Effects | Vignette, chromatic aberration, film grain, scanlines applied contextually by LLM | Low |
| **P2** | Dynamic Music Layering | Music intensity increases with action; ambient exploration music vs. combat music | High |
| **P2** | Character Animation System | Skeletal animation auto-applied to character stamps based on gameplay state | High |
| **P3** | Volumetric Fog | 2D volumetric fog that responds to light sources and wind direction | High |

---

### Code Snippets

#### 1. Procedural Lighting Engine (Python - LLM Backend)

```python
"""
Atmosphere Inference Engine
Maps stamp combinations to lighting/audio/particle parameters.
Called by the LLM backend when stamps are placed.
"""

from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple
from enum import Enum

class TimeOfDay(Enum):
    DAWN = "dawn"
    DAY = "day"
    DUSK = "dusk"
    NIGHT = "night"

class Weather(Enum):
    CLEAR = "clear"
    RAIN = "rain"
    SNOW = "snow"
    FOG = "fog"
    STORM = "storm"

@dataclass
class LightSource:
    """A light source in the scene."""
    x: float
    y: float
    color: Tuple[int, int, int]  # RGB 0-255
    intensity: float  # 0.0 - 1.0
    radius: float  # in game units
    falloff: str = "smooth"  # smooth, linear, sharp
    casts_shadows: bool = True

@dataclass
class AtmosphereConfig:
    """Complete atmosphere configuration inferred from stamps."""
    # Lighting
    ambient_color: Tuple[int, int, int]
    ambient_intensity: float
    directional_light: Optional[LightSource] = None
    point_lights: List[LightSource] = None
    
    # Color grading
    color_temperature: float  # warm (1.0) to cool (-1.0)
    saturation: float  # 0.0 (bw) to 1.5 (oversaturated)
    contrast: float  # 0.5 (flat) to 2.0 (high contrast)
    
    # Fog
    fog_density: float  # 0.0 (none) to 1.0 (thick)
    fog_color: Tuple[int, int, int]
    fog_height: float  # 0.0 (ground) to 1.0 (ceiling)
    
    # Audio layers
    ambient_bed: str  # e.g., "forest_wind", "cave_drips", "city_hum"
    foreground_sounds: List[str]  # e.g., ["bird_chirp", "leaf_rustle"]
    music_mood: str  # e.g., "peaceful", "tense", "mysterious"
    
    # Particles
    particle_effects: List[str]  # e.g., ["fireflies", "dust_motes"]
    
    # Time/Weather
    time_of_day: TimeOfDay
    weather: Weather


# Stamp-to-atmosphere mapping database
# This is referenced by the LLM but could also be used directly
STAMP_ATMOSPHERE_RULES = {
    # Environment stamps set the base atmosphere
    "Forest Stamp": {
        "ambient_color": (30, 50, 25),
        "ambient_intensity": 0.3,
        "color_temperature": 0.4,  # warm
        "ambient_bed": "forest_wind",
        "foreground_sounds": ["bird_chirp", "leaf_rustle", "twig_snap"],
        "music_mood": "peaceful",
        "particle_effects": ["dust_motes", "pollen"],
    },
    "Haunted Forest Stamp": {
        "ambient_color": (10, 15, 25),
        "ambient_intensity": 0.15,
        "color_temperature": -0.6,  # cool
        "ambient_bed": "haunted_wind",
        "foreground_sounds": ["owl_hoot", "branch_creak", "distant_howl"],
        "music_mood": "mysterious",
        "particle_effects": ["fog_ground", "ghost_wisps"],
        "fog_density": 0.4,
        "fog_color": (15, 20, 30),
    },
    "Cave Stamp": {
        "ambient_color": (15, 18, 22),
        "ambient_intensity": 0.2,
        "color_temperature": -0.5,
        "ambient_bed": "cave_drips",
        "foreground_sounds": ["water_drip", "bat_wing", "stone_echo"],
        "music_mood": "mysterious",
        "particle_effects": ["dust_motes", "water_drip"],
        "fog_density": 0.3,
        "fog_color": (20, 22, 28),
    },
    "City Stamp": {
        "ambient_color": (40, 38, 45),
        "ambient_intensity": 0.35,
        "color_temperature": 0.1,
        "ambient_bed": "city_hum",
        "foreground_sounds": ["car_pass", "distant_siren", "footstep_echo"],
        "music_mood": "urban",
        "particle_effects": ["dust_motes"],
    },
    # Light source stamps add point lights
    "Torch Stamp": {
        "add_point_light": True,
        "light_color": (255, 160, 60),
        "light_intensity": 0.8,
        "light_radius": 5.0,
        "foreground_sounds": ["fire_crackle"],
        "particle_effects": ["fire_sparks", "smoke_wisp"],
    },
    "Crystal Stamp": {
        "add_point_light": True,
        "light_color": (100, 200, 255),
        "light_intensity": 0.5,
        "light_radius": 4.0,
        "particle_effects": ["magic_sparkle"],
    },
    # Time stamps modify the base atmosphere
    "Night Stamp": {
        "ambient_multiplier": 0.3,
        "color_temperature": -0.8,
        "add_directional": True,
        "dir_color": (180, 200, 255),  # moon
        "dir_intensity": 0.3,
        "foreground_sounds_add": ["cricket_chirp", "owl_hoot"],
        "particle_effects_add": ["fireflies"],
    },
    "Sunset Stamp": {
        "color_temperature": 0.9,
        "add_directional": True,
        "dir_color": (255, 140, 50),
        "dir_intensity": 0.6,
        "particle_effects_add": ["pollen", "dust_motes"],
    },
    # Weather stamps add effects
    "Rain Stamp": {
        "weather": "rain",
        "ambient_multiplier": 0.7,
        "color_temperature": -0.3,
        "ambient_bed": "rain_heavy",
        "foreground_sounds": ["thunder_distant", "rain_splash"],
        "particle_effects": ["rain_falling", "splash_ground"],
        "fog_density": 0.15,
    },
    "Fog Stamp": {
        "weather": "fog",
        "fog_density": 0.5,
        "fog_color": (180, 185, 190),
        "ambient_multiplier": 0.6,
        "ambient_bed": "fog_wind",
        "particle_effects": ["fog_ground"],
    },
}


def infer_atmosphere(stamps: List[Dict]) -> AtmosphereConfig:
    """
    Core inference function. Takes a list of placed stamps and
    returns a complete atmosphere configuration.
    
    Called by the LLM backend whenever stamps change.
    """
    # Start with default (day, clear)
    config = AtmosphereConfig(
        ambient_color=(120, 130, 140),
        ambient_intensity=0.5,
        directional_light=None,
        point_lights=[],
        color_temperature=0.0,
        saturation=1.0,
        contrast=1.0,
        fog_density=0.0,
        fog_color=(200, 210, 220),
        fog_height=0.0,
        ambient_bed="silence",
        foreground_sounds=[],
        music_mood="neutral",
        particle_effects=[],
        time_of_day=TimeOfDay.DAY,
        weather=Weather.CLEAR,
    )
    
    # Track modifiers separately from base
    ambient_multiplier = 1.0
    has_directional = False
    
    for stamp in stamps:
        stamp_type = stamp.get("type", "")
        stamp_x = stamp.get("x", 0.0)
        stamp_y = stamp.get("y", 0.0)
        
        if stamp_type not in STAMP_ATMOSPHERE_RULES:
            continue
            
        rules = STAMP_ATMOSPHERE_RULES[stamp_type]
        
        # Apply base atmosphere rules
        if "ambient_color" in rules:
            config.ambient_color = rules["ambient_color"]
        if "ambient_intensity" in rules:
            config.ambient_intensity = rules["ambient_intensity"]
        if "color_temperature" in rules:
            config.color_temperature = rules["color_temperature"]
        if "fog_density" in rules:
            config.fog_density = rules["fog_density"]
        if "fog_color" in rules:
            config.fog_color = rules["fog_color"]
        if "ambient_bed" in rules:
            config.ambient_bed = rules["ambient_bed"]
        if "music_mood" in rules:
            config.music_mood = rules["music_mood"]
        if "saturation" in rules:
            config.saturation = rules["saturation"]
        if "contrast" in rules:
            config.contrast = rules["contrast"]
            
        # Merge lists (foreground sounds, particles)
        if "foreground_sounds" in rules:
            config.foreground_sounds = list(set(config.foreground_sounds + rules["foreground_sounds"]))
        if "foreground_sounds_add" in rules:
            config.foreground_sounds = list(set(config.foreground_sounds + rules["foreground_sounds_add"]))
        if "particle_effects" in rules:
            config.particle_effects = list(set(config.particle_effects + rules["particle_effects"]))
        if "particle_effects_add" in rules:
            config.particle_effects = list(set(config.particle_effects + rules["particle_effects_add"]))
            
        # Track multipliers
        if "ambient_multiplier" in rules:
            ambient_multiplier *= rules["ambient_multiplier"]
            
        # Add point lights from light source stamps
        if rules.get("add_point_light"):
            light = LightSource(
                x=stamp_x,
                y=stamp_y,
                color=rules.get("light_color", (255, 255, 255)),
                intensity=rules.get("light_intensity", 0.5),
                radius=rules.get("light_radius", 3.0),
                casts_shadows=True,
            )
            config.point_lights.append(light)
            
        # Add directional light
        if rules.get("add_directional") and not has_directional:
            config.directional_light = LightSource(
                x=stamp_x + 10,  # offset to simulate angled light
                y=stamp_y + 5,
                color=rules.get("dir_color", (255, 255, 255)),
                intensity=rules.get("dir_intensity", 0.5),
                radius=100.0,  # infinite directional
                casts_shadows=False,
            )
            has_directional = True
            
        # Track time/weather
        if "weather" in rules:
            config.weather = Weather(rules["weather"])
    
    # Apply accumulated multipliers
    config.ambient_intensity *= ambient_multiplier
    config.ambient_intensity = max(0.05, min(1.0, config.ambient_intensity))  # clamp
    config.fog_density = max(0.0, min(1.0, config.fog_density))
    
    return config


# Example usage:
if __name__ == "__main__":
    # Simulate a haunted forest at night with torches
    stamps = [
        {"type": "Haunted Forest Stamp", "x": 0, "y": 0},
        {"type": "Night Stamp", "x": 20, "y": 0},
        {"type": "Torch Stamp", "x": 10, "y": 5},
        {"type": "Torch Stamp", "x": 25, "y": 5},
        {"type": "Fog Stamp", "x": 15, "y": 0},
    ]
    
    atmosphere = infer_atmosphere(stamps)
    print(f"Ambient: RGB{atmosphere.ambient_color} @ {atmosphere.ambient_intensity:.2f}")
    print(f"Color Temp: {atmosphere.color_temperature:.1f}")
    print(f"Fog: density={atmosphere.fog_density:.2f}")
    print(f"Point Lights: {len(atmosphere.point_lights)}")
    print(f"Audio Bed: {atmosphere.ambient_bed}")
    print(f"Foreground: {atmosphere.foreground_sounds}")
    print(f"Particles: {atmosphere.particle_effects}")
```

#### 2. Procedural Lighting Engine (GLSL Fragment Shader)

```glsl
// 2D Multi-Light Fragment Shader with Normal Map Support
// For use in WebGL/Canvas-based game engines

precision mediump float;

varying vec2 v_texCoord;
varying vec2 v_position;  // world position

uniform sampler2D u_texture;
uniform sampler2D u_normalMap;  // auto-generated normal map
uniform vec2 u_resolution;
uniform float u_time;

// Ambient light
uniform vec3 u_ambientColor;
uniform float u_ambientIntensity;

// Directional light (sun/moon)
uniform vec3 u_dirColor;
uniform vec2 u_dirDirection;  // normalized direction
uniform float u_dirIntensity;

// Point lights (up to 8 for performance)
#define MAX_POINT_LIGHTS 8
uniform int u_pointLightCount;
uniform vec2 u_pointLightPos[MAX_POINT_LIGHTS];
uniform vec3 u_pointLightColor[MAX_POINT_LIGHTS];
uniform float u_pointLightRadius[MAX_POINT_LIGHTS];
uniform float u_pointLightIntensity[MAX_POINT_LIGHTS];

// Fog
uniform vec3 u_fogColor;
uniform float u_fogDensity;
uniform float u_fogHeight;

// Color grading
uniform float u_colorTemp;  // -1 (cool) to 1 (warm)
uniform float u_saturation;
uniform float u_contrast;

// Helper: apply color temperature
vec3 applyColorTemp(vec3 color, float temp) {
    // Warm = more red/yellow, Cool = more blue
    color.r += temp * 0.1;
    color.g += temp * 0.05;
    color.b -= temp * 0.1;
    return color;
}

// Helper: apply contrast
vec3 applyContrast(vec3 color, float contrast) {
    return (color - 0.5) * contrast + 0.5;
}

// Helper: calculate point light contribution
vec3 calcPointLight(vec2 fragPos, vec3 normal, int index) {
    vec2 lightPos = u_pointLightPos[index];
    vec3 lightColor = u_pointLightColor[index];
    float radius = u_pointLightRadius[index];
    float intensity = u_pointLightIntensity[index];
    
    // Distance attenuation
    float dist = distance(fragPos, lightPos);
    if (dist > radius) return vec3(0.0);
    
    float attenuation = 1.0 - (dist / radius);
    attenuation = attenuation * attenuation;  // smooth falloff
    
    // Normal-based diffuse (if normal map available)
    vec2 lightDir = normalize(lightPos - fragPos);
    float diff = max(dot(normal.xy, lightDir), 0.0);
    
    return lightColor * attenuation * intensity * (0.5 + diff * 0.5);
}

void main() {
    vec4 texColor = texture2D(u_texture, v_texCoord);
    if (texColor.a < 0.1) discard;
    
    // Sample normal map (auto-generated from sprite)
    vec3 normal = vec3(0.0, 0.0, 1.0);  // default: facing camera
    // Uncomment when normal maps are available:
    // normal = texture2D(u_normalMap, v_texCoord).rgb * 2.0 - 1.0;
    
    // Start with ambient
    vec3 lighting = u_ambientColor * u_ambientIntensity;
    
    // Add directional light
    if (u_dirIntensity > 0.0) {
        float dirDiff = max(dot(normal.xy, -u_dirDirection), 0.0);
        lighting += u_dirColor * u_dirIntensity * (0.3 + dirDiff * 0.7);
    }
    
    // Add all point lights
    for (int i = 0; i < MAX_POINT_LIGHTS; i++) {
        if (i >= u_pointLightCount) break;
        lighting += calcPointLight(v_position, normal, i);
    }
    
    // Apply lighting to texture
    vec3 finalColor = texColor.rgb * lighting;
    
    // Apply fog
    if (u_fogDensity > 0.0) {
        float fogFactor = 1.0 - exp(-u_fogDensity * distance(v_position, vec2(0.0)) * 0.01);
        // Height-based fog: more fog at bottom of screen
        float heightFog = 1.0 - v_texCoord.y;
        fogFactor *= 0.5 + heightFog * 0.5;
        finalColor = mix(finalColor, u_fogColor, clamp(fogFactor, 0.0, 1.0));
    }
    
    // Apply color grading
    finalColor = applyColorTemp(finalColor, u_colorTemp);
    finalColor = applyContrast(finalColor, u_contrast);
    
    // Saturation adjustment
    float luminance = dot(finalColor, vec3(0.299, 0.587, 0.114));
    finalColor = mix(vec3(luminance), finalColor, u_saturation);
    
    // Clamp and output
    finalColor = clamp(finalColor, 0.0, 1.0);
    gl_FragColor = vec4(finalColor, texColor.a);
}
```

#### 3. Atmospheric Audio Mixer (JavaScript - Web Audio API)

```javascript
/**
 * Atmospheric Audio Mixer
 * Procedurally generates environmental audio based on stamp context.
 * Uses Web Audio API for synthesis (no external audio files needed for ambience).
 */

class AtmosphericAudioMixer {
    constructor() {
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        this.masterGain = this.ctx.createGain();
        this.masterGain.gain.value = 0.5;
        this.masterGain.connect(this.ctx.destination);
        
        // Active layers
        this.layers = new Map();  // name -> { nodes, gain }
        
        // Sound presets
        this.presets = {
            forest_wind: () => this.createWind(200, 400, 0.15, 0.3),
            haunted_wind: () => this.createWind(100, 200, 0.2, 0.5),
            cave_drips: () => this.createDrips(0.3, 0.8),
            rain_heavy: () => this.createRain(800, 0.4),
            rain_light: () => this.createRain(200, 0.15),
            fire_crackle: () => this.createFireCrackle(0.3),
            cricket_chirp: () => this.createCrickets(0.2),
            city_hum: () => this.createCityHum(0.1),
            fog_wind: () => this.createWind(300, 600, 0.1, 0.2),
            silence: () => null,
        };
    }
    
    /** Wind: filtered noise with slow modulation */
    createWind(minFreq, maxFreq, minVol, maxVol) {
        const bufferSize = 2 * this.ctx.sampleRate;
        const noise = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const output = noise.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            output[i] = Math.random() * 2 - 1;
        }
        
        const source = this.ctx.createBufferSource();
        source.buffer = noise;
        source.loop = true;
        
        // Bandpass filter for wind tone
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.value = (minFreq + maxFreq) / 2;
        filter.Q.value = 0.5;
        
        // Slow modulation for gust effect
        const lfo = this.ctx.createOscillator();
        lfo.frequency.value = 0.2 + Math.random() * 0.3;  // slow gusts
        const lfoGain = this.ctx.createGain();
        lfoGain.gain.value = (maxFreq - minFreq) / 2;
        lfo.connect(lfoGain);
        lfoGain.connect(filter.frequency);
        lfo.start();
        
        // Volume envelope following gusts
        const volLfo = this.ctx.createOscillator();
        volLfo.frequency.value = 0.15 + Math.random() * 0.2;
        const volLfoGain = this.ctx.createGain();
        volLfoGain.gain.value = (maxVol - minVol) / 2;
        const volOffset = this.ctx.createGain();
        volOffset.gain.value = (minVol + maxVol) / 2;
        volLfo.connect(volLfoGain);
        
        const gain = this.ctx.createGain();
        source.connect(filter);
        filter.connect(gain);
        volLfoGain.connect(gain.gain);
        volOffset.connect(gain.gain);
        gain.connect(this.masterGain);
        volLfo.start();
        
        source.start();
        return { source, filter, lfo, volLfo, gain };
    }
    
    /** Rain: many short noise bursts with random timing */
    createRain(dropsPerSecond, volume) {
        const gain = this.ctx.createGain();
        gain.gain.value = volume;
        gain.connect(this.masterGain);
        
        const interval = 1000 / dropsPerSecond;
        const timer = setInterval(() => {
            const drop = this.ctx.createOscillator();
            drop.type = 'sine';
            // Random pitch for each drop
            drop.frequency.setValueAtTime(
                800 + Math.random() * 1200, 
                this.ctx.currentTime
            );
            drop.frequency.exponentialRampToValueAtTime(
                200, 
                this.ctx.currentTime + 0.05
            );
            
            const dropGain = this.ctx.createGain();
            dropGain.gain.setValueAtTime(0.3 + Math.random() * 0.3, this.ctx.currentTime);
            dropGain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.08);
            
            drop.connect(dropGain);
            dropGain.connect(gain);
            drop.start();
            drop.stop(this.ctx.currentTime + 0.1);
        }, interval);
        
        return { gain, timer };
    }
    
    /** Water drips: rhythmic drops with echo */
    createDrips(rate, volume) {
        const gain = this.ctx.createGain();
        gain.gain.value = volume;
        gain.connect(this.masterGain);
        
        const timer = setInterval(() => {
            const drop = this.ctx.createOscillator();
            drop.type = 'sine';
            drop.frequency.setValueAtTime(600, this.ctx.currentTime);
            drop.frequency.exponentialRampToValueAtTime(300, this.ctx.currentTime + 0.1);
            
            const dropGain = this.ctx.createGain();
            dropGain.gain.setValueAtTime(0.5, this.ctx.currentTime);
            dropGain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.2);
            
            // Echo
            const delay = this.ctx.createDelay();
            delay.delayTime.value = 0.3 + Math.random() * 0.2;
            const echoGain = this.ctx.createGain();
            echoGain.gain.value = 0.3;
            
            drop.connect(dropGain);
            dropGain.connect(gain);
            dropGain.connect(delay);
            delay.connect(echoGain);
            echoGain.connect(gain);
            
            drop.start();
            drop.stop(this.ctx.currentTime + 0.6);
        }, (1.0 / rate) * 1000);
        
        return { gain, timer };
    }
    
    /** Fire crackle: filtered noise with random pops */
    createFireCrackle(volume) {
        const gain = this.ctx.createGain();
        gain.gain.value = volume;
        gain.connect(this.masterGain);
        
        // Base rumble
        const bufferSize = this.ctx.sampleRate * 2;
        const noise = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const data = noise.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = Math.random() * 2 - 1;
        }
        const source = this.ctx.createBufferSource();
        source.buffer = noise;
        source.loop = true;
        
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.value = 800;
        
        source.connect(filter);
        filter.connect(gain);
        source.start();
        
        // Crackle pops
        const timer = setInterval(() => {
            const pop = this.ctx.createOscillator();
            pop.type = 'sawtooth';
            pop.frequency.value = 2000 + Math.random() * 3000;
            
            const popGain = this.ctx.createGain();
            popGain.gain.setValueAtTime(0.1 + Math.random() * 0.2, this.ctx.currentTime);
            popGain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.02);
            
            pop.connect(popGain);
            popGain.connect(gain);
            pop.start();
            pop.stop(this.ctx.currentTime + 0.03);
        }, 100 + Math.random() * 400);
        
        return { source, filter, gain, timer };
    }
    
    /** Crickets: oscillators at cricket frequencies */
    createCrickets(volume) {
        const gain = this.ctx.createGain();
        gain.gain.value = volume;
        gain.connect(this.masterGain);
        
        // Create 2-3 crickets at slightly different pitches
        const crickets = [];
        for (let i = 0; i < 3; i++) {
            const osc = this.ctx.createOscillator();
            osc.type = 'sine';
            osc.frequency.value = 3500 + i * 200 + Math.random() * 100;
            
            const cricketGain = this.ctx.createGain();
            // Chirp pattern: on-off-on-off
            const chirpRate = 15 + Math.random() * 10;  // chirps per second
            cricketGain.gain.setValueAtTime(0, this.ctx.currentTime);
            
            osc.connect(cricketGain);
            cricketGain.connect(gain);
            osc.start();
            crickets.push({ osc, gain: cricketGain, chirpRate });
        }
        
        // Simple chirp modulation
        const timer = setInterval(() => {
            crickets.forEach(c => {
                const now = this.ctx.currentTime;
                c.gain.gain.setValueAtTime(0.1, now);
                c.gain.gain.setValueAtTime(0, now + 0.03);
                c.gain.gain.setValueAtTime(0.1, now + 0.06);
                c.gain.gain.setValueAtTime(0, now + 0.09);
            });
        }, 300 + Math.random() * 200);
        
        return { gain, crickets, timer };
    }
    
    /** City hum: low-frequency noise */
    createCityHum(volume) {
        const bufferSize = this.ctx.sampleRate * 2;
        const noise = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const data = noise.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = Math.random() * 2 - 1;
        }
        
        const source = this.ctx.createBufferSource();
        source.buffer = noise;
        source.loop = true;
        
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.value = 300;
        
        const gain = this.ctx.createGain();
        gain.gain.value = volume;
        
        source.connect(filter);
        filter.connect(gain);
        gain.connect(this.masterGain);
        source.start();
        
        return { source, filter, gain };
    }
    
    /** Transition to new atmosphere */
    async transitionTo(atmosphereConfig, fadeDuration = 2.0) {
        const { ambient_bed, foreground_sounds } = atmosphereConfig;
        
        // Fade out current layers not in new config
        for (const [name, layer] of this.layers) {
            if (name !== ambient_bed && !foreground_sounds.includes(name)) {
                await this.fadeOutLayer(name, fadeDuration);
            }
        }
        
        // Fade in new ambient bed
        if (ambient_bed && !this.layers.has(ambient_bed)) {
            await this.fadeInLayer(ambient_bed, fadeDuration);
        }
        
        // Fade in foreground sounds
        for (const sound of foreground_sounds) {
            if (!this.layers.has(sound)) {
                await this.fadeInLayer(sound, fadeDuration * 0.5);
            }
        }
    }
    
    async fadeInLayer(name, duration) {
        if (!this.presets[name]) return;
        
        const nodes = this.presets[name]();
        if (!nodes) return;
        
        const gain = nodes.gain || this.ctx.createGain();
        if (!nodes.gain) {
            // Connect through new gain node
            // (implementation depends on preset structure)
        }
        
        gain.gain.setValueAtTime(0, this.ctx.currentTime);
        gain.gain.linearRampToValueAtTime(1, this.ctx.currentTime + duration);
        
        this.layers.set(name, { nodes, gain });
    }
    
    async fadeOutLayer(name, duration) {
        const layer = this.layers.get(name);
        if (!layer) return;
        
        layer.gain.gain.linearRampToValueAtTime(0, this.ctx.currentTime + duration);
        
        setTimeout(() => {
            // Clean up nodes
            if (layer.nodes.timer) clearInterval(layer.nodes.timer);
            if (layer.nodes.source) layer.nodes.source.stop();
            this.layers.delete(name);
        }, duration * 1000 + 100);
    }
    
    /** Set master volume (0.0 to 1.0) */
    setVolume(vol) {
        this.masterGain.gain.linearRampToValueAtTime(
            Math.max(0, Math.min(1, vol)), 
            this.ctx.currentTime + 0.1
        );
    }
    
    /** Resume audio context (needed after user interaction in browsers) */
    resume() {
        if (this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
    }
}

// Usage:
// const mixer = new AtmosphericAudioMixer();
// mixer.transitionTo({ ambient_bed: "forest_wind", foreground_sounds: ["cricket_chirp"] });
```

#### 4. Parallax Background System (JavaScript)

```javascript
/**
 * Parallax Background System
 * Automatically manages multiple background layers with depth-based scrolling.
 * Each layer scrolls at a different rate relative to camera movement.
 */

class ParallaxBackgroundSystem {
    constructor(canvas, camera) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.camera = camera;  // { x, y } in world coordinates
        
        // Layer definitions: farther = lower parallax factor
        this.layers = [];
        
        // Default layer configuration (5 layers)
        this.defaultConfig = [
            { depth: 0.05, name: "sky", yOffset: 0 },        // Far: sky, moon
            { depth: 0.15, name: "mountains", yOffset: 0.1 },
            { depth: 0.30, name: "hills", yOffset: 0.2 },
            { depth: 0.55, name: "trees_back", yOffset: 0.3 },
            { depth: 0.80, name: "trees_mid", yOffset: 0.4 },
            { depth: 1.00, name: "ground", yOffset: 0.5 },    // Gameplay layer
            { depth: 1.20, name: "foreground", yOffset: 0.6 }, // Near: grass, flowers
        ];
    }
    
    /**
     * Add a stamp to a specific parallax layer.
     * Called by the LLM after determining appropriate depth.
     */
    addStamp(stamp, layerIndex) {
        const layer = this.layers[layerIndex];
        if (!layer) return;
        
        layer.stamps.push({
            image: stamp.image,
            x: stamp.x,
            y: stamp.y + layer.config.yOffset * this.canvas.height,
            width: stamp.width || stamp.image.width,
            height: stamp.height || stamp.image.height,
            repeatX: stamp.repeatX !== false,  // repeat by default
        });
    }
    
    /**
     * Initialize layers from stamp placement data.
     * Called once after LLM determines layer assignments.
     */
    initializeFromStamps(stampPlacements) {
        // Create layer containers
        this.layers = this.defaultConfig.map((config, i) => ({
            config,
            stamps: [],
            layerIndex: i,
        }));
        
        // Distribute stamps to layers based on semantic depth
        // LLM determines: mountains -> layer 1, trees -> layer 3, etc.
        for (const placement of stampPlacements) {
            const layerIndex = this.determineLayer(placement.stampType);
            this.addStamp(placement, layerIndex);
        }
    }
    
    /**
     * Determine which parallax layer a stamp belongs on.
     * This would be called by the LLM; simplified version here.
     */
    determineLayer(stampType) {
        const layerMap = {
            // Far layers (0-2)
            "Sky Stamp": 0,
            "Moon Stamp": 0,
            "Cloud Stamp": 0,
            "Mountain Stamp": 1,
            "Hill Stamp": 2,
            "City Skyline Stamp": 1,
            
            // Mid layers (3-4)
            "Tree Distant Stamp": 3,
            "Tree Stamp": 4,
            "Building Stamp": 3,
            "Bush Stamp": 4,
            
            // Gameplay layer (5) - stamps here have collision
            "Ground Stamp": 5,
            "Platform Stamp": 5,
            "Character Stamp": 5,
            
            // Foreground (6)
            "Grass Foreground Stamp": 6,
            "Flower Stamp": 6,
            "Fence Stamp": 6,
        };
        return layerMap[stampType] || 5;  // default to gameplay layer
    }
    
    /** Render all layers */
    render() {
        const cameraX = this.camera.x;
        const viewWidth = this.canvas.width;
        const viewHeight = this.canvas.height;
        
        for (const layer of this.layers) {
            const depth = layer.config.depth;
            
            for (const stamp of layer.stamps) {
                // Calculate parallax offset
                const parallaxX = stamp.x - cameraX * depth;
                
                // Handle repeating backgrounds (for tiled elements)
                if (stamp.repeatX) {
                    const imgWidth = stamp.width;
                    // Calculate how many repetitions needed
                    const startRepeat = Math.floor((cameraX * depth) / imgWidth) - 1;
                    const endRepeat = startRepeat + Math.ceil(viewWidth / imgWidth) + 2;
                    
                    for (let r = startRepeat; r <= endRepeat; r++) {
                        const drawX = parallaxX + r * imgWidth;
                        this.drawStamp(stamp, drawX, stamp.y);
                    }
                } else {
                    // Non-repeating (like Ori's painted backdrops)
                    this.drawStamp(stamp, parallaxX, stamp.y);
                }
            }
        }
    }
    
    drawStamp(stamp, x, y) {
        // Apply atmospheric effects based on layer depth
        // Distant layers get: atmospheric perspective (blue tint), reduced contrast
        const layerIndex = this.layers.findIndex(l => l.stamps.includes(stamp));
        const depth = this.layers[layerIndex]?.config.depth || 0.5;
        
        this.ctx.save();
        
        // Atmospheric perspective: distant layers are bluer and lower contrast
        if (depth < 0.5) {
            const fogAmount = (0.5 - depth) * 0.4;
            this.ctx.globalAlpha = 1.0 - fogAmount * 0.3;
            // Note: full color tinting would require additional compositing
        }
        
        this.ctx.drawImage(stamp.image, x, y, stamp.width, stamp.height);
        this.ctx.restore();
    }
    
    /** Get collision layer index (gameplay layer) */
    getCollisionLayerIndex() {
        return 5;  // ground/platform layer
    }
    
    /** Get all stamps on collision layer */
    getCollisionStamps() {
        return this.layers[5]?.stamps || [];
    }
    
    /** Cleanup */
    destroy() {
        this.layers = [];
    }
}

// Simplified standalone parallax function for basic use:
function updateParallaxLayer(layerElement, cameraX, parallaxFactor) {
    const offset = -cameraX * parallaxFactor;
    layerElement.style.transform = `translateX(${offset}px)`;
}
```

#### 5. Diegetic Health System (JavaScript)

```javascript
/**
 * Diegetic Health Display System
 * Communicates player state through character appearance, not HUD.
 * Inspired by Journey's scarf [^400^], Dead Space's RIG [^391^], and
 * general diegetic UI principles [^310^][^315^].
 */

class DiegeticHealthSystem {
    constructor(characterSprite) {
        this.sprite = characterSprite;
        this.maxHealth = 3;
        this.currentHealth = 3;
        
        // Visual state
        this.glowIntensity = 1.0;
        this.posture = "normal";  // normal, hunched, injured
        this.tint = { r: 255, g: 255, b: 255 };
    }
    
    takeDamage(amount) {
        this.currentHealth = Math.max(0, this.currentHealth - amount);
        this.updateVisuals();
        this.playHurtAnimation();
    }
    
    heal(amount) {
        this.currentHealth = Math.min(this.maxHealth, this.currentHealth + amount);
        this.updateVisuals();
    }
    
    updateVisuals() {
        const healthPercent = this.currentHealth / this.maxHealth;
        
        // Health-based glow (bright when healthy, dim when hurt)
        this.glowIntensity = 0.3 + healthPercent * 0.7;
        
        // Color shift (healthy = white/bright, hurt = red/dark)
        if (healthPercent > 0.6) {
            this.tint = { r: 255, g: 255, b: 255 };  // Full color
            this.posture = "normal";
        } else if (healthPercent > 0.3) {
            this.tint = { r: 255, g: 220, b: 180 };  // Slight orange
            this.posture = "concerned";
        } else {
            this.tint = { r: 255, g: 150, b: 150 };  // Red tint
            this.posture = "injured";
        }
        
        // Apply to sprite
        this.sprite.setTint(this.tint.r, this.tint.g, this.tint.b);
        this.sprite.setGlow(this.glowIntensity);
        
        // If available, switch to posture-specific animation
        if (this.sprite.animations[this.posture]) {
            this.sprite.playAnimation(this.posture);
        }
    }
    
    playHurtAnimation() {
        // Flash red
        this.sprite.flashColor(255, 0, 0, 200);
        // Knockback visual
        this.sprite.shake(5, 200);
        // Brief invincibility blink
        this.sprite.startBlinking(100, 1500);
    }
    
    /** Render health indicators that exist in the game world */
    renderWorldIndicators(ctx) {
        // Companion follows player and shows health through behavior
        // Health orb particles when at full health
        if (this.currentHealth === this.maxHealth) {
            this.renderFullHealthAura(ctx);
        }
    }
    
    renderFullHealthAura(ctx) {
        // Subtle glow particles around character
        const time = Date.now() / 1000;
        for (let i = 0; i < 3; i++) {
            const angle = time + (i * Math.PI * 2 / 3);
            const x = this.sprite.x + Math.cos(angle) * 20;
            const y = this.sprite.y + Math.sin(angle) * 15 - 10;
            const alpha = 0.3 + Math.sin(time * 3 + i) * 0.2;
            
            ctx.fillStyle = `rgba(255, 255, 200, ${alpha})`;
            ctx.beginPath();
            ctx.arc(x, y, 3, 0, Math.PI * 2);
            ctx.fill();
        }
    }
    
    /** Get health as diegetic string for debugging */
    getStateDescription() {
        const descriptions = {
            3: "Full of energy!",
            2: "A bit tired...",
            1: "Barely hanging on!",
            0: "Needs help!",
        };
        return descriptions[this.currentHealth];
    }
}
```

#### 6. Auto Normal Map Generator (Python - for stamp preprocessing)

```python
"""
Auto Normal Map Generator for 2D Sprite Stamps
Generates normal maps from sprite alpha and color data.
Similar to SpriteIlluminator's algorithmic mode [^375^].
Run once when a new stamp is uploaded to the platform.
"""

from PIL import Image, ImageFilter
import numpy as np


def generate_normal_map(sprite_path, output_path, strength=1.0):
    """
    Generate a normal map from a sprite image.
    Uses alpha channel as height map (solid = high, transparent = low).
    Uses color differences for surface detail.
    """
    img = Image.open(sprite_path).convert('RGBA')
    width, height = img.size
    
    # Extract alpha channel as height map
    alpha = np.array(img)[:, :, 3].astype(float) / 255.0
    
    # Use brightness as secondary height cue
    rgb = np.array(img)[:, :, :3].astype(float)
    brightness = np.mean(rgb, axis=2) / 255.0
    
    # Combined height map: alpha is primary, brightness adds detail
    height_map = alpha * 0.7 + brightness * 0.3
    
    # Calculate gradients (surface normals)
    # Sobel operators for edge detection -> normal direction
    sobel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
    sobel_y = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]])
    
    from scipy.signal import convolve2d
    grad_x = convolve2d(height_map, sobel_x, mode='same', boundary='fill')
    grad_y = convolve2d(height_map, sobel_y, mode='same', boundary='fill')
    
    # Normalize gradients
    grad_x *= strength
    grad_y *= strength
    
    # Create normal map
    # Red = X (left-right), Green = Y (up-down), Blue = Z (out of screen)
    normal = np.zeros((height, width, 3), dtype=np.float32)
    normal[:, :, 0] = np.clip(grad_x * 0.5 + 0.5, 0, 1)  # X -> Red
    normal[:, :, 1] = np.clip(-grad_y * 0.5 + 0.5, 0, 1)  # Y -> Green (flipped)
    normal[:, :, 2] = np.clip(1.0 - np.sqrt(grad_x**2 + grad_y**2), 0.3, 1.0)  # Z -> Blue
    
    # Zero out normals where alpha is 0 (fully transparent)
    normal[alpha < 0.05] = [0.5, 0.5, 1.0]  # flat normal for transparent
    
    # Convert to image
    normal_img = Image.fromarray((normal * 255).astype(np.uint8))
    normal_img.save(output_path)
    
    return normal_img


def generate_height_from_bevel(sprite_path, output_path):
    """
    Alternative: Generate height map by inflating the sprite shape.
    Creates a beveled edge effect like SpriteIlluminator's algorithmic mode.
    """
    img = Image.open(sprite_path).convert('RGBA')
    alpha = np.array(img)[:, :, 3]
    
    # Distance transform: how far is each pixel from transparent edge
    from scipy.ndimage import distance_transform_edt
    height = distance_transform_edt(alpha > 128)
    
    # Normalize
    height = height / height.max() if height.max() > 0 else height
    
    # Convert to grayscale height map
    height_img = Image.fromarray((height * 255).astype(np.uint8))
    height_img.save(output_path)
    
    return height_img


# Example:
# generate_normal_map("tree_stamp.png", "tree_stamp_normal.png")
# generate_height_from_bevel("tree_stamp.png", "tree_stamp_height.png")
```

---

### The "Atmosphere Stamp" Taxonomy

The following taxonomy defines the complete set of atmosphere stamps available to children. Each stamp's atmospheric DNA is pre-defined and automatically activated by the LLM.

#### Category 1: Time-of-Day Stamps (5)

| Stamp | Lighting Effect | Audio Effect | Particle Effect |
|-------|----------------|--------------|-----------------|
| **Dawn Stamp** | Warm orange-pink directional, low ambient | Bird chorus waking up, gentle wind | Dew drops, pollen |
| **Day Stamp** | Bright white directional, blue sky ambient | Full bird song, active wind | Butterflies, dust motes |
| **Sunset Stamp** | Golden-orange directional, warm ambient | Cricket start, evening birds | Fireflies begin, pollen |
| **Night Stamp** | Dim blue moonlight, dark ambient | Crickets, owl hoots, wolf howls | Fireflies, stars |
| **Midnight Stamp** | Very dim, star-based ambient | Sparse sounds, wind only | Star particles, mist |

#### Category 2: Weather Stamps (5)

| Stamp | Visual Effect | Audio Effect | Performance Note |
|-------|---------------|--------------|-----------------|
| **Clear Stamp** | No changes, bright colors | Baseline ambient | Zero performance impact |
| **Rain Stamp** | Rain particles, wet sheen, darker | Rain bed + thunder | Max 500 particles, LOD |
| **Snow Stamp** | Snow particles, white overlay | Muffled sounds, wind | Max 300 particles |
| **Fog Stamp** | Volumetric fog, muted colors | Muffled distant sounds | Shader-based, cheap |
| **Storm Stamp** | Rain + lightning flashes + wind | Thunder + heavy rain | Lightning = full-screen flash, brief |

#### Category 3: Lighting Stamps (6)

| Stamp | Light Type | Color | Radius | Special Effect |
|-------|-----------|-------|--------|----------------|
| **Sun Stamp** | Directional | Warm white | Infinite | God-ray decals, lens flare |
| **Moon Stamp** | Directional | Cool blue | Infinite | Star visibility increase |
| **Torch Stamp** | Point | Orange | 5 units | Flicker animation, smoke particles |
| **Lamp Stamp** | Point | Warm yellow | 4 units | Moth attractor particles |
| **Crystal Stamp** | Point | Cyan/blue | 4 units | Sparkle particles, slight pulse |
| **Campfire Stamp** | Point | Deep orange | 6 units | Fire particles, smoke, warmth glow |

#### Category 4: Ambience Stamps (5)

| Stamp | Base Audio Layer | Modifier | Mood |
|-------|-----------------|----------|------|
| **Forest Stamp** | Wind in trees | Bird layers | Peaceful |
| **Cave Stamp** | Water drips | Echo reverb | Mysterious |
| **City Stamp** | Background hum | Traffic layers | Busy |
| **Ocean Stamp** | Waves | Seagull calls | Calm |
| **Haunted Stamp** | Low drone | Random creaks | Scary (age-gated) |

#### Category 5: Style/Era Stamps (4)

| Stamp | Visual Filter | Audio Filter | Animation Style |
|-------|--------------|--------------|-----------------|
| **8-Bit Stamp** | 4-color palette, pixel edges, 30fps | Chiptune synth | Snappy, few frames |
| **16-Bit Stamp** | 16-color palette, soft gradients, 60fps | FM synthesis | Smooth, more frames |
| **Storybook Stamp** | Watercolor filter, paper texture, vignette | Acoustic instruments | Gentle easing |
| **Cinematic Stamp** | Letterboxing, desaturated, film grain | Orchestral | Dramatic, slow-mo |

#### Category 6: Mood Stamps (4)

| Stamp | Color Grading | Audio Modifier | Particle Additions |
|-------|--------------|----------------|--------------------|
| **Happy Stamp** | Warm, saturated (+20%) | Pitch up +5% | Confetti, sparkles |
| **Spooky Stamp** | Cool, desaturated (-30%) | Add reverb + echo | Fog wisps, shadow |
| **Epic Stamp** | High contrast, warm highlights | Orchestra swells | Light rays, embers |
| **Calm Stamp** | Soft, pastel tones | Volume -20%, slow tempo | Slow particles, dust |

---

### Edge Cases & Mitigations

#### 1. Sensory Overload

**Risk:** Too many particle effects, audio layers, or lighting changes overwhelm young children, especially those with sensory sensitivities [^377^][^382^].

**Mitigation:**
- **Particle budget system:** Hard cap of 500 active particles per scene (child-safe mode: 200)
- **Atmosphere intensity slider:** Global setting (1-5) that scales all effects proportionally
- **Simplified mode for ages 5-6:** Reduced particles, simpler audio layers, brighter base lighting
- **Auto-calm feature:** If the system detects rapid successive stamp placement (>5 in 3 seconds), it gradually fades effects rather than stacking them immediately
- **Pause without breaking flow:** Pressing a "calm" button instantly reduces all effects to minimum for 30 seconds

#### 2. Dark Scenes Too Scary for Children

**Risk:** Night stamps, cave stamps, or haunted forest stamps create genuinely frightening environments for young children [^387^].

**Mitigation:**
- **Minimum ambient floor:** No scene can be darker than 20% ambient intensity (child-safe: 35%)
- **Friendly darkness:** Night scenes always include friendly elements (fireflies, moon glow, sleeping animal NPCs)
- **No jump scares:** Haunted/spooky stamps are age-gated (not available under age 8)
- **Companion reassurance:** Player character maintains visible glow in dark scenes; companion character reacts fearlessly to show it's safe
- **One-tap brightness:** Child can place a "Sun Stamp" at any time to override darkness

#### 3. Performance with Many Particles

**Risk:** Complex particle systems (rain + fog + fire + magic) cause frame rate drops on low-end devices.

**Mitigation:**
- **LOD system:** Particles reduce in count based on device performance (auto-detected)
- **Distance culling:** Particles only spawn within 1.5x screen bounds
- **Priority system:** Essential particles (player torch) always render; ambient particles (dust motes) are first to reduce
- **Shader fog vs. particle fog:** Use shader-based fog (cheap) instead of particle fog (expensive) when FPS drops below 30
- **Mobile mode:** Cap at 100 particles, disable real-time shadows, use baked lighting decals

#### 4. Conflicting Atmosphere Stamps

**Risk:** Child places contradictory stamps ("Rain Stamp" + "Desert Stamp", "Night Stamp" + "Sun Stamp").

**Mitigation:**
- **Semantic conflict resolution:** LLM defines stamp priority hierarchy. Time-of-day stamps override each other (last placed wins). Weather stamps can combine (rain + fog = misty rain) but not contradict (rain + clear = rain wins, clear is ignored)
- **Visual blending:** Conflicting lighting colors blend rather than overriding (sun + moon = twilight colors)
- **Child-friendly feedback:** Conflicts are resolved silently; no error messages, no warnings. The system just picks the most recent stamp of each category.

#### 5. Audio Clipping with Many Layers

**Risk:** Multiple ambient audio beds + foreground sounds + music exceed 0dB and clip.

**Mitigation:**
- **Auto-mixing:** Each audio layer has a defined maximum gain. The mixer automatically scales all layers so the sum never exceeds -3dB
- **Ducking:** When foreground sounds play, ambient bed reduces by 30% (sidechain compression)
- **Max 3 simultaneous foreground sounds:** Additional sounds are queued, not layered
- **Master limiter:** Hard limiter on the master bus prevents any clipping regardless of layer count

#### 6. Child Accidentally Places Atmosphere Stamp in Wrong Location

**Risk:** Child places a "Night Stamp" in the middle of the gameplay area, making that spot dark while the rest is day.

**Mitigation:**
- **Global atmosphere stamps:** Time-of-day, weather, and style stamps are "global stamps" that affect the entire scene regardless of placement position. They snap to the UI bar at the top of the screen, not the gameplay canvas
- **Local atmosphere stamps:** Only light source stamps (torch, lamp) are placed on the canvas at specific positions
- **Undo support:** Every stamp placement can be undone with a single tap (unlimited undo)

#### 7. Color Accessibility

**Risk:** Children with color vision deficiency cannot distinguish atmosphere changes that rely solely on color shifts.

**Mitigation:**
- **Multi-modal feedback:** Every atmosphere change affects lighting intensity (visible as brightness change), particle presence (visible movement), and audio (audible change) - never color alone
- **High contrast mode:** Optional setting that maximizes value differences regardless of hue
- **Pattern overlays:** Subtle texture patterns (stripes, dots) on differently-atmosphered regions as secondary visual cue

---

### Sources

1. [^286^] GDC 2015: Animating Ori and the Blind Forest - Moon Studios technique breakdown. https://zyzyz.github.io/en/2018/01/GDC2015-Animating-Ori/

2. [^284^] REPLACED is a Visual Masterclass in Pixel Art - AllKeyShop analysis of Sad Cat Studios' approach. https://www.allkeyshop.com/blog/replaced-visual-masterclass-pixel-art-news-l/

3. [^288^] Replaced Is a Beautiful, Brilliant 2.5D Cyberpunk Thriller - IGN hands-on preview. https://www.ign.com/articles/replaced-is-a-beautiful-brilliant-25d-cyberpunk-thriller-gamescom-2025

4. [^289^] Replaced - How Sad Cat Studios Crafted 2.5D Combat - Official Xbox blog post. https://news.xbox.com/en-us/2026/04/14/replaced-combat/

5. [^215^] Hop between 8 and 16-bit eras in The Messenger - Rock Paper Shotgun. https://www.rockpapershotgun.com/the-messenger-era-swapping-platformer

6. [^285^] Review: The Messenger - Easy Allies review with era-switching details. https://easyallies.com/review/the-messenger

7. [^213^] The Messenger (2018 video game) - Wikipedia with comprehensive technical details. https://en.wikipedia.org/wiki/The_Messenger_(2018_video_game)

8. [^303^] Parallax Scrolling in pixel-perfect 2D Unity games - Implementation tutorial. https://pavcreations.com/parallax-scrolling-in-pixel-perfect-2d-unity-games/

9. [^304^] Parallax Scrolling: A Simple, Effective Way to Add Depth - Tuts+ tutorial. https://code.tutsplus.com/parallax-scrolling-a-simple-effective-way-to-add-depth-to-a-2d-game--cms-21510t

10. [^307^] Parallax scrolling - Wikipedia technical overview. https://en.wikipedia.org/wiki/Parallax_scrolling

11. [^302^] Creating Compelling Environmental Audio - Roblox developer tutorial. https://devforum.roblox.com/t/ambientsorcerys-tutorial-1-creating-compelling-environmental-audio/3507022

12. [^309^] Choosing Audio Middleware for UE5 Games (2026) - FMOD/Wwise/MetaSounds comparison. https://www.strayspark.studio/blog/wwise-fmod-metasounds-audio-middleware-comparison

13. [^310^] Types of UI in Gaming: Diegetic, Non-Diegetic, Spatial and Meta - Medium article. https://medium.com/@lorenzoardeni/types-of-ui-in-gaming-diegetic-non-diegetic-spatial-and-meta-5024ce6362d0

14. [^314^] Diegetic vs Non-Diegetic UI: The 4-Type Framework - Nasty Rodent design blog. https://nastyrodent.com/diegetic-and-non-diegetic-ui/

15. [^315^] Game UI design - Corporation Pop design agency. https://corporationpop.co.uk/thoughts/game-ui-design

16. [^316^] Cool ways to display information without an HUD - Unity forums discussion. https://discussions.unity.com/t/cool-ways-to-display-information-such-as-mana-and-health-to-the-player-without-an-hud/557498

17. [^317^] What are diegetic, non-diegetic, spatial and meta UIs - GameDev StackExchange. https://gamedev.stackexchange.com/questions/99246/what-are-diegetic-non-diegetic-spatial-and-meta-user-interfaces

18. [^318^] Design Bits Analysis: Limbo's Level Design - Game Developer. https://www.gamedeveloper.com/design/design-bits-analysis-limbo-s-level-design---mostly-perfect

19. [^349^] Inside (game UX analysis) - Medium UX review. https://medium.com/vgux/inside-52d84e8de7c6

20. [^350^] Inside from the creators of Limbo - Indie Game Reviewer. https://indiegamereviewer.com/review-inside/

21. [^379^] Success Story of PlayDead Studio INSIDE - Medium technical analysis. https://medium.com/@7019727855a/success-story-of-playdead-studio-inside-what-we-can-learn-technical-challenges-and-game-design-620db0ab11c3

22. [^403^] The Lighting of INSIDE - Official Playdead blog by Marek Bogdan. https://blog.playdead.com/articles/the_lighting_of_inside/lighting_of_inside.html

23. [^353^] Skeletal Animation Tools discussion - RPG Maker forums. https://forums.rpgmakerweb.com/threads/skeletal-animation-tools-and-why-they-are-a-good-option.75129/

24. [^354^] Vanillaware art/animation technical discussion - Reddit r/gamedev. https://www.reddit.com/r/gamedev/comments/1jios4/vanillaware_artanimation_appreciation_technical/

25. [^410^] Vanillaware - Wikipedia with tebineri process description. https://en.wikipedia.org/wiki/Vanillaware

26. [^370^] Dynamic Sprite Lighting with Normals - Pico-8 forums. https://www.lexaloffle.com/bbs/?tid=147093

27. [^371^] Lighting with 2D normal maps - Godot tutorial by GDQuest. https://gdquest.com/tutorial/godot/2d/lighting-with-normal-maps/

28. [^375^] SpriteIlluminator - Normal map editor for 2D dynamic lighting. https://www.codeandweb.com/spriteilluminator

29. [^391^] The diegetic UI of Dead Space - IABDI design blog. https://www.iabdi.com/designblog/2022/3/18/h04cs7ub04vkmyfcs3t2krmfey5mc3

30. [^398^] Designing Effective Diegetic UI: Lessons from Dead Space - Medium. https://medium.com/@jaiwanthshan/designing-effective-diegetic-ui-lessons-learned-from-dead-spaces-success-and-the-callisto-dbf803639dd6

31. [^400^] Journey Review - Last Save Point (scarf health system). https://lastsavepoint.wordpress.com/2012/03/26/journey-review/

32. [^374^] CrawLLM: An LLM-Based Pipeline for Game Asset Generation - Academic research. https://antoniosliapis.com/research/research_pcg.php

33. [^384^] Procedural Content Generation in Games: A Survey with LLM Integration - arXiv paper. https://arxiv.org/html/2410.15644v1

34. [^377^] Preventing sensory overload on the playground - GameTime. https://www.gametime.com/news/how-to-prevent-sensory-overload-on-the-playground

35. [^387^] 8 fun night games for kids - National Geographic Kids. https://www.natgeokids.com/uk/parents/why-kids-should-play-night-games/

36. [^402^] Age-Appropriate Design - Digital Thriving Playbook. https://digitalthrivingplaybook.org/big-idea/age-appropriate-design/

37. [^308^] Setting Up Lighting for a Cozy Forest Scene in Unreal Engine 5.1 - 80.lv. https://80.lv/articles/setting-up-lighting-for-a-cozy-forest-scene-in-unreal-engine-5-1

38. [^345^] Create an environmental Particle System - Unity Learn. https://learn.unity.com/tutorial/create-an-environmental-particle-system

39. [^346^] Beginning Game Development: Volumetric Effects - Medium. https://medium.com/@lemapp09/beginning-game-development-volumetric-effects-8741d6e3ffa2

40. [^394^] Building a Modular Synth With Web Audio API - Medium. https://medium.com/geekculture/building-a-modular-synth-with-web-audio-api-and-javascript-d38ccdeca9ea

41. [^404^] Rain & Wind procedural audio experiments - Binaura research. https://www.binaura.net/stc/fp/?entry=entry120124-173444

42. [^414^] Generating Rain With Pure Synthesis - Audiokinetic (Wwise). https://www.audiokinetic.com/en/community/blog/generating-rain-with-pure-synthesis

43. [^405^] Multiple lights - LearnOpenGL tutorial. https://learnopengl.com/Lighting/Multiple-lights

44. [^406^] GLSL: Optimize lighting fragment shader for 30+ lights - GameDev StackExchange. https://gamedev.stackexchange.com/questions/184949/glsl-how-can-i-optimize-this-lighting-fragment-shader-basic-2d-game-30-lig

45. [^409^] Lighting in WebGL - MDN Web Docs. https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Tutorial/Lighting_in_WebGL

---

*Document compiled from 30+ independent web searches across studio postmortems, GDC talks, academic papers, engine documentation, and child development research. All citations verified and linked.*
