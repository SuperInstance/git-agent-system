# git-agent-system

A single git-native agent that uses git objects as its entire state machine. No databases, no message queues — just git.

## Concept

Instead of external infrastructure, this agent uses:

- **Git notes** → inbox messages
- **Git tags** → persistent memory (key-value store)
- **Git branches** → thought/scratch space
- **Git commits** → state transitions (auditable history)

## Usage

```bash
# Initialize an agent
./agent.sh init "my-agent"

# Send a message to its inbox
./agent.sh send "analyze the fibonacci sequence"

# Process inbox (one tick)
./agent.sh tick

# Store a memory
./agent.sh remember "fib10" "55"

# Recall a memory
./agent.sh recall "fib10"  # prints: 55

# Start a thought branch
./agent.sh think "optimization-strategies"

# Merge thought back to main
./agent.sh decide "optimization-strategies"

# Check status
./agent.sh status
```

## Why Git?

1. **Zero dependencies** — only requires git
2. **Fully auditable** — every state change is a commit
3. **Merge conflicts** force consensus between agents
4. **Branches** naturally model parallel exploration
5. **Tags** provide O(1) memory lookup

## Commands

| Command | Description |
|---------|-------------|
| `init` | Spawn a new agent |
| `tick` | Process inbox messages |
| `send` | Queue a message |
| `remember` | Store a tagged memory |
| `recall` | Retrieve a tagged memory |
| `think` | Create a thought branch |
| `decide` | Merge thought branch to main |
| `status` | Show agent state |

## License

MIT
