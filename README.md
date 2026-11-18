# skills

[![skills.sh](https://skills.sh/b/jzfgo/agents)](https://skills.sh/jzfgo/agents)

Personal AI agent skills by [Javier Zapata](https://github.com/jzfgo), conforming to the [AgentSkills open standard](https://agentskills.io). Works with any compatible agent harness.

## Skills

| Skill | Description |
|-------|-------------|
| [1on1](./skills/1on1/SKILL.md) | Structured 1:1 professional check-ins — reviews how you and your AI agent have been working together |
| [write-like-me](./skills/write-like-me/SKILL.md) | Writes, rewrites, reviews and corrects text in your own voice. `init` builds the profile from a corpus of your own writing, with a re-runnable regression suite; the profile itself stays private, outside this repo. Spanish and English are both first-class |

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
