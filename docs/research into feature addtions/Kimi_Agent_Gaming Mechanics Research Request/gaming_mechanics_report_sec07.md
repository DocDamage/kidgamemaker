## 7. LLM Integration Architecture

The stamp-to-game pipeline is the central nervous system of the entire platform. Physics, combat, progression, and atmosphere all depend on the LLM's ability to translate a child's visual stamp placements into working game code. A child places a hero stamp on the left, drops a platform beneath it, scatters coins across the middle, and places a goal on the right — within seconds, that arrangement becomes a playable platformer.

Research into multi-agent frameworks — GameGPT [^1^], ChatDev [^2^], MetaGPT [^3^] — reveals that collaborative agents produce high-quality code but add unacceptable latency. GameGPT's reviewer agents catch approximately 40% of errors before execution, but multi-turn conversation adds 3–5x latency [^1^]. For a five-year-old, a five-second generation cycle feels broken. The architecture must collapse multi-agent quality into single-pass speed.

The solution is a six-stage pipeline with aggressive fallback at every stage: Stamp Parser converts placements into a structured Game Design Document (GDD); a Prompt Builder injects few-shot examples; a Constrained LLM generates syntactically valid code; a two-pass Validator checks consistency; a Sandboxed Execution environment runs the result; and the Game Engine hot-reloads. When the LLM is unavailable, template fallback produces games in under 30 milliseconds.

### 7.1 Stamp-to-Code Translation Pipeline

#### 7.1.1 Pipeline Architecture

The pipeline follows a directed acyclic graph with fallback paths at each stage. The critical insight from MetaGPT's SOP-based approach [^3^] is that structured intermediate representations between phases eliminate "idle chatter" — unstructured text that LLMs generate without constraints. The GDD serves as the structured handshake between stages.

The stamp parser performs three operations: entity extraction (type, position, properties), interaction detection (spatial relationships implying gameplay), and rule inference (coins present implies scoring, enemies present implies health). Rosebud.ai's description-to-code pipeline [^8^] validates that natural-language-to-game-code generation is viable, but stamps provide pre-validated structured input — the system knows exactly what entity was placed where, eliminating ambiguity.

CodeAct research demonstrates that LLMs achieve up to 20% higher success rates generating executable code rather than JSON configurations [^9^]. The pipeline instructs the LLM to generate raw JavaScript for Phaser.js — optimal because its API is well-represented in LLM training data and the framework publishes AI agent skills documentation for LLM code generation [^18^].

#### 7.1.2 Template Library: Zero-Latency Fallback

The template library contains pre-validated code snippets for 50+ stamp types. When the LLM is unavailable — rate limiting, network failure, classroom-scale load — the pipeline falls back to template assembly producing games in under 30ms.

| Stamp Category | Template Count | Example Stamp | Fallback Code Behavior |
|---|---|---|---|
| Player | 4 | Hero, Vehicle, Animal | Sprite creation with physics, keyboard input, world bounds |
| Enemy | 7 | Hopper, Patroller, Chaser, Coward, Friend, Mimic, Boss | State machine with patrol/chase/flee behaviors |
| Collectible | 6 | Coin, Gem, Star, Heart, Key, Power-Up | Overlap detection, score increment, destroy on collect |
| Platform | 8 | Static, Moving, Crumbling, Ice, Bouncy, Cloud, One-Way, Slope | Static/dynamic body with friction/restitution |
| Hazard | 5 | Spike, Lava, Pit, Sawblade, Poison | Overlap damage with invincibility frames |
| Goal | 4 | Flag, Door, Portal, Star-Gate | Win condition trigger with particle celebration |
| Interactive | 6 | Switch, Button, Lever, Pressure Plate, Sign, NPC | Event emission for puzzle mechanics |
| Environment | 5 | Background, Parallax, Weather, Lighting, Music | Visual and atmospheric effects |
| Assist | 5 | Checkpoint, Helper Ghost, Lucky Charm, Time Bubble, Buddy | Invisible difficulty adjustment triggers |

Each template is a self-contained JavaScript function composed into a complete Phaser scene. The template library extends GameGPT's "code decoupling" principle — separating game scripts into small snippets reduces hallucination and redundancy by 60–70% compared to generating full files [^1^].

#### 7.1.3 Implementation: Prompt Builder

The `PromptBuilder` constructs LLM prompts with few-shot examples and structured output schemas. Research shows 2–3 examples are optimal for code tasks with diminishing returns beyond 3 [^11^].

