# git-agent-system

A single git-native agent that uses git objects as its entire state machine. No databases, no message queues, no runtimes — just git.

## Concept

This is the single-agent counterpart to [git-native-agents](https://github.com/SuperInstance/git-native-agents) (the multi-agent fleet system). Where that project orchestrates many agents, this one focuses on one agent's lifecycle using pure git primitives:

- **Git notes** → Inbox messages (transient, processed on tick)
- **Git tags** → Persistent memory (key-value store, O(1) lookup)
- **Git branches** → Thought/scratch space (parallel exploration)
- **Git commits** → State transitions (fully auditable history)
- **`.agent-state/`** → Lightweight runtime state (name, tick count, status)

Every operation is a git operation. Every state change is a commit. The entire agent history is inspectable with `git log`.

## Installation

```bash
git clone https://github.com/SuperInstance/git-agent-system.git
cd git-agent-system
chmod +x agent.sh
```

**Requirements:** Bash 4+, git 2.20+

## Usage

```bash
# Initialize the agent (creates workspace, sets identity)
./agent.sh init "my-agent"

# Send a message to the agent's inbox (via git notes)
./agent.sh send "analyze the fibonacci sequence"

# Process inbox — one tick cycle
./agent.sh tick

# Store a persistent memory (creates a git tag)
./agent.sh remember "fib10" "55"

# Recall a memory (reads from git tag)
./agent.sh recall "fib10"
# Output: 55

# Start exploring an idea in isolation
./agent.sh think "optimization-strategies"

# Merge the thought branch back to main
./agent.sh decide "optimization-strategies"

# Check agent state
./agent.sh status
# Agent: my-agent | Tick: 3 | Status: idle | Commits: 7
```

## Commands

| Command | Description |
|---------|-------------|
| `init <name>` | Spawn a new agent with the given name |
| `tick` | Process inbox messages, update state |
| `send <msg>` | Queue a message to the agent's inbox |
| `remember <key> <value>` | Store a tagged memory |
| `recall <key>` | Retrieve a tagged memory |
| `think <topic>` | Create a thought branch for exploration |
| `decide <topic>` | Merge thought branch back to main |
| `status` | Show agent name, tick count, status, and recent commits |

## Why Git?

1. **Zero dependencies** — only requires git and bash
2. **Fully auditable** — every state change is a commit with diff, author, timestamp
3. **Merge conflicts** force consensus between competing thoughts
4. **Branches** naturally model parallel exploration without locks
5. **Tags** provide O(1) named memory lookup
6. **Notes** give a transient channel separate from committed state

## Project Structure

```
.
├── agent.sh           # Main CLI — all agent operations
├── .agent-state/
│   ├── name           # Agent identity
│   ├── tick           # Current tick count
│   └── status         # Current status (idle/working)
├── workspace/         # Git repo created on init (agent's working memory)
├── LICENSE
└── README.md
```

## Part of [SuperInstance](https://superinstance.ai)

## License

MIT
