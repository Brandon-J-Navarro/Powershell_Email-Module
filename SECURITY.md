# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are
currently being supported with security updates. Update this table when you
publish new releases.

| Version | Supported          |
| ------- | ------------------ |
| main (1.0.6) | :white_check_mark: |
| release (1.0.5) | :white_check_mark: |
| release (1.0.4) | :white_check_mark: |

## Reporting a Vulnerability

Preferred reporting methods (in order):

1. Create a private GitHub Security Advisory for this repository (recommended).
2. Email the maintainers directly at: `brandon-j-navarro@outlook.com` — mark the subject line
   "[SECURITY] <short description>".

When reporting, please include:

- A brief title and description of the issue.
- Affected version(s) or commit SHA(s).
- Detailed steps to reproduce the issue (PoC, sample code, logs, or screenshots when helpful).
- The impact (confidentiality, integrity, availability) and any exploitability details.
- Any temporary mitigation or workarounds you discovered.
- Your contact information and preferred disclosure timeline (if any).

Do not include sensitive information such as passwords, private keys, or other secrets in the
initial report. If you need to share sensitive artifacts, we will provide a secure channel.

## What to expect after your report

We will acknowledge receipt of your report within 3 business days. Our response and remediation
process typically follows these steps:

1. Triage and acknowledgement (within 3 business days).
2. Initial analysis and severity assessment.
3. Creating a private issue or advisory to track the remediation.
4. Fix implementation, internal review, and tests.
5. Release of a fix (or mitigation) and coordinated public disclosure.

We aim to provide initial guidance or a mitigation plan within 14 calendar days and to ship a fix
within 30 calendar days for high-severity issues when possible. If more time is required we will
communicate progress and timelines to the reporter.

## Coordinated disclosure

We prefer to coordinate disclosure with the reporter to allow users time to update. If you would
like to remain anonymous or request an embargo, please indicate that in your report and we will
respect reasonable requests when possible.

## CVE assignment and credit

If you request a CVE or public credit, we will work with you to assign credit as appropriate. If
you prefer not to be credited publicly, please state that in your report.

## What we expect from reporters

- Use responsible disclosure practices: avoid public disclosure until a fix is available or we agree
  on a disclosure timeline.
- Provide enough detail for the maintainers to reproduce and fix the issue.
- Do not exploit the vulnerability beyond proof-of-concept testing on systems you own or have
  permission to test.

## Maintainer responsibilities

Maintainers will:

- Triage and acknowledge reports promptly.
- Triage and assess the severity of the report.
- Implement fixes and tests, and include regression tests when practical.
- Publish security advisories and release patches to the `main` branch and create releases when
  appropriate.
- Communicate timelines and provide status updates to the reporter.

## Supported and maintained versions

Security fixes will be provided for the current `main` release and the latest published release.
If a vulnerability affects older released versions, we will assess whether backporting a fix is
necessary and feasible and communicate that in the advisory.

## Additional notes

- Do not post security issues publicly (GitHub issues, social media, mailing lists) before we have
  had an opportunity to respond and mitigate.
- For non-security questions, use the repository's Issues page or discussion channels.

---

Thank you for helping make this project more secure. If you have any questions about this policy,
email `brandon-j-navarro@outlook.com`.
