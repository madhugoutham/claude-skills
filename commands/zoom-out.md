---
description: Zoom out to see the bigger picture around unfamiliar code. Shows module map, callers, data flow, and where the current code fits in the system. Use when lost in controller internals, EPP pipeline, scheduler logic, or any unfamiliar code path.
argument-hint: <file path, function name, or code area>
---

I don't know this area of code well. Go up a layer of abstraction for $ARGUMENTS.

Give me:
1. **Module map** — which packages/files are involved and what each one owns
2. **Callers** — what calls into this code and why
3. **Data flow** — what goes in, what comes out, what gets mutated along the way
4. **Where it fits** — how this piece connects to the broader system (controller loop, request pipeline, CRD lifecycle)

Use ASCII diagrams where they help. Keep it concrete — reference actual file paths and function names from the codebase, not abstract descriptions.
