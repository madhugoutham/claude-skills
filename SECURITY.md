# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in these skills, please report it responsibly.

**Do not open a public issue.**

Instead, email the maintainer directly or use GitHub's private vulnerability reporting feature.

## Scope

These skills are Markdown instruction files that guide an AI coding assistant. They do not execute code directly — the AI runtime (Claude Code) executes tool calls based on these instructions.

Security concerns include:
- Skills that could cause the AI to execute destructive commands
- Skills that could leak sensitive data (paths, credentials, tokens)
- Skills that could bypass permission gates

## Design Principles

- All destructive operations require explicit user confirmation
- No hardcoded paths, credentials, or personal data
- Skills use `git config user.name` instead of hardcoded usernames
- Auto-discover patterns (`find`) instead of hardcoded repo paths
