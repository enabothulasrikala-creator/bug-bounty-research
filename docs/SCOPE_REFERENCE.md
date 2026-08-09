# HackerOne Program Scope Reference

> Definitive scope data for all programs we've researched.
> Sources: Strike.fyi, HackerOne policy_scopes, bountywatch, pentestnepal.tech
> Last updated: June 27, 2026

---

## NEON (`hackerone.com/neon_bbp`)

**3 in-scope assets** — All URL type, Critical max severity, Bounty eligible.

| Asset | Notes |
|-------|-------|
| `https://console.neon.tech/` | Production — use staging unless necessary. @wearehackerone.com email required |
| `https://console-stage.neon.build/` | **Preferred target** — use invite code `I-LOVE-PREVIEWS`. @wearehackerone.com email required |
| `https://console.neon.tech/api/v2/` | API endpoint |

**Rewards:** Low $300 / Medium $750 / High $2,000 / Critical $5,000  
**Bounties paid (90d):** $28,100 | **Reports resolved:** 61 | **Assets:** 3

---

## NBA (`hackerone.com/nba-public`)

**206 in-scope assets** — All individual URLs, **NO wildcard `*.nba.com` scope**.

### Partial Asset List (first 60 of 206):

| Asset | Type |
|-------|------|
| aces-dev.wnba.com | url |
| aces-qa.wnba.com | url |
| aces-qa2.wnba.com | url |
| aces.wnba.com | url |
| adb.nba.com | url |
| auth-identity-dev-ping.nba.com | url |
| auth-identity-dev.nba.com | url |
| auth-identity-ping.nba.com | url |
| auth-identity-qa-ping.nba.com | url |
| auth-identity-qa.nba.com | url |
| auth-identity-uat-ping.nba.com | url |
| auth-identity-uat.nba.com | url |
| auth-identity.nba.com | url |
| bal-dev.nba.com | url |
| bal-qa.nba.com | url |
| bal-uat.nba.com | url |
| bal.nba.com | url |
| br.nba.com | url |
| cares.nba.com | url |
| cdn-bal.nba.com | url |
| cdn.nba.com | url |
| cl.nba.com | url |
| cms.nba.com | url |
| com.nbaimd.gametime.nba2011 | mobile |
| com.nbaimd.gametime.universal | mobile |
| content-api-dev.nba.com | url |
| content-api-nextgen-dev.nba.com | url |
| content-api-nextgen-prod.nba.com | url |
| content-api-nextgen-qa.nba.com | url |
| content-api-nextgen-uat.nba.com | url |
| content-api-prod.nba.com | url |
| content-api-qa.nba.com | url |
| content-api-sandbox.nba.com | url |
| content-api-uat.nba.com | url |
| core-api-aws-dev.nba.com | url |
| core-api-aws-prod-east1.nba.com | url |
| core-api-aws-prod.nba.com | url |
| core-api-aws-qa.nba.com | url |
| core-api-aws-uat.nba.com | url |
| core-api-dev.nba.com | url |
| core-api-devint.nba.com | url |
| core-api-qa.nba.com | url |
| core-api-sandbox.nba.com | url |
| core-api-uat-uc.nba.com | url |
| core-api-uat.nba.com | url |
| core-api-uc.nba.com | url |
| core-api.nba.com | url |
| corp-dev.nba.com | url |
| cweb-ott-aws-qa.nba.com | url |
| cweb-ott-aws-uat-uw2.nba.com | url |
| cweb-ott-aws-uat.nba.com | url |
| cweb-ott-dev-aws.nba.com | url |
| cweb-ott-dev-preview.nba.com | url |
| cweb-ott-dev.nba.com | url |
| cweb-ott-devint.nba.com | url |
| cweb-ott-preview.nba.com | url |
| cweb-ott-qa-aws.nba.com | url |
| cweb-ott-qa-preview.nba.com | url |
| cweb-ott-qa.nba.com | url |
| cweb-ott-uat-preview.nba.com | url |
| *... and 146 more* | |

