# Chapter 9: Accessibility & Assist Features

> **"Every child can play. Every child can create. No exceptions."**
>
> This chapter documents 25+ features that ensure KidGameMaker is universally accessible to children of all abilities. Accessibility is not a stretch goal or a Phase-D afterthought — it is a foundational design pillar that permeates every system. Every feature in this chapter draws from industry-leading accessibility innovations, adapted for a stamp-based creation tool where a 5-year-old is the primary user.

---

## 9.1 Visual Accessibility

### Super See Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Super See Mode |
| **Source Game** | The Last of Us Part II (Naughty Dog, 2020) — High Contrast Display |
| **Description** | Transforms any level into a high-contrast mode where interactive elements are clearly color-coded: platforms glow bright blue, enemies are outlined in red, collectibles pulse gold, and hazards flash orange. Background layers desaturate to soft gray, eliminating visual clutter. |
| **Kid UX** | A 5-year-old opens the Magic Settings menu and taps the rainbow glasses icon. The colorful background instantly fades to soft gray while all important game elements pop with bright, clear colors and thick outlines. "Everything is so easy to see now!" The child can still play normally — only the visuals have changed. |
| **LLM Automation** | Backend: (1) Stamp category classifier tags every element at level-load time into semantic categories (platform, enemy, collectible, hazard, NPC, background); (2) Color palette assignment per category uses accessibility-safe colors meeting WCAG AAA contrast ratios; (3) Outline renderer adds 3px stroke to all interactive elements; (4) Background shader desaturates and dims non-interactive layers to 15% saturation; (5) Glow post-processing effect on collectibles and hazards at 60fps; (6) Persistent per-child preference saved to cloud profile. |
| **JSON Contract Extension** | `{"super_see_mode": {"enabled": "boolean", "category_colors": {"platform": "#0066FF", "enemy": "#FF0000", "collectible": "#FFD700", "hazard": "#FF8800", "npc": "#00FF00"}, "outline_width_px": "3", "background_desaturation": "0.85", "glow_intensity": "float", "colorblind_preset": "protanopia|deuteranopia|tritanopia|none"}}` |

**Why It Matters:** Super See Mode is the single most impactful visual accessibility feature in KidGameMaker. The Last of Us Part II set the industry standard with over 60 accessibility options; KidGameMaker adapts its crown jewel for children. A child with low vision can suddenly see platforms they would otherwise miss. A child with ADHD can focus on gameplay-relevant elements without distracting background detail. The WCAG AAA contrast ratios ensure compliance with the highest international accessibility standards.

---

### Colorblind Palette Adaptation

| Field | Details |
|-------|---------|
| **Feature Name** | Colorblind Palette Adaptation |
| **Source Game** | The Last of Us Part II (2020) — colorblind presets for Protanopia, Deuteranopia, Tritanopia |
| **Description** | Three distinct color-remapping profiles that shift the entire game's palette to compensate for the three major types of color vision deficiency. Each profile is independently selectable and previewed in real-time. |
| **Kid UX** | Parent opens the accessibility menu and selects "See Colors Better." Three friendly animal icons appear: Bear (for red-green help), Fox (for green-red help), and Owl (for blue-yellow help). Tapping each instantly previews the color shift on a sample scene. The child picks the one that looks clearest to them. |
| **LLM Automation** | Backend: (1) Daltonization algorithm remaps RGB values per colorblind type using LMS color-space transformation; (2) Pattern and texture differentiation added where color alone conveys information (striped platforms, dotted enemies); (3) Shape cues supplement color-coded elements; (4) Universal design verification ensures every color-coded mechanic has a non-color visual indicator. |
| **JSON Contract Extension** | `{"colorblind_mode": {"type": "protanopia|deuteranopia|tritanopia|none", "daltonization_strength": "float(0-1)", "pattern_supplement": "boolean", "universal_design_check": "boolean"}}` |

---

### Sound-to-Light Translator

