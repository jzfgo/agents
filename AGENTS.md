# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What This Repo Is

A collection of personal AI agent skills conforming to the [AgentSkills open standard](https://agentskills.io). Each skill is a self-contained directory discoverable by any compatible AI agent. Skills are invoked via the agent's native skill mechanism when their `description:` frontmatter matches the user's intent.

## Skill Structure

Every skill lives in its own directory under `skills/`, named after the skill:

```
skills/<skill-name>/
  SKILL.md          # frontmatter (name, description) + full skill instructions
  evals/
    evals.json       # functional test cases: what the skill should do when triggered
    trigger_eval.json # trigger test cases: when the skill should/should not fire
```

### SKILL.md frontmatter

```yaml
---
name: <skill-name>          # must match the directory name
description: <trigger text> # what the agent reads to decide whether to invoke
---
```

The `description:` field is critical — it drives automatic invocation. It should include trigger phrases, use-case scope, and explicit exclusions for common false-positive queries.

### evals/evals.json schema

```json
{
  "skill_name": "<name>",
  "evals": [
    {
      "id": 1,
      "prompt": "<user input>",
      "expected_output": "<what the skill should produce>",
      "files": [],
      "assertions": []
    }
  ]
}
```

### evals/trigger_eval.json schema

An array of `{ "query": "...", "should_trigger": true|false }` objects. Include both positive examples (clear matches) and negative examples (common false positives that must NOT fire the skill).

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter and instructions.
2. Create `skills/<skill-name>/evals/evals.json` with at least 2–3 functional test cases.
3. Create `skills/<skill-name>/evals/trigger_eval.json` with a mix of positive and negative trigger examples — negative examples are especially important to prevent the skill from firing on superficially similar queries.
4. Create `skills/<skill-name>/.claude-plugin/plugin.json` with skill metadata.
5. Run `ln -s ../../skills/<skill-name> .agents/skills/<skill-name>` and commit the symlink.
6. Add an entry to `.claude-plugin/marketplace.json` under `plugins[]`.
7. Add a row to the `## Skills` table in `README.md`.

## Key Conventions

- Skill instructions inside `SKILL.md` are written for the agent to follow, not for humans to read as documentation. Write them as imperative directives.
- The `description:` should explicitly call out what the skill does NOT cover (e.g., "Use this skill for... Not for code reviews or debugging") — this is what populates the negative trigger cases.
- Report files and persistent artifacts produced by skills go into agent-specific subdirectories (e.g., `.claude/reviews/` for Claude Code) to keep them out of the way.

## Plugin manifests

### Claude Code

Each skill directory must contain `.claude-plugin/plugin.json` with `name`, `description`, `author`, `homepage`, `license`, and `keywords`.

The repo root `.claude-plugin/marketplace.json` lists every skill under `plugins[]`. When adding a new skill, add an entry:

```json
{
  "name": "<skill-name>",
  "description": "<one-line description>",
  "source": "./skills/<skill-name>",
  "category": "<productivity|development|...>"
}
```

The `name` in `plugin.json` and in the `marketplace.json` entry must match the skill directory name.

### Codex

`.codex-plugin/plugin.json` at the repo root points `"skills": "./skills/"`. Codex discovers skills automatically from its subdirectories — no per-skill manifest needed.

### Cursor

`.cursor-plugin/plugin.json` at the repo root points `"skills": "./skills/"`. Same auto-discovery as Codex.

### Antigravity

Antigravity discovers workspace skills in `.agents/skills/` — the same symlinks as Pi below. No manifest or context file is needed.

### OpenCode

See `.opencode/INSTALL.md` for setup instructions. Add `"plugin": ["javito-skills@git+https://github.com/jzfgo/agents.git"]` to your `opencode.json`.

### Pi / AgentSkills standard

`.agents/skills/` (also read by Antigravity) contains relative symlinks to each skill directory. Run `ln -s ../../skills/<skill-name> .agents/skills/<skill-name>` and commit the symlink when adding a new skill.