**Out of scope (17):** 2kleague-dev.nba.com, 2kleague-qa.nba.com, 2kleague.nba.com, arcade.nba.com, coalition.nba.com, dev.stats.2kleague.nba.com, events.bal.nba.com, evergent.com, leaguepass.wnba.com, mindhealth.nba.com, nbafoundation-dev.nba.com, nbafoundation-qa.nba.com, nbafoundation.nba.com, payment.nba.com, smm.events.nba.com, stats.2kleague.nba.com, totalhealth.nba.com

**Rewards:** $50-$6,000 | **Avg bounty:** Low $200 / Med $340 / High $1,500 / Critical $2,000  
**Server info disclosure is OOS** per policy: "Server Information & Status Pages" is explicitly excluded

**OUR FINDING (webmail.nba.com):** ❌ NOT in scope. webmail.nba.com and webmail.hk.nba.com are NOT on the 206-asset list.

---

## TWITTER/X (`hackerone.com/x`)

**20 in-scope assets** — Mostly wildcards.

| Asset | Type | Max Sev | Bounty |
|-------|------|---------|--------|
| `*.grok.com` | wildcard | Critical | ✓ |
| `*.twimg.com` | wildcard | Critical | ✓ |
| `*.twitter.biz` | wildcard | Critical | ✓ |
| `*.twitter.com` | wildcard | Critical | ✓ |
| `*.vine.co` | wildcard | Critical | ✓ |
| `*.x.ai` | wildcard | Critical | ✓ |
| `*.x.com` | wildcard | Critical | ✓ |
| `ai.x.GrokApp` | mobile | Critical | ✓ |
| `ai.x.grok` | mobile | Critical | ✓ |
| `chat.x.com` | url | Critical | ✓ |
| `com.atebits.Tweetie2` | mobile | Critical | ✓ |
| `com.twitter.android` | mobile | Critical | ✓ |
| `gnip.com` | url | Critical | ✓ |
| `grok-build-cli` | other | Critical | ✓ |
| `grok.com` | url | Critical | ✓ |
| `grokipedia.com` | url | Critical | ✓ |
| `money.x.com` | url | Critical | ✓ |
| `t.co` | url | Medium | — |
| `x.com` | url | Critical | ✓ |
| `xadsacademy.com` | url | Medium | — |

**Out of scope:** status.twitter.com

**Rewards:** $100-$20,000 | **Bounties paid (90d):** Unknown  
**Key rules:** No DoS, no automated scanning, test accounts only

---

## MEESHO (`hackerone.com/meesho_bbp`)

**12 in-scope assets** — Specific URLs only. **No wildcards except explicitly listed.**

| Asset | Type | Max Sev | Bounty |
|-------|------|---------|--------|
| `1457958492` (Apple Store ID) | APPLE_STORE_APP_ID | Critical | ✓ |
| `admin.meeshosupply.com` | URL | Critical | ✓ |
| `affiliate.meesho.com` | URL | Critical | ✓ |
| `com.meesho.supply` (Play Store ID) | GOOGLE_PLAY_APP_ID | Critical | ✓ |
| `com.valmo.valmo` (Play Store ID) | GOOGLE_PLAY_APP_ID | Critical | ✓ |
| `investor.meesho.com` | URL | Low | ✓ |
| `meesho.io` | URL | Low | ✓ |
| `prod.meeshoapi.com` | API | Critical | ✓ |
| `superstoreapp.meesho.com` | URL | High | ✓ |
| `supplier.meesho.com` | URL | Critical | ✓ |
| `www.meesho.com` | URL | Critical | ✓ |
| `www.valmo.in` | URL | Critical | ✓ |

**NOT in scope (wildcards explicitly OOS):** `*.meesho.com`, `*.meeshoaiservices.ai`, `*.meeshoapi.com`, `*.meeshogcp.in`, `*.meeshosupply.com`, `*.valmo.in`

