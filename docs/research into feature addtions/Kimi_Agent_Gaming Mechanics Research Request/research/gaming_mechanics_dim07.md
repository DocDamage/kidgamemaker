# Dimension 07: Co-op, Social & Companion Systems

## Executive Summary

Cooperative multiplayer and companion systems represent one of the most emotionally resonant dimensions of game design, especially for young children who naturally want to share experiences with friends and family. This research synthesizes findings from classic arcade co-op beat 'em ups, Nintendo's revolutionary bubble respawn system, modern asynchronous multiplayer paradigms, and child online safety regulations to derive actionable recommendations for a stamp-based, zero-code game creation platform designed for children as young as 5.

The central insight from this research is that **co-op for children must be frictionless and failure-tolerant**. Nintendo's bubble respawn mechanic from *New Super Mario Bros. Wii* stands as the gold standard --- it transforms death from a punishing reset into an opportunity for social bonding, as skilled players rescue trapped friends [^337^]. Similarly, companion AI systems from games like *Sonic 2* (Tails) and *Kirby Star Allies* (Helper system) demonstrate that single-player experiences can feel like co-op without requiring a second human player [^375^] [^419^].

For a stamp-based platform, the key innovation is the **"Social Stamp" taxonomy** --- a set of pre-made stamps that children place on their canvas to instantly add social features. A "Companion Stamp" spawns an AI friend, a "Co-op Portal" enables drop-in multiplayer via shareable links, and a "Share Button" exports the entire game canvas for friends to play. The LLM backend handles all server configuration, networking code, and safety filtering invisibly, so the child simply stamps and plays. This approach aligns with the "privacy by design" principles mandated by COPPA and GDPR-Kids, ensuring that safety is not an afterthought but the foundation of the architecture [^302^] [^392^].

---

## Studio Innovations Analysis

### 1. The Behemoth (Castle Crashers) — Jolly Co-opetition & Drop-in Challenges

**How It Works Technically:**
*Castle Crashers* supports 4-player co-op both locally and online. Players drop in and out of sessions, with the game dynamically scaling enemy counts based on player number. The game features "jolly co-opetition" --- small competitive moments (post-boss duels for princess affection, loot races) woven into cooperative play to keep social dynamics fresh [^335^]. The Behemoth's networking uses a peer-to-peer architecture where one player acts as the host, with all others connecting directly.

However, as noted in a Game Developer postmortem, *Castle Crashers* had significant drop-in/drop-out limitations: all players had to be present to start a game, disconnected players couldn't rejoin without everyone stopping and restarting, and if the last player dropped in an online game, the entire session ended with all progress lost [^343^]. These are critical lessons for designing child-friendly co-op.