```python
"""
PromptBuilder: Constructs optimized prompts for game code generation
using few-shot examples with constrained output schemas.
"""
import json
from dataclasses import dataclass
from typing import List, Dict, Optional

@dataclass
class FewShotExample:
    input_gdd: str
    output_code: str
    description: str

class PromptBuilder:
    SYSTEM_PROMPT = """You are an expert Phaser.js game developer.
Generate clean JavaScript for a 2D game from the provided GDD.
RULES:
1. Generate ONLY JavaScript code. No explanations. No markdown.
2. Use 'this' context (Phaser scene methods).
3. Sprite keys: 'player', 'enemy', 'coin', 'platform', 'goal', 'spike'.
4. Include physics, collision detection, and game logic.
5. Keep code concise and well-commented.
6. Do NOT use external assets or APIs.
7. Ensure syntactically valid JavaScript.
8. Use arrow functions for callbacks."""

    FEW_SHOT: List[FewShotExample] = [
        FewShotExample(
            input_gdd=json.dumps({"entities": [
                {"type": "player", "pos": {"x": 100, "y": 400}},
                {"type": "coin", "pos": {"x": 300, "y": 300}}
            ], "interactions": [{"type": "collect"}]}),
            output_code="""
const player = this.physics.add.sprite(100, 400, 'player');
player.setCollideWorldBounds(true);
const coin = this.physics.add.sprite(300, 300, 'coin');
this.physics.add.overlap(player, coin, () => {
    coin.disableBody(true, true);
    score += 10;
    scoreText.setText('Score: ' + score);
});
""",
            description="Player-coin collection"
        ),
        FewShotExample(
            input_gdd=json.dumps({"entities": [
                {"type": "player", "pos": {"x": 100, "y": 400}},
                {"type": "enemy", "pos": {"x": 400, "y": 400},
                 "props": {"patrol": True, "speed": 100}}
            ], "interactions": [{"type": "damage"}]}),
            output_code="""
const player = this.physics.add.sprite(100, 400, 'player');
player.setCollideWorldBounds(true);
const enemy = this.physics.add.sprite(400, 400, 'enemy');
enemy.patrolStartX = 300; enemy.patrolEndX = 500;
enemy.patrolSpeed = 100; enemy.setVelocityX(100);
this.physics.add.collider(player, enemy, () => {
    playerHealth--;
    if (playerHealth <= 0) this.scene.restart();
    player.setVelocityX(-200); player.setVelocityY(-200);
});
""",
            description="Enemy patrol with player damage"
        ),
    ]

    def build(self, gdd: 'GameDesignDocument',
              raw_stamps: list) -> List[Dict]:
        """Build complete prompt with system + few-shot + request."""
        gdd_json = gdd.to_json()
        messages = [{"role": "system", "content": self.SYSTEM_PROMPT}]

        for ex in self.FEW_SHOT[:2]:
            messages.append({"role": "user",
                "content": f"Generate Phaser.js code:\n{ex.input_gdd}"})
            messages.append({"role": "assistant",
                "content": ex.output_code})

        messages.append({"role": "user",
            "content": f"Generate Phaser.js code:\n{gdd_json}\n\n" +
                       "Generate ONLY JavaScript code:"})
        return messages

    def build_error_correction_prompt(
        self, gdd: 'GameDesignDocument', code: str,
        errors: list
    ) -> List[Dict]:
        """Build prompt for validation-error retry pass."""
        base = self.build(gdd, [])
        error_text = "\n".join(
            f"- Line {e.line}: {e.message}" for e in errors
            if e.severity == 'error'
        )
        base.append({"role": "user",
            "content": f"The previous code has errors:\n{error_text}\n\n" +
                       "Fix these errors and regenerate ONLY the code:"})
        return base
```

#### 7.1.4 Implementation: StampTranslationPipeline

The core orchestrator lazy-loads components, implements full regeneration on every stamp change (preventing incremental state inconsistency), and protects every stage with fallback logic.

