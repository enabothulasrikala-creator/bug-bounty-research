# Consolidated Bug Bounty Findings — Scope-Verified

> Generated: June 27, 2026
> Source of truth: HackerOne policy_scopes pages (not community directories)
> Full scope reference: `SCOPE_REFERENCE.md`

---

## ✅ REPORTABLE FINDINGS

### 1. Neon — CSP Misconfiguration + Sentry DSN Leak
**Scope:** `console-stage.neon.build` explicitly in scope ✓  
**Status:** ✅ Verified live June 27, 2026  
**Est. Bounty:** $150-$750 (Low-Medium)

| Finding | PoC |
|---------|-----|
| **CSP `unsafe-inline` + `unsafe-eval`** in `script-src` | `curl -sI https://console-stage.neon.build/ \| grep content-security-policy` |
| **Sentry DSN exposed** via `report-uri` | `sentry_key=2d65ecac64634befa77615c9077a289e` in CSP |
| **Keycloak OIDC config exposed** | `/.well-known/openid-configuration` accessible |

---

## ❌ NOT REPORTABLE (Verified Out of Scope)

| Finding | Target | Reason |
|---------|--------|--------|
| OWA Basic Auth on webmail.nba.com | NBA | webmail.nba.com NOT in 206 in-scope assets. No wildcard scope. |
| Internal domain leak NBA-HQ.COM | NBA | Same — not on in-scope list |
| GCS bucket meesho/ | Meesho | `*.meesho.com` wildcard explicitly OOS |
| Internal APIs on live.meesho.com | Meesho | Not one of 12 in-scope assets |
| POW Webviews meesho.com | Meesho | Same — not in scope |
| GCP naming *.meeshogcp.in | Meesho | OOS per program policy |
| GCS buckets shopify-cdn/admin | Shopify | storage.googleapis.com = third-party infra |
| GraphQL on api.agoda.com | Agoda | Only www.agoda.com/book/ in scope |
| Twitter/X GCS buckets | Twitter/X | Third-party infra per policy |
| Razer | Razer | Program appears closed (404) |
| Ionity | Ionity | No bounty program |

---

## ACTIONABLE ATTACK SURFACE

Only assets we should actually test, organized by priority:

### HIGH PRIORITY
| Program | In-Scope Assets | Strategy |
|---------|----------------|----------|
| **Neon** | `console-stage.neon.build` (staging), `console.neon.tech`, `console.neon.tech/api/v2/` | Create staging account → test auth, IDOR, GraphQL, SSRF |

### MEDIUM PRIORITY
| Program | In-Scope Assets | Strategy |
|---------|----------------|----------|
| **Twitter/X** | `*.twitter.com`, `*.x.com`, `*.grok.com` (wildcards) | Subdomain enum on twitter.com + x.com → test auth flows |
| **NBA** | 206 specific subdomains (auth-identity-*, content-api-*, core-api-*, etc.) | Start with `auth-identity.nba.com`, `core-api.nba.com` — auth endpoints, API security |

### LOW PRIORITY (Complex setup required)
| Program | Requirement |
|---------|-------------|
| **Shopify** | Need @wearehackerone.com email + create test store |
| **Meesho** | Only 12 specific URLs + mobile apps |

---

## KEY LEARNINGS (Save this)

1. **Community directory ≠ official scope.** `nba_ep` listed `nba.com` but the real program (`nba-public`) has 206 specific assets — no wildcard.
2. **webmail.nba.com was a waste of time.** Always check policy_scopes before starting recon.
3. **Neon is our best target.** 3 simple assets, staging is encouraged, invite code available.
4. **See `SCOPE_REFERENCE.md`** for full asset lists of all programs.
