# Stage 2: Developer Onboarding & The Guardrails

## The Onboarding Process
When a new developer (the Junior) joins the organization:
1. They are granted access to the GitHub repository as a Collaborator by the Senior/Admin.
2. They pull the codebase to their local machine using their own credentials:
   ```bash
   git clone https://github.com/etornamdavoh7-ship-it/devops-sandbox.git
   ```

## The Guardrails (Branch Protection)
In an enterprise environment, the `main` branch is sacred. It represents the code that is running in production. To protect it, we configured GitHub Branch Protection rules:
* **Require a pull request before merging:** Forces all changes to be reviewed.
* **Enforce rules for administrators:** Ensures that even Senior developers cannot accidentally push directly to `main`.

## The Intentional Break
We tested the guardrails by attempting to push a direct commit to `main`. 

**Result:** The system worked perfectly. GitHub rejected the push with a `GH006: Protected branch update failed` error, stating that changes must be made through a pull request.
