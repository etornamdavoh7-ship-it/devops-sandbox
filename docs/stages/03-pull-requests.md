# Stage 3: The Enterprise Pull Request Workflow (The Human Side)

Knowing Git commands is only 20% of the job. The other 80% is knowing how to collaborate with other humans on GitHub. Here is the exact step-by-step workflow of an Enterprise Pull Request.

## Step 1: The Push & The PR

1. **Branch & Push:** You create a branch (`git checkout -b feature/xyz`), write your code, commit it, and push it to GitHub.
2. **Compare & pull request:** You go to GitHub.com. A green banner will appear saying you recently pushed a branch. You click **"Compare & pull request"**.
3. **The Template:** You fill out the Title and Description. (Organizations use a `.github/pull_request_template.md` file so the description box is automatically pre-filled with questions like "What does this PR do?" and "How to test this?").

## Step 2: Hitting the Wall (Branch Protection)

Once you click "Create pull request", you will notice the green "Merge" button is blocked and says **Review required**.

- **The Rule:** You can never approve your own code. GitHub physically prevents the author of the PR from merging it into `main` without a second pair of eyes.

## Step 3: Asking for a Review (The Notification)

You must actively tell a Senior developer that your code is ready for review.

- On the right-hand sidebar of the PR, look for **Reviewers**.
- Click the gear icon and select your Senior's name. This triggers an automated email and GitHub notification to them, saying: _"Review requested by [YourName]"_.

## Step 4: The Review Loop (Feedback vs. Approval)

The Senior logs in, clicks the **Files changed** tab, and reviews your code line-by-line. They will take one of two actions:

### Option A: Request Changes (Feedback)

If the Senior finds a bug or wants something changed, they will select **Request changes** and leave comments.

- **Your action:** You do _not_ close the PR. You go back to your local terminal, make the requested fixes, and run `git add`, `git commit`, and `git push` again.
- The PR will automatically update with your new commits, and you can let the Senior know it's ready for another look.

### Option B: Approve

If the code looks perfect, the Senior selects **Approve**.

- The red block is instantly lifted.

## Step 5: The Merge & Sync

Once approved, either you or the Senior clicks **Merge pull request**. The feature is now officially in production (`main`).

- **Crucial Habit:** The second a PR is merged, your local laptop is officially out-of-date. You must immediately go to your terminal and run:
  ```bash
  git checkout main
  git pull origin main
  ```

## Step 6: Cleanup (Deleting the Branch)

Once a Pull Request is merged, the feature branch is dead. A core DevOps best practice is keeping the repository clean by deleting old branches.

1. **Cloud Cleanup:** Right after merging on GitHub, click the **Delete branch** button that appears.
   _(Alternatively, you can delete it directly from your terminal: `git push origin --delete feature/my-new-feature`)_
2. **Local Cleanup:** After syncing your `main` branch locally, delete the old feature branch from your computer:
   ```bash
   git branch -d feature/my-new-feature
   ```
   _(Pro-tip: Running `git fetch --prune` will automatically clean up your computer's memory of branches that were deleted on GitHub!)_