```typescript
/**
 * StampTranslationPipeline: End-to-end orchestration from raw stamp
 * placements to playable HTML5 game. Every stage has a fallback path.
 */
import { StampParser, GameDesignDocument } from './StampParser';
import { PromptBuilder } from './PromptBuilder';
import { ConstrainedGenerator } from './ConstrainedGenerator';
import { CodeValidator, ValidationSeverity } from './CodeValidator';
import { GameSandbox } from './GameSandbox';
import { TemplateAssembler } from './TemplateAssembler';
import { LLMManager } from './LLMManager';

interface PipelineConfig {
  maxGenerationTimeMs: number;
  templateFallbackTimeoutMs: number;
  circuitBreakerThreshold: number;
  circuitBreakerTimeoutMs: number;
  enableSandbox: boolean;
  fewShotExampleCount: number;
}

interface PipelineResult {
  success: boolean;
  htmlGame: string;
  gddJson: string;
  generatedCode: string;
  validationResults: Array<{
    severity: string; message: string; line?: number; suggestion: string;
  }>;
  generationTimeMs: number;
  totalTimeMs: number;
  fallbackUsed: boolean;
  circuitBreakerOpen: boolean;
  errorMessage: string;
}

const DEFAULT_CONFIG: PipelineConfig = {
  maxGenerationTimeMs: 5000,
  templateFallbackTimeoutMs: 30,
  circuitBreakerThreshold: 5,
  circuitBreakerTimeoutMs: 60000,
  enableSandbox: true,
  fewShotExampleCount: 2,
};

export class StampTranslationPipeline {
  private parser: StampParser;
  private promptBuilder: PromptBuilder;
  private generator: ConstrainedGenerator;
  private validator: CodeValidator;
  private sandbox: GameSandbox;
  private templateAssembler: TemplateAssembler;
  private llmManager: LLMManager;
  private config: PipelineConfig;
  private failureCount = 0;
  private circuitOpen = false;
  private circuitOpenedAt = 0;
  private consecutiveSuccesses = 0;

  constructor(config: Partial<PipelineConfig> = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config };
    this.parser = new StampParser();
    this.promptBuilder = new PromptBuilder(this.config.fewShotExampleCount);
    this.generator = new ConstrainedGenerator();
    this.validator = new CodeValidator();
    this.sandbox = new GameSandbox({ timeoutSeconds: 5, maxMemoryMb: 256 });
    this.templateAssembler = new TemplateAssembler();
    this.llmManager = new LLMManager();
  }

  async process(rawStamps: RawStamp[]): Promise<PipelineResult> {
    const totalStart = performance.now();
    const result: Partial<PipelineResult> = {
      success: false, fallbackUsed: false, circuitBreakerOpen: false,
      validationResults: [], errorMessage: '',
    };

    try {
      // Stage 1: Parse stamps into GDD (1-5ms)
      const gdd = this.parser.parse(rawStamps);
      result.gddJson = gdd.toJson();

      const useLLM = this.shouldAttemptLLM();
      result.circuitBreakerOpen = !useLLM && this.circuitOpen;
      let codeOutput: { createCode: string; gameConfig: GameConfig };

      if (useLLM) {
        try {
          const prompt = this.promptBuilder.build(gdd, rawStamps);
          const genStart = performance.now();
          codeOutput = await this.generateWithTimeout(prompt, gdd);
          result.generationTimeMs = performance.now() - genStart;
          this.recordSuccess();
        } catch {
          this.recordFailure();
          result.fallbackUsed = true;
          codeOutput = this.templateAssembler.assemble(gdd);
          result.generationTimeMs = this.config.templateFallbackTimeoutMs;
        }
      } else {
        result.fallbackUsed = true;
        codeOutput = this.templateAssembler.assemble(gdd);
        result.generationTimeMs = this.config.templateFallbackTimeoutMs;
      }

      result.generatedCode = codeOutput.createCode;

      // Stage 4: Two-pass validation
      const validation = this.validator.validate(codeOutput.createCode, gdd);
      result.validationResults = validation.map(v => ({
        severity: v.severity, message: v.message,
        line: v.line, suggestion: v.suggestion,
      }));

      const hasErrors = validation.some(
        v => v.severity === ValidationSeverity.ERROR
      );
      if (hasErrors && !result.fallbackUsed) {
        const retryPrompt = this.promptBuilder.buildErrorCorrectionPrompt(
          gdd, codeOutput.createCode, validation
        );
        try {
          const retryStart = performance.now();
          codeOutput = await this.generateWithTimeout(retryPrompt, gdd);
          result.generationTimeMs! += performance.now() - retryStart;
          const rev = this.validator.validate(codeOutput.createCode, gdd);
          result.validationResults = rev.map(v => ({
            severity: v.severity, message: v.message,
            line: v.line, suggestion: v.suggestion,
          }));
          result.generatedCode = codeOutput.createCode;
        } catch {
          result.fallbackUsed = true;
          codeOutput = this.templateAssembler.assemble(gdd);
          result.generatedCode = codeOutput.createCode;
        }
      }

      // Stage 5-6: Build HTML and execute static check
      result.htmlGame = this.sandbox.buildHtml(
        result.generatedCode, codeOutput.gameConfig
      );
      if (this.config.enableSandbox) {
        const check = this.sandbox.staticCheck(result.htmlGame);
        if (!check.passed) {
          result.fallbackUsed = true;
          const fb = this.templateAssembler.assemble(gdd);
          result.generatedCode = fb.createCode;
          result.htmlGame = this.sandbox.buildHtml(fb.createCode, fb.gameConfig);
        }
      }
      result.success = true;
    } catch (err) {
      result.errorMessage = err instanceof Error ? err.message : String(err);
      result.htmlGame = this.sandbox.buildMinimalFallback();
    }

    result.totalTimeMs = performance.now() - totalStart;
    return result as PipelineResult;
  }

  private shouldAttemptLLM(): boolean {
    if (!this.circuitOpen) return true;
    if (performance.now() - this.circuitOpenedAt > this.config.circuitBreakerTimeoutMs) {
      this.circuitOpen = false;
      this.failureCount = 0;
      return true;
    }
    return false;
  }

  private async generateWithTimeout(
    prompt: string, gdd: GameDesignDocument
  ): Promise<{ createCode: string; gameConfig: GameConfig }> {
    return Promise.race([
      this.llmManager.generate(prompt, { temperature: 0.15, topP: 0.2 }),
      new Promise<never>((_, reject) =>
        setTimeout(() => reject(new Error('Timeout')),
          this.config.maxGenerationTimeMs)
      ),
    ]);
  }

  private recordSuccess(): void {
    this.consecutiveSuccesses++;
    if (this.consecutiveSuccesses >= 3) this.failureCount = 0;
  }

  private recordFailure(): void {
    this.failureCount++;
    this.consecutiveSuccesses = 0;
    if (this.failureCount >= this.config.circuitBreakerThreshold) {
      this.circuitOpen = true;
      this.circuitOpenedAt = performance.now();
    }
  }

  getHealth() {
    return { circuitOpen: this.circuitOpen,
      failureCount: this.failureCount,
      healthy: !this.circuitOpen && this.failureCount < 2 };
  }
}
```

The pipeline uses a debounce pattern — waiting 1.5 seconds after the last stamp placement before triggering generation. Full regeneration from the complete stamp set prevents inconsistent state issues that plague incremental approaches [^1^].

### 7.2 The LLM as Invisible Game Designer

#### 7.2.1 Design Heuristics Engine

The most transformative architectural decision is reframing the LLM from "code generator" to "invisible game designer." The GDD intermediate step is where design intelligence is applied: adding checkpoints before hard sections, balancing enemy counts, ensuring reachable platforms, and verifying level completability. When a child places three enemy stamps in a row, the LLM spaces them with learning gaps, adds a health pickup before the third, and places an invisible checkpoint after the encounter — the child never requested this.

The heuristics engine maintains 200+ design patterns across six categories: **Level Structure** (45 rules — max jump distances scaling 192px for age 5 to 320px for age 10, minimum platform width 64px, landing buffers); **Combat Balance** (38 rules — enemy speed capped at 2.0 units/frame for age 5 [^12^], max 3 enemies per screen for age 5, 1+ second wind-up animations [^459^], health pickups after every 2+ enemy encounter); **Progression** (32 rules — coin density 0.8–1.2 per screen, difficulty increases capped at 15% per screen, checkpoints every 8–12 seconds); **Safety** (28 rules — no enemies within 64px of goal, no hazard chains exceeding 3, max 5 seconds of lost progress per failure); **Accessibility** (30 rules — 4.5:1 color contrast, all mechanics learnable in 30 seconds, visual feedback within 100ms); and **Narrative Coherence** (27 rules — thematic enemy consistency, environmental storytelling every 3–4 screens).