| Field | Details |
|-------|---------|
| **Feature Name** | Sound-to-Light Translator |
| **Source Game** | The Last of Us Part II — awareness indicators for deaf/hard-of-hearing players |
| **Description** | All audio events — enemy footsteps, collectible chimes, hazard alarms, approaching projectile whooshes — are translated into visual indicators: directional pulses emanate from the sound source, on-screen ripples indicate distance, and color flashes communicate urgency. |
| **Kid UX** | An enemy approaches from the left side of the screen. A gentle blue ripple emanates from the left edge, growing larger as the enemy gets closer. A collectible coin sits on a high platform — it pulses with a golden glow even when off-screen, with an arrow pointing toward it. The child sees everything they need to, even in silent mode. |
| **LLM Automation** | Backend: (1) Audio event classification tags all sounds with type (footstep, collect, hazard, projectile) and spatial direction; (2) Visual indicator selector maps sound categories to visual patterns — direction ripple for movement, glow pulse for collectibles, orange flash for hazards; (3) Indicator intensity scales with audio volume and proximity; (4) Off-screen edge indicators show arrows pointing toward important sounds outside the viewport; (5) Character portrait in the corner reacts with facial expressions (surprised = danger, happy = collectible) for emotional context. |
| **JSON Contract Extension** | `{"sound_to_light": {"indicator_types": [{"sound_category": "string", "visual_pattern": "ripple|glow|flash|arrow", "color": "string", "directional": "boolean"}], "edge_indicators": "boolean", "character_portrait_reactions": "boolean", "intensity_scale": "float(0-1)"}}` |

---

### Screen Edge Directional Indicators

| Field | Details |
|-------|---------|
| **Feature Name** | Screen Edge Directional Indicators |
| **Source Game** | Fortnite (visualize sound effects), TLOU2 (awareness indicators) |
| **Description** | Thin colored bars appear at the screen edges to indicate the direction of off-screen sounds and important events. The bar's height represents proximity, and its color represents event type. |
| **Kid UX** | The child hears (or sees via Sound-to-Light) a treasure chest somewhere to the right, off-screen. A small golden bar rises on the right edge of the screen, pulsing gently. As the child moves closer, the bar grows taller. When the chest enters the screen, the bar fades away. |
| **LLM Automation** | Backend: (1) Spatial audio analysis determines direction and distance to sound sources; (2) Edge bar renderer places indicators on appropriate screen borders; (3) Height interpolation based on proximity with exponential falloff; (4) Color mapping tied to KidGameMaker's semantic color system; (5) Fade-out when source enters viewport. |
| **JSON Contract Extension** | `{"edge_indicators": {"enabled": "boolean", "bar_max_height_px": "40", "proximity_sensitivity": "float", "fade_on_viewport_enter": "boolean", "color_map": {"collectible": "#FFD700", "enemy": "#FF0000", "hazard": "#FF8800"}}}` |

---

### Sensitivity Safe Zone

| Field | Details |
|-------|---------|
| **Feature Name** | Sensitivity Safe Zone |
| **Source Game** | Xbox Adaptive Controller philosophy, TLOU2 motion sickness options, sensory-friendly game design |
| **Description** | A comprehensive sensory control panel that allows parents and children to reduce or eliminate screen shake, flashing effects, particle density, motion blur, camera dolly zoom, and loud sounds. Includes a persistent center-dot option for spatial grounding. |
| **Kid UX** | Parent opens "Comfort Settings" and sees simple picture toggles: a shaking phone icon for screen shake, a lightning bolt for flashing effects, confetti for particles, a speaker for loud sounds. Each toggle has three positions: Full (normal), Gentle (reduced), and Off. Changes apply instantly — the child never sees an overwhelming effect. |
| **LLM Automation** | Backend: (1) All visual effects tagged with intensity categories at asset-import time (shake, flash, motion, particles, dolly_zoom); (2) Effect renderer reads comfort settings and applies attenuation multipliers; (3) Flashing effects converted to gentle fade when set to reduced; (4) Particle culling scales max particle count by setting level; (5) Audio limiter hard-caps at 70dB for gentle setting; (6) Center dot renderer always-on when enabled; (7) Per-child comfort profile auto-loaded on login. |
| **JSON Contract Extension** | `{"sensitivity_safe": {"screen_shake": "full|reduced|off", "flashing_effects": "full|dim|off", "particle_density": "full|reduced|minimal", "motion_blur": "full|reduced|off", "sound_volume_cap_db": "70|80|90", "center_dot": "boolean", "dolly_zoom": "on|off"}}` |

---

### Font Size & Dyslexia-Friendly Reader

| Field | Details |
|-------|---------|
| **Feature Name** | Font Size & Dyslexia-Friendly Reader |
| **Source Game** | Industry best practice — OpenDyslexic font research |
| **Description** | All in-game text can be scaled to 150% and 200% sizes. A dyslexia-friendly font mode switches all UI text to a weighted typeface designed to reduce character rotation confusion (b/d/p/q distinction). Word-spacing increases and line-height expands for easier reading. |
| **Kid UX** | The child taps the "Bigger Words" button in settings. All text in menus, dialogue boxes, and story blocks grows larger. If dyslexia-friendly mode is on, the letters become slightly heavier at the bottom, making them easier to distinguish. Dialogue boxes widen to accommodate longer lines with more breathing room. |
| **LLM Automation** | Backend: (1) Dynamic font scaling system reflows all UI containers at 1.5x and 2.0x sizes; (2) OpenDyslexic-weighted font family loaded on toggle; (3) Word-spacing and line-height CSS variables adjusted; (4) Container bounds recalculated to prevent text overflow; (5) Combined with Read-to-Me Everything for multimodal text support. |
| **JSON Contract Extension** | `{"font_accessibility": {"scale_factor": "1.0|1.5|2.0", "dyslexia_font": "boolean", "word_spacing_px": "int", "line_height_multiplier": "float"}}` |

