#!/bin/bash
# git-agent: A git-native agent system
# Uses git objects (commits, trees, blobs) as the agent's memory and state machine
set -euo pipefail

AGENT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_DIR="$AGENT_DIR/.agent-state"
mkdir -p "$STATE_DIR"

# Initialize agent workspace (git-based)
agent_init() {
    local name="${1:-git-agent}"
    git init -q "$AGENT_DIR/workspace" 2>/dev/null || true
    cd "$AGENT_DIR/workspace"
    git config user.name "$name"
    git config user.email "$name@git-agent.local"
    echo "# $name workspace" > README.md
    git add -A && git commit -m "init: agent $name spawned" -q
    echo "$name" > "$STATE_DIR/name"
    echo "0" > "$STATE_DIR/tick"
    echo "idle" > "$STATE_DIR/status"
    echo "agent $name initialized at $(date)"
}

# Agent tick - process inbox, update state
agent_tick() {
    cd "$AGENT_DIR/workspace"
    local tick=$(cat "$STATE_DIR/tick")
    local status=$(cat "$STATE_DIR/status")
    
    # Check inbox (git notes on HEAD)
    local inbox=$(git notes show HEAD 2>/dev/null || echo "")
    
    if [ -n "$inbox" ]; then
        echo "tick $tick: processing inbox: $inbox"
        # Process the note and create output
        echo "# Tick $tick Output\n\nInput: $inbox\nProcessed: $(date)" > "tick-${tick}.md"
        git add -A
        git commit -m "tick $tick: processed inbox" -q
        # Clear inbox
        git notes remove HEAD 2>/dev/null || true
        echo "working" > "$STATE_DIR/status"
    else
        echo "tick $tick: idle (no inbox messages)"
        echo "idle" > "$STATE_DIR/status"
    fi
    
    echo $((tick + 1)) > "$STATE_DIR/tick"
}

# Send message to agent (via git notes)
agent_send() {
    local msg="$1"
    cd "$AGENT_DIR/workspace"
    echo "$msg" | git notes add -f HEAD 2>/dev/null
    echo "message queued: $msg"
}

# Show agent state
agent_status() {
    cd "$AGENT_DIR/workspace"
    local name=$(cat "$STATE_DIR/name")
    local tick=$(cat "$STATE_DIR/tick")
    local status=$(cat "$STATE_DIR/status")
    local commits=$(git log --oneline | wc -l)
    echo "Agent: $name | Tick: $tick | Status: $status | Commits: $commits"
    echo "Git log:"
    git log --oneline -5
}

# Agent branch - create a thought branch
agent_think() {
    local topic="$1"
    cd "$AGENT_DIR/workspace"
    local branch="thought/${topic}"
    git checkout -b "$branch" -q 2>/dev/null || git checkout "$branch" -q
    echo "# Thought: $topic\n\nStarted: $(date)" > "thought-${topic}.md"
    git add -A && git commit -m "think: started $topic" -q
    echo "Created thought branch: $branch"
}

# Merge thoughts back to main
agent_decide() {
    local topic="$1"
    cd "$AGENT_DIR/workspace"
    git checkout main -q 2>/dev/null || git checkout master -q
    git merge "thought/${topic}" -m "decide: merged thought $topic" -q 2>/dev/null
    echo "Merged thought: $topic → main"
}

# Agent memory (git tags)
agent_remember() {
    local key="$1"
    local value="$2"
    cd "$AGENT_DIR/workspace"
    mkdir -p .memory && echo "$value" > ".memory/${key}"
    git add -A && git commit -m "remember: $key" -q
    git tag "memory/${key}" HEAD -f 2>/dev/null
    echo "Remembered: $key"
}

agent_recall() {
    local key="$1"
    cd "$AGENT_DIR/workspace"
    git show "memory/${key}":.memory/"${key}" 2>/dev/null || echo "Not found: $key"
}

case "${1:-help}" in
    init)   agent_init "${2:-git-agent}" ;;
    tick)   agent_tick ;;
    send)   agent_send "${2:-hello}" ;;
    status) agent_status ;;
    think)  agent_think "${2:-idea}" ;;
    decide) agent_decide "${2:-idea}" ;;
    remember) agent_remember "${2:-key}" "${3:-value}" ;;
    recall) agent_recall "${2:-key}" ;;
    help|*) 
        echo "git-agent: A git-native agent system"
        echo "Commands: init, tick, send, status, think, decide, remember, recall"
        ;;
esac