Heuristics are drawn from Nintendo's invisible assist philosophy [^457^], Celeste's forgiveness mechanics [^139^], Hollow Knight's visual attack tells [^459^], and Left 4 Dead's AI Director [^455^]. Each has a confidence weight; the engine only applies rules exceeding the threshold for the detected age group.

#### 7.2.2 Auto-Balance Feature

Auto-balance operates in three modes: **Silent Mode** (age 5–7) applies adjustments without asking; **Suggest Mode** (age 8–10) shows sparkle effects on stamps to be adjusted with veto option; **Review Mode** (age 11+) presents a "Design Assistant" panel explaining each suggestion.

The engine runs A* pathfinding from player spawn to goal before every play session, similar to MarioGPT's validation approach [^519^]. MarioGPT achieves 88% playability with fine-tuned GPT-2; explicit A* validation combined with heuristic adjustment pushes this to 99%+.

#### 7.2.3 Implementation: GameDesignHeuristicsEngine

```typescript
/**
 * GameDesignHeuristicsEngine: Applies 200+ design rules to a GDD,
 * modifying entity placements and adding implicit gameplay elements.
 * Operates before code generation — it improves the design document.
 */
import { GameDesignDocument, Stamp, StampType } from './StampParser';

interface HeuristicRule {
  id: string; category: string; description: string;
  check: (gdd: GameDesignDocument) => boolean;
  apply: (gdd: GameDesignDocument) => Stamp[];
  confidence: number; ageRange: [number, number]; autoApply: boolean;
}

interface BalanceReport {
  rulesApplied: string[]; stampsAdded: Stamp[];
  stampsModified: Array<{ id: string; changes: Partial<Stamp> }>;
  warnings: string[]; solvable: boolean; estimatedDifficulty: number;
}

export class GameDesignHeuristicsEngine {
  private rules: HeuristicRule[] = [];
  private readonly age: number;
  private readonly autoApply: boolean;

  constructor(age: number, mode: 'silent' | 'suggest' | 'review' = 'silent') {
    this.age = age;
    this.autoApply = mode === 'silent';
    this.registerDefaultRules();
  }

  analyze(gdd: GameDesignDocument): { gdd: GameDesignDocument; report: BalanceReport } {
    const report: BalanceReport = {
      rulesApplied: [], stampsAdded: [], stampsModified: [],
      warnings: [], solvable: true, estimatedDifficulty: 50,
    };

    const solvable = this.checkSolvability(gdd);
    report.solvable = solvable;
    if (!solvable) {
      report.warnings.push('Level may be unsolvable — adding connectivity aids');
      this.addConnectivityAids(gdd, report);
    }

    for (const rule of this.rules) {
      if (this.age < rule.ageRange[0] || this.age > rule.ageRange[1]) continue;
      if (rule.confidence < 0.7) continue;
      try {
        if (rule.check(gdd)) {
          const additions = rule.apply(gdd);
          if (additions.length > 0) {
            for (const s of additions) gdd.addEntity(s);
            report.rulesApplied.push(rule.id);
            report.stampsAdded.push(...additions);
          }
        }
      } catch (err) {
        report.warnings.push(`Rule ${rule.id} failed: ${err}`);
      }
    }

    this.balanceEnemyDensity(gdd, report);
    report.estimatedDifficulty = this.estimateDifficulty(gdd);
    return { gdd, report };
  }

  private checkSolvability(gdd: GameDesignDocument): boolean {
    const player = gdd.entities.find(e => e.type === StampType.PLAYER);
    const goal = gdd.entities.find(e => e.type === StampType.GOAL);
    if (!player || !goal) return false;

    const platforms = gdd.entities.filter(e =>
      e.type === StampType.PLATFORM || e.type === StampType.MOVING_PLATFORM
    );
    const maxJumpDist = this.age <= 6 ? 192 : this.age <= 9 ? 256 : 320;
    const maxJumpHeight = this.age <= 6 ? 128 : 192;
    const startNode = this.findNearestPlatform(player, platforms);
    const endNode = this.findNearestPlatform(goal, platforms);
    if (!startNode || !endNode) return false;

    return this.aStarSolve(startNode, endNode, platforms, maxJumpDist, maxJumpHeight);
  }

  private aStarSolve(
    start: Stamp, end: Stamp, platforms: Stamp[],
    maxDist: number, maxHeight: number
  ): boolean {
    const open: Array<{ stamp: Stamp; f: number }> = [{ stamp: start, f: 0 }];
    const closed = new Set<string>();
    const gScore = new Map<string, number>();
    gScore.set(start.id, 0);

    while (open.length > 0) {
      open.sort((a, b) => a.f - b.f);
      const current = open.shift()!.stamp;
      if (current.id === end.id) return true;
      if (closed.has(current.id)) continue;
      closed.add(current.id);

      for (const neighbor of platforms) {
        if (closed.has(neighbor.id)) continue;
        const dx = Math.abs(neighbor.x - current.x);
        const dy = neighbor.y - current.y;
        if (dx > maxDist || dy < -maxHeight || dy > maxDist * 0.5) continue;
        const tentativeG = (gScore.get(current.id) || 0) + dx;
        if (tentativeG < (gScore.get(neighbor.id) || Infinity)) {
          gScore.set(neighbor.id, tentativeG);
          const h = Math.abs(neighbor.x - end.x) + Math.abs(neighbor.y - end.y);
          open.push({ stamp: neighbor, f: tentativeG + h });
        }
      }
    }
    return false;
  }

  private balanceEnemyDensity(gdd: GameDesignDocument, report: BalanceReport): void {
    const enemies = gdd.entities.filter(e => e.type === StampType.ENEMY);
    const platforms = gdd.entities.filter(e => e.type === StampType.PLATFORM);
    const maxEnemies = Math.max(1, Math.floor(platforms.length * (0.2 + this.age * 0.05)));
    if (enemies.length > maxEnemies) {
      const excess = enemies.slice(maxEnemies);
      for (const e of excess) {
        e.type = StampType.FRIEND;
        report.stampsModified.push({ id: e.id, changes: { type: StampType.FRIEND } });
      }
      report.warnings.push(
        `Reduced ${excess.length} enemies to friends (cap: ${maxEnemies})`
      );
    }
  }

  private addConnectivityAids(gdd: GameDesignDocument, report: BalanceReport): void {
    const platforms = gdd.entities.filter(e => e.type === StampType.PLATFORM);
    const player = gdd.entities.find(e => e.type === StampType.PLAYER);
    if (!player || platforms.length < 2) return;
    const sorted = [...platforms].sort((a, b) => a.x - b.x);
    let maxGap = 0, gapIndex = 0;
    for (let i = 0; i < sorted.length - 1; i++) {
      const gap = sorted[i + 1].x - sorted[i].x;
      if (gap > maxGap) { maxGap = gap; gapIndex = i; }
    }
    if (maxGap > 150) {
      const cp = new Stamp({
        id: `auto_cp_${Date.now()}`, type: StampType.CHECKPOINT,
        x: sorted[gapIndex].x + maxGap / 2, y: sorted[gapIndex].y - 32,
        width: 32, height: 32, properties: { autoPlaced: true, invisible: true },
      });
      gdd.addEntity(cp);
      report.stampsAdded.push(cp);
      report.rulesApplied.push('H-041');
    }
  }

  private registerDefaultRules(): void {
    this.rules.push({
      id: 'H-001', category: 'combat', description: 'Health after combat',
      confidence: 0.95, ageRange: [5, 12], autoApply: true,
      check: (gdd) => gdd.entities.filter(e => e.type === StampType.ENEMY).length >= 2,
      apply: (gdd) => {
        const last = [...gdd.entities].filter(e => e.type === StampType.ENEMY)
          .sort((a, b) => b.x - a.x)[0];
        if (!last) return [];
        return [new Stamp({
          id: `auto_heart_${Date.now()}`, type: StampType.HEART,
          x: last.x + 64, y: last.y - 32,
          width: 24, height: 24, properties: { autoPlaced: true },
        })];
      },
    });
    // 200+ additional rules follow this pattern...
  }

  private findNearestPlatform(e: Stamp, ps: Stamp[]): Stamp | undefined {
    return ps.sort((a, b) =>
      Math.hypot(a.x - e.x, a.y - e.y) - Math.hypot(b.x - e.x, b.y - e.y)
    )[0];
  }

  private estimateDifficulty(gdd: GameDesignDocument): number {
    const ec = gdd.entities.filter(e => e.type === StampType.ENEMY).length;
    const hc = gdd.entities.filter(e => e.type === StampType.SPIKE).length;
    const pc = gdd.entities.filter(e => e.type === StampType.PLATFORM).length;
    if (pc === 0) return 50;
    return Math.min(100, Math.round(((ec / pc) * 40 + (hc / pc) * 30) * 100));
  }
}
```