---

## 9.2 Motor Accessibility

### One-Tap Wonder Mode

| Field | Details |
|-------|---------|
| **Feature Name** | One-Tap Wonder Mode |
| **Source Game** | Xbox Adaptive Controller support paradigm, one-button games design |
| **Description** | The entire platformer controlled with a single input — anywhere on screen. The character auto-runs forward; the child only decides WHEN to jump by tapping anywhere. The AI handles all movement direction, obstacle avoidance, and timing automatically. |
| **Kid UX** | The child taps anywhere on the screen and their character jumps over the next obstacle. The character runs forward automatically and even slows down before tricky jumps. A gentle highlight appears under the character when a jump is approaching, giving a subtle timing cue. If the child doesn't tap, the character stops at edges rather than falling. |
| **LLM Automation** | Backend: (1) Auto-run system moves character forward at optimal speed; (2) Jump cue predictor analyzes upcoming terrain and provides visual highlight 0.5s before recommended jump time; (3) Auto-pilot steering guides character toward safe paths when multiple routes exist; (4) Jump timing auto-correction within a 100ms forgiveness window; (5) Edge detection ensures character stops before cliffs if no tap received; (6) Graduated mode can add a second tap region for "high jump" as the child builds skill. |
| **JSON Contract Extension** | `{"one_tap_mode": {"input_type": "single_tap|adaptive_switch|eye_gaze", "auto_run_speed": "float", "jump_cue_highlight": "boolean", "auto_correct_window_ms": "100", "edge_stop": "boolean", "graduated_second_tap": "boolean"}}` |

---

### Auto-Pilot Companion

| Field | Details |
|-------|---------|
| **Feature Name** | Auto-Pilot Companion |
| **Source Game** | Celeste Assist Mode (infinite dashes, slowdown), TLOU2 traversal assistance |
| **Description** | A toggleable companion creature — shaped as a firefly, robot, or butterfly — that assists with specific actions the child finds challenging. The companion can catch the player if they fall, suggest jump timing through brightness pulses, provide soft auto-aim for projectiles, and even demonstrate difficult sections as a ghost replay. |
| **Kid UX** | A cute glowing firefly follows the character. When a difficult jump approaches, the firefly glows brighter and pulses — the child knows to jump on the brightest pulse. If the child misses the jump, the firefly catches them and gently lifts them to the platform. "The firefly saved me!" The child can choose to let the firefly "show how it's done" and watch a demonstration anytime. |
| **LLM Automation** | Backend: (1) Multi-assist module system: catch_assist, aim_assist, timing_assist, demo_assist — each independently toggleable; (2) Catch trigger activates when fall trajectory intersects with a safe platform within catch radius; (3) Aim assist provides soft lock-on to nearest enemy with gradual acquisition (never snapping); (4) Timing assist encodes recommended jump moment in firefly pulse frequency; (5) Demo mode records optimal AI path and plays it as ghost demonstration with narration; (6) Assist intensity slider from "gentle hint" to "full help." |
| **JSON Contract Extension** | `{"auto_pilot": {"companion_type": "firefly|robot|butterfly", "active_assists": [{"assist_id": "catch|aim|timing|demo", "intensity": "float(0-1)"}], "catch_prediction": {"fall_detected": "boolean", "safe_platform_nearby": "boolean"}, "demo_mode": {"optimal_path": [{"x": "float", "y": "float"}], "playback_speed": "float"}}}` |

---

