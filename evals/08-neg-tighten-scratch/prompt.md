---
max_turns: 5
timeout_seconds: 120
allowed_tools: [Read, Glob, Grep, Skill]
runs: 3
plugins: [../../skills/write-like-me]
---
tighten this paragraph to about 80 words. it's internal scratch, doesn't matter whose voice:

The main reason we decided to move the staging database off the shared cluster is that, over the past few weeks, we have repeatedly seen situations where load tests run by the data team against their own schemas ended up saturating the connection pool, which in turn caused our staging deploys to time out and fail in ways that were quite hard to diagnose, because the errors surfaced as generic timeouts rather than anything pointing at the pool. Moving staging to its own small instance costs roughly 40 dollars a month, which is well within budget, and it removes the coupling entirely, so a load test in one place can no longer break a deploy somewhere else. We will keep the shared cluster for production for now and revisit that decision at the end of the quarter once we have better numbers on cost.