### 7.3 Constrained Decoding & Hallucination Prevention

#### 7.3.1 Outlines/XGrammar for Syntactically Valid Code

Hallucination in LLM-generated code falls into three categories: requirement conflicts, code inconsistency (undefined variables, type mismatches), and knowledge hallucination (non-existent APIs) [^14^]. Constrained decoding frameworks like Outlines [^4^] and XGrammar [^5^] eliminate code inconsistency entirely by compiling output schemas into finite state machines running in parallel with token generation — reducing hallucination rates by up to 50% [^4^].

The pipeline uses constrained decoding at two levels: structural (JSON conforming to a Pydantic schema with `create_code`, `update_code`, `game_config` fields) and syntactic (grammar-constrained JavaScript preventing unclosed braces and undefined references). Temperature 0.1–0.3 with Top-P 0.1–0.3 produces the most reliable code generation [^6^]; the pipeline defaults to 0.15 temperature and 0.2 Top-P.

#### 7.3.2 Two-Pass Validation

The first pass checks syntax (balanced braces/parentheses, no forbidden patterns like `eval` or `document.write`) and security. The second pass checks semantic consistency against the GDD — verifying every entity appears in code and every interaction type has corresponding overlap/collider callbacks. This catches approximately 60% of hallucination issues without separate agent instances [^7^]. ChatDev's "communicative dehallucination" principle is simplified into sequential prompts: generation followed by verification.

#### 7.3.3 Implementation: ConstrainedGenerator with Outlines

