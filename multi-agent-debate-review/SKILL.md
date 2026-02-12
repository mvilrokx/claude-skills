---
name: multi-agent-debate-review
description: >
  Launch parallel specialized agents to review a codebase, then synthesize
  findings through adversarial debate. Use when user says "debate review",
  "multi-agent review", "codebase review", "full review", or asks for a
  comprehensive code/architecture/security audit. Also use proactively before
  major releases, after large refactors, or when preparing production
  deployments. Supports two modes: "direct" (you coordinate) and "delegated" (a
  single general-purpose agent coordinates everything autonomously).
---

# Multi-Agent Debate Review

Run 6+ specialized agents in parallel against a codebase, compare findings,
re-invoke agents on points of disagreement, and produce a consolidated report
with prioritized actions.

## Mode Selection

Ask the user which mode to use, or infer from context:

- **Direct mode** (default): You coordinate — launch agents, collect results,
  run debates, write report. More interactive, allows user to discuss findings
  between phases.
- **Delegated mode**: Launch a single `general-purpose` agent that coordinates
  the entire debate autonomously. Hands-off — user gets a final report. Use when
  user says "run it hands-off", "do it all automatically", or wants minimal
  interaction.

## Direct Mode

### Step 1: Load Standards

Load relevant skills to give agents better baselines. Select based on project
language:

- **Go**: `coding-standards`, `golang-patterns`, `security-review`,
  `backend-patterns`
- **Python**: `coding-standards`, `python-patterns`, `security-review`
- **TypeScript/JS**: `coding-standards`, `frontend-patterns`, `security-review`

### Step 2: Launch Agents in Parallel

Launch all agents with `mode: "background"`. Each agent gets a focused prompt
with explicit instructions to provide severity ratings, file references, and
suggested fixes.

Select agents based on the project. See `references/agent-configs.md` for the
full prompt templates for each agent type.

- **Go projects**: go-reviewer, go-security-reviewer, go-refactor-cleaner,
  code-reviewer, database-reviewer, architect
- **Python projects**: python-reviewer, python-security-reviewer,
  python-refactor-cleaner, code-reviewer, database-reviewer, architect
- **JS/TS projects**: code-reviewer, js-security-reviewer, js-refactor-cleaner,
  database-reviewer, architect

Always include `code-reviewer`, `database-reviewer`, and `architect` regardless
of language.

#### Model Selection

Use the `model` parameter on each agent to assign different models. Two
strategies:

**Cost-optimized** (default): Match model capability to task complexity.

| Role                  | Model               | Rationale                                      |
| --------------------- | ------------------- | ---------------------------------------------- |
| Security reviewer     | `claude-opus-4.6`   | Deep reasoning for exploit scenarios           |
| Architect             | `claude-sonnet-4-5` | Good balance for system-level thinking         |
| Code reviewer         | `claude-sonnet-4-5` | Standard code review                           |
| Refactor/cleaner      | `claude-haiku-4.5`  | Mechanical analysis, fast/cheap                |
| Database reviewer     | `claude-sonnet-4-5` | Schema analysis                                |
| Debate re-invocations | `claude-opus-4.6`   | Nuanced position changes need strong reasoning |

**Diversity-optimized**: Use different model families to get genuinely different
perspectives. Model diversity reduces shared blind spots — if Claude and GPT
both flag the same issue independently, confidence is very high. If only one
flags it, the debate round is more informative.

| Role                  | Model                  | Rationale                      |
| --------------------- | ---------------------- | ------------------------------ |
| Code reviewer         | `claude-sonnet-4-5`    | Claude perspective             |
| Security reviewer     | `gpt-5.2-codex`        | GPT perspective                |
| Architect             | `gemini-3-pro-preview` | Gemini perspective             |
| Database reviewer     | `gpt-5.2`              | GPT perspective                |
| Refactor/cleaner      | `claude-haiku-4.5`     | Fast/cheap for mechanical work |
| Debate re-invocations | `claude-opus-4.6`      | Strongest model resolves ties  |

Ask the user which strategy they prefer, or default to cost-optimized.

### Step 3: Track Findings

After collecting results, insert all findings into a SQL table:

```sql
CREATE TABLE findings (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,    -- SECURITY, DATABASE, CODE, OBSERVABILITY, etc.
  severity TEXT NOT NULL,    -- CRITICAL, HIGH, MEDIUM, LOW
  title TEXT NOT NULL,
  agents_agreeing TEXT NOT NULL,    -- comma-separated agent names
  agents_disagreeing TEXT DEFAULT '',
  status TEXT DEFAULT 'open',
  consensus TEXT DEFAULT 'pending'  -- UNANIMOUS, RESOLVED, SINGLE_AGENT, UNRESOLVED
);
```

Mark consensus:

- **UNANIMOUS**: 3+ agents independently flagged the same issue
- **SINGLE_AGENT**: Only one agent found it (may be novel or false positive)
- **UNRESOLVED**: Agents actively disagree

### Step 4: Identify Debates

Look for these patterns:

- **Severity disagreement**: One agent says CRITICAL, another says it's fine
- **Approach conflict**: One says "remove X", another says "keep X"
- **Scope tension**: One says "fix now", another says "fix later"

### Step 5: Re-invoke Disagreeing Agents

For each debate, re-invoke the agents with the opposing position stated
explicitly.

Prompt template:

```
You are participating in a multi-agent debate review.

[Agent A] found: [their position with reasoning]
[Agent B] found: [opposing position with reasoning]

Review the actual code at [path]. Then give your FINAL POSITION with reasoning
in 3-8 sentences. Acknowledge what the other agent got right.
```

Update the findings table with resolved positions.

### Step 6: Consolidated Report

Structure the final report in this order:

1. **Executive Summary** — overall grade, agent scores table
2. **Unanimous Findings** — issues 3+ agents agree on (highest confidence)
3. **Resolved Debates** — disagreements settled through re-invocation
4. **Unresolved Trade-offs** — genuine tensions with no clear winner
5. **Unique Insights** — single-agent findings worth noting
6. **Prioritized Action Plan** — grouped by urgency with effort estimates
7. **Strengths** — what all agents praised (important for morale/context)

Save the report to the session artifacts directory.

## Delegated Mode

Launch a single `general-purpose` agent that acts as debate coordinator. This
agent has full access to the `task` tool and can launch sub-agents itself.

Use `agent_type: "general-purpose"` — this is the only agent type that can spawn
sub-agents.

Prompt the coordinator with the full workflow. See
`references/delegated-coordinator-prompt.md` for the complete prompt template.

Key points for the coordinator prompt:

- Tell it which agent types to launch (based on project language)
- Tell it to launch all review agents in parallel using `mode: "background"`
- Tell it to collect all results via `read_agent`
- Tell it to identify disagreements and re-invoke with opposing positions
- Tell it to produce the consolidated report in the standard format
- Give it the codebase path and any project-specific context

The coordinator runs autonomously — it launches reviewers as sub-agents,
collects findings, runs the debate rounds, and returns the final consolidated
report.

### When to Prefer Delegated Mode

- User wants a fully autonomous review with no interaction
- Context window is getting full and you want to offload the work
- Running as part of an automated pipeline (e.g., pre-push hook, CI trigger)

### Limitations of Delegated Mode

- No interactive discussion between phases — user gets final report only
- Coordinator context window is separate, so it won't have prior conversation
  history
- Coordinator must be given all relevant context in its prompt (project
  language, paths, focus areas)
