# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. 

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

## Pull Request Process

We follow a two-stage pull request flow that ensures changes are built, integration-tested, and
published in a controlled and repeatable way. Follow the steps below when contributing.

1) Branching and naming
   - Create a short-lived feature branch off `testing` for each logical change. Keep branches
     focused (one change per branch) and use descriptive names, for example:
       - `feat/<short-description>`
       - `fix/<short-description>`
       - `docs/<short-description>`

2) Stage 1 — PR into `testing` (required)
   - Open a pull request from your feature branch into the `testing` branch. This is the required
     gate that triggers the repository CI (`.github/workflows/tests.yml`) which runs:
       - .NET Framework and .NET Core builds
       - Integration tests across the OS matrix
       - Artifact creation for the module
   - Keep this PR up-to-date with `testing` (rebase or merge as required) until checks pass.

3) Stage 1 requirements (before merging into `testing`)
   - Provide a clear PR description explaining what changed and why.
   - Run local smoke builds for `EmailLibraryCore` and `EmailLibraryDesktop` when possible.
   - Do not include secrets or credentials in commits or PRs.
   - Update `README.md` and `CHANGELOG.md` for user-visible or breaking changes.
   - Assign reviewers and link relevant issues.

4) Stage 2 — PR into `main` (release)
   - Once the PR into `testing` has passed all required checks, open a PR from `testing` 
     into `main` to promote the change to release.
   - Merging into `main` triggers the release workflow which packages and publishes artifacts
     (for example NuGet packages, zip GitHub release artifacts and PSGallery Publish).
     Only promote changes to `main` after `testing` has succeeded.

5) Merge policy
   - Required checks must be green before merging (the CI jobs defined in `tests.yml`).
   - Require at least one reviewer approval.
   - Use a consistent merge strategy: squash-and-merge or rebase-and-merge. Resolve conflicts by
     rebasing your branch on the target branch and pushing the updated branch.

6) Public API / assembly version changes
   - If the PR modifies public C# APIs or assembly versioning:
       - Call out the change in the PR description and `CHANGELOG.md`.
       - Add notes about backwards compatibility and consumer impact.
       - Ensure integration tests cover the changed surface area.

7) PR description checklist (copy this into your PR body)
   - Title: short summary + issue number (if applicable)
   - Description: what changed and why
   - Checklist:
     - [ ] Built locally: `EmailLibraryCore` and `EmailLibraryDesktop`
     - [ ] Integration tests run locally (if applicable)
     - [ ] PR target is `testing`
     - [ ] `CHANGELOG.md` updated (if applicable)
     - [ ] No secrets in this PR
     - [ ] Reviewers assigned

8) Automation and tags
   - The CI may create tags or artifacts for successful `testing` builds; do not manually publish
     packages from feature branches. Publishing and releases are performed from `main` as part of
     the CI release workflow.

If you want, we can also add a repository-level Pull Request template so PRs are pre-populated with
the checklist and guidance. See the `.github/PULL_REQUEST_TEMPLATE.md` file for an example.

9) CI / Workflow changes and tests
   - If your change affects the build, test matrix, or release behavior, update the relevant
     workflow files in `.github/workflows/` (for example `tests.yml` and any release workflow that
     runs on `main`). Include a clear description in your PR of why the workflow change is needed.
   - If you change any build steps (commands, outputs, artifact locations, publish paths, or
     build configuration), update the repository's "Build from source" documentation so users
     can reproduce the build locally. The primary guide is at `docs/Build from source.md` (so
     the wiki page can be updated and changes maintained).
   - Add or update automated tests for new features or behavior in `tests.yml` (under the
     integration test jobs). Prefer adding discrete, independent steps named
     `Integration Test - <Feature>` so failures are easy to diagnose.
   - When modifying CI/workflows include the following in your PR:
       - The changed workflow file(s).
       - A description of the new test(s) and any required repository secrets.
       - Notes for maintainers on how to run the test(s) locally if they require special setup.
   - CI changes should be reviewed carefully; consider requesting an additional approval from a
     maintainer before merging workflow changes.

See the wiki page `docs/CI-and-Adding-Integration-Tests.md` for sample snippets and guidance when
adding or modifying integration tests and CI workflows.

