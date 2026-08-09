# 🔒 PRIVATE.md — What Is Hidden & Where It Lives

This public repo is fully **sanitized**. The following material is **NOT** included here and lives in a
**separate PRIVATE GitHub repository** (visible only to the owner):

## 🚫 Hidden from this repo

| Material | Why hidden | Where it lives |
|----------|-----------|----------------|
| **Per-program findings** (`companies/<program>/`) — raw, unreported vulnerability write-ups | Unreported bounties, program confidentiality | `private/companies/` |
| **Evidence files** (JS chunks, source maps, screenshots, PDFs) | May contain PII / internal data | `private/companies/*/evidence/` |
| **Agent memory** (`agent_memory/`) — session logs, live credentials | Contains test creds, TOTP, API keys | `private/agent_memory/` |
| **Verified / rejected findings** | Unreported vulnerability details | `private/verified_findings/`, `private/rejected_findings/` |
| **BugBase reports** | Submitted-report copies | `private/bugbase_reports/` |
| **Attack plans** | Tactical details | `private/plans/` |
| **Raw portfolio docs** (`docs_raw/`) — FULL_VULNERABILITY_PORTFOLIO, ALL_AGENTS_COMBINED | Contain live keys before redaction | `private/docs_raw/` |
| **Target lists** (`targets/`, subdomain lists) | Live attack-surface data | `private/targets/` |
| **Notes** (`notes/`) | Personal research scratch | `private/notes/` |
| **Original `AGENTS.md`** (unredacted) | Test credentials inside | `private/AGENTS.md` |

## 🔴 Redacted in this repo (placeholders used)

Everywhere in this repo, the following were replaced with `REDACTED_*` placeholders:

- Google API keys (`AIza...`)
- Razorpay / Stripe live keys
- AWS access key IDs (`AKIA...`)
- SendGrid API keys, Slack tokens
- JWTs, session IDs, CSRF tokens
- TOTP secrets
- OpenRouter API keys (`sk-or-v1-...`)
- Private key blocks (examples left as-is — they are dork strings, not real keys)
- Test credentials (UAT customer IDs, passwords)
- Personal email address
- Internal RFC1918 IPs (`REDACTED_INTERNAL_IP`)

## ⭐ How to access the real docs

If you are the repo owner:
1. The private repo is `-bug-bounty-research-private` (same GitHub account).
2. It is **private** — visible only to you. Never make it public; GitHub secret-scanning also watches
   private repos, and raw credentials are present.
3. Recommended: rotate any live key that ever touched these docs (Razorpay, Google, Stripe, OpenRouter).

> ⚠️ If you found this repo, the public copy intentionally contains **no credentials** — there is
> nothing to exploit here. This is a methodology/education repository.
