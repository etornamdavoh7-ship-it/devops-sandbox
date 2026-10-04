# Troubleshooting Log

This document serves as our "Break & Fix" ledger. Every time we encounter an error (either intentionally triggered or accidental), we will log it here so you have a quick reference for the future.

---

## 🛑 Template for Logging Issues

### Issue: [Short Description of the Error]
- **Scenario:** What were we trying to do?
- **Error Message:** (Paste the terminal output or GitHub UI error here)
- **Root Cause:** Why did this happen?
- **Solution:** 
  ```bash
  # Commands used to fix it
  ```

---

### Issue: 403 Permission Denied (Wrong Cached Account)
- **Scenario:** Trying to push the initial commit to a new repository owned by a secondary account (`Xeroxy24`).
- **Error Message:** 
  `remote: Permission to Xeroxy24/devops-sandbox.git denied to Leospe24.`
  `fatal: unable to access '...': The requested URL returned error: 403`
- **Root Cause:** The OS Git Credential Manager locks a domain (`github.com`) to a single saved user account (in this case, `Leospe24`), rejecting pushes to a repo where that user lacks permissions.
- **Solution:** 
  **1. Best Approach (For Team Simulation):** Used a second physical computer. Because Git tightly couples to the OS credential manager, separating the two identities across two physical machines provides a frictionless, realistic team workflow.
  **2. Technical Alternative (Single Machine):** Bypass the credential manager for a specific repository by hardcoding the username into the Git remote URL and using a Personal Access Token (PAT) when prompted:
  ```bash
  git remote set-url origin https://<USERNAME>@github.com/owner/repo.git
  ```

---

### Issue: GH006 Protected Branch Update Failed
- **Scenario:** The Junior developer attempted to push a commit directly to the `main` branch.
- **Error Message:** 
  `remote: error: GH006: Protected branch update failed for refs/heads/main.`
  `remote: - Changes must be made through a pull request.`
  `! [remote rejected] main -> main (protected branch hook declined)`
- **Root Cause:** The GitHub repository has Branch Protection rules enabled that strictly forbid direct pushes to `main` and require all code to go through a Pull Request.
- **Solution:** 
  ```bash
  # 1. Move the commit to a new feature branch
  git checkout -b feature/update-readme
  
  # 2. Push the new branch to GitHub
  git push -u origin feature/update-readme
  
  # 3. Create a Pull Request on GitHub.com
  ```

---

*(Future issues will be appended below this line)*


### Issue 3: GitHub Actions `docker-compose: command not found` (Exit Code 127)
* **Scenario:** When running the CI pipeline on the `ubuntu-latest` runner, the step fails attempting to build the application.
* **Root Cause:** The pipeline YAML used the outdated Docker Version 1 syntax (`docker-compose` with a hyphen), which was a standalone program. Modern Linux servers use Docker Version 2, which integrated compose directly into the main docker executable.
* **Solution:** Remove the hyphen in the YAML file. Change the command from `run: docker-compose build` to `run: docker compose build`.
