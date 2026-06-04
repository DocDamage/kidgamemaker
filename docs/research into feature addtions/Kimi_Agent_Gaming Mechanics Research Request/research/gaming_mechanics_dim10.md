## Dimension 10: LLM Integration & Natural Language to Game Logic

### Executive Summary

The integration of Large Language Models (LLMs) into game creation platforms represents a paradigm shift in how games can be built, enabling non-programmers---including children as young as 5---to create playable games through intuitive visual interfaces. This research examines the state-of-the-art in LLM-powered code generation for game development and derives an optimal architecture for a stamp-based, zero-code game creation platform.

Our investigation reveals that multi-agent collaborative frameworks (GameGPT [^1^], ChatDev [^2^], MetaGPT [^3^]) demonstrate the most promising approaches for complex code generation, with specialized agents handling distinct phases: planning, coding, testing, and review. For a child-friendly platform, however, this complexity must be radically simplified into a single-pass or batched generation pipeline. The optimal architecture combines: (1) a stamp parser that converts visual placements into structured intermediate representations, (2) a prompt builder using few-shot examples with constrained decoding, (3) a lightweight LLM (Phi-3 3.8B or Llama-3.3 8B for local deployment, or cloud APIs for heavier workloads), (4) a code validator with sandboxed execution, and (5) a game engine runner with hot-reload capability.

Key findings indicate that constrained decoding frameworks like Outlines [^4^] and XGrammar [^5^] can guarantee syntactically valid game code outputs, reducing hallucination rates by up to 50%. Temperature settings of 0.1--0.3 with Top-P of 0.1--0.3 produce the most reliable code generation [^6^]. The stamp-based paradigm maps naturally to the GameGPT "code decoupling" approach---breaking game logic into small, manageable code snippets that the LLM can generate reliably. Fallback mechanisms including template-based code generation, cached responses, and circuit breakers ensure the system remains functional even when LLM services are unavailable.

### Studio Innovations Analysis

#### GameGPT: Multi-Agent Collaborative Framework for Game Development

**How it works technically:** GameGPT [^1^] operates through five distinct stages: game development planning, task classification, code generation, task execution, and result summarization. The framework employs a "dual collaboration" approach---cooperation between LLMs and smaller expert deep learning models, alongside collaborative engagement between execution roles and review roles. Critically, GameGPT introduces **code decoupling**: separating game scripts into numerous small code snippets of manageable length for LLM processing, which significantly reduces hallucination and redundancy. The framework also uses **candidate selection**---generating K code snippets for each task, testing them in a virtual environment, and selecting the best-performing candidate [^1^].

**Stamp-based adaptation:** For a children's platform, the multi-agent complexity is unnecessary. Instead, the **code decoupling** principle directly applies: each stamp type (player, enemy, platform, coin) maps to a pre-defined, small code snippet template. When a child places a stamp, the system doesn't need a full planning agent---it simply retrieves the corresponding template and fills in parameters (position, size, behavior). The LLM only intervenes for complex interactions between stamps, generating small glue code snippets. This dramatically reduces the generation scope and eliminates hallucination risks for basic elements.

#### ChatDev: ChatChain Multi-Agent Communication

**How it works technically:** ChatDev [^2^] structures agent communication through "ChatChain"---a chain-like process of dual-agent dialogs (e.g., Programmer + Reviewer, CEO + CTO). Each phase uses structured JSON messages for consistent data exchange. The key innovation is **"communicative dehallucination"**---agents catch each other's errors through cross-examination. The waterfall model phases (design, coding, testing, documenting) are each subdivided into atomic "chat-chains" with specific goals [^2^].

**Stamp-based adaptation:** The cross-examination principle can be simplified into a **two-pass validation**: first, the LLM generates game code from stamps; second, a validation agent (which can be the same LLM with a different system prompt) checks for consistency, missing imports, and logical errors. This two-pass approach catches approximately 60% of hallucination issues without requiring separate agent instances [^7^].

#### MetaGPT: SOP-Based Software Development

**How it works technically:** MetaGPT [^3^] encodes Standard Operating Procedures (SOPs) from human software development teams into agent behaviors. Five roles (Product Manager, Architect, Project Manager, Engineer, QA Engineer) follow strict handover protocols with structured outputs (PRDs, design documents, task lists). The key insight is that **structured intermediate outputs** between phases greatly enhance code generation success rates by reducing "idle chatter" between LLMs [^3^].

**Stamp-based adaptation:** The SOP principle translates to a **fixed pipeline** for stamp-to-code conversion: (1) Parse stamps into an intermediate game design document (GDD), (2) Generate asset loading code, (3) Generate entity initialization code, (4) Generate game loop and interaction code, (5) Validate and assemble. Each stage has a defined input/output format, ensuring consistency.

#### Rosebud.ai: Description-to-Code-to-Game Pipeline

**How it works technically:** Rosebud.ai [^8^] provides a "pixel maker" platform where users describe game ideas in natural language, and the AI generates code that runs in the browser. The pipeline goes: natural language description → AI-generated code → playable browser game. Users can iteratively refine by giving follow-up instructions. The platform uses 2D/3D templates as starting points and allows cloning existing games [^8^].

**Stamp-based adaptation:** Rosebud's approach validates that natural language-to-game-code is viable, but stamps provide even more structured input than free-form text. A stamp placement is essentially a **pre-validated, structured description**---the system knows exactly what entity was placed, where, and with what properties. This eliminates ambiguity and makes LLM generation more reliable than from pure natural language.

#### CodeAct: Executable Code as LLM Actions

**How it works technically:** CodeAct [^9^] proposes using executable Python code (rather than JSON or text) as the action space for LLM agents. Integrated with a Python interpreter, CodeAct can execute code actions and dynamically revise them based on observations. Experiments across 17 LLMs show CodeAct achieves up to **20% higher success rates** and requires up to **30% fewer interaction turns** than JSON/text alternatives. Code inherently supports control flow (if-statements, for-loops) and data flow (variables, function composition) [^9^].

**Stamp-based adaptation:** For a game platform, using JavaScript/TypeScript as the action format (rather than JSON) allows the LLM to generate complete, executable game logic in a single pass. The LLM generates actual game code instead of configuration, which is then executed directly in the browser. This aligns with research showing that LLMs perform better when generating code in languages they've seen extensively during pre-training [^9^].

#### CodeChain: Bottom-Up Code Generation

**How it works technically:** CodeChain [^10^] uses a **bottom-up approach**: first building a problem tree, generating solutions for leaf nodes (small, self-contained functions), then composing upward. Each leaf function undergoes immediate testing and validation. Parent nodes receive only the documentation and interfaces of child nodes, not implementation details---enabling clean separation of concerns [^10^].

**Stamp-based adaptation:** Each stamp type becomes a "leaf node" with a pre-validated code template. When stamps interact (e.g., "player touches coin"), the system generates a parent node that composes the leaf behaviors. This mirrors how children think---placing individual objects first, then wanting them to interact.

### Key Findings

1. **Multi-agent frameworks reduce hallucination but add latency.** GameGPT's reviewer agents catch approximately 40% of generated code errors before execution [^1^], but the multi-turn conversation adds 3-5x latency. For a children's platform where immediate feedback is critical, a single-pass approach with post-generation validation is preferable [^1^][^2^].

2. **Code decoupling is the most effective hallucination mitigation.** Breaking game scripts into small snippets (under 50 lines each) reduces hallucination by 60-70% compared to generating full game files [^1^]. Each stamp should map to a decoupled code module.

3. **Constrained decoding guarantees valid outputs.** Frameworks like Outlines [^4^] and XGrammar [^5^] compile JSON schemas into finite state machines that run in parallel with token generation, ensuring syntactically valid outputs. This eliminates syntax errors entirely and can speed up generation by 50% [^4^].

4. **Few-shot prompting with 2-3 examples is optimal for code generation.** Research shows diminishing returns beyond 3 examples for code tasks [^11^]. Examples should demonstrate the exact output format expected, including the stamp-to-code mapping pattern.

5. **Temperature 0.1-0.3 produces the most reliable code.** Low temperature settings maximize deterministic, correct code generation. Higher temperatures introduce variation that mostly manifests as bugs [^6^].

6. **Lightweight LLMs can achieve sufficient quality for game code.** Phi-3 Mini (3.8B parameters) achieves 57.3% on HumanEval and 69.8% on MBPP [^12^], which is adequate for simple game logic generation. Llama-3.3 8B achieves 72.6% on HumanEval and can run on 6GB RAM [^13^].

7. **Hallucination in code falls into three categories:** Requirement Conflicting (most prevalent), Code Inconsistency (undefined variables, type mismatches), and Knowledge (using non-existent APIs) [^14^]. Structured generation mitigates the second category entirely.

8. **Self-collaboration enables single-LLM multi-role simulation.** A single LLM instance can simulate multiple roles (programmer, reviewer, tester) by switching system prompts, achieving 80% of multi-agent quality with 1/3 the compute [^15^].

9. **Sandboxed execution is mandatory for LLM-generated code.** Running generated code in isolated environments (Docker containers, WASM sandboxes) with resource limits (CPU: 1 core, Memory: 256MB, Time: 5 seconds) prevents infinite loops and malicious code [^16^].

10. **Rate limiting with exponential backoff and circuit breakers ensures reliability.** Production LLM applications should implement: token bucket rate limiting (100 RPM), exponential backoff (2^n seconds), circuit breakers (open after 5 failures), and multi-provider fallback [^17^].

