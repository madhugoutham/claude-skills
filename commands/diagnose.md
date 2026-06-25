---
description: Disciplined diagnosis loop for hard bugs and performance regressions — reproduce, minimise, hypothesise, instrument, fix, regression-test. Use when debugging controller reconciliation, EPP routing, scheduler issues, CRD validation, tracing pipeline failures, or K8s operator bugs.
argument-hint: <bug description, error message, or Jira ticket>
---

# Diagnose

Disciplined diagnosis for $ARGUMENTS. Skip phases only when explicitly justified.

## Phase 1 — Build a feedback loop

**This is the skill.** If you have a fast, deterministic pass/fail signal for the bug, you will find the cause. If you don't, no amount of reading code will save you.

Spend disproportionate effort here. Be aggressive. Be creative.

### Ways to construct a feedback loop — try in order

1. **Failing Go test** — `go test -run TestSpecific -v ./pkg/...` at whatever seam reaches the bug (unit, integration, envtest).
2. **kubectl/oc command** — apply a CR and check the reconciled state: `kubectl apply -f /tmp/test-cr.yaml && kubectl get <resource> -o yaml | grep <expected>`.
3. **Controller log grep** — `kubectl logs -l app=<controller> --tail=100 | grep -i error` with a specific CR trigger.
4. **Port-forward + curl** — for EPP/vLLM/inference path bugs: `kubectl port-forward svc/<svc> 8080:8080 && curl localhost:8080/v1/...`.
5. **Envtest harness** — spin up a minimal controller-runtime envtest that exercises the bug code path with a single reconcile.
6. **Differential loop** — run same CR through old vs new controller version and diff the reconciled resources.
7. **Replay a captured trace** — save a real OTel trace/Jaeger span, replay through the code path.
8. **Property/fuzz** — for "sometimes wrong" bugs, run 100 random CRs through the reconciler.
9. **Bisection** — `git bisect run go test -run TestSpecific ./pkg/...` between known-good and known-bad commits.
10. **Manual loop** — last resort. Write exact steps in `/tmp/repro.sh` so the loop is structured.

### Iterate on the loop

- Can you make it faster? (Cache setup, narrow test scope, skip unrelated init.)
- Can you make the signal sharper? (Assert on specific symptom, not "didn't crash".)
- Can you make it deterministic? (Pin time, seed RNG, control K8s fake client state.)

### Non-deterministic bugs (race conditions, controller timing)

Goal: raise reproduction rate. Loop the trigger 100x, add concurrent reconciles, inject sleeps at suspect points. 50% flake is debuggable; 1% is not.

### When you cannot build a loop

Stop and say so. List what you tried. Ask for: (a) access to the cluster that reproduces it, (b) captured artifacts (controller logs, OTel traces, events), or (c) permission to add temporary instrumentation. Do NOT proceed to Phase 2 without a loop.

## Phase 2 — Reproduce

Run the loop. Confirm:

- [ ] Failure matches what the user/ticket described — not a different failure nearby
- [ ] Reproducible across multiple runs (or high enough rate for flaky bugs)
- [ ] Exact symptom captured (error message, wrong field value, missing resource)

Do not proceed until reproduced.

## Phase 3 — Hypothesise

Generate **3-5 ranked hypotheses** before testing any. Single-hypothesis locks onto first plausible idea.

Each hypothesis must be falsifiable:

> "If <X> is the cause, then <changing Y> makes the bug disappear / <changing Z> makes it worse."

Show the ranked list to the user. They often have domain knowledge that re-ranks instantly. Proceed with your ranking if user is away.

## Phase 4 — Instrument

Each probe maps to a specific prediction from Phase 3. **Change one variable at a time.**

Tool preference for Go/K8s:
1. **Debugger** — `dlv test ./pkg/... -- -test.run TestSpecific` if env supports it
2. **Targeted log lines** — `klog.V(2).InfoS("DEBUG-a4f2", "key", value)` at boundaries that distinguish hypotheses
3. **kubectl describe / events** — check K8s events for controller-side clues
4. Never "log everything and grep"

**Tag every debug log** with `[DEBUG-xxxx]` prefix. Cleanup = single grep.

**Perf bugs:** logs are usually wrong. Establish baseline measurement (`go test -bench`, pprof, Prometheus query), then bisect. Measure first, fix second.

## Phase 5 — Fix + regression test

**Auto-checkpoint:** Before making changes, run `/checkpoint save pre-fix` silently. This is the last safe rewind point.

Write the regression test **before the fix** — but only if a correct seam exists.

A correct seam exercises the real bug pattern at the call site. If the only seam is too shallow (unit test when bug needs full reconcile loop), note it — the architecture is preventing lockdown.

If correct seam exists:
1. Turn minimised repro into failing test at that seam
2. Watch it fail
3. Apply the smallest correct fix
4. Watch it pass
5. Re-run Phase 1 feedback loop against original scenario

**Never weaken a test to make it pass. Fix production code.**

## Phase 6 — Cleanup + post-mortem

Before declaring done:

- [ ] Original repro no longer reproduces (re-run Phase 1 loop)
- [ ] Regression test passes (or absence of seam documented)
- [ ] All `[DEBUG-...]` instrumentation removed (`grep -r "DEBUG-" .`)
- [ ] The correct hypothesis stated in commit message
- [ ] `go test ./...` passes, `go vet ./...` clean

**Then ask: what would have prevented this bug?** If the answer is architectural (no test seam, tangled reconcile, hidden coupling), note it as a follow-up. Make the recommendation after the fix, not before.

**Variant scan (auto for security/logic bugs):** Run `variant-analysis` to search for structural siblings of the bug across the codebase. If the root cause is a pattern (e.g., missing nil check on `*bool`, unchecked error return), find all other instances. Skip for one-off configuration bugs.

Output format:
- Done: <what changed>
- Validation: <test/command and result>
- Root cause: <the correct hypothesis, one sentence>
- Variants found: <N siblings, or "none — unique instance">
- Follow-ups: <anything deferred>
