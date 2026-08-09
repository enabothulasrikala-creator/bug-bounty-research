# ACTIVE SCOPE — DO NOT MODIFY DURING SESSION
# Generated: 2026-08-09 (Plaid HackerOne program)

## Program
- Name: Plaid (HackerOne)
- Platform: HackerOne
- Reporter: {{ASK_USER}} (HackerOne username)
- Testing Email: {{username}}@WeAreHackerOne.com
- Bounty launched: Mar 2018 | Response efficiency: 91%
- SLA: 48hr first response / 5 biz days triage / 10 biz days bounty

## In-Scope (exact matches)
### Domains (12 assets — broad: any Plaid domain/property)
- *.plaid.com
- plaid.com
- api.plaid.com
- sandbox.plaid.com
- dashboard.plaid.com
- development.plaid.com
- Any other Plaid-owned domain/property (accepted at Plaid's discretion, not guaranteed)

### IP Ranges (if any)
- N/A — web/API only

### Mobile Apps (if any)
- N/A (check program assets page for full 12)

## Out-of-Scope (explicitly excluded)
- Same-client Dashboard Users / Dashboard Team Permission Management (privilege escalation)
- Clickjacking on pages with no sensitive actions
- Unauthenticated/logout/login CSRF
- Attacks requiring MITM
- Known vulnerable libraries WITHOUT working PoC
- CSV injection without demonstrating vulnerability
- Missing best practices in SSL/TLS config
- Any activity that could disrupt service (DoS)
- Content spoofing/text injection without attack vector
- User account enumeration
- Vulns requiring attacker to obtain another user's authenticated session/tokens/physical access
- Issues depending on unpatched/outdated browsers or mobile platforms
- Version disclosure, detailed error messages, attacker-recon-only findings
- SPF and email antispam hygiene issues
- Cookie subdomain settings, security flags, missing security headers (app hygiene)
- Reports from automated scanners without validation/analysis
- Rate limit bypasses on sign-in and forgot/reset password (at discretion)
- Homoglyph phishing attacks / domain registration
- Dependency scan issues
- Best practices concerns

## Rules & Restrictions
- NO automated scanning (Burp Active Scan, ZAP Active Scan explicitly BANNED)
- NO social engineering (phishing, vishing, smishing)
- NO privacy violations, data destruction, service interruption
- Only interact with accounts you own or with explicit permission
- One vulnerability per report (unless chaining for impact)
- NDA — no public disclosure of vulnerabilities
- Use username@WeAreHackerOne.com email when testing
- Detailed reproducible reports required — not detailed = no reward
- Only first 2 bugs paid if pattern of vulnerability discovered
- Testing resources: plaid.com/docs/sandbox/institutions/ + test-credentials
- Postman docs: github.com/plaid/plaid-openapi, plaid-postman, plaid/pattern

## Session Safety
- [ ] Scope verified with user
- [ ] Test accounts ready (sandbox env)
- [ ] No OOS assets in any command
- [ ] No automated scanners — MANUAL testing only