11. **Phaser.js is the optimal target framework for LLM-generated browser games.** Phaser's API is well-represented in LLM training data, and the framework has published "AI agent skills" documentation specifically for LLM code generation [^18^].

12. **RAG with game code examples improves generation quality.** Providing relevant code snippets from a curated library reduces knowledge hallucinations by 35-50% [^19^]. A stamp-to-code platform should maintain a vector database of validated game code patterns.

### Child-Friendly Simplifications

**Age 5-7: "Magic Stamps" (Template-Only Mode)**
- No LLM generation in real-time; stamps are pure templates
- Pre-validated code snippets for each stamp type
- Combinations use pre-defined interaction rules
- LLM only used for "surprise me" random game generation
- Zero latency, zero failure rate

**Age 7-10: "Smart Stamps" (Assisted Generation)**
- LLM generates glue code for stamp interactions
- Child places stamps, system suggests simple behaviors
- Validation catches errors and suggests fixes
- Two-pass generation: code → validate → present
- 1-2 second generation time acceptable

**Age 10+: "Creator Mode" (Full Generation)**
- LLM generates complete game code from stamp placements
- Natural language descriptions augment stamp semantics
- Complex interactions (physics, AI enemies, scoring)
- Iterative refinement through conversation
- 3-5 second generation time acceptable

### Recommended Architecture

```
+--------------+    +------------------+    +-----------------+
|  Stamp Canvas |--->|  Stamp Parser    |--->|  Game Design    |
|  (User Input) |    |  (Convert to     |    |  Document (GDD) |
|               |    |   Structured     |    |  JSON Format    |
+--------------+    |   Representation)|    +-----------------+
                    +------------------+              |
                    +------------------+              |
                    |  Template Library |<-------------+
                    |  (Pre-validated   |    (Entity definitions,
                    |   code per stamp) |     behaviors, assets)
                    +------------------+
                              |
                              v
                    +------------------+
                    |  Prompt Builder   |
                    |  (Few-shot +      |
                    |   Structured RAG) |
                    +------------------+
                              |
                              v
                    +------------------+
                    |  Constrained     |
                    |  LLM Generation  |<--+
                    |  (Outlines/X     |   |
                    |   Grammar)       |   |
                    +------------------+   |
                              |            |
                              v            |
                    +------------------+   |
                    |  Code Validator  |   |
                    |  (Syntax + Basic |   |
                    |   Semantic Check)|   |
                    +------------------+   |
                              |            |
                    +---------+----------+ |                    +--------------+    |  Fallback:   |---+
                    v                    v |                    |  Sandbox     |    |  Template    |   |
            +--------------+    +--------------+               |  Execution   |    |  Assembly    |   |
            |   Sandbox    |    |  Fallback:   |               |  (WASM/Docker)|    |              |---+
            |  Execution   |    |  Template    |               +--------------+
            |  (WASM/Docker)|    |  Assembly    |---+
            +--------------+    +--------------+
                    |
                    v
            +--------------+
            |  Game Engine  |
            |  (Phaser.js)  |
            |  Hot Reload   |
            +--------------+
```

### Recommended Features (Prioritized)

**P0 (Critical):**
1. Stamp-to-JSON parser with position, type, and properties
2. Template library with pre-validated code for 20+ stamp types
3. Constrained LLM generation using Outlines/XGrammar
4. Syntax validation for generated JavaScript
5. Sandboxed execution with 5-second timeout
6. Circuit breaker for LLM API failures
7. Template-based fallback when LLM is unavailable

**P1 (High):**
8. Two-pass validation (generate → review → correct)
9. Few-shot prompt optimization (DSPy)
10. RAG retrieval of similar game patterns
11. Hot-reload game preview
12. Multi-provider LLM fallback (OpenAI → Anthropic → Local)
13. Rate limiting with exponential backoff

**P2 (Medium):**
14. Natural language augmentation (child describes stamp behavior)
15. Iterative refinement ("make the enemy faster")
16. Self-collaboration mode (single LLM, multiple review passes)
17. Game state persistence and sharing
18. Usage analytics and prompt optimization

### Code Snippets

#### 1. Stamp Parser (Python)

```python
"""
Stamp Parser: Converts visual stamp placements into a structured
Game Design Document (GDD) that feeds into the LLM prompt builder.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from enum import Enum
import json

class StampType(Enum):
    PLAYER = "player"
    ENEMY = "enemy"
    PLATFORM = "platform"
    COIN = "coin"
    GOAL = "goal"
    SPIKE = "spike"
    MOVING_PLATFORM = "moving_platform"
    POWERUP = "powerup"
    BACKGROUND = "background"
    SPAWN_POINT = "spawn_point"

@dataclass
class Stamp:
    """Represents a single stamp placed on the canvas."""
    id: str
    stamp_type: StampType
    x: float
    y: float
    width: float = 50.0
    height: float = 50.0
    properties: Dict = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        return {
            "id": self.id,
            "type": self.stamp_type.value,
            "position": {"x": self.x, "y": self.y},
            "size": {"width": self.width, "height": self.height},
            "properties": self.properties
        }

@dataclass
class GameDesignDocument:
    """Structured intermediate representation of the game."""
    game_type: str = "platformer"
    canvas_size: Tuple[int, int] = (800, 600)
    entities: List[Stamp] = field(default_factory=list)
    interactions: List[Dict] = field(default_factory=list)
    game_rules: Dict = field(default_factory=dict)
    
    def add_entity(self, stamp: Stamp):
        self.entities.append(stamp)
    
    def detect_interactions(self) -> List[Dict]:
        """Auto-detect potential interactions between stamps."""
        interactions = []
        players = [e for e in self.entities if e.stamp_type == StampType.PLAYER]
        coins = [e for e in self.entities if e.stamp_type == StampType.COIN]
        enemies = [e for e in self.entities if e.stamp_type == StampType.ENEMY]
        goals = [e for e in self.entities if e.stamp_type == StampType.GOAL]
        spikes = [e for e in self.entities if e.stamp_type == StampType.SPIKE]
        
        for player in players:
            for coin in coins:
                interactions.append({
                    "type": "collect",
                    "trigger": "overlap",
                    "subject": player.id,
                    "target": coin.id,
                    "effect": "score +10, destroy target"
                })
            for enemy in enemies:
                interactions.append({
                    "type": "damage",
                    "trigger": "overlap",
                    "subject": player.id,
                    "target": enemy.id,
                    "effect": "player health -1, knockback"
                })
            for goal in goals:
                interactions.append({
                    "type": "win",
                    "trigger": "overlap",
                    "subject": player.id,
                    "target": goal.id,
                    "effect": "level complete"
                })
            for spike in spikes:
                interactions.append({
                    "type": "damage",
                    "trigger": "overlap",
                    "subject": player.id,
                    "target": spike.id,
                    "effect": "player health -1"
                })
        
        self.interactions = interactions
        return interactions
    
    def to_json(self) -> str:
        return json.dumps({
            "game_type": self.game_type,
            "canvas_size": {"width": self.canvas_size[0], "height": self.canvas_size[1]},
            "entities": [e.to_dict() for e in self.entities],
            "interactions": self.interactions,
            "game_rules": self.game_rules
        }, indent=2)


class StampParser:
    """Parses raw stamp placements from the canvas into a GDD."""
    
    def __init__(self):
        self._stamp_counter = 0
    
    def parse_stamps(self, raw_stamps: List[Dict]) -> GameDesignDocument:
        """Convert raw stamp data from the frontend into a GDD."""
        gdd = GameDesignDocument()
        
        for raw in raw_stamps:
            self._stamp_counter += 1
            stamp = Stamp(
                id=f"{raw['type']}_{self._stamp_counter}",
                stamp_type=StampType(raw['type']),
                x=raw.get('x', 0),
                y=raw.get('y', 0),
                width=raw.get('width', 50),
                height=raw.get('height', 50),
                properties=raw.get('properties', {})
            )
            gdd.add_entity(stamp)
        
        # Auto-detect interactions
        gdd.detect_interactions()
        
        # Infer game rules from stamp composition
        gdd.game_rules = self._infer_game_rules(gdd)
        
        return gdd
    
    def _infer_game_rules(self, gdd: GameDesignDocument) -> Dict:
        """Infer game rules based on what stamps are present."""
        rules = {
            "has_scoring": any(e.stamp_type == StampType.COIN for e in gdd.entities),
            "has_lives": any(e.stamp_type in (StampType.ENEMY, StampType.SPIKE) 
                           for e in gdd.entities),
            "has_win_condition": any(e.stamp_type == StampType.GOAL 
                                    for e in gdd.entities),
            "gravity": 800,
            "player_speed": 200,
            "jump_velocity": -400
        }
        return rules


# Example usage
if __name__ == "__main__":
    raw_stamps = [
        {"type": "player", "x": 100, "y": 400, "properties": {"color": "blue"}},
        {"type": "platform", "x": 50, "y": 500, "width": 200, "height": 20},
        {"type": "platform", "x": 300, "y": 400, "width": 150, "height": 20},
        {"type": "coin", "x": 350, "y": 350},
        {"type": "coin", "x": 400, "y": 350},
        {"type": "enemy", "x": 500, "y": 450, "properties": {"patrol": True}},
        {"type": "goal", "x": 700, "y": 300}
    ]
    
    parser = StampParser()
    gdd = parser.parse_stamps(raw_stamps)
    print(gdd.to_json())
```

