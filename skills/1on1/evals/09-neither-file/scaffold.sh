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