### Pause-and-Think Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Pause-and-Think Mode |
| **Source Game** | Cognitive accessibility best practices, TLOU2 slow motion while aiming |
| **Description** | Game time freezes automatically whenever the child stops providing input for a configurable duration (default 2 seconds). The freeze allows unlimited planning time. Time resumes smoothly when the child acts. Smart triggers can also auto-freeze when an enemy is spotted or a hazard is detected. |
| **Kid UX** | The child reaches a tricky platforming section and pauses to think. The screen gently softens with a subtle vignette, and a small "Thinking Time" badge appears. The character stays frozen mid-action. The child studies the layout, plans their moves, and presses jump — everything resumes smoothly. No pressure. Think as long as needed. |
| **LLM Automation** | Backend: (1) Input idle timer triggers pause at configurable threshold (default 2s, range 1-10s); (2) Smooth time dilation: gameplay slows to freeze over 0.3s for a gentle transition; (3) Visual feedback via soft vignette and optional "Thinking Time" badge; (4) Smart freeze triggers: enemy enters proximity, hazard detected, branching path available; (5) Resume on any input with 0.1s ease-in; (6) Parental override for freeze conditions and duration. |
| **JSON Contract Extension** | `{"pause_think": {"freeze_trigger": "idle_timer|enemy_proximity|hazard|branching_path", "idle_threshold_seconds": "float", "time_dilation_speed": "0.3", "smart_freeze_enabled": "boolean", "resume_ease_in_seconds": "0.1", "parental_override": "boolean"}}` |

---

### Jump Timing Highlight

| Field | Details |
|-------|---------|
| **Feature Name** | Jump Timing Highlight |
| **Source Game** | Rhythm game visual cue systems, platformer accessibility mods |
| **Description** | A predictive visual cue that appears at the edge of platforms, indicating the optimal moment to press the jump button. The cue takes the form of a pulsing ring or bouncing arrow that peaks at the ideal frame. |
| **Kid UX** | The child approaches a gap between platforms. A soft glowing ring appears at the platform edge, pulsing gently. The child learns to press jump when the ring is at its brightest and largest. After a few successful jumps, they start to feel the rhythm naturally and can turn the cue down or off. |
| **LLM Automation** | Backend: (1) Trajectory prediction calculates required jump velocity for each gap; (2) Timing cue renders as pulse animation peaking at optimal jump frame; (3) Cue intensity adjustable from subtle glow to prominent arrow; (4) Adaptive fading: cue reduces prominence automatically as the child demonstrates consistent success; (5) Disabled automatically when One-Tap Wonder Mode is active. |
| **JSON Contract Extension** | `{"jump_timing_highlight": {"visual_style": "pulse_ring|bounce_arrow|sparkle_line", "intensity": "subtle|medium|prominent", "adaptive_fade": "boolean", "peak_frame_offset": "int"}}` |

---

### Adaptive Controller & Switch Support

| Field | Details |
|-------|---------|
| **Feature Name** | Adaptive Controller & Switch Support |
| **Source Game** | Xbox Adaptive Controller (Microsoft), AbleNet switches |
| **Description** | Full compatibility with the Xbox Adaptive Controller and single-switch input devices. Large programmable buttons, switch inputs, and USB joystick alternatives are all supported with automatic input remapping. |
| **Kid UX** | A child uses a large red AbleNet switch connected to the tablet. Each press of the big red button makes the character jump. The auto-run system handles forward movement. The child can play entire levels with a single large button press, building confidence and having fun alongside friends. |
| **LLM Automation** | Backend: (1) Adaptive controller input API integration via MFi and Bluetooth; (2) Switch debouncing with 150ms cooldown to prevent accidental double-inputs; (3) One-switch scanning mode for menu navigation (auto-cycles through options, switch press to select); (4) Two-switch mode for binary navigation (switch A = next, switch B = select); (5) Auto-detection of connected adaptive hardware; (6) Input calibration wizard for sensitivity tuning. |
| **JSON Contract Extension** | `{"adaptive_controller": {"enabled": "boolean", "controller_type": "xbox_adaptive|ablenet|custom_switch", "switch_mode": "one_switch_scan|two_switch_binary", "debounce_ms": "150", "auto_detect": "boolean"}}` |

---

### Input Buffer & Forgiving Timing

| Field | Details |
|-------|---------|
| **Feature Name** | Input Buffer & Forgiving Timing |
| **Source Game** | Celeste (generous coyote time, input buffering), modern platformer design |
| **Description** | Platforming timing windows are deliberately generous: coyote time (jump can be pressed briefly after leaving a platform), input buffering (jump pressed before landing is queued), and extended invincibility frames after taking damage. These invisible assists make the game feel fair without appearing to lower the bar. |
| **Kid UX** | The child presses jump a split-second after running off a platform. In a strict game, they would fall. In KidGameMaker, the jump still executes — the platform gave them a little "credit." They don't know why it felt easier; they just know they made the jump and feel proud. |
| **LLM Automation** | Backend: (1) Coyote time window: 100ms after leaving platform edge where jump still registers; (2) Input buffer: 80ms pre-landing jump input is queued and executes on touchdown; (3) Post-damage invincibility: 2.0s with flashing visual feedback; (4) All windows adjustable per child's assist profile; (5) Ghost inputs (accidental double-taps) filtered with 50ms minimum press duration. |
| **JSON Contract Extension** | `{"input_forgiveness": {"coyote_time_ms": "100", "input_buffer_ms": "80", "post_damage_iframes_seconds": "2.0", "ghost_input_filter_ms": "50", "adaptive_window_scaling": "boolean"}}` |

