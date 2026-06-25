---
description: Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved. Use before implementing controller changes, CRD modifications, complex features, or any medium/high risk work. Stress-tests your thinking.
argument-hint: <plan description, feature spec, or Jira ticket>
---

Interview me relentlessly about every aspect of $ARGUMENTS until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

For each question, provide your recommended answer based on:
1. What you find in the codebase (check actual code, not assumptions)
2. Existing patterns in the repo
3. Upstream conventions (KServe, GAIE, K8s)

Ask questions one at a time. Wait for my answer before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead of asking me. Tell me what you found.

## What to probe

- **Edge cases:** What happens when the field is nil? Empty? Invalid?
- **Backwards compatibility:** Does this break existing CRs? Existing Helm values?
- **Controller reconciliation:** What gets reconciled? What order? What if reconcile fails halfway?
- **Upgrade path:** What happens to existing clusters when this ships?
- **Test coverage:** Which seam tests this? envtest? unit? integration?
- **Blast radius:** How many files change? Which other controllers/webhooks touch this?
- **Rollback:** If this breaks production, what's the undo?

## When to stop

Stop when every decision branch is resolved and I can state the plan in one paragraph. Summarize the final decisions as a numbered list I can use as an implementation checklist.
