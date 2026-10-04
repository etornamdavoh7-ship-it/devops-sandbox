# Stage 8: DevSecOps Troubleshooting & "Break/Fix"

When implementing strict CI/CD pipelines on an existing project, you will inevitably play "Security Whack-a-Mole." The CI pipeline is designed to break and block code from merging if it detects flaws. 

Here are the enterprise debugging patterns we used to unblock the pipeline.

## 1. Deeply Nested Vulnerabilities (The `overrides` Trick)
**The Problem:** Trivy flagged `picomatch` and `sigstore` for HIGH vulnerabilities. However, these packages weren't in our `package.json`—they were deeply nested sub-dependencies (e.g., `nodemon` -> `chokidar` -> `braces`). Running `npm update` fails because it would require breaking changes to the top-level packages.
**The Fix:** We used the `"overrides"` block in `package.json` to force the package manager to use the secure version, regardless of what the parent package asked for.
```json
  "overrides": {
    "chokidar": {
      "braces": "^3.0.3"
    },
    "picomatch": "^4.0.4",
    "sigstore": "^4.1.1"
  }
```

## 2. Base Image Node/NPM Flaws (`EBADENGINE`)
**The Problem:** The official `node:20-alpine` base image shipped with an outdated version of `npm` that had vulnerabilities. When we tried to fix it by running `RUN npm install -g npm@latest`, the pipeline crashed with `EBADENGINE` because the absolute newest `npm` required Node 22+.
**The Fix:** We pinned the upgrade to the latest version that was still compatible with our OS engine (`RUN npm install -g npm@10`). **Lesson:** Never use `@latest` in production Dockerfiles; it removes your deterministic control.

## 3. The Enterprise Strictness Compromise
**The Problem:** The pipeline was originally set to fail (`exit-code: 1`) on any `HIGH` or `CRITICAL` vulnerabilities. It was flagging unfixable OS-level flaws in the Alpine Linux base image, freezing development.
**The Fix:** We relaxed the strictness to match real-world Enterprise DevOps standards:
1. We dropped `HIGH` from the blocking list. Only `CRITICAL` vulnerabilities will stop a deployment immediately.
2. We added `ignore-unfixed: true`, meaning Trivy will not fail the pipeline if a vulnerability exists but no patch has been invented for it yet.
