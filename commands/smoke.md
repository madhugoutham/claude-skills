---
description: Generate a smoke test report for cluster testing
argument-hint: <topic-slug>
allowed-tools: Read, Write, Bash(kubectl get:*), Bash(kubectl describe:*), Bash(kubectl logs:*), Bash(oc get:*), Bash(oc status)
---
Create `reports/$(date +%Y-%m-%d)-$1.md` with these sections:

## Environment
- Cluster type and version
- Kube context: !`kubectl config current-context`
- Namespace
- Image tags tested
- Date/time

## Steps run
Numbered list with EXACT commands I ran (from our conversation).

## Observed
What actually happened. Include log excerpts (redact secrets/tokens).

## Expected
What should have happened.

## Verdict
PASS / FAIL / PARTIAL — one sentence rationale.

## Artifacts
- Paths to must-gather output
- Pod logs saved locally
- YAML manifests used

Use bash/yaml/text fences. Add `> [!NOTE]` callouts for anything non-obvious.
Do NOT post to Slack. Output the file path only.