---

## 9.3 Cognitive & Communication Accessibility

### Symbol Speak Communication (AAC)

| Field | Details |
|-------|---------|
| **Feature Name** | Symbol Speak Communication (AAC) |
| **Source Game** | AAC (Augmentative and Alternative Communication) best practices, symbol-based communication for non-verbal children |
| **Description** | All in-game communication — NPC dialogues, quest descriptions, tutorial text, menu labels — can be displayed as picture symbols alongside or instead of text. Children can also "reply" to NPCs using symbol selection. Based on PCS (Picture Communication Symbols) and Widget symbol libraries. |
| **Kid UX** | An NPC asks "Will you help me find my ball?" The dialog displays text AND picture symbols: [help] [find] [ball] [question mark]. The child can answer by tapping symbols: [yes] [help] or [no] [later]. Every game text element has a symbol overlay available. Symbol size is configurable from small beside-text to large replacing-text for pre-readers. |
| **LLM Automation** | Backend: (1) Text-to-symbol parser converts all game text to symbol sequences using an AAC symbol library of 5000+ symbols; (2) Symbol sentence builder arranges symbols left-to-right in grammatical order; (3) Three display modes: small beside text, medium overlapping, large replacing text; (4) Symbol response interface for NPC interactions with Yes/No/Help/Later/Fun/Hard options; (5) Custom symbol upload support for personalized vocabulary; (6) Symbol-to-speech: tapping symbols reads them aloud via TTS. |
| **JSON Contract Extension** | `{"symbol_speak": {"symbol_library": "pcs|widget|custom", "display_mode": "beside_text|replace_text", "symbol_size": "small|medium|large", "response_symbols": ["yes", "no", "help", "later", "fun", "hard"], "tts_on_tap": "boolean"}}` |

---

### Difficulty Rainbow Slider

| Field | Details |
|-------|---------|
| **Feature Name** | Difficulty Rainbow Slider |
| **Source Game** | Celeste Assist Mode (granular toggles), God of War difficulty presets |
| **Description** | A child-friendly difficulty selector that replaces intimidating text labels ("Easy/Normal/Hard") with five colorful animal characters, each representing a difficulty setting. Each animal shows what changes via simple icon previews. Children can mix-and-match individual assist options to create a custom experience. |
| **Kid UX** | The child opens settings and sees five adorable animals arranged on a rainbow arc: Snail (very gentle — infinite jumps, no damage), Bunny (gentle — extra health, slower enemies), Cat (medium — balanced experience), Fox (challenging — faster enemies, fewer pickups), and Tiger (super challenging — one-hit kills, speed runs). Tapping each animal shows simple icons of what changes: hearts for health, clocks for speed, wings for jump help. The child can pick Bunny AND turn on wing help for a fully custom experience. |
| **LLM Automation** | Backend: (1) Five base difficulty presets map to parameter bundles: enemy count, platform timing window, player health, hint frequency, enemy projectile speed; (2) Independent assist toggles (infinite jumps, slow motion, invincibility frames, auto-aim) can override any preset; (3) LLM generates kid-friendly descriptions for each setting change; (4) Adaptive recommendation engine suggests settings based on play history and death patterns; (5) Parental lock option on certain settings; (6) Achievement eligibility preserved across all settings — no penalty for playing on "easier" modes. |
| **JSON Contract Extension** | `{"rainbow_slider": {"selected_character": "snail|bunny|cat|fox|tiger", "active_assists": [{"assist_id": "string", "icon": "heart|clock|wing|star|shield", "enabled": "boolean"}], "adaptive_recommendation": "string", "parental_lock": "boolean", "achievement_eligibility": "boolean"}}` |

---

### Granular Assist Toggles