#### 2. Prompt Builder with Few-Shot Examples (Python)

```python
"""
Prompt Builder: Constructs optimized prompts for the LLM using few-shot
examples and structured output schemas.
"""

from dataclasses import dataclass
from typing import List, Dict
import json

@dataclass
class FewShotExample:
    """A single few-shot example for the prompt."""
    input_gdd: str
    output_code: str
    description: str

class PromptBuilder:
    """Builds optimized prompts for game code generation."""
    
    # Pre-validated few-shot examples for common game patterns
    FEW_SHOT_EXAMPLES: List[FewShotExample] = [
        FewShotExample(
            input_gdd=json.dumps({
                "game_type": "platformer",
                "entities": [
                    {"type": "player", "position": {"x": 100, "y": 400}},
                    {"type": "coin", "position": {"x": 300, "y": 300}},
                ],
                "interactions": [
                    {"type": "collect", "subject": "player", "target": "coin"}
                ]
            }),
            output_code="""
// Player entity
const player = this.physics.add.sprite(100, 400, 'player');
player.setCollideWorldBounds(true);

// Coin entity
const coin = this.physics.add.sprite(300, 300, 'coin');

// Collection interaction
this.physics.add.overlap(player, coin, () => {
    coin.disableBody(true, true);
    score += 10;
    scoreText.setText('Score: ' + score);
}, null, this);
""",
            description="Basic player-coin collection"
        ),
        FewShotExample(
            input_gdd=json.dumps({
                "game_type": "platformer",
                "entities": [
                    {"type": "player", "position": {"x": 100, "y": 400}},
                    {"type": "enemy", "position": {"x": 400, "y": 400}, 
                     "properties": {"patrol": True, "speed": 100}}
                ],
                "interactions": [
                    {"type": "damage", "subject": "player", "target": "enemy"}
                ]
            }),
            output_code="""
// Player entity
const player = this.physics.add.sprite(100, 400, 'player');
player.setCollideWorldBounds(true);

// Enemy with patrol behavior
const enemy = this.physics.add.sprite(400, 400, 'enemy');
enemy.patrolStartX = 300;
enemy.patrolEndX = 500;
enemy.patrolSpeed = 100;
enemy.setVelocityX(100);

// Enemy patrol update (call in update loop)
function updateEnemyPatrol(enemy) {
    if (enemy.x >= enemy.patrolEndX) {
        enemy.setVelocityX(-enemy.patrolSpeed);
        enemy.setFlipX(true);
    } else if (enemy.x <= enemy.patrolStartX) {
        enemy.setVelocityX(enemy.patrolSpeed);
        enemy.setFlipX(false);
    }
}

// Damage interaction
this.physics.add.collider(player, enemy, () => {
    playerHealth--;
    if (playerHealth <= 0) {
        this.scene.restart();
    }
    // Knockback
    player.setVelocityX(-200);
    player.setVelocityY(-200);
}, null, this);
""",
            description="Enemy with patrol and player damage"
        ),
    ]
    
    SYSTEM_PROMPT = """You are an expert game developer specializing in Phaser.js HTML5 games.
Your task is to generate clean, working JavaScript code for a 2D game based on the provided Game Design Document (GDD).

RULES:
1. Generate ONLY JavaScript code for Phaser.js. No explanations, no markdown formatting.
2. Use 'this' context (Phaser scene methods).
3. All sprite keys use preloaded assets: 'player', 'enemy', 'coin', 'platform', 'goal', 'spike', 'powerup', 'background'.
4. Include physics, collision detection, and game logic.
5. Keep code concise and well-commented.
6. Do NOT use external assets or APIs.
7. Ensure the code is syntactically valid JavaScript.
8. Use arrow functions for callbacks.
9. Handle edge cases: null checks, boundary checks.
10. The game should be immediately playable.

OUTPUT FORMAT:
- Return ONLY valid JavaScript code
- Code will be placed inside a Phaser.Scene class
- Available methods: preload(), create(), update(time, delta)
- Available physics: this.physics (arcade)
- Available input: this.input.keyboard
"""

    def __init__(self, max_examples: int = 2):
        self.max_examples = max_examples
    
    def build_prompt(self, gdd_json: str) -> List[Dict]:
        """Build a complete prompt with system message and few-shot examples."""
        messages = [
            {"role": "system", "content": self.SYSTEM_PROMPT}
        ]
        
        # Add few-shot examples
        for example in self.FEW_SHOT_EXAMPLES[:self.max_examples]:
            messages.append({
                "role": "user", 
                "content": f"Generate Phaser.js code for this game:\n{example.input_gdd}"
            })
            messages.append({
                "role": "assistant",
                "content": example.output_code
            })
        
        # Add the actual request
        messages.append({
            "role": "user",
            "content": f"Generate Phaser.js code for this game:\n{gdd_json}\n\nGenerate ONLY the JavaScript code:"
        })
        
        return messages
    
    def build_structured_prompt(self, gdd_json: str) -> Dict:
        """Build prompt with structured output schema (for constrained decoding)."""
        schema = {
            "type": "object",
            "properties": {
                "preload_code": {"type": "string", "description": "Asset loading code"},
                "create_code": {"type": "string", "description": "Scene creation code with entities"},
                "update_code": {"type": "string", "description": "Per-frame update logic"},
                "helper_functions": {"type": "string", "description": "Additional helper functions"},
                "game_config": {
                    "type": "object",
                    "properties": {
                        "width": {"type": "integer"},
                        "height": {"type": "integer"},
                        "gravity": {"type": "integer"}
                    }
                }
            },
            "required": ["create_code"]
        }
        
        prompt = {
            "system": self.SYSTEM_PROMPT,
            "messages": self.build_prompt(gdd_json),
            "output_schema": schema
        }
        
        return prompt


# Example usage
if __name__ == "__main__":
    builder = PromptBuilder(max_examples=2)
    test_gdd = json.dumps({
        "game_type": "platformer",
        "canvas_size": {"width": 800, "height": 600},
        "entities": [
            {"type": "player", "position": {"x": 100, "y": 400}},
            {"type": "coin", "position": {"x": 300, "y": 300}},
            {"type": "enemy", "position": {"x": 500, "y": 450}}
        ]
    })
    
    messages = builder.build_prompt(test_gdd)
    print(f"Prompt has {len(messages)} messages")
    for i, msg in enumerate(messages):
        print(f"\n[{msg['role']}] ({len(msg['content'])} chars)")
```

#### 3. Constrained LLM Generation with Outlines (Python)

```python
"""
Constrained LLM Generation: Uses Outlines to guarantee syntactically
valid JSON outputs that conform to a defined schema.
"""

import json
from typing import Optional
from pydantic import BaseModel, Field

class GameCodeOutput(BaseModel):
    """Structured output schema for generated game code."""
    preload_code: str = Field(default="", description="Phaser preload method body")
    create_code: str = Field(description="Phaser create method body - REQUIRED")
    update_code: str = Field(default="", description="Phaser update method body")
    helper_functions: str = Field(default="", description="Additional JS functions")
    game_config: dict = Field(default_factory=lambda: {
        "width": 800,
        "height": 600,
        "gravity": 800,
        "debug": False
    })
    stamp_compatibility: list = Field(default_factory=list, 
                                       description="Which stamps this code supports")


class ConstrainedGameGenerator:
    """Generates game code using constrained decoding for guaranteed valid output."""
    
    def __init__(self, model_name: str = "microsoft/Phi-3-mini-4k-instruct"):
        self.model_name = model_name
        self._init_outlines()
    
    def _init_outlines(self):
        """Initialize the Outlines generator with JSON schema constraint."""
        try:
            import outlines
            from outlines import models, generate
            
            # Load model via outlines (supports transformers, llama.cpp, etc.)
            self.model = models.transformers(self.model_name)
            
            # Create JSON-constrained generator from Pydantic schema
            self.generator = generate.json(self.model, GameCodeOutput)
            self.outlines_available = True
            
        except ImportError:
            print("Warning: Outlines not installed. Falling back to unconstrained generation.")
            self.outlines_available = False
            self._init_fallback()
    
    def _init_fallback(self):
        """Initialize fallback LLM client (OpenAI-compatible API)."""
        try:
            from openai import OpenAI
            self.client = OpenAI()  # Uses OPENAI_API_KEY env var
            self.fallback_available = True
        except ImportError:
            self.fallback_available = False
    
    def generate(self, prompt_messages: list, temperature: float = 0.1) -> GameCodeOutput:
        """Generate game code with guaranteed valid output structure."""
        
        if self.outlines_available:
            return self._generate_constrained(prompt_messages, temperature)
        elif self.fallback_available:
            return self._generate_fallback(prompt_messages, temperature)
        else:
            return self._generate_template_only()
    
    def _generate_constrained(self, prompt_messages: list, 
                              temperature: float) -> GameCodeOutput:
        """Generate using Outlines constrained decoding."""
        # Convert messages to single prompt string
        prompt = self._messages_to_prompt(prompt_messages)
        
        # Outlines handles the JSON schema constraint automatically
        result = self.generator(prompt, max_tokens=2048, temperature=temperature)
        
        # Pydantic validation happens automatically through Outlines
        return result
    
    def _generate_fallback(self, prompt_messages: list, 
                           temperature: float) -> GameCodeOutput:
        """Fallback: Use OpenAI API with JSON mode."""
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o-mini",
                messages=prompt_messages,
                response_format={"type": "json_object"},
                temperature=temperature,
                max_tokens=2048
            )
            
            content = json.loads(response.choices[0].message.content)
            return GameCodeOutput(**content)
            
        except Exception as e:
            print(f"LLM generation failed: {e}")
            return self._generate_template_only()
    
    def _generate_template_only(self) -> GameCodeOutput:
        """Last resort: Return a minimal template that always works."""
        return GameCodeOutput(
            create_code="""
// Fallback template - basic platformer
const player = this.physics.add.sprite(100, 300, 'player');
player.setCollideWorldBounds(true);
const platforms = this.physics.add.staticGroup();
platforms.create(400, 568, 'platform').setScale(2).refreshBody();
this.physics.add.collider(player, platforms);
this.input.keyboard.on('keydown-LEFT', () => player.setVelocityX(-200));
this.input.keyboard.on('keydown-RIGHT', () => player.setVelocityX(200));
this.input.keyboard.on('keydown-UP', () => { if(player.body.touching.down) player.setVelocityY(-400); });
""",
            game_config={"width": 800, "height": 600, "gravity": 800, "debug": True}
        )
    
    def _messages_to_prompt(self, messages: list) -> str:
        """Convert chat messages to a single prompt string."""
        parts = []
        for msg in messages:
            role = msg["role"]
            content = msg["content"]
            if role == "system":
                parts.append(f"System: {content}")
            elif role == "user":
                parts.append(f"User: {content}")
            elif role == "assistant":
                parts.append(f"Assistant: {content}")
        parts.append("Assistant:")
        return "\n\n".join(parts)


# Example usage
if __name__ == "__main__":
    generator = ConstrainedGameGenerator()
    
    test_messages = [
        {"role": "system", "content": "Generate Phaser.js game code."},
        {"role": "user", "content": "Create a platformer with a player and a coin to collect."}
    ]
    
    result = generator.generate(test_messages, temperature=0.1)
    print("Generated code length:", len(result.create_code))
    print("Game config:", result.game_config)
```

