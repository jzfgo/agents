#!/usr/bin/env bash
# Sourced by scaffolds: a small git repo with recent history in cwd.
set -euo pipefail
g() { git -c user.name=Test -c user.email=test@example.com "$@"; }
git init -q -b main .
cat > package.json <<'J'
{ "name": "dashboard-api", "version": "0.3.0", "scripts": { "test": "vitest" }, "dependencies": { "fastify": "^4.28.0" } }
J
mkdir -p src && echo 'export const health = () => ({ ok: true });' > src/health.ts
g add -A && g commit -qm "feat: health endpoint"
echo 'export const users = () => [];' > src/users.ts
g add -A && g commit -qm "feat: users route (wip)"
echo 'export const users = () => [] as string[];' > src/users.ts
g add -A && g commit -qm "fix: users route typing"
cat > AGENTS.md <<'M'
# dashboard-api
Fastify + TypeScript. Run tests with `npm test`.

## Open Action Items (1:1 — 2026-10-23)

**AI:**
- [ ] Run the test suite before declaring a task done

**You:**
- [ ] Add a test for the users route

> When you notice context in a session that relates to one of these items, surface it proactively — don't wait for the next 1:1. Mark items complete or remove them when done.
M
g add -A && g commit -qm "chore: project instructions" || true
