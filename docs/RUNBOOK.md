# DevOps Sandbox Runbook: Git, GitHub, Actions & Security

This runbook documents our simulated team environment, the issues we intentionally triggered ("break"), the solutions ("fix"), and the commands used along the way.

## Table of Contents
1. [Environment Setup: Multi-Account Management](#environment-setup-multi-account-management)
2. [Repository & Branch Protection](#repository--branch-protection)
3. [Break & Fix Scenarios](#break--fix-scenarios)
4. [GitHub Actions & CI](#github-actions--ci)
5. [Security & OIDC](#security--oidc)

---

## 1. Environment Setup: Single-Account Team Simulation
*Goal: Simulate a multi-developer environment using a single GitHub account, utilizing different branches, terminals, and enforced branch protection rules.*

### Planned Steps:
1. Create a repository on GitHub.
2. Configure Branch Protection on `main` (Require PRs, **Enforce for Administrators**, but disable "Require Approvals" to allow solo merging).
3. Use two separate terminals/folders locally to simulate "Junior" and "Senior" workflows.
4. Set distinct local `git config user.name` in different folders to visually distinguish commits.

*(Commands and execution details will be logged here as we complete them).*
