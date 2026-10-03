# Stage 1: Git Basics & Initialization

## Goal
Initialize the clean sandbox repository, set up the base code (the Dockerized fullstack app), and push it to the remote repository.

## Key Commands Used

```bash
# Initialize a new Git repository
git init

# Set local repository identity
git config user.name "Senior Dev"
git config user.email "senior@example.com"

# Stage all files for commit
git add .

# Commit changes to local history
git commit -m "Initial commit: Add fullstack base code"

# Rename the default branch
git branch -M main

# Link local repository to the remote GitHub repository
git remote add origin <SSH_URL>

# Push local commits to the remote repository
git push -u origin main
```
