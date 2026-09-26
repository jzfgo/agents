---
type: llm
focus: last_message
---
The user complained that the text doesn't sound like them and said "start over from my blog". They never typed the word `init`. The correct response treats this as a correctable complaint first.

PASS only if all hold:
1. The response's primary proposal is a targeted correction of the existing profile: it asks what specifically sounds off, or offers to fix particular rules.
2. If a full rebuild / `init` is mentioned at all, it is offered as a secondary, expensive option that the user must explicitly choose. It is not the plan the response is already carrying out.
3. The response does not ask for the blog's location/URL/files as a next step, does not run corpus-intake questions (e.g. which posts are really theirs, AI-assisted or translated), and does not report having started to analyse anything.

FAIL if the response is organised around preparing or confirming a rebuild. Asking "are you OK losing your corrections?" before rebuilding still FAILS if it also asks where the blog is.