**Stamp-Based Adaptation:**
- A "Co-op Castle Stamp" placed on the canvas enables multiplayer for that level
- The LLM backend auto-generates session codes (like Fall Guys' 12-digit share codes [^416^]) that children can text to friends
- Auto-scaling enemy counts based on player number happens invisibly
- Progress is saved per-player (not per-session), so disconnects don't lose anything
- The "Princess Duel" competitive minigame becomes an optional "Mini-Game Stamp" that children can place if they want friendly competition

### 2. Technos Japan (Double Dragon, River City Ransom) — Co-op with Friendly Fire & AI Companions

**How It Works Technically:**
*River City Ransom* (1989) featured true 2-player co-op with shared lives and friendly fire enabled --- players could accidentally (or intentionally) hit each other. The GBA remake *River City Ransom EX* notably replaced true co-op with an AI-controlled partner system, allowing players to have up to three AI-controlled allies forming a "posse" [^341^]. The AI partners followed the player, assisted in combat, and could be configured with adjustable behavior parameters.

**Stamp-Based Adaptation:**
- The "Friendly Fire Stamp" toggle (default: OFF for child safety) lets children decide if players can hurt each other
- The "Posse Stamp" spawns 1-3 AI companions that follow the player character
- Each companion can have a behavior assigned by the LLM (follow, attack, collect, protect)
- The companion system uses the same position-recording algorithm as classic DKC tag-team followers [^426^]

### 3. Nintendo (New Super Mario Bros. series) — The Bubble Respawn System

**How It Works Technically:**
The bubble respawn system, as described in Iwata Asks, was born from a genuine design problem: when four players co-op and one dies, that player sits idle while others continue playing [^337^]. The solution was multi-faceted:

1. **Death transforms into a bubble**: When a player loses a life, they respawn inside a floating bubble at the nearest safe location
2. **Invincibility while bubbled**: The player cannot be hurt while inside
3. **Phasing through obstacles**: The bubble can pass through walls, enemies, and hazards
4. **Requires rescue to resume**: Another player must touch the bubble to pop it and free the trapped player
5. **Voluntary bubble entry**: Players can press a button to enter a bubble at will, useful when a less-skilled player wants to skip a difficult section
6. **Drift toward players**: The bubble slowly moves toward living players, making rescue easier

The bubble solves multiple problems simultaneously: it keeps all players engaged, enables mixed-skill co-op (beginners can bubble through hard sections), creates moments of teamwork (rescuing friends), and removes the frustration of waiting to respawn [^337^].

**Stamp-Based Adaptation:**
- The "Bubble Respawn Stamp" placed on a level enables the bubble mechanic
- The LLM backend automatically generates bubble spawn points at safe locations
- When a child stamps this, the entire level gets invisible "safe zones" where bubbles can spawn
- The companion AI automatically prioritizes bubble-popping as a behavior when nearby
- Voluntary bubbling becomes a "Panic Button" that appears on screen when co-op is active

### 4. Nintendo (Kirby Star Allies / Super Star) — Helper System & Friend Hearts

**How It Works Technically:**
*Kirby Star Allies* refines the Helper system from *Kirby Super Star* (1996). Kirby throws "Friend Hearts" at enemies to convert them into AI-controlled allies [^419^]. Up to 3 friends can be active simultaneously (4 players total). Friends can be either human-controlled (drop-in via Joy-Con sharing) or CPU-controlled. The system includes:

- **Friend Abilities**: Combined power attacks when friends work together
- **Friend Actions**: Special cooperative moves (Friend Circle, Friend Train)
- **AI for CPU friends**: Auto-follow, auto-attack, and context-aware ability usage
- **Color-coded players**: Player 2 = yellow, Player 3 = blue, Player 4 = green [^419^]
- **Dream Friends**: Special pre-unlocked characters from past games

**Stamp-Based Adaptation:**
- The "Friend Heart Stamp" converts defeated enemies into AI companions
- The "Dream Friend Stamp" places a special companion with unique abilities
- Companion colors auto-assign based on join order
- Friend Abilities trigger automatically when companions are nearby (no complex input)
- The LLM backend handles all AI state management (follow, attack, assist)

### 5. SEGA (Sonic the Hedgehog 2) — Tails AI Companion

**How It Works Technically:**
Tails in *Sonic 2* operates as a player-like entity that constantly attempts to follow Sonic [^375^]. The AI mimics player inputs with a delay, creating the illusion of a second player. Key behaviors:

- **Input recording**: Tails's movements are based on recorded player inputs with a time delay
- **Jump assistance**: If Tails is below the player, he attempts to jump up to reach them
- **Flying ability**: When AI-controlled, Tails uses his flight to catch up if he falls behind
- **Carry mechanic**: In *Sonic 3*, players could grab Tails to be flown to hard-to-reach areas
- **No life cost**: Tails dying has no penalty, making him perfect for beginner-friendly co-op

However, as noted by the SRB2 community, Tails AI has reliability issues: he often fails to keep up, the carry mechanic is finicky, and he can be unavailable when needed most [^377^]. These are critical considerations for designing companion AI in a stamp-based system.

**Stamp-Based Adaptation:**
- The "Sidekick Stamp" places a Tails-like companion on the canvas
- The companion uses a recorded-input system with configurable delay
- The LLM backend auto-generates pathfinding to keep the companion from getting stuck
- Death has no penalty for companions, maintaining child-friendly difficulty
- The carry mechanic becomes automatic --- if a player is struggling to jump, the companion offers a boost

### 6. Rare (Donkey Kong Country) — Tag-Team Co-op

**How It Works Technically:**
*Donkey Kong Country* (1994) introduced tag-team co-op where two Kongs (Donkey and Diddy) work together [^381^]:

- **Follow behavior**: The inactive Kong follows behind the active one, copying their movements
- **Character switching**: Players can swap between Kongs at any time
- **Different abilities**: Diddy is faster and jumps higher; Donkey is stronger and can defeat certain enemies
- **Shared lives**: When one Kong is hit, the other runs away and is unavailable until a DK Barrel is found
- **Reserve system**: Only one Kong can be active at a time; the other follows in reserve

The GBA version added true simultaneous co-op, but the original's tag-team system remains a model for how to give two players distinct roles without overwhelming either [^381^].

**Stamp-Based Adaptation:**
- The "Tag Team Stamp" enables two-character gameplay
- The LLM backend auto-assigns distinct abilities to each character (speed vs. strength)
- Character switching is a simple tap on the character portrait
- The inactive character auto-follows using a position-recording buffer [^426^]
- Shared lives are the default (no separate life pools to confuse children)

### 7. Modern Innovations — Asynchronous Multiplayer & Level Sharing

**How It Works Technically:**
Modern games use several asynchronous social paradigms:

- **Ghost races** (*Mario Kart* Time Trials): Players race against recorded replays of other players' best times [^338^]. The ghost is a transparent recording of inputs, not a live player.
- **Level sharing** (*Little Big Planet*, *Fall Guys Creative*): Players create levels, publish them to a server, and share unique codes. Others can download and play these levels [^360^] [^425^].
- **Community showdowns** (*Fall Guys*): Player-created levels are featured alongside official content [^425^].
- **Asynchronous challenges**: Players attempt the same challenge and compare scores without being online simultaneously.

**Stamp-Based Adaptation:**
- The "Ghost Race Stamp" records a player's run and lets friends race their ghost
- The "Share Code Stamp" generates a short code that friends can enter to play the same level
- The "Community Gallery Stamp" browses popular levels created by other children (moderated)
- The LLM backend handles all recording, storage, and playback invisibly
- No account required --- codes are tied to the game canvas, not personal data

---

## Key Findings

### Co-op Design Principles for Children

1. **Drop-in/drop-out must be truly frictionless.** *Castle Crashers* failed here --- requiring all players to restart when one disconnects is unacceptable for children [^343^]. The platform must support reconnecting without interrupting other players.

2. **The bubble respawn is the most child-friendly mechanic ever invented for co-op.** As described in Iwata Asks, the bubble "solves multiple problems at once" --- it keeps all players engaged, enables skill-gap bridging, and creates positive social moments [^337^].

3. **Companion AI must be reliable above all else.** Tails in *Sonic 2* is beloved but frequently unreliable [^377^]. A companion that fails to help when needed is worse than no companion at all.

4. **Competition within cooperation creates natural social dynamics.** *Castle Crashers*' post-boss duels and loot races create "frequent and natural tension points" without derailing cooperation [^335^]. These can be optional stamps.

5. **Friendly fire should default to OFF for children's games.** *River City Ransom* and *New Super Mario Bros. Wii* show that friendly fire can be fun for adults but frustrating for children playing together [^309^].

6. **Pre-defined communication only.** *Among Us*' Quick Chat system (pre-set phrases instead of free text) demonstrates safe communication for children under 13 [^371^]. Free text should never be available in a platform for 5-year-olds.

### Online Safety Requirements

7. **COPPA mandates verifiable parental consent for collecting any personal information from children under 13.** This includes IP addresses, device IDs, and even usernames that can identify a child [^302^] [^305^].

8. **The UK Age-Appropriate Design Code requires high-privacy defaults for all users under 18.** All settings must be "high privacy" by default, with communication features turned OFF until a parent explicitly enables them [^392^].

9. **Zero-data environments are the safest approach.** *Bloxels Builder* demonstrates that games can function as "zero-data environments" where no personal information is collected [^302^]. For a stamp platform, this should be the default mode.

10. **Parental controls must be appropriate for each age group, not just under-13s.** The ICO recommends controls that "gradually reduce as children approach adulthood, rather than a step change at 13" [^392^].

11. **Pre-moderation of user-generated content is essential.** The UNICEF report on protecting children in online gaming recommends pre-moderation of user-created levels to prevent harmful content [^365^]. An LLM backend can automate this.

### Technical Implementation Insights

12. **Photon Quantum's reconnection system provides a technical blueprint for handling disconnections.** PlayerTTL (keeping disconnected players reserved for 20+ seconds), RoomTTL (keeping rooms alive when empty), and buddy snapshots for late-joining are all proven patterns [^417^].

13. **The position-recording buffer is the classic approach to companion following.** Recording player positions into a ring buffer and having the companion lerp between delayed positions creates smooth following behavior [^363^].

14. **NavMesh-based following is the modern standard for companion AI.** Unity's NavMeshAgent with simple state machines (Idle, Follow, Assist) provides mobile-friendly, lightweight AI [^361^].

15. **Among Us' private lobby system with invite codes demonstrates child-safe multiplayer.** Private games require a code to join, limiting interaction to known friends [^371^].

---

## Child-Friendly Simplifications

### How Each Mechanic Becomes a Stamp

| Complex Mechanic | Stamp Name | Child Interaction |
|-----------------|-----------|-------------------|
| Drop-in/drop-out co-op session management | **Co-op Portal Stamp** | Place on canvas, auto-generates share code. Child texts code to friend. |
| Bubble respawn system | **Bubble Rescue Stamp** | Place on canvas. When someone dies, they float in a bubble until rescued. |
| Companion AI (follow/assist) | **Buddy Stamp** | Choose from pre-made buddies (pet, robot, fairy). LLM generates AI behavior. |
| Level sharing | **Share Button Stamp** | One-tap sharing of the entire game canvas. Generates a short code. |
| Friendly fire toggle | **Gentle Mode Stamp** | On by default. When ON, players can't hurt each other. |
| AI difficulty scaling | **Helper Hand Stamp** | Auto-adjusts difficulty based on player skill. Invisible to the child. |
| Communication | **Cheer Stamp** | Pre-defined positive messages ("Great job!", "Need help?"). No free text. |
| Parental controls | **Family Lock Stamp** | Parent-configured once, applies to all games child creates. |

### The Child's Mental Model

For a 5-year-old, the co-op experience should feel like this:
1. They place a "Buddy Stamp" on their canvas. A cute character appears.
2. They place a "Co-op Portal Stamp". A colorful portal appears.
3. They tap "Share" and a 4-digit code appears (like a treasure code!).
4. They tell their friend the code over the phone or in person.
5. The friend enters the code and appears in the game as a second character.
6. When someone falls in a pit, they float in a bubble and call for help.
7. Their friend (or Buddy) pops the bubble and saves them.
8. Everyone wins together.

---

## Recommended Features

### P0 (Critical) — Core Co-op & Companion

1. **Buddy Stamp** — AI companion with follow, assist, and bubble-rescue behaviors
2. **Co-op Portal Stamp** — Share-code-based drop-in co-op (2-4 players)
3. **Bubble Rescue Stamp** — Bubble respawn system for all co-op levels
4. **Gentle Mode** — Friendly fire disabled by default, players can't push each other off platforms
5. **Zero-Data Mode** — No personal information collected by default, session codes are random and temporary

### P1 (Important) — Social Sharing & Safety

6. **Share Code System** — Short, memorable codes (4-6 digits) for sharing levels
7. **Ghost Race Stamp** — Race against a friend's recorded run
8. **Cheer System** — Pre-defined positive messages only (no free text)
9. **Parental Gate** — COPPA-compliant parental consent flow (handled by LLM backend)
10. **Content Moderation** — LLM auto-scans all shared content before it's accessible to others

### P2 (Nice to Have) — Advanced Social Features

11. **Community Gallery** — Curated showcase of popular child-created levels
12. **Tag Team Stamp** — Two-character switching like DKC
13. **Dream Friend Stamp** — Special companions with unique abilities (like Kirby)
14. **Posse Stamp** — Multiple AI companions following the player (like River City Ransom)
15. **Family Account System** — Parent dashboard for managing all child's creations and social interactions

---

## Code Snippets

### Companion AI (Follow / Assist / Bubble Rescue)

```javascript
// ============================================================
// SimpleCompanionAI.ts
// A lightweight companion AI for 2D side-scrolling platformers
// Designed for stamp-based deployment - the LLM configures params
// ============================================================

interface CompanionConfig {
  followDistance: number;      // pixels to maintain from player
  teleportDistance: number;    // max distance before teleport
  jumpThreshold: number;       // vertical gap to trigger jump
  assistRange: number;         // detection radius for enemies
  bubbleRescueRange: number;   // auto-rescue bubbled players
  inputDelay: number;          // frames of input recording delay
  moveSpeed: number;           // max horizontal speed
  jumpForce: number;           // vertical jump impulse
}

enum CompanionState {
  IDLE = 'idle',
  FOLLOW = 'follow',
  ASSIST = 'assist',
  RESCUE = 'rescue',
  CATCH_UP = 'catch_up'
}

class SimpleCompanionAI {
  private player: GameObject;
  private companion: GameObject;
  private config: CompanionConfig;
  private state: CompanionState = CompanionState.IDLE;
  
  // Position history ring buffer for smooth following
  private positionBuffer: { x: number; y: number; action: string }[] = [];
  private bufferIndex: number = 0;
  private readonly BUFFER_SIZE: number = 120; // 2 seconds at 60fps
  
  constructor(player: GameObject, companion: GameObject, config: CompanionConfig) {
    this.player = player;
    this.companion = companion;
    this.config = config;
  }

  update(deltaTime: number): void {
    const distanceToPlayer = this.getDistanceToPlayer();
    
    // State machine transitions
    this.updateState(distanceToPlayer);
    
    // Execute current state behavior
    switch (this.state) {
      case CompanionState.FOLLOW:
        this.executeFollow();
        break;
      case CompanionState.ASSIST:
        this.executeAssist();
        break;
      case CompanionState.RESCUE:
        this.executeBubbleRescue();
        break;
      case CompanionState.CATCH_UP:
        this.executeTeleport();
        break;
      case CompanionState.IDLE:
      default:
        this.executeIdle();
        break;
    }
    
    // Record current player position for delayed following
    this.recordPlayerPosition();
  }

  private updateState(distance: number): void {
    // Check for bubble rescue priority (highest)
    const bubbledPlayer = this.findBubbledPlayer();
    if (bubbledPlayer && this.getDistance(bubbledPlayer) < this.config.bubbleRescueRange) {
      this.state = CompanionState.RESCUE;
      return;
    }
    
    // Check for assist priority
    const nearbyEnemy = this.findNearbyEnemy();
    if (nearbyEnemy && this.getDistance(nearbyEnemy) < this.config.assistRange) {
      this.state = CompanionState.ASSIST;
      return;
    }
    
    // Distance-based state transitions
    if (distance > this.config.teleportDistance) {
      this.state = CompanionState.CATCH_UP;
    } else if (distance > this.config.followDistance) {
      this.state = CompanionState.FOLLOW;
    } else {
      this.state = CompanionState.IDLE;
    }
  }

  private executeFollow(): void {
    // Retrieve delayed player position from ring buffer
    const delayedPos = this.getDelayedPosition(this.config.inputDelay);
    const directionX = delayedPos.x - this.companion.x;
    const directionY = delayedPos.y - this.companion.y;
    
    // Horizontal movement toward delayed position
    if (Math.abs(directionX) > 10) {
      this.companion.velocityX = Math.sign(directionX) * this.config.moveSpeed;
    } else {
      this.companion.velocityX = 0;
    }
    
    // Jump if player is significantly above and on ground
    if (directionY < -this.config.jumpThreshold && this.companion.isOnGround) {
      this.companion.velocityY = -this.config.jumpForce;
    }
    
    // Face the direction of movement
    this.companion.facing = directionX >= 0 ? 1 : -1;
  }

  private executeAssist(): void {
    const target = this.findNearbyEnemy();
    if (!target) {
      this.state = CompanionState.FOLLOW;
      return;
    }
    
    // Move toward enemy
    const directionX = target.x - this.companion.x;
    this.companion.velocityX = Math.sign(directionX) * this.config.moveSpeed;
    
    // Jump toward enemy if needed
    if (target.y < this.companion.y - 20 && this.companion.isOnGround) {
      this.companion.velocityY = -this.config.jumpForce;
    }
    
    // Attack when in range
    if (Math.abs(directionX) < 30) {
      this.companion.attack();
    }
  }

  private executeBubbleRescue(): void {
    const bubbledPlayer = this.findBubbledPlayer();
    if (!bubbledPlayer) {
      this.state = CompanionState.FOLLOW;
      return;
    }
    
    // Move directly toward bubbled player
    const directionX = bubbledPlayer.x - this.companion.x;
    const directionY = bubbledPlayer.y - this.companion.y;
    
    this.companion.velocityX = Math.sign(directionX) * this.config.moveSpeed;
    
    // Jump to reach bubble if needed
    if (Math.abs(directionY) > 20 && this.companion.isOnGround) {
      this.companion.velocityY = -this.config.jumpForce;
    }
    
    // Pop bubble on contact (handled by collision system)
  }

  private executeTeleport(): void {
    // Emergency teleport when companion is too far behind
    // Spawn a poof effect, then appear near player
    this.spawnTeleportEffect();
    this.companion.x = this.player.x - (this.config.followDistance * this.player.facing);
    this.companion.y = this.player.y;
    this.state = CompanionState.FOLLOW;
  }

  private executeIdle(): void {
    // Play idle animation, maybe small bounce
    this.companion.velocityX = 0;
    
    // Occasional look around animation
    if (Math.random() < 0.005) {
      this.companion.playAnimation('look_around');
    }
  }

  // Position recording for smooth delayed following
  private recordPlayerPosition(): void {
    this.positionBuffer[this.bufferIndex] = {
      x: this.player.x,
      y: this.player.y,
      action: this.player.currentAction
    };
    this.bufferIndex = (this.bufferIndex + 1) % this.BUFFER_SIZE;
  }

  private getDelayedPosition(delayFrames: number): { x: number; y: number } {
    const index = (this.bufferIndex - delayFrames + this.BUFFER_SIZE) % this.BUFFER_SIZE;
    return this.positionBuffer[index] || { x: this.player.x, y: this.player.y };
  }

  // Helper methods
  private getDistanceToPlayer(): number {
    return Math.sqrt(
      Math.pow(this.player.x - this.companion.x, 2) + 
      Math.pow(this.player.y - this.companion.y, 2)
    );
  }

  private getDistance(other: GameObject): number {
    return Math.sqrt(
      Math.pow(other.x - this.companion.x, 2) + 
      Math.pow(other.y - this.companion.y, 2)
    );
  }

  private findBubbledPlayer(): GameObject | null {
    // Returns the nearest player in bubble state, or null
    return GameWorld.findNearestObject(
      this.companion.x, this.companion.y, 
      (obj) => obj.type === 'player' && obj.state === 'bubbled'
    );
  }

  private findNearbyEnemy(): GameObject | null {
    return GameWorld.findNearestObject(
      this.companion.x, this.companion.y,
      (obj) => obj.type === 'enemy' && !obj.isDefeated,
      this.config.assistRange
    );
  }

  private spawnTeleportEffect(): void {
    GameWorld.spawnParticleEffect('teleport_poof', this.companion.x, this.companion.y);
  }
}

// ============================================================
// Default configurations for different companion types
// The LLM backend selects based on the Buddy Stamp chosen
// ============================================================

const COMPANION_PRESETS: Record<string, CompanionConfig> = {
  speedy_pet: {
    followDistance: 40,
    teleportDistance: 300,
    jumpThreshold: 30,
    assistRange: 80,
    bubbleRescueRange: 150,
    inputDelay: 15,
    moveSpeed: 4.5,
    jumpForce: 10
  },
  strong_robot: {
    followDistance: 50,
    teleportDistance: 250,
    jumpThreshold: 20,
    assistRange: 60,
    bubbleRescueRange: 120,
    inputDelay: 30,
    moveSpeed: 3.0,
    jumpForce: 8
  },
  helpful_fairy: {
    followDistance: 35,
    teleportDistance: 400, // Can fly, so less teleporting needed
    jumpThreshold: 10,
    assistRange: 100,
    bubbleRescueRange: 200,
    inputDelay: 10,
    moveSpeed: 3.5,
    jumpForce: 12 // Floaty jumps
  }
};
```

### Bubble Respawn System

```javascript
// ============================================================
// BubbleRespawnSystem.ts
// Nintendo-inspired bubble respawn for child-friendly co-op
// ============================================================

interface BubbleConfig {
  floatSpeed: number;           // upward drift speed
  driftSpeed: number;           // horizontal drift toward players
  popOnContact: boolean;        // any player touch pops bubble
  selfPopDelay: number;         // frames before player can self-pop
  invincibilityDuration: number; // frames of post-bubble invincibility
  maxBubbleTime: number;        // maximum frames before forced pop
  safeZoneOffset: number;       // pixels above last safe position to spawn
}

enum PlayerState {
  ACTIVE = 'active',
  BUBBLED = 'bubbled',
  RESPAWNING = 'respawning',
  INVINCIBLE = 'invincible'
}

class BubbleRespawnSystem {
  private players: Player[];
  private bubbles: Bubble[] = [];
  private config: BubbleConfig;
  private safeZones: SafeZone[] = []; // Auto-generated safe spawn points
  
  constructor(players: Player[], config: BubbleConfig) {
    this.players = players;
    this.config = config;
    this.generateSafeZones();
  }

  update(deltaTime: number): void {
    this.updateBubbles();
    this.checkBubbleCollisions();
    this.updatePlayerStates();
  }

  // Called when a player "dies" --- they enter a bubble instead
  onPlayerDeath(player: Player): void {
    // Don't bubble if all players are dead
    const alivePlayers = this.players.filter(p => p.state === PlayerState.ACTIVE);
    if (alivePlayers.length === 0) {
      // All players dead --- trigger normal game over / checkpoint reset
      this.onAllPlayersDefeated();
      return;
    }
    
    // Find nearest safe zone for bubble spawn
    const spawnZone = this.findNearestSafeZone(player.lastSafeX, player.lastSafeY);
    
    // Create bubble at safe location
    const bubble = new Bubble({
      x: spawnZone.x,
      y: spawnZone.y - this.config.safeZoneOffset,
      trappedPlayer: player,
      lifetime: 0,
      canSelfPop: false
    });
    
    this.bubbles.push(bubble);
    
    // Set player state
    player.state = PlayerState.BUBBLED;
    player.bubble = bubble;
    
    // Visual effects
    this.spawnBubbleEffects(spawnZone.x, spawnZone.y);
    
    // Audio cue --- playful "help me!" sound (not distressing)
    AudioSystem.play('bubble_spawn_cute');
  }

  private updateBubbles(): void {
    for (const bubble of this.bubbles) {
      bubble.lifetime++;
      
      // Find nearest active player for drift direction
      const nearestPlayer = this.findNearestActivePlayer(bubble.x, bubble.y);
      
      if (nearestPlayer) {
        // Drift toward nearest player
        const dirX = nearestPlayer.x - bubble.x;
        bubble.x += Math.sign(dirX) * this.config.driftSpeed;
        
        // Gentle bobbing motion
        bubble.y += Math.sin(bubble.lifetime * 0.05) * 0.5;
      }
      
      // Enable self-pop after delay
      if (bubble.lifetime > this.config.selfPopDelay) {
        bubble.canSelfPop = true;
      }
      
      // Visual indicator that self-pop is available
      if (bubble.canSelfPop && bubble.lifetime % 60 < 30) {
        bubble.showPrompt('Press JUMP to pop!');
      }
      
      // Forced pop after max time (safety valve)
      if (bubble.lifetime > this.config.maxBubbleTime) {
        this.popBubble(bubble, 'timeout');
      }
    }
  }

  private checkBubbleCollisions(): void {
    for (const bubble of this.bubbles) {
      // Check if any active player touches the bubble
      for (const player of this.players) {
        if (player.state !== PlayerState.ACTIVE) continue;
        
        if (this.checkCollision(player, bubble)) {
          this.popBubble(bubble, 'rescued');
          this.onBubbleRescued(bubble, player);
          return;
        }
      }
      
      // Check if trapped player requests self-pop
      if (bubble.canSelfPop && bubble.trappedPlayer.input.jumpPressed) {
        this.popBubble(bubble, 'self_pop');
      }
    }
  }

  private popBubble(bubble: Bubble, reason: string): void {
    // Remove from tracking
    this.bubbles = this.bubbles.filter(b => b !== bubble);
    
    // Release player
    const player = bubble.trappedPlayer;
    player.state = PlayerState.RESPAWNING;
    player.bubble = null;
    
    // Position at bubble location
    player.x = bubble.x;
    player.y = bubble.y;
    
    // Visual effects
    this.spawnPopEffects(bubble.x, bubble.y, reason);
    
    // Brief invincibility after popping
    this.giveTemporaryInvincibility(player);
    
    // Audio
    AudioSystem.play(reason === 'rescued' ? 'bubble_pop_happy' : 'bubble_pop_self');
  }

  private onBubbleRescued(bubble: Bubble, rescuer: Player): void {
    // Celebration effect for rescue
    this.spawnRescueCelebration(bubble.x, bubble.y);
    
    // Score bonus (if using score system)
    rescuer.addScore(100);
    bubble.trappedPlayer.addScore(50);
    
    // Show "Teamwork!" celebration text
    UI.showFloatingText(bubble.x, bubble.y - 30, 'Teamwork!', '#FFD700');
  }

  private giveTemporaryInvincibility(player: Player): void {
    player.state = PlayerState.INVINCIBLE;
    player.invincibilityTimer = this.config.invincibilityDuration;
    
    // Flashing effect
    player.startFlashingEffect(this.config.invincibilityDuration);
  }

  private updatePlayerStates(): void {
    for (const player of this.players) {
      if (player.state === PlayerState.INVINCIBLE) {
        player.invincibilityTimer--;
        if (player.invincibilityTimer <= 0) {
          player.state = PlayerState.ACTIVE;
          player.stopFlashingEffect();
        }
      }
      
      // Track "last safe position" for bubble spawn
      if (player.state === PlayerState.ACTIVE && player.isOnGround && !player.inDanger) {
        player.lastSafeX = player.x;
        player.lastSafeY = player.y;
      }
    }
  }

  // Generate safe zones automatically (called when level loads)
  private generateSafeZones(): void {
    // The LLM backend analyzes the level layout and places safe zones at:
    // - Checkpoints
    // - Solid ground areas away from hazards
    // - Before and after challenging platforming sections
    // - At the start of the level
    
    this.safeZones = LevelAnalyzer.findSafeZones({
      minWidth: 100,      // Minimum platform width
      awayFromHazards: 50, // Minimum distance from enemies/pits
      checkpointSpacing: 300 // Max distance between safe zones
    });
  }

  private findNearestSafeZone(x: number, y: number): SafeZone {
    let nearest = this.safeZones[0];
    let nearestDist = Infinity;
    
    for (const zone of this.safeZones) {
      const dist = Math.abs(zone.x - x) + Math.abs(zone.y - y);
      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = zone;
      }
    }
    
    return nearest;
  }

  private findNearestActivePlayer(x: number, y: number): Player | null {
    let nearest: Player | null = null;
    let nearestDist = Infinity;
    
    for (const player of this.players) {
      if (player.state !== PlayerState.ACTIVE) continue;
      const dist = Math.abs(player.x - x) + Math.abs(player.y - y);
      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = player;
      }
    }
    
    return nearest;
  }

  private onAllPlayersDefeated(): void {
    // Reset to last checkpoint or level start
    CheckpointSystem.resetToLastCheckpoint();
    
    // Show "Let's try again!" message (never "Game Over" for children)
    UI.showEncouragementMessage('Let\'s try again together!');
  }

  // Voluntary bubble entry --- for skipping hard sections
  onPlayerRequestBubble(player: Player): void {
    // Only allow if player has been alive for minimum time (prevent spam)
    if (player.timeSinceSpawn < 60) return;
    
    // Only allow if not already in bubble and not in danger
    if (player.state !== PlayerState.ACTIVE) return;
    
    this.onPlayerDeath(player);
    
    // Mark as voluntary (affects visual feedback)
    player.bubble.isVoluntary = true;
    player.bubble.selfPopDelay = 30; // Faster self-pop for voluntary bubbles
  }

  // Visual effect methods
  private spawnBubbleEffects(x: number, y: number): void {
    ParticleSystem.spawn('bubble_form_sparkles', x, y, 20);
  }

  private spawnPopEffects(x: number, y: number, reason: string): void {
    const color = reason === 'rescued' ? '#FFD700' : '#87CEEB';
    ParticleSystem.spawn('bubble_pop_burst', x, y, 15, color);
  }

  private spawnRescueCelebration(x: number, y: number): void {
    ParticleSystem.spawn('star_burst', x, y, 30);
    ParticleSystem.spawn('heart_particles', x, y, 10);
  }
}

// Default child-friendly configuration
const CHILD_FRIENDLY_BUBBLE_CONFIG: BubbleConfig = {
  floatSpeed: 0.5,
  driftSpeed: 1.2,
  popOnContact: true,
  selfPopDelay: 120,        // 2 seconds before self-pop available
  invincibilityDuration: 90, // 1.5 seconds of post-bubble invincibility
  maxBubbleTime: 600,       // 10 seconds max in bubble
  safeZoneOffset: 50
};
```

### Safe Invite & Session Management System

```javascript
// ============================================================
// SafeInviteSystem.ts
// COPPA-compliant co-op session management for children
// Zero personal data collected --- sessions are anonymous
// ============================================================

interface SessionConfig {
  maxPlayers: number;           // 2-4 for child-friendly games
  sessionTimeout: number;       // seconds until idle session expires
  codeLength: number;           // digits in share code
  allowRejoin: boolean;         // can disconnected players return
  requireParentApproval: boolean; // COPPA compliance flag
  communicationMode: 'none' | 'cheers' | 'voice_filtered';
}

interface GameSession {
  id: string;
  code: string;                 // short numeric code children share
  canvasId: string;             // which game canvas is being played
  hostId: string;               // anonymous session identifier
  players: SessionPlayer[];
  state: 'waiting' | 'playing' | 'paused' | 'ended';
  createdAt: number;
  expiresAt: number;
  parentApproved: boolean;      // COPPA compliance
  safetyFlags: SafetyFlag[];
}

interface SessionPlayer {
  id: string;                   // anonymous player identifier
  slot: number;                 // player slot (1-4)
  state: 'connected' | 'disconnected' | 'bubbled';
  joinTime: number;
  lastActivity: number;
  cheerHistory: string[];       // logged for safety review
}

interface SafetyFlag {
  type: 'disconnect_spam' | 'inappropriate_name' | 'reported_behavior';
  severity: 'low' | 'medium' | 'high';
  timestamp: number;
  details: string;
}

class SafeInviteSystem {
  private sessions: Map<string, GameSession> = new Map();
  private activeCodes: Map<string, string> = new Map(); // code -> sessionId
  private config: SessionConfig;
  private safetyModerator: SafetyModerator;
  
  constructor(config: SessionConfig, safetyModerator: SafetyModerator) {
    this.config = config;
    this.safetyModerator = safetyModerator;
  }

  // ============================================================
  // SESSION CREATION
  // Called when child places a Co-op Portal Stamp
  // ============================================================
  async createSession(canvasId: string, hostPlayerId: string): Promise<GameSession> {
    // COPPA check --- if child is under 13, require parent approval
    const needsApproval = this.config.requireParentApproval && 
                         await this.checkNeedsParentApproval(hostPlayerId);
    
    if (needsApproval) {
      await this.requestParentApproval(hostPlayerId, canvasId);
      // Return pending session (will activate when parent approves)
      return this.createPendingSession(canvasId, hostPlayerId);
    }
    
    // Generate short numeric code (e.g., "4729")
    const code = await this.generateUniqueCode();
    
    const session: GameSession = {
      id: this.generateSessionId(),
      code,
      canvasId,
      hostId: this.anonymizePlayerId(hostPlayerId),
      players: [{
        id: this.anonymizePlayerId(hostPlayerId),
        slot: 1,
        state: 'connected',
        joinTime: Date.now(),
        lastActivity: Date.now(),
        cheerHistory: []
      }],
      state: 'waiting',
      createdAt: Date.now(),
      expiresAt: Date.now() + (this.config.sessionTimeout * 1000),
      parentApproved: !needsApproval,
      safetyFlags: []
    };
    
    this.sessions.set(session.id, session);
    this.activeCodes.set(code, session.id);
    
    // Auto-cleanup after expiry
    this.scheduleSessionCleanup(session.id, this.config.sessionTimeout);
    
    return session;
  }

  // ============================================================
  // JOIN SESSION
  // Called when friend enters the share code
  // ============================================================
  async joinSession(code: string, joiningPlayerId: string): Promise<JoinResult> {
    const sessionId = this.activeCodes.get(code);
    if (!sessionId) {
      return { success: false, error: 'invalid_code' };
    }
    
    const session = this.sessions.get(sessionId);
    if (!session) {
      return { success: false, error: 'session_expired' };
    }
    
    // Check session state
    if (session.state === 'ended') {
      return { success: false, error: 'session_ended' };
    }
    
    // Check player capacity
    if (session.players.length >= this.config.maxPlayers) {
      return { success: false, error: 'session_full' };
    }
    
    // Safety moderation --- check if joining player is blocked
    const isBlocked = await this.safetyModerator.checkPlayerBlocked(
      session.hostId, 
      joiningPlayerId
    );
    if (isBlocked) {
      return { success: false, error: 'access_denied' };
    }
    
    // COPPA check for joining player
    if (this.config.requireParentApproval) {
      const approved = await this.checkNeedsParentApproval(joiningPlayerId);
      if (approved) {
        return { success: false, error: 'needs_parent_approval', pending: true };
      }
    }
    
    // Assign player to first available slot
    const usedSlots = session.players.map(p => p.slot);
    const availableSlot = [1, 2, 3, 4].find(s => !usedSlots.includes(s)) || 2;
    
    const player: SessionPlayer = {
      id: this.anonymizePlayerId(joiningPlayerId),
      slot: availableSlot,
      state: 'connected',
      joinTime: Date.now(),
      lastActivity: Date.now(),
      cheerHistory: []
    };
    
    session.players.push(player);
    
    // Auto-start when first guest joins
    if (session.players.length >= 2 && session.state === 'waiting') {
      session.state = 'playing';
    }
    
    return { 
      success: true, 
      session,
      playerSlot: availableSlot
    };
  }

  // ============================================================
  // DISCONNECTION HANDLING
  // Graceful handling of players leaving/rejoining
  // ============================================================
  async handleDisconnection(sessionId: string, playerId: string): Promise<void> {
    const session = this.sessions.get(sessionId);
    if (!session) return;
    
    const player = session.players.find(p => p.id === playerId);
    if (!player) return;
    
    // Mark as disconnected (keep slot reserved for rejoining)
    player.state = 'disconnected';
    
    if (this.config.allowRejoin) {
      // Start rejoin grace period (20 seconds)
      setTimeout(() => {
        this.finalizePlayerRemoval(sessionId, playerId);
      }, 20000);
    } else {
      this.finalizePlayerRemoval(sessionId, playerId);
    }
    
    // If host disconnects, migrate host or end session
    if (playerId === session.hostId) {
      const remaining = session.players.filter(p => p.state === 'connected');
      if (remaining.length > 0) {
        session.hostId = remaining[0].id;
      } else {
        session.state = 'paused';
      }
    }
    
    // If only one player remains, pause (bubble system handles single-player)
    if (session.players.filter(p => p.state === 'connected').length <= 1) {
      session.state = 'paused';
    }
  }

  // ============================================================
  // COMMUNICATION --- CHEER SYSTEM
  // Pre-defined positive messages only (no free text)
  // ============================================================
  
  private readonly ALLOWED_CHEERS: string[] = [
    'Great job!',
    'Nice work!',
    'Need help?',
    'Over here!',
    'Thank you!',
    'You can do it!',
    'Teamwork!',
    'Awesome!',
    'Wait for me!',
    'Follow me!'
  ];

  sendCheer(sessionId: string, playerId: string, cheerIndex: number): CheerResult {
    const session = this.sessions.get(sessionId);
    if (!session) return { success: false, error: 'session_not_found' };
    
    // Validate cheer index
    if (cheerIndex < 0 || cheerIndex >= this.ALLOWED_CHEERS.length) {
      // Flag potential abuse attempt
      this.safetyModerator.flagBehavior(sessionId, playerId, 'invalid_cheer_index');
      return { success: false, error: 'invalid_cheer' };
    }
    
    const cheer = this.ALLOWED_CHEERS[cheerIndex];
    const player = session.players.find(p => p.id === playerId);
    if (!player) return { success: false, error: 'player_not_found' };
    
    // Log for safety review
    player.cheerHistory.push(cheer);
    
    // Broadcast to all connected players
    this.broadcastToSession(sessionId, {
      type: 'cheer',
      fromSlot: player.slot,
      message: cheer,
      timestamp: Date.now()
    });
    
    return { success: true, message: cheer };
  }

  // ============================================================
  // COPPA COMPLIANCE
  // ============================================================
  
  private async checkNeedsParentApproval(playerId: string): Promise<boolean> {
    // Query the LLM backend for the player's age status
    // Returns true if player is under 13 and parent approval is needed
    const playerInfo = await LLMBackend.getPlayerAgeStatus(playerId);
    return playerInfo.age < 13 && !playerInfo.parentConsentOnFile;
  }

  private async requestParentApproval(playerId: string, canvasId: string): Promise<void> {
    // Send notification to parent's email/app
    await LLMBackend.sendParentNotification({
      type: 'multiplayer_request',
      childId: playerId,
      canvasId,
      actionRequired: 'approve_multiplayer',
      expiresIn: 86400 // 24 hours
    });
  }

  // ============================================================
  // UTILITIES
  // ============================================================
  
  private async generateUniqueCode(): Promise<string> {
    // Generate 4-digit numeric code
    let code: string;
    let attempts = 0;
    do {
      code = Math.floor(1000 + Math.random() * 9000).toString();
      attempts++;
    } while (this.activeCodes.has(code) && attempts < 100);
    
    if (attempts >= 100) {
      // Fall back to longer code if collision
      code = Math.floor(10000 + Math.random() * 90000).toString();
    }
    
    return code;
  }

  private generateSessionId(): string {
    return 'sess_' + Math.random().toString(36).substring(2, 15);
  }

  private anonymizePlayerId(playerId: string): string {
    // Create one-way hash --- never store original player ID in session data
    return crypto.subtle.digest('SHA-256', new TextEncoder().encode(playerId + 'session_salt'))
      .then(buf => Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join(''));
  }

  private scheduleSessionCleanup(sessionId: string, delaySeconds: number): void {
    setTimeout(() => {
      const session = this.sessions.get(sessionId);
      if (session) {
        this.activeCodes.delete(session.code);
        this.sessions.delete(sessionId);
      }
    }, delaySeconds * 1000);
  }

  private finalizePlayerRemoval(sessionId: string, playerId: string): void {
    const session = this.sessions.get(sessionId);
    if (!session) return;
    
    // Only remove if player hasn't reconnected
    const player = session.players.find(p => p.id === playerId);
    if (player && player.state === 'disconnected') {
      session.players = session.players.filter(p => p.id !== playerId);
      
      // End session if no players left
      if (session.players.length === 0) {
        session.state = 'ended';
        this.activeCodes.delete(session.code);
      }
    }
  }

  private broadcastToSession(sessionId: string, message: any): void {
    // Send to all connected players in session
    const session = this.sessions.get(sessionId);
    if (!session) return;
    
    for (const player of session.players) {
      if (player.state === 'connected') {
        NetworkLayer.send(player.id, message);
      }
    }
  }

  // ============================================================
  // PARENT DASHBOARD API
  // For the Family Lock Stamp --- parents can review activity
  // ============================================================
  
  async getChildActivitySummary(parentId: string, childId: string): Promise<ActivitySummary> {
    // Return anonymized activity data for parent review
    const sessions = Array.from(this.sessions.values())
      .filter(s => s.players.some(p => p.id === childId));
    
    return {
      totalSessions: sessions.length,
      totalPlayTime: sessions.reduce((sum, s) => sum + (s.expiresAt - s.createdAt), 0),
      peersEncountered: this.countUniquePeers(sessions, childId),
      cheersExchanged: sessions.flatMap(s => 
        s.players.find(p => p.id === childId)?.cheerHistory || []
      ),
      safetyFlags: sessions.flatMap(s => s.safetyFlags),
      lastActive: sessions.length > 0 ? sessions[sessions.length - 1].createdAt : null
    };
  }
}

// Type definitions for return types
interface JoinResult {
  success: boolean;
  error?: string;
  pending?: boolean;
  session?: GameSession;
  playerSlot?: number;
}

interface CheerResult {
  success: boolean;
  error?: string;
  message?: string;
}

interface ActivitySummary {
  totalSessions: number;
  totalPlayTime: number;
  peersEncountered: number;
  cheersExchanged: string[];
  safetyFlags: SafetyFlag[];
  lastActive: number | null;
}

// Default child-safe configuration
const CHILD_SAFE_SESSION_CONFIG: SessionConfig = {
  maxPlayers: 4,
  sessionTimeout: 3600,        // 1 hour max session
  codeLength: 4,               // 4-digit codes children can remember
  allowRejoin: true,           // Disconnected friends can come back
  requireParentApproval: true, // COPPA compliance
  communicationMode: 'cheers'  // Pre-defined messages only
};
```

### Parent Dashboard (Backend-Only, No Child UI)

```python
# ============================================================
# parent_dashboard.py
# Parent-facing API for monitoring child's social activity
# Children never see this --- it's accessed via parent's app
# ============================================================

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import List, Optional, Dict
from enum import Enum

class SafetyLevel(Enum):
    GREEN = "green"      # No concerns
    YELLOW = "yellow"    # Minor flags, review recommended
    RED = "red"          # Serious concern, immediate review

@dataclass
class SessionReport:
    session_id: str
    date: datetime
    duration_seconds: int
    game_title: str
    peer_count: int
    communication_used: bool
    safety_flags: List[str]
    screenshots: List[str]  # Auto-captured at key moments

@dataclass
class PeerSummary:
    anonymized_id: str
    first_encounter: datetime
    session_count: int
    communication_frequency: int
    blocked: bool

class ParentDashboard:
    """
    Provides parents with visibility into their child's online gaming activity.
    All data is anonymized --- parents see activity patterns, not personal data
    of other children.
    """
    
    def __init__(self, safety_db, session_store):
        self.safety_db = safety_db
        self.session_store = session_store
    
    def get_activity_summary(self, child_account_id: str, 
                            days: int = 7) -> Dict:
        """
        Get a summary of child's gaming activity for the past N days.
        Called when parent opens the dashboard.
        """
        since = datetime.now() - timedelta(days=days)
        sessions = self.session_store.get_sessions_for_account(
            child_account_id, since
        )
        
        total_play_time = sum(s.duration_seconds for s in sessions)
        unique_peers = len(set(
            peer for s in sessions for peer in s.peer_ids
        ))
        
        # Calculate safety score
        safety_score = self._calculate_safety_score(sessions)
        
        return {
            "period_days": days,
            "total_sessions": len(sessions),
            "total_play_time_minutes": total_play_time // 60,
            "unique_peers_encountered": unique_peers,
            "average_session_length": total_play_time // max(len(sessions), 1),
            "safety_level": safety_score.value,
            "safety_recommendations": self._get_safety_recommendations(
                sessions, safety_score
            ),
            "recent_sessions": [
                self._format_session_report(s) for s in sessions[-5:]
            ]
        }
    
    def get_communication_log(self, child_account_id: str,
                              days: int = 7) -> List[Dict]:
        """
        Get all communication (cheers) exchanged by the child.
        Parents can review what messages were sent/received.
        """
        since = datetime.now() - timedelta(days=days)
        communications = self.safety_db.get_communications(
            child_account_id, since
        )
        
        return [
            {
                "timestamp": comm.timestamp.isoformat(),
                "direction": comm.direction,  # "sent" or "received"
                "message": comm.message,  # One of the pre-defined cheers
                "session_id": comm.session_id,
                "anonymized_peer": comm.peer_hash[:8] + "..."
            }
            for comm in communications
        ]
    
    def set_safety_level(self, child_account_id: str, 
                        level: SafetyLevel) -> Dict:
        """
        Parent sets the safety level for their child.
        This controls what social features are available.
        
        GREEN: Full social features (co-op, sharing, cheers)
        YELLOW: Limited --- co-op with approved friends only
        RED: No social features --- single player only
        """
        self.safety_db.set_child_safety_level(child_account_id, level)
        
        return {
            "safety_level": level.value,
            "allowed_features": self._get_allowed_features(level),
            "effective_immediately": True
        }
    
    def approve_friend(self, child_account_id: str, 
                      friend_code: str) -> bool:
        """
        Parent pre-approves a friend for their child to play with.
        Friend codes are anonymous --- parents don't see personal info.
        """
        self.safety_db.add_approved_friend(child_account_id, friend_code)
        return True
    
    def block_peer(self, child_account_id: str, 
                  session_id: str, peer_hash: str) -> bool:
        """
        Parent blocks a specific peer from interacting with their child.
        This is irreversible without contacting support.
        """
        self.safety_db.block_peer(child_account_id, peer_hash)
        
        # Immediately terminate any active session with this peer
        self.session_store.terminate_sessions_with_peer(
            child_account_id, peer_hash
        )
        
        return True
    
    def _calculate_safety_score(self, sessions: List[SessionReport]) -> SafetyLevel:
        """Calculate overall safety level based on activity patterns."""
        if not sessions:
            return SafetyLevel.GREEN
        
        total_flags = sum(len(s.safety_flags) for s in sessions)
        
        if total_flags >= 5:
            return SafetyLevel.RED
        elif total_flags >= 2:
            return SafetyLevel.YELLOW
        return SafetyLevel.GREEN
    
    def _get_safety_recommendations(self, sessions: List[SessionReport],
                                    score: SafetyLevel) -> List[str]:
        """Generate parent-friendly safety recommendations."""
        recommendations = []
        
        if score == SafetyLevel.RED:
            recommendations.append(
                "Multiple safety flags detected. Consider setting "
                "safety level to RED (single player only) until reviewed."
            )
        
        if score == SafetyLevel.YELLOW:
            recommendations.append(
                "Some unusual activity detected. Review the communication "
                "log and consider limiting co-op to approved friends only."
            )
        
        # Check for late-night gaming
        late_sessions = [
            s for s in sessions 
            if s.date.hour >= 21 or s.date.hour <= 6
        ]
        if late_sessions:
            recommendations.append(
                f"{len(late_sessions)} sessions occurred during late hours. "
                "Consider setting play time limits."
            )
        
        return recommendations
    
    def _get_allowed_features(self, level: SafetyLevel) -> List[str]:
        """Return list of allowed features for each safety level."""
        features = {
            SafetyLevel.GREEN: [
                "single_player",
                "co_op_random",
                "co_op_friends",
                "share_levels",
                "cheer_messages",
                "community_gallery"
            ],
            SafetyLevel.YELLOW: [
                "single_player",
                "co_op_friends",  # Approved friends only
                "share_levels",
                "cheer_messages"
                # No random co-op, no community gallery
            ],
            SafetyLevel.RED: [
                "single_player"
                # No social features at all
            ]
        }
        return features.get(level, features[SafetyLevel.RED])
    
    def _format_session_report(self, session: SessionReport) -> Dict:
        """Format a session for parent-friendly display."""
        return {
            "date": session.date.isoformat(),
            "duration_minutes": session.duration_seconds // 60,
            "game": session.game_title,
            "players": session.peer_count + 1,
            "safety_flags": len(session.safety_flags),
            "had_communication": session.communication_used
        }
```

---

## The "Social Stamp" Taxonomy

### Core Social Stamps

```
SOCIAL_STAMPS/
|-- CO_OP/
|   |-- Co-op Portal Stamp      [P0] - Enables multiplayer, generates share code
|   |-- Bubble Rescue Stamp     [P0] - Bubble respawn for failed players
|   |-- Gentle Mode Stamp       [P0] - No friendly fire (default: ON)
|   |-- Tag Team Stamp          [P1] - Two-character switching like DKC
|   |-- Dream Friend Stamp      [P2] - Special companion with unique powers
|
|-- COMPANION/
|   |-- Buddy Stamp             [P0] - AI companion (choose type)
|   |   |-- Speedy Pet          [P1] - Fast, follows closely
|   |   |-- Strong Robot        [P1] - Slow, powerful attacks
|   |   |-- Helpful Fairy       [P1] - Floaty, can reach anywhere
|   |-- Posse Stamp             [P2] - Multiple AI companions
|   |-- Helper Heart Stamp      [P2] - Turn enemies into friends (Kirby-style)
|
|-- SHARING/
|   |-- Share Button Stamp      [P1] - Generate code to share level
|   |-- Ghost Race Stamp        [P1] - Record run, challenge friends
|   |-- Community Gallery Stamp [P2] - Browse popular levels
|
|-- COMMUNICATION/
|   |-- Cheer Stamp             [P1] - Pre-defined positive messages
|   |   |-- "Great job!"
|   |   |-- "Nice work!"
|   |   |-- "Need help?"
|   |   |-- "Over here!"
|   |   |-- "Thank you!"
|   |   |-- "You can do it!"
|   |   |-- "Teamwork!"
|   |   |-- "Awesome!"
|   |   |-- "Wait for me!"
|   |   |-- "Follow me!"
|
|-- SAFETY/
    |-- Family Lock Stamp        [P1] - Parent-configured safety level
    |-- Content Filter Stamp     [P2] - LLM auto-moderation toggle
```

### Stamp Interaction Matrix

| Stamp | Works With | Conflicts With | LLM-Generated Behavior |
|-------|-----------|---------------|----------------------|
| Co-op Portal | Bubble Rescue, Buddy, Cheer | (none) | Auto-generates session, manages player slots |
| Bubble Rescue | Co-op Portal, Buddy | (none) | Auto-places safe zones, manages bubble state |
| Buddy | Bubble Rescue, Co-op Portal | Tag Team | Generates companion AI with configured behavior |
| Tag Team | Co-op Portal | Buddy | Enables two-character switching with unique abilities |
| Gentle Mode | Co-op Portal, Tag Team | (none) | Disables player-player collision and damage |
| Cheer | Co-op Portal | (none) | Validates pre-defined messages, logs for safety |
| Share Button | (all level content) | (none) | Generates short code, auto-moderates content |

---

## Edge Cases & Mitigations

### 1. Griefing Prevention

**Risk:** Even without free text chat, children can grief by repeatedly bubbling themselves, refusing to rescue others, or intentionally getting in the way.

**Mitigations:**
- **Gentle Mode** is ON by default --- players can't push each other or cause harm [^335^]
- **Voluntary bubbling** has a cooldown timer (can't spam it)
- **Auto-rescue timeout**: After 10 seconds in a bubble, it auto-pops
- **Buddy AI** auto-prioritizes bubble rescue, so a human player ignoring a bubbled friend gets assistance
- **No inventory stealing**: Unlike *Castle Crashers*, there's no competitive loot system that creates conflict
- **Report system**: Parents can review session logs and block problematic peers

### 2. Network Lag & Disconnection

**Risk:** Children have limited patience for network issues. A dropped connection can ruin the experience.

**Mitigations:**
- **Auto-rejoin grace period**: Disconnected players have 20 seconds to reconnect without losing their slot [^417^]
- **Buddy AI takeover**: If a human player disconnects, their character becomes AI-controlled (no interruption)
- **Local snapshot**: Game state is cached locally so brief disconnections are invisible
- **Room persistence**: Empty rooms stay alive for 60 seconds (configurable via RoomTTL) [^417^]
- **Visual feedback**: "Reconnecting..." with a fun animation (not an error message)

### 3. Online Safety & COPPA Compliance

**Risk:** Collecting any data from children under 13 without parental consent violates COPPA ($50,120 per violation) [^307^].

**Mitigations:**
- **Zero-data by default**: No personal information collected. Session codes are random and temporary [^302^]
- **Anonymous sessions**: Player IDs are one-way hashed. No usernames, no profiles
- **Parental approval gate**: COPPA-compliant consent flow managed by LLM backend [^302^]
- **No free communication**: Only pre-defined "cheers" --- no text input at all [^371^]
- **No external links**: Platform is a closed system
- **Auto-moderation**: LLM scans all shared content before it becomes public
- **Parent dashboard**: Full visibility into activity, ability to block peers, set safety levels

### 4. Mixed Skill Levels

**Risk:** When a skilled player plays with a beginner, the beginner gets frustrated or feels left behind.

**Mitigations:**
- **Voluntary bubbling**: Less skilled players can bubble through hard sections [^337^]
- **Buddy AI assistance**: AI companion helps struggling players automatically
- **Gentle Mode**: No way for skilled players to accidentally harm beginners
- **Shared victory**: All players win together --- no individual rankings
- **Dynamic difficulty**: LLM subtly adjusts enemy count/speed based on weakest player's performance
- **Cheer system**: Skilled players can send encouragement, not taunts

### 5. Content Moderation

**Risk:** Children might create and share inappropriate content.

**Mitigations:**
- **LLM pre-moderation**: All shared canvases are scanned by the LLM before being accessible
- **Stamp-only creation**: Since children only place pre-made stamps (not draw freehand), content is inherently limited
- **No image uploads**: Unlike *Little Big Planet*'s sticker system [^360^], no external images can be imported
- **Report system**: Parents can report concerning content
- **Community gallery curation**: Only LLM-approved levels appear in public gallery

### 6. Session Hijacking

**Risk:** A malicious actor guesses a session code and joins a child's game.

**Mitigations:**
- **Short-lived codes**: 4-digit codes expire when the session ends
- **Player limit**: Max 4 players --- hard to hide in a small group
- **No random matchmaking**: Codes are shared privately, not listed publicly
- **Parent approval**: YELLOW safety level restricts co-op to pre-approved friends only
- **Instant kick**: Host (or parent via dashboard) can remove any player immediately
- **No persistent rooms**: Sessions don't exist beyond the play session

### 7. Accidental Data Exposure

**Risk:** The platform might inadvertently collect IP addresses, device IDs, or other identifiers that qualify as personal information under COPPA.

**Mitigations:**
- **IP anonymization**: IP addresses are hashed and discarded after session
- **No cookies or tracking**: Zero persistent identifiers [^302^]
- **No analytics on children**: All usage data is aggregated and anonymized
- **Data minimization**: Only collect what's technically necessary for the session to function
- **Session isolation**: Each session is independent with no cross-session tracking

---

## Sources

1. **Iwata Asks: New Super Mario Bros. Wii** - Nintendo's official developer interview on the bubble system. [^337^] https://iwataasks.nintendo.com/interviews/wii/nsmb/2/0/

2. **Studying Castle Crashers' Multiplayer Design** - KokuTech analysis of co-opetition mechanics. [^335^] https://www.kokutech.com/blog/gamedev/design-patterns/social-interaction/castle-crashers

3. **Design Lesson 101: Castle Crashers** - Game Developer postmortem on networking issues. [^343^] https://www.gamedeveloper.com/design/design-lesson-101---i-castle-crashers-i-

4. **River City Ransom Wikipedia** - Co-op mechanics and GBA AI companion system. [^341^] https://en.wikipedia.org/wiki/River_City_Ransom

5. **Bubble - Mario Wiki** - Technical details of bubble mechanics across Mario games. [^308^] https://mario.fandom.com/wiki/Bubble

6. **Bubble | Super Mario Maker 2 Wiki** - Multiplayer bubble behavior in SMM2. [^334^] https://super-mario-maker-2-wiki.fandom.com/wiki/Bubble

7. **Design Mostly Right: Co-Op In New Super Mario Bros. Wii** - Co-Optimus review analysis. [^309^] https://arcengames.com/design-mostly-right-co-op-in-new-super-mario-bros-wii/

8. **New Super Mario Bros. Wii Review** - Nintendo World Report multiplayer analysis. [^310^] http://www.nintendoworldreport.com/review/20368/new-super-mario-bros-wii-wii

9. **Legal Requirements for Children's Gaming Apps** - COPPA and GDPR compliance guide. [^302^] https://www.termsfeed.com/blog/childrens-gaming-apps-legal-requirements/

10. **Parental controls and COPPA compliance** - Xsolla regulatory analysis. [^303^] https://xsolla.com/blog/parental-controls-and-coppa-compliance-safeguarding-childrens-privacy-in-the-gaming-industry

11. **Complying with COPPA: Frequently Asked Questions** - Official FTC guidance. [^305^] https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions

12. **What is COPPA and how does it affect my game company?** - Legal overview for game developers. [^306^] https://odinlaw.com/what-is-coppa-and-how-does-it-affect-my-game-company/

13. **Appropriate Gameplay under COPPA and GDPR** - Academic paper on compliance-driven game design. [^304^] http://ijses.com/wp-content/uploads/2025/09/62-IJSES-V9N9.pdf

14. **How did Tails's AI work in Sonic 2 and 3?** - Reddit technical analysis. [^375^] https://www.reddit.com/r/howdidtheycodeit/comments/eliruc/how_did_tailss_ai_work_in_sonic_2_and_3/

15. **Trouble with Tails's AI | SRB2 Message Board** - Community feedback on AI reliability issues. [^377^] https://mb.srb2.org/threads/trouble-with-tailss-ai.46370/

16. **Donkey Kong Country Wikipedia** - Tag-team co-op mechanics. [^383^] https://en.wikipedia.org/wiki/Donkey_Kong_Country

17. **Donkey Kong Country Wiki - Gameplay** - Detailed co-op and tag-team analysis. [^381^] https://donkeykong.fandom.com/wiki/Donkey_Kong_Country

18. **Kirby Star Allies Wiki** - Helper system and Friend Heart mechanics. [^419^] https://kirby.fandom.com/wiki/Kirby_Star_Allies

19. **Kirby Star Allies Review** - Gameplay analysis of the friend system. [^421^] https://www.analogstickgaming.com/game-reviews/2018/4/9/kirby-star-allies-tezxn

20. **LittleBigPlanet Gameplay & Development** - User-generated content sharing system. [^360^] https://littlebigplanet.fandom.com/wiki/LittleBigPlanet/Gameplay_%26_Development

21. **Epic Introduces Fall Guys Creative Mode** - Level sharing with unique codes. [^425^] https://tracker.gg/checkpoint/articles/epic-introduces-fall-guys-creative-mode-allowing-players-design-levels

22. **How Do I Play with Others in Fall Guys Creative?** - Share code system documentation. [^416^] https://www.epicgames.com/help/c-202300000001638/c-Trending_0/how-do-i-play-with-others-in-fall-guys-creative-a202300000016229

23. **Quantum 3 - Reconnecting** - Photon reconnection system technical documentation. [^417^] https://doc.photonengine.com/quantum/current/manual/game-session/reconnecting

24. **AI Companion Tutorial in Unity** - Companion AI implementation with NavMesh. [^361^] https://medium.com/@IAMFANTASYSTORYTELLER/ai-companion-tutorial-in-unity-3d-mobile-game-2026-create-a-smart-follower-that-helps-the-b8aa626dadab

25. **2D Platformer - Sidekick / Helper / Follower / Companion** - Unity forums position-recording approach. [^363^] https://discussions.unity.com/t/2d-platformer-sidekick-helper-follower-companion/159241

26. **Creating a Companion AI | Emerald AI Wiki** - Companion AI technical documentation. [^336^] https://black-horizon-studios.gitbook.io/emerald-ai-wiki/emerald-components-required/behaviors-component/creating-a-companion-ai

27. **Online games - NSPCC** - Child safety in online gaming. [^364^] https://www.nspcc.org.uk/keeping-children-safe/online-safety/online-games/

28. **Protecting Children in Online Gaming: Mitigating Risks** - UNICEF report on child safety. [^365^] https://www.unicef.org/innocenti/media/11836/file/UNICEF-Innocenti-Protecting-Children-Online-Gaming-Working-Paper-2025.pdf

29. **Is Among Us safe for children?** - Internet Matters safety guide. [^371^] https://www.internetmatters.org/advice/apps-and-platforms/online-gaming/among-us/

30. **Roblox parental controls guide** - Internet Matters parental control documentation. [^370^] https://www.internetmatters.org/parental-controls/gaming-consoles/roblox-parental-controls/

31. **Use Parental Controls to Keep Your Child Safe** - NSPCC parental controls overview. [^366^] https://www.nspcc.org.uk/keeping-children-safe/online-safety/parental-controls/

32. **How game developers can use privacy-by-design** - TIGA regulatory guidance. [^392^] https://tiga.org/news/how-game-developers-can-use-privacy-by-design-to-conform-with-the-childrens-code

33. **Mario Kart Time Trial Wiki** - Ghost race mechanics. [^338^] https://mariokart.fandom.com/wiki/Time_Trial

34. **Designing Games for Every Skill Level** - Digital Thriving Playbook. [^427^] https://digitalthrivingplaybook.org/method/designing-games-for-every-skill-level/

35. **Game design patterns for building friendships** - Game Developer social design patterns. [^430^] https://www.gamedeveloper.com/design/game-design-patterns-for-building-friendships

36. **How do I Make a Tag-Team Mechanic Like in Donkey Kong Country?** - GDevelop implementation tutorial. [^426^] https://forum.gdevelop.io/t/how-do-i-make-a-tag-team-mechanic-like-in-donkey-kong-country/39641

37. **Safeguarding Kids in Online Gaming Worlds** - Age-appropriate communication guidelines. [^415^] https://www.victimscivilattorneys.com/blog/safeguarding-kids-in-online-gaming-worlds/

38. **COPPA Compliance for Businesses Serving Children Online** - Accessibility Assistant compliance guide. [^307^] https://accessibilityassistant.com/compliance/coppa-compliance-for-businesses-serving-children-online/

39. **Bloxels is the Best STEAM Software for Kids** - Zero-code child game creation. [^423^] https://andrewwalpole.com/blog/bloxels-is-the-best-steam-software-for-kids/

40. **Game Design: No Child's Play** - Academic thesis on child rights in game design. [^369^] https://defenceforchildren.nl/media/6897/msc-thesis-game-design_k-schuurman-utrecht-university-2023.pdf
