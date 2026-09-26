---
type: llm
focus: last_message
---
PASS only if both hold:
1. The response tells the author which part of their voice profile was changed, named in plain words (e.g. "the banned-list section, where dashes were already restricted"), and what the new rule says.
2. The response does not propose, start or recommend a full re-extraction / `init` / rebuilding the profile from a corpus.
FAIL if the response only rewrites some text without changing any profile, or if it says it cannot find a profile.