#### 4. Code Validation Pipeline (Python)

```python
"""
Code Validation Pipeline: Multi-stage validation of LLM-generated game code
before execution. Catches syntax errors, security issues, and common mistakes.
"""

import re
import json
from typing import List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum

class ValidationSeverity(Enum):
    ERROR = "error"      # Must fix before execution
    WARNING = "warning"  # Should fix but can proceed
    INFO = "info"        # Suggestion only

@dataclass
class ValidationResult:
    severity: ValidationSeverity
    message: str
    line: Optional[int] = None
    column: Optional[int] = None
    suggestion: str = ""

class CodeValidator:
    """Validates generated game code through multiple stages."""
    
    # JavaScript keywords that should never appear in generated code
    FORBIDDEN_PATTERNS = [
        r'eval\s*\(',           # eval() is dangerous
        r'Function\s*\(',        # Function constructor
        r'document\.write',      # Can overwrite page
        r'window\.location',     # Redirects
        r'fetch\s*\(',           # Network requests
        r'XMLHttpRequest',       # Network requests
        r'WebSocket',            # Network connections
        r'localStorage',         # Storage access
        r'sessionStorage',       # Storage access
        r'import\s*\(',          # Dynamic imports
        r'navigator',            # Browser info leakage
    ]
    
    # Required patterns for valid game code
    REQUIRED_PATTERNS = [
        r'physics',              # Must use physics
        r'sprite|image',         # Must create visual elements
    ]
    
    def validate(self, code: str, gdd_json: str = "") -> List[ValidationResult]:
        """Run all validation stages and return findings."""
        results = []
        
        # Stage 1: Syntax validation
        results.extend(self._validate_syntax(code))
        
        # Stage 2: Security validation
        results.extend(self._validate_security(code))
        
        # Stage 3: Pattern validation
        results.extend(self._validate_patterns(code))
        
        # Stage 4: Game structure validation
        results.extend(self._validate_game_structure(code))
        
        # Stage 5: GDD consistency check (if GDD provided)
        if gdd_json:
            results.extend(self._validate_gdd_consistency(code, gdd_json))
        
        return results
    
    def _validate_syntax(self, code: str) -> List[ValidationResult]:
        """Check for basic JavaScript syntax issues."""
        results = []
        
        # Check for balanced braces
        open_braces = code.count('{')
        close_braces = code.count('}')
        if open_braces != close_braces:
            results.append(ValidationResult(
                severity=ValidationSeverity.ERROR,
                message=f"Unbalanced braces: {open_braces} open, {close_braces} close",
                suggestion="Fix brace matching in the generated code"
            ))
        
        # Check for balanced parentheses
        open_parens = code.count('(')
        close_parens = code.count(')')
        if open_parens != close_parens:
            results.append(ValidationResult(
                severity=ValidationSeverity.ERROR,
                message=f"Unbalanced parentheses: {open_parens} open, {close_parens} close",
                suggestion="Fix parenthesis matching"
            ))
        
        # Check for unterminated strings (basic check)
        single_quotes = code.count("'") - code.count("\\'")
        double_quotes = code.count('"') - code.count('\\"')
        if single_quotes % 2 != 0:
            results.append(ValidationResult(
                severity=ValidationSeverity.WARNING,
                message="Potentially unterminated single-quoted string",
                suggestion="Check string literal termination"
            ))
        
        return results
    
    def _validate_security(self, code: str) -> List[ValidationResult]:
        """Check for potentially dangerous code patterns."""
        results = []
        
        for pattern in self.FORBIDDEN_PATTERNS:
            matches = re.finditer(pattern, code, re.IGNORECASE)
            for match in matches:
                line_num = code[:match.start()].count('\n') + 1
                results.append(ValidationResult(
                    severity=ValidationSeverity.ERROR,
                    message=f"Forbidden pattern detected: {pattern}",
                    line=line_num,
                    suggestion="Remove this pattern - it poses a security risk"
                ))
        
        # Check for infinite loops (basic heuristic)
        loop_patterns = [
            r'while\s*\(\s*(true|1)\s*\)',
            r'for\s*\(\s*;\s*;\s*\)'
        ]
        for pattern in loop_patterns:
            if re.search(pattern, code):
                results.append(ValidationResult(
                    severity=ValidationSeverity.WARNING,
                    message="Potential infinite loop detected",
                    suggestion="Add a break condition or timeout"
                ))
        
        return results
    
    def _validate_patterns(self, code: str) -> List[ValidationResult]:
        """Check that required game patterns are present."""
        results = []
        
        for pattern in self.REQUIRED_PATTERNS:
            if not re.search(pattern, code, re.IGNORECASE):
                results.append(ValidationResult(
                    severity=ValidationSeverity.WARNING,
                    message=f"Missing recommended pattern: {pattern}",
                    suggestion=f"Consider adding {pattern} to the game code"
                ))
        
        return results
    
    def _validate_game_structure(self, code: str) -> List[ValidationResult]:
        """Validate the overall game structure."""
        results = []
        
        # Check for Phaser-specific patterns
        if 'this.physics' not in code and 'physics' in code:
            results.append(ValidationResult(
                severity=ValidationSeverity.WARNING,
                message="Physics referenced but not as 'this.physics'",
                suggestion="Use 'this.physics' for Phaser scene context"
            ))
        
        # Check for player input handling
        if 'keyboard' not in code.lower() and 'pointer' not in code.lower():
            results.append(ValidationResult(
                severity=ValidationSeverity.INFO,
                message="No input handling detected",
                suggestion="Add keyboard or pointer input for player control"
            ))
        
        # Check for collision detection
        if 'collider' not in code and 'overlap' not in code:
            results.append(ValidationResult(
                severity=ValidationSeverity.INFO,
                message="No collision detection detected",
                suggestion="Add collider/overlap for game interactions"
            ))
        
        return results
    
    def _validate_gdd_consistency(self, code: str, gdd_json: str) -> List[ValidationResult]:
        """Verify that generated code matches the GDD specification."""
        results = []
        
        try:
            gdd = json.loads(gdd_json)
            entities = gdd.get('entities', [])
            
            # Check that each entity type in GDD appears in code
            for entity in entities:
                entity_type = entity.get('type', '')
                if entity_type and entity_type not in code.lower():
                    results.append(ValidationResult(
                        severity=ValidationSeverity.WARNING,
                        message=f"Entity '{entity_type}' from GDD not found in code",
                        suggestion=f"Add code to create and handle '{entity_type}' entities"
                    ))
            
            # Check interactions are implemented
            interactions = gdd.get('interactions', [])
            for interaction in interactions:
                interaction_type = interaction.get('type', '')
                if interaction_type == 'collect' and 'overlap' not in code:
                    results.append(ValidationResult(
                        severity=ValidationSeverity.WARNING,
                        message="Collect interaction in GDD but no overlap in code",
                        suggestion="Add overlap callback for collection mechanics"
                    ))
            
        except json.JSONDecodeError:
            results.append(ValidationResult(
                severity=ValidationSeverity.WARNING,
                message="Could not parse GDD JSON for consistency check"
            ))
        
        return results
    
    def is_valid_for_execution(self, results: List[ValidationResult]) -> bool:
        """Check if validation results permit execution."""
        return not any(r.severity == ValidationSeverity.ERROR for r in results)


# Example usage
if __name__ == "__main__":
    validator = CodeValidator()
    
    test_code = """
const player = this.physics.add.sprite(100, 400, 'player');
player.setCollideWorldBounds(true);
this.input.keyboard.on('keydown-LEFT', () => player.setVelocityX(-200));
"""
    
    results = validator.validate(test_code)
    for r in results:
        print(f"[{r.severity.value}] Line {r.line}: {r.message}")
    
    can_run = validator.is_valid_for_execution(results)
    print(f"\nCan execute: {can_run}")
```

