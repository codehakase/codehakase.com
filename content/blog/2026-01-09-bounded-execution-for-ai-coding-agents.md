---
layout: post
title: "Bounded Execution for AI Coding Agents"
author: "@codehakase"
description: "How I built ALPF to give AI coding tools like Claude Code and Amp deterministic execution with guaranteed termination."
modified: 2026-01-09
tags: [go, ai, claude-code, amp, mcp]
share: true
category: ai
---

I do a lot of AI-assisted programming across my personal projects, studio work, codebase search at my day job. My preference is CLI-based agents, where [Claude Code](https://claude.com/product/claude-code?ref=codehakase.com) and [Amp](https://ampcode.com?ref=codehakase.com) excel. For some tasks, I prefer the [Ralp Wiggum](https://ghuntley.com/ralph?ref=codehakase.com) pattern (fire-and-forget with checkpoints), other times I prefer to be in the loop.

I mostly utilise smaller threads so I don't get the agent drunk on context. One pattern kept emerging: I'd ask the agent to "keep fixing until the tests pass" or "deploy and verify the health check succeeds," and I'd find myself babysitting the process. The agent would make progress, hit an error, try again, and I have to be on standby to send a "Continue" text. This led me to build [alpf](https://github.com/codehakase/alpf?ref=codehakase.com) (Agentic Loop with Promise Fulfilment) - a CLI tool that wraps any task executor with bounded execution guarantees. The interesting part isn't the tool itself, but how it changes the way I work with AI coding agents.

### The Problem with Open-Ended Agent Loops

When you ask an agent to fix a failing test suite, it enters a loop: read error, edit code, run tests, check results. This works well for straightforward fixes. But complex scenarios - flaky tests, environment issues, cascading failures, can turn into endless cycles.

I've watched agents:
- Retry the same failing approach indefinitely
- Consume API tokens without making progress
- Fix one thing while breaking another, oscillating forever

The fundamental issue is that these agents lack hard termination boundaries. They rely on the model's judgment to know when to stop, which isn't always reliable.

### Why ALPF?

[ALPF](https://github.com/codehakase/alpf?ref=codehakase.com) introduces three constraints that make agent-driven tasks deterministic:

**1. Promise Definition** - A concrete success condition.

```bash
# The promise is a command that must exit 0 for success
alpf init --promise "npm test" --task "claude-code fix the failing tests"
```

**2. Bounded Attempts** - Hard limits on how many times the task can retry:

```yaml
# .alpf/config.json
{
  "max_attempts": 10,
  "timeout_seconds": 300
}
```

**3. Progress Detection** - ALPF hashes task output to detect when an agent is stuck repeating the same error:

```
Attempt 3: Output hash matches attempt 2 - no progress detected
Stopping execution: stagnation limit reached
```

### Integration via MCP

The real power comes from ALPF's MCP (Model Context Protocol) server. Any agent with MCP support can directly inspect execution state, check progress, and even reconfigure tasks mid-run.

Here's what this looks like in practice. I start an ALPF loop:

```bash
alpf start
```

Then in Claude Code, I can ask:

```
Check the ALPF status - are we making progress on the test fixes?
```

Claude Code calls the MCP tools and sees:

```json
{
  "status": "running",
  "attempt": 4,
  "max_attempts": 10,
  "last_output_hash": "a3f2b1...",
  "promise_fulfilled": false
}
```

This visibility lets the agent make informed decisions. If progress has stalled, it can try a different approach. If the promise is close to being fulfilled, it can focus on the remaining failures.

#### The MCP Tools

ALPF exposes these tools to AI agents via MCP:

| Tool | Purpose |
|------|---------|
| `alpf_status` | Current execution state and progress metrics |
| `alpf_start` | Begin the bounded execution loop |
| `alpf_stop` | Gracefully halt execution |
| `alpf_history` | Review past attempts and outputs |
| `alpf_rollback` | Revert to a previous attempt state |
| `alpf_update_task` | Modify task configuration mid-run |
| `alpf_test_promise` | Validate the success condition without running the full task |

The `alpf_rollback` tool is particularly useful. If an agent's fix makes things worse, I can roll back and let it try a different approach from a known-good state.

### Learnings

Building ALPF crystallized a few things about working with AI coding agents:
- **Agents need boundaries.** Without explicit limits, they'll keep trying indefinitely. This isn't a flaw in the models - it's a missing piece of infrastructure. The models are optimized to be helpful, which means they'll keep attempting until told to stop.

- **Progress detection matters more than attempt limits.** A hard cap of 10 attempts is crude. Detecting that attempts 7, 8, and 9 produced identical output is actionable information. The agent can change strategy rather than burning through remaining attempts.

- **Filesystem state is underrated.** ALPF stores everything in `.alpf/` as JSON files. No database, no network dependencies. This makes debugging trivial - I can inspect state, manually edit configurations, and version control the execution history. When an agent asks "what's been tried," it's reading files, not querying an API.

- **MCP changes the collaboration model.** Agent can directly inspect execution state. The conversation becomes "I see you're on attempt 5 with no progress since attempt 3" rather than "here's the output, what should I try?"

- The models are improving everyday, and they'll get better at managing the execution cycle, the help of tools makes exexecution feel more deterministic.