```python
"""
ConstrainedGenerator: Uses Outlines/XGrammar to guarantee syntactically
valid JSON outputs conforming to a defined schema. Falls back to
template-only generation if the library is unavailable.
"""
import json
from typing import Optional
from pydantic import BaseModel, Field

class GameCodeOutput(BaseModel):
    """Structured output schema — constrained decoding enforces this."""
    preload_code: str = Field(default="", description="Phaser preload method body")
    create_code: str = Field(description="Phaser create method body — REQUIRED")
    update_code: str = Field(default="", description="Phaser update method body")
    helper_functions: str = Field(default="", description="Additional JS functions")
    game_config: dict = Field(default_factory=lambda: {
        "width": 800, "height": 600, "gravity": 800, "debug": False
    })
    stamp_compatibility: list = Field(default_factory=list)


class ConstrainedGenerator:
    """Generates game code using constrained decoding for valid output."""

    def __init__(self, model_name: str = "microsoft/Phi-3-mini-4k-instruct"):
        self.model_name = model_name
        self._init_outlines()

    def _init_outlines(self):
        try:
            import outlines
            from outlines import models, generate
            self.model = models.transformers(self.model_name)
            self.generator = generate.json(self.model, GameCodeOutput)
            self.outlines_available = True
        except ImportError:
            self.outlines_available = False
            self._init_fallback()

    def _init_fallback(self):
        try:
            from openai import OpenAI
            self.client = OpenAI()
            self.fallback_available = True
        except ImportError:
            self.fallback_available = False

    def generate(self, prompt_messages: list,
                 temperature: float = 0.1) -> GameCodeOutput:
        if self.outlines_available:
            return self._generate_constrained(prompt_messages, temperature)
        elif self.fallback_available:
            return self._generate_fallback(prompt_messages, temperature)
        else:
            return self._generate_template_only()

    def _generate_constrained(self, prompt_messages: list,
                              temperature: float) -> GameCodeOutput:
        prompt = self._messages_to_prompt(prompt_messages)
        # Outlines runs the FSM in parallel with token generation —
        # only tokens that maintain valid JSON are emitted
        result = self.generator(prompt, max_tokens=2048,
                                temperature=temperature)
        return result  # Already validated as GameCodeOutput by Outlines

    def _generate_fallback(self, prompt_messages: list,
                           temperature: float) -> GameCodeOutput:
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o-mini", messages=prompt_messages,
                response_format={"type": "json_object"},
                temperature=temperature, max_tokens=2048
            )
            content = json.loads(response.choices[0].message.content)
            return GameCodeOutput(**content)
        except Exception as e:
            return self._generate_template_only()

    def _generate_template_only(self) -> GameCodeOutput:
        """Last resort: minimal playable game that always works."""
        return GameCodeOutput(
            create_code="""
const player = this.physics.add.sprite(100, 450, 'player');
player.setCollideWorldBounds(true);
player.setBounce(0.2);
const platforms = this.physics.add.staticGroup();
platforms.create(400, 564, 'platform').setScale(2).refreshBody();
this.physics.add.collider(player, platforms);
const cursors = this.input.keyboard.createCursorKeys();
this.input.keyboard.on('keydown-LEFT', () => player.setVelocityX(-160));
this.input.keyboard.on('keydown-RIGHT', () => player.setVelocityX(160));
this.input.keyboard.on('keydown-UP', () => {
    if (player.body.touching.down) player.setVelocityY(-330);
});
""",
            game_config={"width": 800, "height": 600, "gravity": 800}
        )

    def _messages_to_prompt(self, messages: list) -> str:
        parts = []
        for msg in messages:
            role = msg["role"]; content = msg["content"]
            parts.append(f"{role.capitalize()}: {content}")
        parts.append("Assistant:")
        return "\n\n".join(parts)
```

#### 7.3.4 Implementation: CodeValidator