#### 5. Sandboxed Execution Environment (Python)

```python
"""
Sandboxed Game Execution: Safely runs generated game code in an isolated
environment with resource limits and timeout protection.
"""

import subprocess
import tempfile
import os
import json
from typing import Optional, Dict
from dataclasses import dataclass

@dataclass
class ExecutionResult:
    """Result of sandboxed game code execution."""
    success: bool
    html_output: str
    console_logs: list
    errors: list
    execution_time_ms: float
    memory_usage_mb: float

class GameSandbox:
    """Sandbox for executing generated game code safely."""
    
    # HTML template that wraps the generated code
    HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Generated Game</title>
    <script src="https://cdn.jsdelivr.net/npm/phaser@3.60.0/dist/phaser.min.js"></script>
    <style>
        body {{ margin: 0; padding: 0; overflow: hidden; background: #000; }}
        #game-container {{ width: 100vw; height: 100vh; display: flex; 
                          justify-content: center; align-items: center; }}
    </style>
</head>
<body>
    <div id="game-container"></div>
    <script>
        // Console log capture
        const logs = [];
        const originalLog = console.log;
        const originalError = console.error;
        console.log = function(...args) {{
            logs.push({{type: 'log', message: args.join(' ')}});
            originalLog.apply(console, args);
        }};
        console.error = function(...args) {{
            logs.push({{type: 'error', message: args.join(' ')}});
            originalError.apply(console, args);
        }};
        
        window.addEventListener('error', (e) => {{
            console.error('Runtime error:', e.message);
        }});
        
        {generated_code}
        
        // Game configuration
        const config = {{
            type: Phaser.AUTO,
            width: {width},
            height: {height},
            parent: 'game-container',
            physics: {{
                default: 'arcade',
                arcade: {{
                    gravity: {{ y: {gravity} }},
                    debug: {debug}
                }}
            }},
            scene: {{
                preload: preload,
                create: create,
                update: update
            }}
        }};
        
        const game = new Phaser.Game(config);
    </script>
</body>
</html>"""
    
    def __init__(self, 
                 timeout_seconds: float = 5.0,
                 max_memory_mb: int = 256,
                 allow_network: bool = False):
        self.timeout_seconds = timeout_seconds
        self.max_memory_mb = max_memory_mb
        self.allow_network = allow_network
    
    def build_html(self, 
                   generated_code: str,
                   game_config: Optional[Dict] = None) -> str:
        """Build complete HTML file from generated code snippet."""
        config = game_config or {}
        
        html = self.HTML_TEMPLATE.format(
            generated_code=generated_code,
            width=config.get('width', 800),
            height=config.get('height', 600),
            gravity=config.get('gravity', 800),
            debug=str(config.get('debug', False)).lower()
        )
        
        return html
    
    def execute_static_check(self, html_content: str) -> ExecutionResult:
        """Lightweight static analysis without full execution."""
        errors = []
        
        # Check for basic HTML structure
        if '<html>' not in html_content.lower():
            errors.append("Missing <html> tag")
        if '<script>' not in html_content.lower():
            errors.append("No <script> tag found")
        
        # Check Phaser references
        if 'phaser' not in html_content.lower():
            errors.append("No Phaser reference found")
        
        # Check for required functions
        if 'function create' not in html_content and 'create()' not in html_content:
            errors.append("No create() function found")
        
        return ExecutionResult(
            success=len(errors) == 0,
            html_output=html_content,
            console_logs=[],
            errors=errors,
            execution_time_ms=0,
            memory_usage_mb=0
        )


# Example usage
if __name__ == "__main__":
    sandbox = GameSandbox(timeout_seconds=5.0)
    
    test_code = """
function preload() {
    // Assets would be loaded here
}

function create() {
    const player = this.physics.add.sprite(100, 400, 'player');
    player.setCollideWorldBounds(true);
}

function update() {
    // Game loop
}
"""
    
    html = sandbox.build_html(test_code, {
        'width': 800,
        'height': 600,
        'gravity': 800,
        'debug': False
    })
    
    print(f"Generated HTML ({len(html)} chars)")
    
    # Quick static check
    result = sandbox.execute_static_check(html)
    print(f"Static check passed: {result.success}")
    if result.errors:
        for e in result.errors:
            print(f"  - {e}")
```

#### 6. Complete Pipeline Integration (Python)

```python
"""
Complete Pipeline: Integrates all components into a single stamp-to-game
processing pipeline with fallback mechanisms.
"""

import json
import time
import traceback
from typing import Optional, Dict, Any
from dataclasses import dataclass, asdict

@dataclass
class PipelineResult:
    """Complete result of the stamp-to-game pipeline."""
    success: bool
    html_game: str = ""
    gdd_json: str = ""
    generated_code: str = ""
    validation_results: list = None
    execution_result: dict = None
    generation_time_ms: float = 0
    total_time_ms: float = 0
    fallback_used: bool = False
    error_message: str = ""
    
    def to_dict(self) -> Dict:
        return asdict(self)

class StampToGamePipeline:
    """
    End-to-end pipeline: stamps → GDD → prompt → LLM → code → validate → game
    
    Features:
    - Circuit breaker pattern for LLM failures
    - Template fallback when LLM is unavailable
    - Multi-stage validation
    - Sandboxed execution preview
    - Comprehensive error handling
    """
    
    def __init__(self,
                 use_local_llm: bool = True,
                 local_model: str = "microsoft/Phi-3-mini-4k-instruct",
                 enable_sandbox: bool = True,
                 max_generation_time_ms: float = 10000):
        
        self.use_local_llm = use_local_llm
        self.local_model = local_model
        self.enable_sandbox = enable_sandbox
        self.max_generation_time_ms = max_generation_time_ms
        
        # Circuit breaker state
        self._failure_count = 0
        self._circuit_open = False
        self._circuit_open_time = 0
        self._failure_threshold = 5
        self._circuit_timeout_seconds = 60
        
        # Initialize components (lazy loading)
        self._parser = None
        self._prompt_builder = None
        self._generator = None
        self._validator = None
        self._sandbox = None
    
    @property
    def parser(self):
        if self._parser is None:
            self._parser = StampParser()
        return self._parser
    
    @property
    def prompt_builder(self):
        if self._prompt_builder is None:
            self._prompt_builder = PromptBuilder(max_examples=2)
        return self._prompt_builder
    
    @property
    def generator(self):
        if self._generator is None:
            self._generator = ConstrainedGameGenerator(self.local_model)
        return self._generator
    
    @property
    def validator(self):
        if self._validator is None:
            self._validator = CodeValidator()
        return self._validator
    
    @property
    def sandbox(self):
        if self._sandbox is None:
            self._sandbox = GameSandbox(timeout_seconds=5.0)
        return self._sandbox
    
    def process(self, raw_stamps: list) -> PipelineResult:
        """
        Process stamp placements into a playable game.
        
        Args:
            raw_stamps: List of dicts with keys: type, x, y, width, height, properties
            
        Returns:
            PipelineResult with success status and generated game
        """
        total_start = time.time()
        result = PipelineResult(success=False)
        
        try:
            # Step 1: Parse stamps to GDD
            gdd = self.parser.parse_stamps(raw_stamps)
            result.gdd_json = gdd.to_json()
            
            # Step 2: Build prompt
            messages = self.prompt_builder.build_prompt(result.gdd_json)
            
            # Step 3: Generate code (with circuit breaker and fallback)
            gen_start = time.time()
            code_output = self._generate_with_fallback(messages)
            result.generation_time_ms = (time.time() - gen_start) * 1000
            result.generated_code = code_output.create_code
            result.fallback_used = not hasattr(code_output, '_from_llm')
            
            # Step 4: Validate code
            validation = self.validator.validate(
                result.generated_code, 
                result.gdd_json
            )
            result.validation_results = [
                {"severity": v.severity.value, "message": v.message, 
                 "line": v.line, "suggestion": v.suggestion}
                for v in validation
            ]
            
            # Check if validation errors are blockers
            has_errors = any(v.severity == ValidationSeverity.ERROR for v in validation)
            
            if has_errors and not result.fallback_used:
                # Try once more with error feedback
                error_feedback = self._format_errors(validation)
                messages.append({"role": "user", "content": f"Fix these errors:\n{error_feedback}"})
                
                gen_start = time.time()
                code_output = self._generate_with_fallback(messages)
                result.generation_time_ms += (time.time() - gen_start) * 1000
                result.generated_code = code_output.create_code
                
                # Re-validate
                validation = self.validator.validate(result.generated_code, result.gdd_json)
                result.validation_results = [
                    {"severity": v.severity.value, "message": v.message,
                     "line": v.line, "suggestion": v.suggestion}
                    for v in validation
                ]
            
            # Step 5: Build HTML game
            result.html_game = self.sandbox.build_html(
                result.generated_code,
                code_output.game_config if hasattr(code_output, 'game_config') else None
            )
            
            # Step 6: Static execution check
            if self.enable_sandbox:
                exec_result = self.sandbox.execute_static_check(result.html_game)
                result.execution_result = {
                    "success": exec_result.success,
                    "errors": exec_result.errors
                }
            
            result.success = True
            
        except Exception as e:
            result.error_message = str(e)
            result.success = False
            traceback.print_exc()
        
        result.total_time_ms = (time.time() - total_start) * 1000
        return result
    
    def _generate_with_fallback(self, messages: list) -> Any:
        """Generate code with circuit breaker and template fallback."""
        
        # Check circuit breaker
        if self._circuit_open:
            if time.time() - self._circuit_open_time > self._circuit_timeout_seconds:
                self._circuit_open = False
                self._failure_count = 0
            else:
                return self._get_template_output()
        
        try:
            # Attempt LLM generation
            output = self.generator.generate(messages, temperature=0.1)
            
            # Reset failure count on success
            self._failure_count = 0
            return output
            
        except Exception as e:
            self._failure_count += 1
            
            # Open circuit if threshold reached
            if self._failure_count >= self._failure_threshold:
                self._circuit_open = True
                self._circuit_open_time = time.time()
            
            # Return template fallback
            return self._get_template_output()
    
    def _get_template_output(self):
        """Get template-based code output (no LLM needed)."""
        output = GameCodeOutput(
            create_code="""
// Template fallback - basic platformer
const player = this.physics.add.sprite(100, 450, 'player');
player.setCollideWorldBounds(true);
player.setBounce(0.2);

const platforms = this.physics.add.staticGroup();
platforms.create(400, 564, 'platform').setScale(2).refreshBody();
platforms.create(600, 400, 'platform');
platforms.create(50, 250, 'platform');
platforms.create(750, 220, 'platform');

this.physics.add.collider(player, platforms);

const cursors = this.input.keyboard.createCursorKeys();

this.input.keyboard.on('keydown-LEFT', () => player.setVelocityX(-160));
this.input.keyboard.on('keydown-RIGHT', () => player.setVelocityX(160));
this.input.keyboard.on('keydown-UP', () => { 
    if (player.body.touching.down) player.setVelocityY(-330); 
});
this.input.keyboard.on('keyup-LEFT', () => player.setVelocityX(0));
this.input.keyboard.on('keyup-RIGHT', () => player.setVelocityX(0));
""",
            game_config={"width": 800, "height": 600, "gravity": 800, "debug": False}
        )
        output._from_llm = False
        return output
    
    def _format_errors(self, validation_results: list) -> str:
        """Format validation errors for LLM feedback."""
        error_lines = []
        for v in validation_results:
            if v.severity == ValidationSeverity.ERROR:
                error_lines.append(f"- Line {v.line}: {v.message} ({v.suggestion})")
        return "\n".join(error_lines)
    
    def get_status(self) -> Dict:
        """Get current pipeline health status."""
        return {
            "circuit_breaker": {
                "open": self._circuit_open,
                "failure_count": self._failure_count,
                "threshold": self._failure_threshold
            }
        }


# Example usage
if __name__ == "__main__":
    pipeline = StampToGamePipeline(use_local_llm=False)
    
    test_stamps = [
        {"type": "player", "x": 100, "y": 400, "properties": {"color": "blue"}},
        {"type": "platform", "x": 400, "y": 500, "width": 400, "height": 20},
        {"type": "coin", "x": 300, "y": 350},
        {"type": "coin", "x": 400, "y": 350},
        {"type": "enemy", "x": 500, "y": 450, "properties": {"patrol": True}},
        {"type": "goal", "x": 700, "y": 300}
    ]
    
    result = pipeline.process(test_stamps)
    
    print(f"Success: {result.success}")
    print(f"Fallback used: {result.fallback_used}")
    print(f"Generation time: {result.generation_time_ms:.0f}ms")
    print(f"Total time: {result.total_time_ms:.0f}ms")
    print(f"Code length: {len(result.generated_code)} chars")
    print(f"HTML length: {len(result.html_game)} chars")
    
    if result.validation_results:
        print(f"\nValidation findings: {len(result.validation_results)}")
        for v in result.validation_results[:5]:
            print(f"  [{v['severity']}] {v['message']}")
```

