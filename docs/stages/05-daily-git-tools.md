# Stage 5: Daily Git Tools & "Oh No!" Commands

While the standard Pull Request workflow covers the "happy path", real-world DevOps requires you to pause work, fix mistakes, and undo broken code. Here are the three most important daily utility commands.

## 1. The Pause Button (`git stash`)
**Scenario:** You are halfway through writing a new feature, but a Senior developer asks you to urgently switch branches to look at a bug. You can't commit half-written code.
* **Hide your work:** Run `git stash`. Git takes all your uncommitted changes and hides them in a temporary clipboard, leaving your workspace completely clean so you can safely switch branches.
* **Bring it back:** When you return to your feature branch, run `git stash pop`. Git drops all your half-written work exactly where you left it!

## 2. The Typo Fixer (`git commit --amend`)
**Scenario:** You just made a commit, but you realize you misspelled the commit message or forgot to include a crucial file.
* **The Fix:** Stage the forgotten file (if applicable) and run:
  ```bash
  git commit --amend -m "feat: corrected commit message"
  ```
* **How it works:** Git intercepts your previous commit and overwrites it. It literally rewrites your local history so the mistake never existed.
* ⚠️ **DevOps Warning:** NEVER use `--amend` on a commit that has already been pushed and merged into `main`. It will cause massive sync issues for your team. Only amend local, unpushed commits!

## 3. The Safe Undo (`git revert`)
**Scenario:** Your Pull Request was approved and merged, but it crashed the production servers! You need to undo the code immediately.
* **The Fix:** Find the ID of the bad commit (using `git log`), and run:
  ```bash
  git revert <commit-id>
  ```
  *(To undo the very last commit, use `git revert HEAD`)*
* **How it works:** Unlike `--amend` or `reset` which try to erase history, `revert` is the safe Enterprise standard. It creates a **brand-new commit** that perfectly does the exact opposite of the bad commit. It safely removes the bad code while keeping a permanent, auditable record of the mistake and the rollback.