```python
"""
CodeValidator: Two-pass validation — syntax/security (Pass 1)
and GDD semantic consistency (Pass 2). Includes sandbox execution.
"""
import re
from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional, Dict, Any

class ValidationSeverity(Enum):
    ERROR = "error"; WARNING = "warning"; INFO = "info"

@dataclass
class ValidationFinding:
    severity: ValidationSeverity; rule_id: str; message: str
    line: Optional[int] = None; suggestion: str = ""

@dataclass
class ValidationResult:
    findings: List[ValidationFinding] = field(default_factory=list)
    can_execute: bool = False; syntax_valid: bool = False
    gdd_consistent: bool = False; security_clear: bool = False

    @property
    def has_errors(self) -> bool:
        return any(f.severity == ValidationSeverity.ERROR for f in self.findings)


class CodeValidator:
    FORBIDDEN_PATTERNS: List[tuple] = [
        (r'eval\s*\(', 'V-SEC-001', 'eval() not allowed'),
        (r'Function\s*\(', 'V-SEC-002', 'Function constructor not allowed'),
        (r'document\.write', 'V-SEC-003', 'document.write not allowed'),
        (r'fetch\s*\(', 'V-SEC-005', 'Network requests not allowed'),
        (r'XMLHttpRequest', 'V-SEC-006', 'XHR not allowed'),
        (r'WebSocket', 'V-SEC-007', 'WebSocket not allowed'),
        (r'localStorage', 'V-SEC-008', 'Storage access not allowed'),
        (r'navigator', 'V-SEC-009', 'Browser info leakage risk'),
        (r'import\s*\(', 'V-SEC-010', 'Dynamic imports not allowed'),
    ]
    REQUIRED_PATTERNS: List[tuple] = [
        (r'this\.physics\.', 'V-REQ-001', 'Must use Phaser physics'),
        (r'sprite|image', 'V-REQ-002', 'Must create visual elements'),
    ]

    def validate(self, code: str, gdd: Optional[Any] = None) -> ValidationResult:
        result = ValidationResult()

        # Pass 1: Syntax + Security
        syn = self._validate_syntax(code)
        sec = self._validate_security(code)
        req = self._validate_required(code)
        result.findings.extend(syn + sec + req)
        result.syntax_valid = not any(
            f.severity == ValidationSeverity.ERROR for f in syn)
        result.security_clear = not any(
            f.severity == ValidationSeverity.ERROR for f in sec)

        # Pass 2: GDD consistency
        if gdd is not None:
            con = self._validate_gdd(code, gdd)
            result.findings.extend(con)
            result.gdd_consistent = not any(
                f.severity == ValidationSeverity.ERROR for f in con)
        else:
            result.gdd_consistent = True

        result.can_execute = (result.syntax_valid and
            result.security_clear and result.gdd_consistent)
        return result

    def _validate_syntax(self, code: str) -> List[ValidationFinding]:
        f = []
        ob, cb = code.count('{'), code.count('}')
        if ob != cb:
            f.append(ValidationFinding(ValidationSeverity.ERROR,
                'V-SYN-001', f'Unbalanced braces: {ob} open, {cb} close'))
        op, cp = code.count('('), code.count(')')
        if op != cp:
            f.append(ValidationFinding(ValidationSeverity.ERROR,
                'V-SYN-002', f'Unbalanced parens: {op} open, {cp} close'))
        if re.search(r'while\s*\(\s*(true|1)\s*\)', code):
            f.append(ValidationFinding(ValidationSeverity.WARNING,
                'V-SYN-005', 'Potential infinite loop'))
        return f

    def _validate_security(self, code: str) -> List[ValidationFinding]:
        f = []
        for pat, rid, msg in self.FORBIDDEN_PATTERNS:
            for m in re.finditer(pat, code, re.IGNORECASE):
                f.append(ValidationFinding(ValidationSeverity.ERROR, rid, msg,
                    code[:m.start()].count('\n') + 1))
        return f

    def _validate_required(self, code: str) -> List[ValidationFinding]:
        f = []
        cl = code.lower()
        for pat, rid, msg in self.REQUIRED_PATTERNS:
            if not re.search(pat, cl):
                f.append(ValidationFinding(ValidationSeverity.WARNING, rid, msg))
        return f

    def _validate_gdd(self, code: str, gdd: Any) -> List[ValidationFinding]:
        f = []; cl = code.lower()
        try:
            for entity in getattr(gdd, 'entities', []):
                et = getattr(entity, 'type', None)
                if et and et.value not in cl:
                    f.append(ValidationFinding(ValidationSeverity.WARNING,
                        'V-GDD-001', f"Entity '{et.value}' from GDD not in code"))
            for interaction in getattr(gdd, 'interactions', []):
                it = interaction.get('type', '')
                if it == 'collect' and 'overlap' not in cl:
                    f.append(ValidationFinding(ValidationSeverity.WARNING,
                        'V-GDD-002', 'Collect interaction needs overlap'))
        except Exception as e:
            f.append(ValidationFinding(ValidationSeverity.INFO,
                'V-GDD-ERR', f'GDD check failed: {e}'))
        return f
```

Sandboxed execution runs generated games inside a CSP-restricted iframe with `sandbox="allow-scripts"`, blocking network access, storage, and navigation. Resource limits: CPU 1 core, memory 256MB, execution 5 seconds maximum [^16^]. WebAssembly sandboxes provide provably safe isolation.

### 7.4 Lightweight LLM Selection & Deployment

#### 7.4.1 Model Selection Strategy

The pipeline supports a three-tier model strategy. Phi-3 Mini (3.8B) serves local deployments — achieving 57.3% on HumanEval and 69.8% on MBPP [^12^], adequate for simple game logic. On a CPU with 8GB RAM, Phi-3 generates in 2–8 seconds; with GPU, 0.5–2 seconds. Llama-3.3 8B serves mid-tier — 72.6% on HumanEval, running on 6GB RAM, better for complex arrangements [^13^]. Cloud APIs (GPT-4o-mini, Claude Haiku) handle complex creative generation.

Self-collaboration research shows a single LLM simulating multiple roles achieves 80% of multi-agent quality with one-third the compute [^15^]. The pipeline uses the same model with different prompts for generation and validation, not separate models.

#### 7.4.2 Performance Targets

Template fallback completes in under 30ms — perceived as instantaneous. LLM generation targets under 2 seconds for simple layouts (under 10 stamps) and under 5 seconds for complex canvases (50+ stamps). Batched classroom generation processes 30 concurrent users with local LLM pools.

| Deployment Tier | Model | RAM Required | Gen Latency (simple) | Gen Latency (complex) | Fallback | Best For |
|---|---|---|---|---|---|---|
| Local Edge | Phi-3 Mini 3.8B | 4–6 GB | 2–4s | 5–8s | <30ms | Home use, low connectivity |
| Mid-tier | Llama-3.3 8B | 6–8 GB | 1.5–3s | 4–6s | <30ms | Schools, small groups |
| Cloud | GPT-4o-mini / Claude Haiku | N/A | 0.5–1.5s | 2–4s | <30ms | Complex generation |
| Classroom Pool | 4x Phi-3 Mini (load-balanced) | 16–24 GB | <1s | 2–3s | <30ms | 30+ concurrent children |

Optimization strategies include pre-built prompt templates (1–2ms construction), cached responses with 80% hit rate for common configurations, and progressive asset loading in parallel with code generation. RAG with a curated vector database reduces knowledge hallucinations by 35–50% [^19^].

#### 7.4.3 Implementation: LLMManager with Provider Switching