**Out of scope URLs:** admin.meesho.io, affiliate-c.meesho.com, agency.meesho.com, atlas.valmo.in, com.valmo.ops, console.valmo.in, di-prd-superset.meesho.com, farmiso.meeshosupply.com, grocery-supplier.meesho.com, log10-web-staging.valmo.in, warehouse.meesho.com

**Rewards:** Low $50-$150 / Med $150-$600 / High $600-$1,200 / Critical $1,200-$2,000 (web)
Mobile: Low $100-$250 / Med $250-$800 / High $800-$1,700 / Critical $1,700-$2,500

**OUR FINDINGS:** All 4 Meesho findings (GCS bucket, live.meesho.com internal APIs, pow-webviews.meesho.com, meeshogcp.in) — ❌ NOT reportable.

---

## SHOPIFY (`hackerone.com/shopify`)

**30+ in-scope assets** — Partial list from policy_scopes:

| Asset | Type | Notes |
|-------|------|-------|
| `*.myshopify.com` (your-store) | Domain | Core — create dev store at partners.shopify.com |
| `shopify.plus` | Domain | Core |
| Shopify Mobile Apps | Other | Android + iOS |
| `shop.app` | Domain | Core |
| `partners.shopify.com` | Domain | Core |
| `Authentication & ATO` | Other | New (added Jun 2026) |
| `arrive-server.shopifycloud.com` | Domain | Core |
| `admin.shopify.com` | Domain | Core |
| `accounts.shopify.com` | Domain | Core |
| `*.shopify.com` | wildcard | Likely |
| `cdn.shopify.com` | Domain | May be OOS |
| `*.shopifycloud.com` | wildcard | Likely |

**Rewards:** Up to $200,000 | **Requires:** @wearehackerone.com email, test stores only  
**OUR FINDING (GCS buckets):** ❌ storage.googleapis.com is third-party infra — NOT reportable

---

## AGODA (`hackerone.com/agoda-public`)

**1 in-scope asset:**

| Asset | Type | Notes |
|-------|------|-------|
| `https://www.agoda.com/book/` | URL | Only this path on www.agoda.com |

**OUR FINDINGS (GraphQL endpoints):** ❌ api.agoda.com and partners.agoda.com are NOT in scope.

---

## RAPID SCOPE CHECK COMMANDS

```bash
# Quick scope lookup via Strike.fyi
program="nba-public"  # or: x, neon_bbp, shopify, meesho_bbp
curl -s "https://strike.fyi/bounty/$program" | grep -E "In-scope assets|Out-of-scope" | head -5

# Source: bounty-targets-data (5MB+ JSON - slow)
curl -s "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/hackerone_data.json" | \
  python3 -c "import json,sys; d=json.load(sys.stdin); [print(p['name'],len(p['targets']['in_scope'])) for p in d['programs'] if 'nba' in p['handle']]"

# Source: pentestnepal.tech
curl -s "https://blog.pentestnepal.tech/bugbounty/neon" | grep -A2 "In-Scope"
```

## KEY TAKEAWAYS FOR FUTURE SESSIONS

1. **NEVER trust community directory pages** (like `nba_ep`) — the official `policy_scopes` is the truth
2. **No wildcard = not in scope** — if `webmail.nba.com` isn't literally listed, don't test it
3. **Staging CAN be in scope** — Neon explicitly lists `console-stage.neon.build`. Always check
4. **GCS/S3 buckets on storage.googleapis.com** are almost always third-party infra → OOS
5. **Check scope before recon** — saves hours of wasted effort
6. **Strike.fyi** is the best quick source for parsed scope data

## TOOL: h1-scope-fetcher
```bash
# Requires HackerOne API credentials
go install github.com/0xDexter0us/h1-scope-fetcher@latest
h1-scope-fetcher -p "shopify" -u "username" -k "api_key"
```