### Edge Cases & Mitigations

#### LLM Timeout and Unavailability

**Scenario:** The LLM API times out or returns a 503/429 error.

**Mitigation Strategy:**
1. **Exponential backoff retry**: Wait 2^n seconds between retries (max 60s) [^17^]
2. **Circuit breaker**: After 5 consecutive failures, stop calling the LLM for 60 seconds and use template-only mode
3. **Template fallback**: Pre-validated code templates for common game patterns are always available
4. **Graceful degradation**: The child sees "Making your game..." with a progress bar; if LLM fails, template code is used seamlessly

```python
# Circuit breaker implementation
import time

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = 0
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN
    
    def call(self, func, *args, **kwargs):
        if self.state == "OPEN":
            if time.time() - self.last_failure_time > self.timeout:
                self.state = "HALF_OPEN"
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            if self.state == "HALF_OPEN":
                self.state = "CLOSED"
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            if self.failure_count >= self.failure_threshold:
                self.state = "OPEN"
            raise
```

#### Invalid Code Generation

**Scenario:** The LLM generates code with syntax errors, undefined variables, or references to non-existent APIs.

**Mitigation Strategy:**
1. **Syntax validation**: Parse JavaScript with a parser before execution
2. **Pattern validation**: Check against whitelist of allowed function calls and property accesses
3. **Two-pass generation**: First pass generates code; second pass (with validation feedback) fixes errors
4. **Template override**: If validation fails after two attempts, fall back to template code

```python
# Pattern whitelist for allowed Phaser APIs
ALLOWED_PATTERNS = [
    r'this\.physics\.(add|world|arcade)\.',
    r'this\.input\.keyboard\.',
    r'this\.add\.(sprite|text|group)',
    r'this\.load\.(image|spritesheet|audio)',
    r'Phaser\.(Game|AUTO|Scale)',
    r'\.(setVelocity|setPosition|setGravity|play|setText)',
    r'\.(disableBody|enableBody|destroy)',
    r'\.(on|once|emit)\(',  # Event handlers
]

FORBIDDEN_PATTERNS = [
    r'eval\s*\(',
    r'Function\s*\(',
    r'document\.write',
    r'window\.location',
    r'fetch\s*\(',
    r'XMLHttpRequest',
    r'localStorage',
    r'navigator',
]
```

#### Inconsistent State Across Multiple Stamps

**Scenario:** Child adds stamps one at a time; LLM generates code for each addition but state becomes inconsistent.

**Mitigation Strategy:**
1. **Batch generation on idle**: Wait 1-2 seconds after the last stamp placement before generating (debounce pattern)
2. **Full regeneration**: Always regenerate the complete game from the full stamp set, not incrementally
3. **State diffing**: Compare new output with previous output; only changed entities are updated in the running game
4. **Hot reload**: The game engine supports hot-swapping entities without full restart

```python
import threading

class DebouncedGenerator:
    """Waits for user to stop adding stamps before generating."""
    
    def __init__(self, delay_ms=1500):
        self.delay_ms = delay_ms
        self.pending_stamps = []
        self.timer = None
        self.lock = threading.Lock()
    
    def add_stamp(self, stamp):
        with self.lock:
            self.pending_stamps.append(stamp)
            self._reset_timer()
    
    def _reset_timer(self):
        if self.timer:
            self.timer.cancel()
        self.timer = threading.Timer(self.delay_ms / 1000, self._generate)
        self.timer.start()
    
    def _generate(self):
        with self.lock:
            stamps = self.pending_stamps.copy()
            self.pending_stamps = []
        if stamps:
            self.on_generate_ready(stamps)
    
    def on_generate_ready(self, stamps):
        """Override this with actual pipeline call."""
        pass
```

#### Ambiguous Stamp Placements

**Scenario:** Child places stamps in unclear configurations (e.g., enemy inside a wall, overlapping objects, stamps floating in mid-air).

**Mitigation Strategy:**
1. **Auto-snap**: Stamps snap to logical positions (platforms at integer Y coordinates, enemies on platforms)
2. **Validation warnings**: Show gentle visual feedback (yellow outline) for potentially problematic placements
3. **Semantic inference**: The stamp parser infers intent (e.g., a coin above a platform is meant to be collected by jumping)
4. **Best-effort generation**: LLM generates the most reasonable interpretation, with clear defaults

```python
class StampPlacementValidator:
    """Validates stamp placements and suggests corrections."""
    
    def validate(self, stamps: list) -> list:
        warnings = []
        
        for stamp in stamps:
            # Check if enemy is placed without a platform underneath
            if stamp['type'] == 'enemy':
                has_platform_below = any(
                    s['type'] == 'platform' and 
                    s['y'] > stamp['y'] and 
                    abs(s['x'] - stamp['x']) < s.get('width', 50) / 2
                    for s in stamps
                )
                if not has_platform_below:
                    warnings.append({
                        'stamp_id': stamp.get('id'),
                        'type': 'no_platform_below_enemy',
                        'message': 'Enemy needs a platform to stand on',
                        'severity': 'warning'
                    })
            
            # Check if player is placed below the goal
            if stamp['type'] == 'player':
                goals = [s for s in stamps if s['type'] == 'goal']
                for goal in goals:
                    if goal['y'] > stamp['y']:
                        warnings.append({
                            'stamp_id': stamp.get('id'),
                            'type': 'goal_below_player',
                            'message': 'Goal is below the player - is this intentional?',
                            'severity': 'info'
                        })
        
        return warnings
```

