---
name: validate-council
description: Multi-perspective validation council — 3 independent agents verify claims against code, then a 4th compares and flags disagreements. Use when validating PR proposals, issue claims, or code assumptions that need rigorous checking.
---

Run a multi-perspective validation council on the given claims or proposals.

## How this works

Spawn 3 independent agents with DIFFERENT perspectives, each reading the SAME code and verifying the SAME claims. Then a 4th agent compares their findings and flags disagreements.

This replicates the Opus/Composer/Codex pattern from the latency predictor session — but automated, no copy-paste needed.

## Instructions

The user will provide either:
- A list of claims/proposals to validate
- A file path containing proposals
- A description of what to verify

### Step 1: Gather context

If the user provided a file, read it. If they described claims verbally, write them to a temp file for reference.

### Step 2: Spawn 3 agents in parallel using the Workflow tool

```javascript
export const meta = {
  name: 'validate-council',
  description: 'Multi-perspective validation of claims against code',
  phases: [
    { title: 'Independent Analysis', detail: '3 agents verify claims from different angles' },
    { title: 'Compare', detail: 'Flag agreements and disagreements' },
  ],
}

const CLAIMS = args  // passed from the skill invocation

const PERSPECTIVES = [
  {
    key: 'code-verifier',
    prompt: `You are a CODE VERIFIER. For each claim below, go to the actual source code and verify:
- Is the file path correct?
- Is the line number correct?
- Does the code do what the claim says?
- Has this been changed since the claim was written?
Do NOT trust the claim. Read the actual code. Report: CONFIRMED, REFUTED, or OUTDATED for each.

Claims to verify:
${CLAIMS}`
  },
  {
    key: 'ownership-checker',
    prompt: `You are an OWNERSHIP and COORDINATION checker. For each claim below, check:
- Is there an existing issue or PR that already covers this?
- Who owns the relevant code? Check OWNERS file and recent commit authors.
- Are there open PRs in the same area that would conflict?
- Would filing this duplicate or step on someone else's work?
- Check GitHub issue comments for scoping decisions.

Claims to verify:
${CLAIMS}`
  },
  {
    key: 'devils-advocate',
    prompt: `You are a DEVIL'S ADVOCATE. Your job is to try to REFUTE each claim below. For each:
- What could go wrong with this proposal?
- Is the impact overstated?
- Is there a simpler solution the proposer missed?
- Would the maintainer reject this and why?
- What assumptions are unverified?
Default to refuted=true if uncertain.

Claims to verify:
${CLAIMS}`
  },
]

phase('Independent Analysis')

const analyses = await parallel(
  PERSPECTIVES.map(p => () =>
    agent(p.prompt, {
      label: p.key,
      phase: 'Independent Analysis',
    })
  )
)

phase('Compare')

const comparison = await agent(
  `Three independent analysts verified the same set of claims.
Their reports are below. Your job:

1. For each claim: did all 3 agree? If not, what's the disagreement?
2. Flag any claim where the devil's advocate REFUTED something the code-verifier CONFIRMED
3. Flag any ownership/coordination risks the code-verifier missed
4. Produce a final KEEP / ADJUST / DISCARD verdict for each claim

REPORT FORMAT:
For each claim:
  Claim: [one-line summary]
  Code Verifier: [CONFIRMED/REFUTED/OUTDATED + key finding]
  Ownership: [OK/RISK + detail]
  Devil's Advocate: [SURVIVES/REFUTED + strongest objection]
  VERDICT: [KEEP/ADJUST/DISCARD]
  Reason: [one sentence]

=== CODE VERIFIER ===
${analyses[0]}

=== OWNERSHIP CHECKER ===
${analyses[1]}

=== DEVIL'S ADVOCATE ===
${analyses[2]}`,
  { label: 'synthesizer', phase: 'Compare' }
)

return comparison
```

### Step 3: Present the synthesis

Show the user the comparison report. Highlight:
- Claims all 3 agents agreed on (high confidence)
- Claims with disagreements (needs investigation)
- Claims the devil's advocate killed (reconsider)

### When to suggest this skill

When the user says any of:
- "validate these claims"
- "check if this is right"
- "get a second opinion on these proposals"
- "run the council"
- "verify against code"
