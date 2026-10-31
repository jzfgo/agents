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
cat > CLAUDE.md <<'M'
# dashboard-api
Fastify + TypeScript. Run tests with `npm test`.
M
mkdir -p .agents/1on1-reviews
cat > .agents/1on1-reviews/2026-10-23.md <<'M'
# 1:1 Review — dashboard-api — 2026-10-23
## Action Items
| Owner | Item | Priority |
|-------|------|----------|
| AI | Run the test suite before declaring a task done | High |
| You | Add a test for the users route | Med |
M
g add -A && g commit -qm "chore: project instructions" || true
