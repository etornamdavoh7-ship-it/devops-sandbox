# Stage 4: Resolving Merge Conflicts

## What is a Merge Conflict?
A merge conflict occurs when two separate branches modify the **exact same line of code**. Git is smart enough to auto-merge different files (like adding a new documentation file while changing a config file), but it will never guess which version of a single modified line to keep. It stops the merge and relies on human intervention.

## The "Browser vs. Local" Rule
While GitHub offers a "Resolve conflicts" button in the web UI, **DevOps best practice dictates resolving conflicts locally.** 
If you fix code in the browser, you cannot test it (e.g., running `docker-compose up` to ensure the port isn't broken) before merging it into `main`. By resolving it locally, you can test the fix *before* it hits production.

## The Resolution Workflow
When GitHub blocks your Pull Request with a conflict, follow these steps in your terminal:

### 1. Force the Collision Locally
Ensure you are on your broken feature branch, and pull the latest `main` into it:
```bash
git checkout feature/my-broken-branch
git pull origin main
```
*(Note: If Git pauses with a "divergent branches" hint, ensure your pull strategy is set to merge by running: `git config pull.rebase false`)*

### 2. Locate the Warning Markers
Git will inject physical warning markers into the broken files. Open the file in your code editor and look for this block:
```text
<<<<<<< HEAD
(Your branch's code)
=======
(The code that was already merged into main)
>>>>>>> main
```

### 3. The Human Fix
Manually edit the code to exactly how it should look in production. You must **delete the `<<<<<<<`, `=======`, and `>>>>>>>` markers.** Save the file.

### 4. Commit the Resolution
Tell Git the conflict is resolved and push the fix back up to update your Pull Request.
```bash
git add .
git commit -m "chore: resolved merge conflict with main"
git push origin feature/my-broken-branch
```
GitHub will automatically detect the resolution, remove the red block, and light up the green Merge button!