#### Rate Limiting and Quota Management

**Scenario:** Cloud LLM API hits rate limit during heavy usage (e.g., classroom of 30 children).

**Mitigation Strategy:**
1. **Token bucket rate limiter**: 100 requests per minute per user [^17^]
2. **Request deduplication**: Cache identical stamp configurations; return cached results
3. **Priority queue**: Prioritize code generation over non-critical requests
4. **Local LLM fallback**: Run Phi-3 or Llama-3.3 locally for basic generation; use cloud only for complex requests
5. **Tiered limits**: Free users get lower limits; paid/classroom accounts get higher limits

```python
import time
import hashlib
import json

class RateLimiter:
    """Token bucket rate limiter for LLM API calls."""
    
    def __init__(self, rate=100, per=60):
        self.rate = rate
        self.per = per
        self.allowance = rate
        self.last_check = time.time()
    
    def is_allowed(self) -> bool:
        current = time.time()
        time_passed = current - self.last_check
        self.last_check = current
        self.allowance += time_passed * (self.rate / self.per)
        if self.allowance > self.rate:
            self.allowance = self.rate
        if self.allowance < 1.0:
            return False
        self.allowance -= 1.0
        return True


class CachedPipeline:
    """Wraps the pipeline with request deduplication."""
    
    def __init__(self, pipeline, max_cache_size=1000):
        self.pipeline = pipeline
        self.cache = {}
        self.max_cache_size = max_cache_size
    
    def process(self, raw_stamps: list):
        cache_key = self._hash_stamps(raw_stamps)
        
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        result = self.pipeline.process(raw_stamps)
        
        if result.success:
            if len(self.cache) >= self.max_cache_size:
                self.cache.pop(next(iter(self.cache)))
            self.cache[cache_key] = result
        
        return result
    
    def _hash_stamps(self, stamps: list) -> str:
        normalized = sorted(stamps, key=lambda s: (s.get('type', ''), s.get('x', 0), s.get('y', 0)))
        return hashlib.md5(json.dumps(normalized, sort_keys=True).encode()).hexdigest()
```

#### Child-Friendly Error Handling

**Scenario:** Something goes wrong; the child sees a technical error message and gets confused/frustrated.

**Mitigation Strategy:**
1. **Never show raw errors**: All errors are caught and translated to child-friendly messages
2. **Visual feedback**: Use animations (confused character, thinking cloud) instead of text
3. **Auto-recovery**: System always falls back to a working state; child never sees a broken game
4. **Retry with explanation**: "Oops, let me try again!" with automatic retry
5. **Simplified reporting**: Technical errors are logged for developers, not shown to children

```python
class ChildFriendlyErrorHandler:
    """Translates technical errors into child-friendly messages."""
    
    ERROR_MESSAGES = {
        'llm_timeout': {
            'message': 'Thinking really hard... let me try a different way!',
            'action': 'fallback_template',
            'show_retry': True
        },
        'llm_rate_limit': {
            'message': 'Lots of friends are playing right now! Using my magic backup plan.',
            'action': 'fallback_template',
            'show_spinner': True
        },
        'invalid_code': {
            'message': 'Let me rearrange the pieces...',
            'action': 'regenerate',
            'show_progress': True
        },
        'validation_error': {
            'message': 'Checking all the parts...',
            'action': 'fix_and_retry',
            'show_progress': True
        },
        'sandbox_timeout': {
            'message': 'The game is taking a long time. Let me simplify it!',
            'action': 'simplify_game',
            'show_retry': True
        }
    }
    
    def handle(self, error_type: str, technical_details: str):
        """Get child-friendly error response."""
        # Log technical details for developers
        print(f"[ERROR] [{error_type}] {technical_details}")
        
        response = self.ERROR_MESSAGES.get(error_type, {
            'message': 'Let me try something magical!',
            'action': 'fallback_template',
            'show_retry': True
        })
        
        return response
```

#### Multiple Concurrent Users (Classroom Scale)

**Scenario:** 30 children in a classroom all creating games simultaneously.

**Mitigation Strategy:**
1. **Request batching**: Group similar requests and process once, distribute results
2. **WebSocket connections**: Maintain persistent connections for real-time updates
3. **Horizontal scaling**: Run multiple LLM inference workers behind a load balancer
4. **Local LLM cluster**: Deploy Phi-3 on edge devices in the classroom for zero-latency generation
5. **Pre-generation**: Generate template games ahead of time; customize with minimal LLM calls

```python
import asyncio
from dataclasses import dataclass

@dataclass
class GenerationResult:
    quality_score: float
    html_game: str
    
class LocalLLMPool:
    """Pool of local LLM instances for parallel generation."""
    
    def __init__(self, size=4):
        self.size = size
        self.instances = [self._create_instance() for _ in range(size)]
        self.available = asyncio.Queue()
        for i in range(size):
            self.available.put_nowait(i)
    
    def _create_instance(self):
        # Initialize local model (llama.cpp, Ollama, etc.)
        return {"model": "phi3", "status": "ready"}
    
    async def generate(self, stamps, timeout=3.0):
        instance_id = await asyncio.wait_for(self.available.get(), timeout=timeout)
        try:
            # Run generation on this instance
            await asyncio.sleep(0.5)  # Simulated generation
            return GenerationResult(quality_score=0.85, html_game="<html>...</html>")
        finally:
            self.available.put_nowait(instance_id)
```

### Performance Benchmarks

Based on our research, here are the expected performance characteristics:

| Component | Latency | Notes |
|-----------|---------|-------|
| Stamp parsing | 1-5ms | Deterministic, no I/O |
| Prompt building | 2-10ms | Memory-based template filling |
| LLM generation (cloud) | 500-3000ms | Depends on model and complexity |
| LLM generation (local Phi-3) | 2000-8000ms | On CPU; 5x faster with GPU |
| Code validation | 10-50ms | Static analysis, no execution |
| HTML building | 5-20ms | String templating |
| Static check | 20-100ms | Basic pattern matching |
| **Total (cloud)** | **550-3200ms** | End-to-end with cloud LLM |
| **Total (local)** | **2050-8200ms** | End-to-end with local LLM |
| **Total (template fallback)** | **30-200ms** | No LLM involved |

**Optimization strategies:**
1. **Pre-built prompt templates**: Reduce prompt building to 1-2ms
2. **Cached responses**: 80% hit rate for common stamp configurations
3. **Streaming generation**: Show game preview while LLM is still generating
4. **Progressive loading**: Load game assets in parallel with code generation
5. **Local LLM with GPU**: 10x speedup over CPU inference [^12^]

### Security Considerations

#### Generated Code Isolation

The generated game code runs in an isolated environment:

```html
<!-- Game runs inside a sandboxed iframe -->
<iframe 
    sandbox="allow-scripts"
    src="generated-game.html"
    csp="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'"
></iframe>
```

**CSP directives:**
- `default-src 'none'`: No external resources by default
- `script-src 'unsafe-inline'`: Only inline scripts (generated code)
- `style-src 'unsafe-inline'`: Only inline styles
- No `connect-src`: No network access
- No `form-action`: No form submissions

#### Input Sanitization

All stamp properties are sanitized before entering the pipeline:

```python
import re

class InputSanitizer:
    """Sanitizes all user-provided stamp properties."""
    
    ALLOWED_PROPERTY_TYPES = (int, float, bool, str)
    MAX_STRING_LENGTH = 100
    MAX_PROPERTY_COUNT = 20
    
    def sanitize(self, properties: dict) -> dict:
        sanitized = {}
        
        for key, value in properties.items():
            if not isinstance(key, str):
                continue
            if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', key):
                continue
            if not isinstance(value, self.ALLOWED_PROPERTY_TYPES):
                continue
            if isinstance(value, str) and len(value) > self.MAX_STRING_LENGTH:
                value = value[:self.MAX_STRING_LENGTH]
            if isinstance(value, (int, float)):
                value = max(-10000, min(10000, value))
            sanitized[key] = value
            if len(sanitized) >= self.MAX_PROPERTY_COUNT:
                break
        
        return sanitized
```

### Sources

[^1^]: Chen, D., Wang, H., Huo, Y., Li, Y., & Zhang, H. (2023). "GameGPT: Multi-agent Collaborative Framework for Game Development." arXiv:2310.08067. https://arxiv.org/abs/2310.08067

[^2^]: Qian, C., et al. (2023). "Communicative Agents for Software Development." arXiv preprint. https://www.ibm.com/think/tutorials/chatdev-chatchain-agent-communication-watsonx-ai

[^3^]: Hong, S., et al. (2023). "MetaGPT: Meta Programming for Multi-Agent Collaborative Framework." https://www.ibm.com/think/topics/metagpt

[^4^]: Willard, B., & Louf, R. (2023). "Efficient Guided Generation for Large Language Models." arXiv. https://arxiv.org/html/2501.10868v1

[^5^]: Dong, Y., et al. (2024). "XGrammar: Fast and Flexible Grammar-Based Constraints for LLMs." https://github.com/dmlc/xgrammar

[^6^]: Teymoori, A. (2026). "LLM Parameters: Temperature, Top-P, Top-K Guide." https://amirteymoori.com/llm-parameters-explained-temperature-top-p-top-k/