| Field | Details |
|-------|---------|
| **Feature Name** | Granular Assist Toggles |
| **Source Game** | Celeste Assist Mode (individual toggle system) |
| **Description** | Beyond the Rainbow Slider presets, every assist type can be toggled independently with fine-grained control. This empowers children with specific disabilities to enable exactly what they need and nothing more. |
| **Kid UX** | A 6-year-old with dyspraxia turns on "Extra Jump Time" and "No Knockback" but leaves everything else at default. A 7-year-old with anxiety turns on "Infinite Health" and "Slow Motion" for their first playthrough. Each child creates their own perfect experience. |
| **LLM Automation** | Backend: (1) 15+ independent assist parameters each with range sliders: game_speed (50%-100%), extra_midair_jumps (0-5), invincibility (boolean), auto_aim_strength (0-100%), platform_edge_extension (0-20px), enemy_projectile_speed (25%-100%), infinite_dashes (boolean), infinite_stamina (boolean), no_knockback (boolean), extra_health (1-10 hearts), hint_frequency (low/medium/high), checkpoint_density (normal/dense/very_dense), death_penalty (none/mild/full); (2) Preset combinations auto-saved per child profile; (3) Suggested presets based on common accessibility needs. |
| **JSON Contract Extension** | `{"granular_assists": {"game_speed_percent": "float(50-100)", "extra_midair_jumps": "int(0-5)", "invincibility": "boolean", "auto_aim_strength": "float(0-1)", "no_knockback": "boolean", "extra_hearts": "int(1-10)", "hint_frequency": "low|medium|high", "death_penalty": "none|mild|full"}}` |

---

### Auto-Aim for Projectiles

| Field | Details |
|-------|---------|
| **Feature Name** | Auto-Aim for Projectiles |
| **Source Game** | TLOU2 lock-on targeting, modern shooter accessibility |
| **Description** | When the player uses any projectile attack — fireballs, arrows, boomerangs, or thrown items — a soft lock-on system gently guides the projectile toward the nearest valid target. The assist never feels like cheating; it simply reduces the precision required for directional aiming. |
| **Kid UX** | The child presses the fireball button. Instead of flying straight (and probably missing), the fireball curves slightly toward the nearby enemy. The child still chooses the general direction and timing, but the game helps with precision. At higher assist levels, a subtle targeting reticle shows which enemy will be targeted. |
| **LLM Automation** | Backend: (1) Proximity-based target selection within a cone in the facing direction; (2) Projectile trajectory correction applied as a gentle curve (max 15 degrees deflection); (3) Target preview reticle shown at high assist levels; (4) Correction strength scales with assist setting: gentle (5 degrees), medium (10 degrees), strong (15 degrees); (5) Respects line-of-sight — won't curve through walls. |
| **JSON Contract Extension** | `{"auto_aim": {"enabled": "boolean", "max_deflection_degrees": "float", "target_cone_angle": "float", "show_reticle": "boolean", "respect_line_of_sight": "boolean"}}` |

---

### Story Simplification Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Story Simplification Mode |
| **Source Game** | Cognitive accessibility best practices, simplified language frameworks |
| **Description** | Reduces the complexity of all narrative text to a target reading level (ages 5-6). Long paragraphs become short sentences. Complex vocabulary is replaced with common words. Symbol Speak overlays become more prominent. This mode ensures that pre-readers and children with reading difficulties can fully understand the narrative. |
| **Kid UX** | A story block that normally reads: "The valiant protagonist must traverse the perilous chasm to retrieve the ancient artifact before the nefarious sorcerer claims it for his own!" simplifies to: "Jump across the big hole! Get the treasure before the bad guy!" The child laughs and understands exactly what to do. |
| **LLM Automation** | Backend: (1) LLM text simplification pipeline reduces vocabulary to Dolch sight words and age-appropriate alternatives; (2) Long sentences broken into short declarative statements; (3) Passive voice converted to active voice; (4) Symbol density increased in simplified mode; (5) TTS narration speed slightly reduced; (6) Simplification applied to all story blocks, NPC dialogue, and quest descriptions in real-time. |
| **JSON Contract Extension** | `{"story_simplification": {"target_reading_level": "int(5-12)", "vocabulary_set": "dolch_sight|age_appropriate", "max_sentence_length": "int", "symbol_density": "normal|high", "tts_speed": "float(0.5-1.5)"}}` |

---

## 9.4 Reading & Audio Accessibility

### Read-to-Me Everything

