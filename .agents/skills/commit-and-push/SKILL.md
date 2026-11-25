---
name: commit-and-push
description: Standard workflow for committing and pushing changes in the PopPage repository with pre-flight checks, documentation sync, and user confirmation.
---

# Commit & Push Workflow

Follow this workflow whenever committing and pushing changes in the PopPage repository.

## 1. Pre-flight Checks

1. Check remote state and working tree:
   ```bash
   git fetch && git status -sb
   ```
   If local `main` is behind `origin/main`, sync (`git pull --rebase` or merge) before proceeding.
2. Review changes:
   ```bash
   git diff --stat
   ```
3. Verify build & lint pass when code or resources changed:
   ```bash
   make lint && make build
   ```
4. Verify documentation sync:
   - Confirm `README.md`, `docs/README.*.md`, `AGENTS.md`, and `CHANGELOG.md` (`[Unreleased]` section) reflect any new features, bug fixes, or structural changes.
   - If UI changed, run `update-screenshots` to refresh `docs/images/*.png`.

## 2. User Confirmation (Mandatory)

Per repository rules, **always ask the user for explicit confirmation** before running `git commit` or `git push`. Present:
- Summary of files to be staged/committed
- Proposed commit message (Conventional Commits style, e.g. `feat: ...`, `fix: ...`, `docs: ...`, `chore: ...`)
- Target branch (e.g. `main`)

## 3. Commit & Push

After user approval:
```bash
git add -A
git commit -m "<type>: <concise summary>"
git push origin main
```
Confirm `git status -sb` shows clean working tree and `main...origin/main` up to date.