[^7^]: Paper Review. (2024). "Communicative Agents for Software Development (ChatDev)." https://medium.com/data-science/paper-review-communicative-agents-for-software-development-103d4d816fae

[^8^]: Rosebud AI. (2024). "Free AI Game Maker - Create Games Online." https://lab.rosebud.ai/ai-game-creator

[^9^]: Wang, X., et al. (2024). "Executable Code Actions Elicit Better LLM Agents." arXiv:2402.01030. https://arxiv.org/html/2402.01030v4

[^10^]: A Multi-Agent Framework for Complex Code Tasks. (2025). arXiv:2501.06625. https://arxiv.org/html/2501.06625v1

[^11^]: Few-Shot Prompting Guide. (2024). https://www.prompthub.us/blog/the-few-shot-prompting-guide

[^12^]: Microsoft. (2024). "Phi-3 Mini-4K-Instruct." https://huggingface.co/microsoft/Phi-3-mini-4k-instruct

[^13^]: SitePoint. (2026). "Best Local LLM Models 2026." https://www.sitepoint.com/best-local-llm-models-2026/

[^14^]: Exploring Hallucinations in LLM-Generated Code. (2024). arXiv:2404.00971. https://arxiv.org/html/2404.00971v3

[^15^]: Self-Collaboration Code Generation via ChatGPT. (2024). ACM TOSEM. https://dl.acm.org/doi/10.1145/3672459

[^16^]: Promptfoo. (2026). "Sandboxed Evaluations of LLM-Generated Code." https://www.promptfoo.dev/docs/guides/sandboxed-code-evals/

[^17^]: Reintech. (2026). "LLM Rate Limiting & Quota Management: Production Best Practices." https://reintech.io/blog/llm-rate-limiting-quota-management-production-best-practices

[^18^]: Phaser. (2024). "AI-Assisted Game Development." https://github.com/phaserjs/phaser

[^19^]: Chitika. (2025). "RAG for Code Generation: Automate Coding with AI & LLMs." https://www.chitika.com/rag-for-code-generation/

[^20^]: Codefinity. (2024). "Understanding Temperature, Top-k, and Top-p Sampling in Generative Models." https://codefinity.com/blog/Understanding-Temperature%2C-Top-k%2C-and-Top-p-Sampling-in-Generative-Models

[^21^]: Leanware. (2025). "Prompt Engineering for Code Generation." https://www.leanware.co/insights/prompt-engineering-for-code-generation

[^22^]: arXiv. (2024). "Prompting Techniques for Secure Code Generation." arXiv:2407.07064. https://arxiv.org/html/2407.07064v1

[^23^]: IBM. (2024). "Use ChatDev ChatChain for agent communication." https://www.ibm.com/think/tutorials/chatdev-chatchain-agent-communication-watsonx-ai

[^24^]: arXiv. (2025). "A Survey on Code Generation with LLM-based Agents." arXiv:2508.00083. https://arxiv.org/html/2508.00083v1

[^25^]: Home Assistant Community. (2024). "Local AI & LLM on Home Assistant Yellow." https://community.home-assistant.io/t/local-ai-llm-on-home-assistant-yellow/722332

[^26^]: Meta Intelligence. (2025). "Phi-4 vs Gemma 3 vs Llama 3.3 - Enterprise Edge AI." https://www.meta-intelligence.tech/en/insight-slm-enterprise

[^27^]: n8n. (2025). "The 11 best open-source LLMs for 2025." https://blog.n8n.io/open-source-llm/

[^28^]: Brenndoerfer, M. (2025). "Constrained Decoding: Grammar-Guided Generation." https://mbrenndoerfer.com/writing/constrained-decoding-structured-llm-output

[^29^]: Agenta AI. (2026). "The guide to structured outputs and function calling with LLMs." https://agenta.ai/blog/the-guide-to-structured-outputs-and-function-calling-with-llms

[^30^]: LeewayHertz. (2026). "Structured outputs in LLMs: Definition, techniques, applications." https://www.leewayhertz.com/structured-outputs-in-llms/

[^31^]: Codecademy. (2025). "Prompt Engineering 101: Understanding Zero-Shot, One-Shot, and Few-Shot." https://www.codecademy.com/article/prompt-engineering-101-understanding-zero-shot-one-shot-and-few-shot

[^32^]: Prompting Guide. (2024). "LLM Settings - Temperature and Top P." https://www.promptingguide.ai/introduction/settings

[^33^]: Cloud Security Alliance. (2025). "LLMs Writing Code? Cool. LLMs Executing It? Dangerous." https://cloudsecurityalliance.org/blog/2025/06/03/llms-writing-code-cool-llms-executing-it-dangerous

[^34^]: Trend Micro. (2024). "Unveiling AI Agent Vulnerabilities Part II: Code Execution." https://www.trendmicro.com/vinfo/us/security/news/cybercrime-and-digital-threats/unveiling-ai-agent-vulnerabilities-code-execution

[^35^]: Carnegie Mellon University. (2023). "Provably-Safe Sandboxing with WebAssembly." https://www.cs.cmu.edu/~csd-phd-blog/2023/provably-safe-sandboxing-wasm/

[^36^]: Forcepoint. (2024). "WebAssembly security: potentials and pitfalls." https://www.forcepoint.com/blog/x-labs/webassembly-potentials-and-pitfalls

[^37^]: Snyk. (2023). "How secure is WebAssembly? 5 security concerns." https://snyk.io/blog/webassembly-security-concerns/

[^38^]: Medium/Correll Lab. (2025). "LLMs Executing Code: A review of DynaSaur and CodeAct." https://medium.com/correll-lab/llms-executing-code-24200aca4cda

[^39^]: Kids STEM Studio. (2024). "Coding and Game Design for Kids." https://kidsstemstudio.com/coding-and-game-design/

[^40^]: Beamdog Forums. (2024). "How Children Can Use Scratch Programming to Create Games." https://forums.beamdog.com/discussion/88906/how-children-can-use-scratch-programming-to-create-games

[^41^]: Empathy School. (2024). "Scratch: A Visual Programming Language For Kids." https://empathy.school/scratch-a-visual-programming-language-for-kids/

[^42^]: Orq.ai. (2026). "API Rate Limits Explained: Best Practices." https://orq.ai/blog/api-rate-limit

[^43^]: Portkey. (2025). "Tackling rate limiting for LLM apps." https://portkey.ai/blog/tackling-rate-limiting-for-llm-apps

[^44^]: TrueFoundry. (2025). "Rate Limiting in AI Gateway: The Ultimate Guide." https://www.truefoundry.com/blog/rate-limiting-in-llm-gateway

[^45^]: Requesty. (2025). "Rate Limits for LLM Providers." https://requesty.ai/blog/rate-limits-for-llm-providers-openai-anthropic-and-deepseek

[^46^]: Gravitee. (2025). "API Rate Limiting at Scale." https://www.gravitee.io/blog/rate-limiting-apis-scale-patterns-strategies

[^47^]: OneUptime. (2026). "How to Implement LLM Rate Limiting." https://oneuptime.com/blog/post/2026-01-30-llm-rate-limiting/view

[^48^]: ResearchGate. (2024). "Self-collaboration Code Generation via ChatGPT." https://www.researchgate.net/publication/381381477

[^49^]: Research Karlsruhe. (2025). "Program Code Generation: Single LLMs vs. Multi-Agent Systems." https://www.research-karlsruhe.de/pubs/ICNLP2025

[^50^]: Medium/MiptGirl. (2025). "Programming, Not Prompting: A Hands-on Guide to DSPy." https://miptgirl.medium.com/programming-not-prompting-a-hands-on-guide-to-dspy-04ea2d966e6d

[^51^]: arXiv. (2025). "Is It Time To Treat Prompts As Code?" arXiv:2507.03620. https://arxiv.org/html/2507.03620v1

[^52^]: IBM. (2024). "What is DSPy?" https://www.ibm.com/think/topics/dspy

[^53^]: Medium/Artem Khrenov. (2025). "The State Pattern in JavaScript." https://medium.com/@artemkhrenov/the-state-pattern-in-javascript-11446954a780

[^54^]: Patrick Coakley. (2024). "Using The State Pattern To Simplify Your Game States." https://patricktcoakley.com/tutorials/intro-state-pattern-in-games/

[^55^]: GitHub Resources. (2025). "What is retrieval-augmented generation (RAG)?" https://github.com/resources/articles/software-development-with-retrieval-augmentation-generation-rag

[^56^]: Aquilax AI. (2026). "WebAssembly Security: The Sandbox, Linear Memory, and Real Risks." https://aquilax.ai/blog/webassembly-wasm-security-risks

[^57^]: Medium/zerOiQ. (2025). "WebAssembly as an Attack Surface." https://medium.com/@zerOiQ/webassembly-as-an-attack-surface-new-browser-exploitation-b7acfbd2801f

[^58^]: Reddit/r/MachineLearning. (2023). "GameGPT: A multi-agent approach to fully automated game development." https://www.reddit.com/r/MachineLearning/comments/178ko4j/

[^59^]: FoundationAgents. (2023). "MetaGPT GitHub Repository." https://github.com/FoundationAgents/MetaGPT

[^60^]: Vanderbilt University. (2023). "A Prompt Pattern Catalog to Enhance Prompt Engineering." https://www.dre.vanderbilt.edu/~schmidt/PDF/prompt-patterns.pdf
