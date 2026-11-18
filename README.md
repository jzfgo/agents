# skills

[![skills.sh](https://skills.sh/b/jzfgo/agents)](https://skills.sh/jzfgo/agents)

Personal AI agent skills by [Javier Zapata](https://github.com/jzfgo), conforming to the [AgentSkills open standard](https://agentskills.io). Works with any compatible agent harness.

## Skills

| Skill | Description |
|-------|-------------|
| [1on1](./skills/1on1/SKILL.md) | Structured 1:1 professional check-ins — reviews how you and your AI agent have been working together |
| [write-like-me](./skills/write-like-me/SKILL.md) | Writes, rewrites, reviews and corrects text in your own voice. `init` builds the profile from a corpus of your own writing, with a re-runnable regression suite; the profile itself stays private, outside this repo. Spanish and English are both first-class |
| [cdmon](./skills/cdmon/SKILL.md) | Manages domains and DNS records at cdmon through its API: lists domains and records, adds, changes and deletes A, CNAME and TXT records (the API cannot write AAAA or MX) with a diff and explicit confirmation before every write, and checks propagation with `dig`. Needs `CDMON_API_KEY`, `curl` and `jq` |
| [babysit-pr](./skills/babysit-pr/SKILL.md) | Owns a GitHub PR until it is merge-ready: triages review comments, fixes real issues, answers false positives with evidence, fixes red CI and loops on `@claude` re-reviews until a review of the current HEAD comes back clean. Never merges. Needs `gh`, `jq` and a repo reviewed by `anthropics/claude-code-action` |
| [sync-docs](./skills/sync-docs/SKILL.md) | Audits agent guidance files, context skills, README and `docs/` against the code, reports every drifted claim with its evidence, and fixes them on a branch once the report is approved. Reads an optional per-repo claims map from `.agents/sync-docs/sources.md`; never edits generated files such as `CHANGELOG.md` |

## Installation

Skills are auto-discovered by any [AgentSkills-compatible](https://agentskills.io) harness. For harnesses that require explicit installation:

| Harness | Install |
|---------|---------|
| **Claude Code** | `claude mcp add javito-skills@git+https://github.com/jzfgo/agents.git` |
| **OpenCode** | Add `"plugin": ["javito-skills@git+https://github.com/jzfgo/agents.git"]` to `opencode.json` |
| **Antigravity** | Auto-discovered via `.agents/skills/` symlinks in this workspace; for every workspace, symlink `skills/<name>` into `~/.gemini/config/skills/` |
| **Pi** | Auto-discovered via `.agents/skills/` symlinks |
| **Codex** | Auto-discovered via `.codex-plugin/plugin.json` |
| **Cursor** | Auto-discovered via `.cursor-plugin/plugin.json` |

## Credits

`write-like-me` derives its three-pass structure, analysis dimensions, and
review taxonomies from [sam-dumont/claude-skills](https://github.com/sam-dumont/claude-skills)
(MIT, © 2025 Sam Dumont). See [NOTICE](./NOTICE) for details of what is derived
and what is original.

## License

MIT