| Field | Details |
|-------|---------|
| **Feature Name** | Read-to-Me Everything |
| **Source Game** | TLOU2 text-to-speech system, ReadSpeaker TTS for gaming |
| **Description** | Every text element in the game — menus, dialogues, stories, level descriptions, settings labels, tutorial text — can be read aloud via high-quality text-to-speech. The child can tap any text to hear it, or enable auto-read for continuous narration. |
| **Kid UX** | The child taps any text and a warm, friendly voice reads it aloud. Menu items announce themselves when highlighted. Story text auto-reads with synchronized word-by-word highlighting in a soft blue glow. The voice is kid-appropriate, never robotic. A turtle/rabbit slider adjusts speed from slow and clear to normal pace. |
| **LLM Automation** | Backend: (1) Full UI element tagging for TTS eligibility; (2) Tap-to-speak event handler on all text elements; (3) TTS engine with kid-optimized voice model (natural-sounding, warm tone, trained on child-friendly content); (4) Word-level synchronization for visual highlighting; (5) Speed control: 0.5x to 2.0x playback; (6) Language auto-detection with 20+ language support; (7) Voice profile selection: Friendly Male, Friendly Female, or Character Voices. |
| **JSON Contract Extension** | `{"read_to_me": {"tts_enabled": "boolean", "tap_to_speak": "boolean", "voice_profile": "friendly_male|friendly_female|character", "playback_speed": "float(0.5-2.0)", "word_highlighting": "boolean", "auto_read_stories": "boolean", "supported_languages": ["string"]}}` |

---

### Haptic Beat Buddy

| Field | Details |
|-------|---------|
| **Feature Name** | Haptic Beat Buddy |
| **Source Game** | Nintendo Switch HD Rumble, PS5 DualSense haptic feedback |
| **Description** | Rich haptic feedback patterns synchronized to gameplay events, music beats, and terrain types. Each surface produces a distinct tactile sensation; every action provides physical confirmation. For children who cannot hear or see well, haptics become a primary information channel. |
| **Kid UX** | The child walks on grass — a gentle continuous rumble. They jump on stone — a sharp quick pulse. They collect a coin — a satisfying ding-like vibration. An enemy approaches — heartbeat-style pulsing intensifies with proximity. The controller or tablet feels alive with information. |
| **LLM Automation** | Backend: (1) Haptic event mapper assigns vibration patterns to 100+ game events; (2) Music beat extractor syncs haptic pulses to percussion; (3) Terrain haptic textures: grass = smooth low-amplitude continuous, stone = short high-amplitude pulses, ice = slippery sliding pattern; (4) Proximity-based intensity: enemies trigger heartbeat that speeds up as they approach; (5) Platform abstraction supports HD Rumble, DualSense, mobile vibration, and adaptive controllers; (6) Haptic strength adjustable or convertible to on-screen visual pulse. |
| **JSON Contract Extension** | `{"haptic_beat": {"enabled": "boolean", "event_patterns": [{"event": "string", "pattern_type": "continuous|pulse|heartbeat|slide", "amplitude": "float"}], "terrain_textures": [{"terrain": "grass|stone|ice|sand", "pattern": "string"}], "proximity_patterns": [{"target_type": "enemy|collectible|hazard", "base_pattern": "string"}], "strength_multiplier": "float(0-1)"}}` |

---

## 9.5 Adaptive Intelligence & Support

### Smart Checkpoint Dropper

| Field | Details |
|-------|---------|
| **Feature Name** | Smart Checkpoint Dropper |
| **Source Game** | Celeste Assist Mode, Left 4 Dead relax phase recovery |
| **Description** | AI analyzes death patterns and dynamically adjusts checkpoint placement. Frequent deaths in one section trigger a closer checkpoint. As the child improves, checkpoints subtly space out. The checkpoint never appears to be "given" — it is presented as a discovery with a sparkle animation. |
| **Kid UX** | The child falls in the same pit three times. On the fourth attempt, a glowing checkpoint flag appears just before the pit with a celebratory sparkle. "Woohoo, I'm getting farther!" The child feels improvement, not handouts. After a streak of successes, the next checkpoint appears farther ahead, matching their growing skill. |
| **LLM Automation** | Backend: (1) Death heatmap tracks clustering of failure events per zone; (2) Checkpoint need score = death density × average time since last checkpoint; (3) Optimal checkpoint position calculated as nearest safe platform before death zone; (4) Visual feedback designed to look like "discovery" not "assistance" — sparkle animation frames it as a reward; (5) Minimum 3-attempt cooldown before checkpoint trigger to prevent spam; (6) Gradual removal: as child succeeds consistently, checkpoints space out to match skill growth. |
| **JSON Contract Extension** | `{"smart_checkpoint": {"death_heatmap": [{"zone_id": "string", "death_count": "int"}], "checkpoint_need_score": "float", "suggested_position": {"x": "float", "y": "float"}, "trigger_attempts": "int", "gradual_removal_rate": "float"}}` |

---

### Virtual Co-Pilot Companion