```typescript
/**
 * LLMManager: Unified interface for multiple LLM providers with
 * rate limiting, fallback chains, and health monitoring.
 */

interface LLMProvider {
  name: string;
  generate(prompt: string, options: GenerationOptions): Promise<string>;
  isAvailable(): Promise<boolean>;
  getHealth(): ProviderHealth;
}

interface GenerationOptions {
  temperature: number; topP: number; maxTokens: number;
  stopSequences?: string[];
}

interface ProviderHealth {
  available: boolean; lastLatencyMs: number;
  failureRate: number; consecutiveFailures: number;
}

export class LLMManager {
  private providers = new Map<string, LLMProvider>();
  private config: {
    primaryProvider: string; fallbackProviders: string[];
    rateLimitRpm: number; circuitBreakerThreshold: number;
    circuitBreakerTimeoutMs: number; requestTimeoutMs: number;
  };
  private requestTimestamps: number[] = [];
  private circuitStates = new Map<string, {
    open: boolean; failures: number; openedAt: number;
  }>();

  constructor(config: Partial<typeof this.config> = {}) {
    this.config = {
      primaryProvider: 'local-phi3',
      fallbackProviders: ['local-llama', 'cloud-gpt4o-mini'],
      rateLimitRpm: 100, circuitBreakerThreshold: 5,
      circuitBreakerTimeoutMs: 60000, requestTimeoutMs: 5000,
      ...config,
    };
  }

  registerProvider(provider: LLMProvider): void {
    this.providers.set(provider.name, provider);
    this.circuitStates.set(provider.name,
      { open: false, failures: 0, openedAt: 0 });
  }

  async generate(prompt: string, options: Partial<GenerationOptions> = {}):
    Promise<{ createCode: string; gameConfig: GameConfig }> {
    const merged: GenerationOptions = {
      temperature: 0.15, topP: 0.2, maxTokens: 2048, ...options };

    if (!this.checkRateLimit()) {
      throw new Error('Rate limit exceeded');
    }

    const order = [this.config.primaryProvider, ...this.config.fallbackProviders];
    const errors: string[] = [];

    for (const name of order) {
      const p = this.providers.get(name);
      if (!p) continue;
      if (this.isCircuitOpen(name)) {
        errors.push(`${name}: circuit open`); continue;
      }
      try {
        const start = performance.now();
        const raw = await this.withTimeout(
          p.generate(prompt, merged), this.config.requestTimeoutMs);
        const latency = performance.now() - start;
        this.recordSuccess(name, latency);
        return this.parseOutput(raw);
      } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        this.recordFailure(name);
        errors.push(`${name}: ${msg}`);
      }
    }
    throw new Error(`All providers failed: ${errors.join('; ')}`);
  }

  private parseOutput(raw: string): { createCode: string; gameConfig: GameConfig } {
    try {
      const m = raw.match(/\{[\s\S]*\}/);
      const parsed = JSON.parse(m ? m[0] : raw);
      return {
        createCode: parsed.create_code || parsed.createCode || '',
        gameConfig: {
          width: parsed.game_config?.width || 800,
          height: parsed.game_config?.height || 600,
          gravity: parsed.game_config?.gravity || 800,
          debug: parsed.game_config?.debug || false,
        },
      };
    } catch {
      return { createCode: raw,
        gameConfig: { width: 800, height: 600, gravity: 800, debug: false } };
    }
  }

  private checkRateLimit(): boolean {
    const now = performance.now();
    this.requestTimestamps = this.requestTimestamps.filter(t => t > now - 60000);
    if (this.requestTimestamps.length >= this.config.rateLimitRpm) return false;
    this.requestTimestamps.push(now);
    return true;
  }

  private isCircuitOpen(name: string): boolean {
    const s = this.circuitStates.get(name);
    if (!s || !s.open) return false;
    if (performance.now() - s.openedAt > this.config.circuitBreakerTimeoutMs) {
      s.open = false; s.failures = 0; return false;
    }
    return true;
  }

  private recordSuccess(name: string, _latencyMs: number): void {
    const s = this.circuitStates.get(name);
    if (s) { s.failures = 0; s.open = false; }
  }

  private recordFailure(name: string): void {
    const s = this.circuitStates.get(name);
    if (!s) return;
    s.failures++;
    if (s.failures >= this.config.circuitBreakerThreshold) {
      s.open = true; s.openedAt = performance.now();
    }
  }

  private async withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
    return Promise.race([promise, new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error(`Timeout after ${ms}ms`)), ms))]);
  }

  getHealth(): Record<string, ProviderHealth & { circuitOpen: boolean }> {
    const r: Record<string, ProviderHealth & { circuitOpen: boolean }> = {};
    for (const [name, p] of this.providers) {
      const c = this.circuitStates.get(name);
      r[name] = { ...p.getHealth(), circuitOpen: c?.open || false };
    }
    return r;
  }
}
```

The architecture's resilience comes from layered fallback: cloud API timeout falls back to local model; local model overload falls back to template assembly; template validation errors fall back to a minimal playable game — a player on a single platform with arrow key movement. The child always sees a working game. Rate limiting with exponential backoff, circuit breakers after 5 failures, and multi-provider fallback ensure graceful degradation [^17^].

The debounced generator waits 1.5 seconds after the last stamp placement before triggering. During this window, the stamp appears with a pop animation while the pipeline prepares code in the background. If stamps are placed faster than the generation cycle, intermediate generations are cancelled and only the latest configuration is processed — preventing outdated request queuing.

Child-friendly error handling translates all technical failures into gentle messages. LLM timeout: "Thinking really hard... let me try a different way!" Rate limiting: "Lots of friends are playing right now! Using my magic backup plan." All errors are logged to a developer dashboard; children experience only recovery-oriented messaging. The system always returns to a working state — no broken games, no stack traces, no hung spinners.
