# CI, Workflow and Adding Integration Tests

This document explains what to do when a change affects the build, CI matrix, or requires new
integration tests.

When you add a new feature or make build-affecting changes you should also:

- Update the workflow files in `.github/workflows/` (for example `tests.yml`) to include any
  additional build steps, matrix changes, or integration tests required by your feature.
- If you add integration tests, add them under the Integration Test job(s) (the `integration-test-core`
  or `integration-test-desktop` jobs). Create discrete steps named like `Integration Test - <Feature>`
  so test results are easy to interpret.
- If the new test requires repository secrets (SMTP credentials, test recipients, etc.), list them in
  your PR and ask a repository maintainer to add them to GitHub Settings → Secrets.

Example (what to add to `tests.yml` under the integration-test job):

```yaml
      - name: Integration Test - My New Feature
        shell: pwsh
        run: |
          Import-Module .\\EmailModule\\EmailModule.psm1
          $AuthUser = "${{ secrets.AUTHUSER }}"
          $AuthPass = "${{ secrets.AUTHPASS }}"
          $To = "${{ secrets.TO }}"
          $MailServer = "${{ secrets.MAILSERVER }}"
          Send-Email -AuthUser $AuthUser -AuthPass $AuthPass -EmailTo $To -EmailFrom $AuthUser -SmtpServer $MailServer
```

Run the same commands locally when possible to validate behavior before opening a PR. For running
GitHub Actions locally you can use tools like `act` (optional), but local builds with `dotnet build` and
`msbuild` and running the PowerShell integration steps manually will usually catch most issues.

Finally, when opening the PR:

- Target the `testing` branch so CI runs the integration matrix.
- Include the updated workflow files and clearly document new test requirements and secrets.