| Field | Details |
|-------|---------|
| **Feature Name** | Virtual Co-Pilot Companion |
| **Source Game** | Microsoft Copilot Voice (Mico character), conversational AI assistants |
| **Description** | A friendly AI companion character that children can talk to for help, creative suggestions, or emotional support. The Co-Pilot understands the full game context — current level, player position, recent failures — and responds with encouragement, hints, or demonstrations. |
| **Kid UX** | A cute floating robot named "Chip" hovers at the edge of the screen. The child taps Chip and says "I'm stuck..." Chip responds: "Want me to show you a hint? Or should I try the tricky part for you?" The child says "Show me!" Chip demonstrates a ghost jump. After success, Chip cheers: "You got it! You're amazing!" |
| **LLM Automation** | Backend: (1) Conversational LLM fine-tuned on kid-friendly game assistance; (2) Game state awareness — Co-Pilot has access to current level layout, player position, recent death clusters; (3) Intent routing: hint_request, play_assist, creative_suggestion, emotional_support; (4) Response safety filter ensures all outputs are age-appropriate, positive, and constructive; (5) Memory across sessions: Co-Pilot remembers child's preferences and past conversations; (6) Parent dashboard visibility for all Co-Pilot conversations. |
| **JSON Contract Extension** | `{"virtual_copilot": {"companion_id": "string", "personality": "helpful_robot|friendly_wizard|cheerful_animal", "game_state_access": "boolean", "intent": "hint|play_assist|creative|emotional", "safety_filter": "boolean", "parent_visible": "boolean", "conversation_memory": "boolean"}}` |

---

### Assist Mode Presets Library

| Field | Details |
|-------|---------|
| **Feature Name** | Assist Mode Presets Library |
| **Source Game** | Celeste Assist Mode, Forza accessibility presets |
| **Description** | Pre-configured assist bundles designed for specific accessibility needs. Instead of manually toggling dozens of options, parents or therapists can select a preset that matches the child's needs. Presets are labeled by benefit, not disability. |
| **Kid UX** | Parent opens the "Helpful Settings" menu and sees friendly preset cards: "Gentle Explorer" (for children who want a relaxed experience), "Focus Helper" (reduces distractions), "Steady Hands" (motor assistance), "Clear View" (visual enhancements), "Calm Play" (reduces intensity). Each card shows a simple before/after preview. |
| **LLM Automation** | Backend: (1) 8 curated presets each configuring 15+ parameters: Gentle Explorer (low enemy count, infinite health, slow motion), Focus Helper (reduced particles, Super See Mode, no screen shake), Steady Hands (input buffering, auto-aim, forgiving timing), Clear View (high contrast, large text, Sound-to-Light), Calm Play (no time limits, gentle music, pause-and-think), Independent Reader (Symbol Speak + Read-to-Me + simplified text), Social Creator (co-op assist, shared checkpoints, guided building); (2) Custom preset save slots for therapists and parents; (3) Preset import/export via shareable codes. |
| **JSON Contract Extension** | `{"assist_presets": {"selected_preset": "string", "custom_presets": [{"name": "string", "settings": "object"}], "preset_categories": ["gentle_explorer", "focus_helper", "steady_hands", "clear_view", "calm_play", "independent_reader", "social_creator"]}}` |

---

## Feature Summary: Accessibility Coverage Matrix

| Accessibility Need | Features Addressing It |
|-------------------|----------------------|
| Low vision / Blindness | Super See Mode, Sound-to-Light, Read-to-Me, Haptic Beat Buddy, Screen Edge Indicators |
| Colorblindness (all 3 types) | Colorblind Palette Adaptation, Super See Mode, pattern/texture supplements |
| Deaf / Hard of hearing | Sound-to-Light Translator, Screen Edge Indicators, Haptic Beat Buddy, visual subtitles |
| Motor impairments | One-Tap Wonder Mode, Adaptive Controller Support, Auto-Pilot Companion, Input Buffer, Eye Control (Ch 8) |
| Cognitive / Learning differences | Symbol Speak, Story Simplification, Pause-and-Think, Virtual Co-Pilot, Granular Assists |
| Dyslexia | Dyslexia-Friendly Font, Read-to-Me Everything, Word Highlighting, Symbol Speak |
| ADHD / Focus challenges | Super See Mode, Sensitivity Safe Zone, Focus Helper preset, Pause-and-Think |
| Anxiety / Sensory processing | Sensitivity Safe Zone, Calm Play preset, Smart Checkpoint Dropper, Emotional Flow Guardian (Ch 8) |
| Non-verbal communication | Symbol Speak (AAC), Voice Naming, TTS for all interactions |
| Autism spectrum | Sensitivity Safe Zone, Predictable timing, Symbol Speak, Consistent haptic feedback |

