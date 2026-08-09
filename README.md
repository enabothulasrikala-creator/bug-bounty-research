# 🛡️ Bug Bounty Research Workspace — LostSec Methodology

> **A full offensive-security research workspace** built on the **LostSec (coffinxp)** bug-bounty methodology.
> Everything here is **public, sanitized, and credential-free**. Live findings, credentials, and private
> reports live in a **separate private repository** (see [`PRIVATE.md`](PRIVATE.md)).

---

## 📖 What Is This?

This is a complete, portable **bug-bounty hunting research environment** — methodology, automation
scripts, agent definitions, and a 100+ file security skills library. It was built and used to run
authorized bug-bounty programs (HackerOne/BugBase-style) against Indian fintech and consumer brands.

It implements the exact workflow popularized by **LostSec / coffinxp** (Mar 2026):

```
CHAOS → HTTPX → NAABU → NMAP + PARSERS → NUCLEI → FFUF
```

Plus deep WAF-bypass, secret-hunting, and vulnerability-chaining playbooks.

---

## 🗂️ Repository Layout — **Every File** (full structure)

```
AGENTS.md
agents/
│   ├── auditor.md
│   ├── debug.md
│   ├── hunter.md
│   ├── plan.md
│   ├── recon.md
│   ├── reporter.md
│   └── verifier.md
docs/
│   ├── ALL_AGENTS_COMBINED.md
│   ├── ALL_AGENTS_COMBINED.pdf
│   ├── BUGBASE_THREADS.md
│   ├── CONSOLIDATED_FINDINGS.md
│   ├── FULL_VULNERABILITY_PORTFOLIO (1).md
│   ├── FULL_VULNERABILITY_PORTFOLIO.md
│   ├── FULL_VULNERABILITY_PORTFOLIO_updated.md
│   ├── LOSTSEC_METHODS.md
│   ├── MASTER_TIMELINE_LOG.md
│   ├── MASTER_VULNERABILITY_PORTFOLIO.md
│   ├── METHODOLOGIES.md
│   ├── README.md
│   ├── SCOPE_REFERENCE.md
│   ├── SWEEP_REPORT_20260720.md
│   ├── TOR.md
│   ├── Vulnerability_Portfolio.pdf
│   └── opencode-landing/
│       ├── PROGRESS.md
│       └── index.html
methodology/
│   ├── CHAINING_VULNS.md
│   ├── CWE_DATABASE.md
│   ├── LOSTSEC_ACTUATOR.md
│   ├── LOSTSEC_AUTH_SESSION.md
│   ├── LOSTSEC_BLIND_XSS.md
│   ├── LOSTSEC_CACHE_DECEPTION.md
│   ├── LOSTSEC_CRLF_INJECTION.md
│   ├── LOSTSEC_CT_MONITORING.md
│   ├── LOSTSEC_GITHUB_RECON.md
│   ├── LOSTSEC_GOOGLE_API_KEYS.md
│   ├── LOSTSEC_IIS_HACKING.md
│   ├── LOSTSEC_MASS_ASSIGNMENT.md
│   ├── LOSTSEC_ORIGIN_IP.md
│   ├── LOSTSEC_PUNYCODE_ATO.md
│   ├── LOSTSEC_REACT2SHELL.md
│   ├── LOSTSEC_REGISTRATION_BUGS.md
│   ├── LOSTSEC_S3_BUCKETS.md
│   ├── LOSTSEC_SQLMAP_GHAURI.md
│   ├── LOSTSEC_SWAGGER_UI.md
│   ├── LOSTSEC_WORKFLOW.md
│   ├── SCOPE_POLICY.md
│   ├── SSRF_ADVANCED.md
│   ├── TOOLS_REFERENCE.md
│   ├── TRAINING_GUIDE.md
│   └── WAF_BYPASS_ADVANCED.md
scripts/
│   ├── 1.js
│   ├── 1.py
│   ├── 123.sh
│   ├── 1234.sh
│   ├── 74.py
│   ├── CorsPoC.html
│   ├── README.md
│   ├── __pycache__/
│   │   └── new1.cpython-39.pyc
│   ├── agents_launcher.sh
│   ├── alienvault.sh
│   ├── client.py
│   ├── client.spec
│   ├── clinet.py
│   ├── common.txt
│   ├── continuous_probe.sh
│   ├── dorking.py
│   ├── forever_agent.sh
│   ├── generate_key.py
│   ├── hunter.sh
│   ├── index.html
│   ├── install
│   ├── install.sh
│   ├── lastmile_login.js
│   ├── lastmile_test2.js
│   ├── lostfuzzer.sh
│   ├── lostsec_hunter_agent.sh
│   ├── ls.txt
│   ├── naabutonmap.py
│   ├── new.sh
│   ├── new1.py
│   ├── news.sh
│   ├── nmap_scan.log
│   ├── orch.py
│   ├── punycode_gen.py
│   ├── python.py
│   ├── raparapa.html
│   ├── report_agent.sh
│   ├── restart_agent.sh
│   ├── sast_fuzzer.py
│   ├── server.nim
│   ├── server.py
│   ├── server.spec
│   ├── subdomains-200.txt
│   ├── subs.txt
│   ├── tv.py
│   ├── tv_paths.txt
│   ├── urlscan.py
│   ├── verify_agent.sh
│   ├── virustotal.sh
│   ├── voice_assistant.html
│   ├── wapiti_build/
│   │   ├── base_check.sh
│   │   ├── base_only.sh
│   │   ├── check_func.sh
│   │   ├── check_func_clean.sh
│   │   ├── check_part.sh
│   │   ├── check_part2.sh
│   │   ├── check_part3.sh
│   │   ├── check_part4.sh
│   │   ├── check_t.sh
│   │   ├── commented.sh
│   │   ├── comp_test.sh
│   │   ├── no_entry.sh
│   │   ├── phase_report_body.sh
│   │   ├── stripped.sh
│   │   ├── test1.sh
│   │   ├── test2.sh
│   │   ├── test_base.sh
│   │   ├── test_phase_report.sh
│   │   ├── test_tail.sh
│   │   ├── toplevel_test.sh
│   │   ├── trunced_100000.sh
│   │   ├── trunced_110000.sh
│   │   ├── trunced_115000.sh
│   │   ├── trunced_118000.sh
│   │   ├── trunced_120000.sh
│   │   ├── trunced_121000.sh
│   │   ├── trunced_121500.sh
│   │   ├── trunced_121800.sh
│   │   ├── trunced_121900.sh
│   │   ├── up_to_100k.sh
│   │   ├── wrap_full.sh
│   │   └── wrap_toplevel.sh
│   ├── wapiti_improvised.sh
│   ├── wapiti_improvised_test.sh
│   └── wayback.sh
skills/
    ├── 401-403-bypass-techniques/
    │   └── SKILL.md
    ├── active-directory-acl-abuse/
    │   ├── BLOODHOUND_PATHS.md
    │   └── SKILL.md
    ├── active-directory-certificate-services/
    │   ├── ADCS_ESC_MATRIX.md
    │   └── SKILL.md
    ├── active-directory-kerberos-attacks/
    │   ├── KERBEROS_ATTACK_CHAINS.md
    │   └── SKILL.md
    ├── ai-ml-security/
    │   └── SKILL.md
    ├── android-pentesting-tricks/
    │   ├── FRIDA_SCRIPTS.md
    │   └── SKILL.md
    ├── anti-debugging-techniques/
    │   ├── ANTI_DEBUG_MATRIX.md
    │   └── SKILL.md
    ├── api-auth-and-jwt-abuse/
    │   └── SKILL.md
    ├── api-authorization-and-bola/
    │   └── SKILL.md
    ├── api-recon-and-docs/
    │   └── SKILL.md
    ├── api-sec/
    │   └── SKILL.md
    ├── arbitrary-write-to-rce/
    │   └── SKILL.md
    ├── auth-sec/
    │   └── SKILL.md
    ├── authbypass-authentication-flaws/
    │   └── SKILL.md
    ├── binary-protection-bypass/
    │   ├── PROTECTION_BYPASS_MATRIX.md
    │   └── SKILL.md
    ├── browser-exploitation-v8/
    │   ├── SKILL.md
    │   └── V8_EXPLOITATION_PATTERNS.md
    ├── bug-bounty/
    │   ├── BYPASS_DATABASE.md
    │   ├── SKILL.md
    │   ├── best_skill.md
    │   ├── index.json
    │   ├── seed_skill.md
    │   ├── skillopt_config.yaml
    │   ├── trajectories/
    │   │   ├── traj_07f4da75_Subdomain_takeover_nuclei_scan.json
    │   │   ├── traj_0d271887_GraphQL_introspection_on_boat.json
    │   │   ├── traj_10fc8746_HDFC_Netbanking_JS_bundle_analysis.json
    │   │   ├── traj_1125cc87_Wayback_CDX_bypass_via_Tor_proxy.json
    │   │   ├── traj_2004f29d_Spring_Boot_actuator_enumeration.json
    │   │   ├── traj_238a002b_Laravel_debug_mode_testretailer_boat.json
    │   │   ├── traj_27a85f0b_SSRF_cloud_metadata_test_failed.json
    │   │   ├── traj_32f7d5bc_HDFC_CBX_Web_portal_recon.json
    │   │   ├── traj_4108276b_HDFC_Lastmile_Web_login_page_analysis.json
    │   │   ├── traj_43fe6c31_Full_LostSec_recon_pipeline_successful.json
    │   │   ├── traj_6c66b25d_Grafana_dashboard_grafana-gcp_boat.json
    │   │   ├── traj_82d72e28_HDFC_OTP_bypass_test_on_Netbanking.json
    │   │   ├── traj_9dd46c0b_S3_PII_Leak_boat_PDFs_exposed.json
    │   │   ├── traj_a629e2f7_HDFC_Netbanking_Rewrite_auth_analysis.json
    │   │   ├── traj_c47a93f7_Crewex_OTP_rate_limit_bypass_analysis.json
    │   │   ├── traj_c7209125_JWT_secret_scanning_JS_bundles.json
    │   │   ├── traj_d287eb52_Mendix_SOAP_endpoint_enumeration_naavik.json
    │   │   ├── traj_f10d6018_Apache_no_TLS_on_test.boat-lifestyle.com.json
    │   │   └── traj_f269ba1c_Razorpay_Live_Key_found_in_Mendix.json
    │   └── versions/
    │       ├── v0.md
    │       ├── v0.meta.json
    │       ├── v1.md
    │       └── v1.meta.json
    ├── business-logic-vuln/
    │   └── SKILL.md
    ├── business-logic-vulnerabilities/
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── classical-cipher-analysis/
    │   └── SKILL.md
    ├── clickjacking/
    │   └── SKILL.md
    ├── cmdi-command-injection/
    │   └── SKILL.md
    ├── code-obfuscation-deobfuscation/
    │   └── SKILL.md
    ├── container-escape-techniques/
    │   ├── DOCKER_ESCAPE_CHAINS.md
    │   └── SKILL.md
    ├── cors-cross-origin-misconfiguration/
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── crlf-injection/
    │   └── SKILL.md
    ├── csp-bypass-advanced/
    │   └── SKILL.md
    ├── csrf-cross-site-request-forgery/
    │   └── SKILL.md
    ├── csv-formula-injection/
    │   └── SKILL.md
    ├── dangling-markup-injection/
    │   └── SKILL.md
    ├── defi-attack-patterns/
    │   └── SKILL.md
    ├── dependency-confusion/
    │   └── SKILL.md
    ├── deserialization-insecure/
    │   ├── JAVA_GADGET_CHAINS.md
    │   └── SKILL.md
    ├── dns-rebinding-attacks/
    │   └── SKILL.md
    ├── dns-recon/
    │   └── SKILL.md
    ├── email-header-injection/
    │   └── SKILL.md
    ├── expression-language-injection/
    │   └── SKILL.md
    ├── file-access-vuln/
    │   └── SKILL.md
    ├── format-string-exploitation/
    │   └── SKILL.md
    ├── graphql-and-hidden-parameters/
    │   └── SKILL.md
    ├── hack/
    │   └── SKILL.md
    ├── hash-attack-techniques/
    │   └── SKILL.md
    ├── heap-exploitation/
    │   ├── HOUSE_OF_TECHNIQUES.md
    │   ├── IO_FILE_EXPLOITATION.md
    │   └── SKILL.md
    ├── http-host-header-attacks/
    │   └── SKILL.md
    ├── http-parameter-pollution/
    │   └── SKILL.md
    ├── http2-specific-attacks/
    │   └── SKILL.md
    ├── idor-broken-object-authorization/
    │   └── SKILL.md
    ├── injection-checking/
    │   ├── EXTRA_INJECTION_TYPES.md
    │   └── SKILL.md
    ├── insecure-source-code-management/
    │   └── SKILL.md
    ├── ios-pentesting-tricks/
    │   ├── IOS_RUNTIME_TRICKS.md
    │   └── SKILL.md
    ├── jndi-injection/
    │   └── SKILL.md
    ├── js-analysis/
    │   └── SKILL.md
    ├── jwt-oauth-token-attacks/
    │   └── SKILL.md
    ├── kernel-exploitation/
    │   ├── KERNEL_HEAP_TECHNIQUES.md
    │   ├── KERNEL_MITIGATION_BYPASS.md
    │   └── SKILL.md
    ├── kubernetes-pentesting/
    │   └── SKILL.md
    ├── lattice-crypto-attacks/
    │   └── SKILL.md
    ├── linux-lateral-movement/
    │   └── SKILL.md
    ├── linux-privilege-escalation/
    │   ├── KERNEL_EXPLOITS_CHECKLIST.md
    │   ├── SKILL.md
    │   └── SUID_CAPABILITIES_TRICKS.md
    ├── linux-security-bypass/
    │   └── SKILL.md
    ├── llm-prompt-injection/
    │   ├── JAILBREAK_PATTERNS.md
    │   └── SKILL.md
    ├── macos-process-injection/
    │   ├── DYLIB_XPC_TECHNIQUES.md
    │   └── SKILL.md
    ├── macos-security-bypass/
    │   ├── SKILL.md
    │   └── TCC_BYPASS_MATRIX.md
    ├── memory-forensics-volatility/
    │   ├── SKILL.md
    │   └── VOLATILITY_CHEATSHEET.md
    ├── mobile-ssl-pinning-bypass/
    │   └── SKILL.md
    ├── network-protocol-attacks/
    │   ├── NAME_RESOLUTION_POISONING.md
    │   └── SKILL.md
    ├── nosql-injection/
    │   └── SKILL.md
    ├── ntlm-relay-coercion/
    │   ├── COERCION_METHODS.md
    │   └── SKILL.md
    ├── oauth-oidc-misconfiguration/
    │   └── SKILL.md
    ├── open-redirect/
    │   └── SKILL.md
    ├── path-traversal-lfi/
    │   └── SKILL.md
    ├── prototype-pollution/
    │   └── SKILL.md
    ├── prototype-pollution-advanced/
    │   ├── KNOWN_GADGETS.md
    │   └── SKILL.md
    ├── race-condition/
    │   └── SKILL.md
    ├── recon-and-methodology/
    │   └── SKILL.md
    ├── recon-for-sec/
    │   └── SKILL.md
    ├── request-smuggling/
    │   ├── H2_SMUGGLING_VARIANTS.md
    │   └── SKILL.md
    ├── reverse-shell-techniques/
    │   ├── SHELL_CHEATSHEET.md
    │   └── SKILL.md
    ├── rsa-attack-techniques/
    │   ├── RSA_ATTACK_CATALOG.md
    │   └── SKILL.md
    ├── saml-sso-assertion-attacks/
    │   └── SKILL.md
    ├── sandbox-escape-techniques/
    │   ├── PYTHON_SANDBOX_ESCAPE.md
    │   ├── SECCOMP_BYPASS.md
    │   └── SKILL.md
    ├── scope-guard/
    │   ├── SCOPE_ACTIVE.md
    │   ├── SKILL.md
    │   └── scope_init.sh
    ├── skillopt/
    │   ├── README.md
    │   ├── SKILL.md
    │   ├── opencode_hook.py
    │   ├── seed_bug_bounty.md
    │   ├── skillopt_cli.py
    │   ├── skillopt_config.yaml
    │   └── skillopt_optimizer.py
    ├── smart-contract-vulnerabilities/
    │   ├── SKILL.md
    │   └── SOLIDITY_VULN_PATTERNS.md
    ├── sqli-sql-injection/
    │   ├── SCENARIOS.md
    │   ├── SKILL.md
    │   └── SQLMAP_ADVANCED.md
    ├── ssrf-server-side-request-forgery/
    │   ├── SCENARIOS.md
    │   ├── SKILL.md
    │   └── URL_PARSER_TRICKS.md
    ├── ssti-server-side-template-injection/
    │   ├── ENGINE_PAYLOADS.md
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── stack-overflow-and-rop/
    │   ├── ROP_ADVANCED_TECHNIQUES.md
    │   └── SKILL.md
    ├── steganography-techniques/
    │   ├── SKILL.md
    │   └── STEGO_TOOLS_GUIDE.md
    ├── subdomain-takeover/
    │   └── SKILL.md
    ├── symbolic-execution-tools/
    │   ├── ANGR_COOKBOOK.md
    │   └── SKILL.md
    ├── symmetric-cipher-attacks/
    │   ├── BLOCK_CIPHER_ATTACKS.md
    │   └── SKILL.md
    ├── traffic-analysis-pcap/
    │   └── SKILL.md
    ├── tunneling-and-pivoting/
    │   └── SKILL.md
    ├── type-juggling/
    │   └── SKILL.md
    ├── unauthorized-access-common-services/
    │   ├── PORT_SERVICE_MATRIX.md
    │   └── SKILL.md
    ├── upload-insecure-files/
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── vm-and-bytecode-reverse/
    │   └── SKILL.md
    ├── waf-bypass-techniques/
    │   ├── SKILL.md
    │   └── WAF_PRODUCT_MATRIX.md
    ├── web-cache-deception/
    │   ├── CACHE_POISONING_TECHNIQUES.md
    │   └── SKILL.md
    ├── websocket-security/
    │   └── SKILL.md
    ├── windows-av-evasion/
    │   ├── AMSI_BYPASS_TECHNIQUES.md
    │   └── SKILL.md
    ├── windows-lateral-movement/
    │   ├── CREDENTIAL_DUMPING.md
    │   └── SKILL.md
    ├── windows-privilege-escalation/
    │   ├── SKILL.md
    │   ├── TOKEN_POTATO_TRICKS.md
    │   └── UAC_BYPASS_METHODS.md
    ├── xslt-injection/
    │   └── SKILL.md
    ├── xss-cross-site-scripting/
    │   ├── ADVANCED_XSS_TRICKS.md
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    └── xxe-xml-external-entity/
        ├── SCENARIOS.md
        └── SKILL.md
```

---

## ⚙️ The Core Pipeline (LostSec one-liner)

```bash
chaos -d target.com -o subs.txt && \
httpx -l subs.txt -ip -silent | sed -nE 's/.*\[([0-9.]+)\].*/\1/p' | sort -u > ip.txt && \
httpx -l ip.txt -title -silent | grep -vi "cloudflare\|akamai\|fastly" | awk '{print $1}' > origin_ips.txt && \
naabu -l origin_ips.txt -top-ports 100 -rate 1500 -verify -silent -o naabu.txt && \
python3 ~/scripts/naabutonmap.py -i naabu.txt && \
cat ip.txt | nuclei -tags cve -bs 200 && \
cat naabu.txt | nuclei -tags cve -bs 200 && \
ffuf -w naabu.txt:URL -w payloads/backup_files_only.txt:FILE -u https://URL/FILE -mc 200 -rate 50 -fs 0
```

### Key principles
1. **CDN/WAF filtering is MANDATORY** — only scan origin IPs (skip Cloudflare/Akamai/Fastly).
2. **Non-standard ports matter** — feed `naabu.txt` into nuclei + ffuf, not just 80/443.
3. **403 is gold** — always try bypass techniques (headers, path manipulation, case, double-encoding).
4. **Response-size analysis** — a `200 OK` can be a custom error page; compare size/word counts.
5. **IP dedup** — many subdomains resolve to the same backend; `sort -u` first.

---

## 🤖 Agent System

The workspace is designed as a **multi-agent pipeline** (opencode agents):

| Agent | Role |
|-------|------|
| **hunter** | Runs the LostSec pipeline, continuous probing, WAF bypass, saves findings |
| **verifier** | Re-checks every finding (3-request rule, baseline diff, CVSS 3.1, false-positive signatures) |
| **reporter** | Produces BugBase-format reports (≤120-char title, single URL, live curl PoCs) |
| **plan** | OSINT + attack-surface research → step-by-step plan |
| **recon** | Fast subdomain enumeration + attack-surface discovery |
| **debug** | Self-improvement, mistake logging, cross-agent learning |
| **auditor** | Static code + dependency vulnerability audit |

---

## 🎯 What the Research Covers

- **Reconnaissance**: passive subdomain enum (Chaos, subfinder, assetfinder, crt.sh, CT logs),
  live-host probing (httpx), port scanning (naabu/nmap), JS bundle analysis, source-map mining.
- **Vulnerability classes**: SQLi, XSS, SSRF, SSTI, LFI, IDOR, CORS, CSRF, open redirect,
  actuator exposure, cache deception, blind XSS, subdomain takeover, mass assignment, auth/session bugs.
- **WAF bypass**: 15+ techniques (encoding chains, comment injection, HPP, chunked encoding,
  body padding, protocol downgrade, request smuggling, origin-IP discovery).
- **Cloud**: S3 bucket recon/exploitation, GCP/AWS metadata SSRF, Google API key hunting + validation.
- **Business logic**: race conditions, price manipulation, OTP brute-force, punycode 0-click ATO.
- **Chaining**: SSRF→internal API→RCE, auth bypass→IDOR→data exfiltration, etc.

---

## 🚀 Quick Start

```bash
# 1. Clone
git clone https://github.com/enabothulasrikala-creator/bug-bounty-research.git
cd bug-bounty-research

# 2. Read the methodology
cat methodology/LOSTSEC_WORKFLOW.md
cat methodology/TRAINING_GUIDE.md

# 3. Use the scripts (example: passive URL collection)
cat subs.txt | waybackurls | uro > urls.txt
bash scripts/lostfuzzer.sh
```

> ⚠️ **Ethics**: This methodology is for **authorized** testing only. Every real program tested here was
> in-scope with permission (BugBase / HackerOne style programs). Unauthorized use against any system is
> illegal. All live credentials, test accounts, internal IPs, and unreported findings are **NOT** in this
> repo — they are kept in a private repository.

---

## 🔒 Privacy & Sanitization

- This public repo was **auto-redacted**: live API keys (Google, Razorpay, Stripe, AWS, SendGrid,
  OpenRouter), session tokens, JWTs, private keys, TOTP secrets, test credentials, personal email, and
  internal RFC1918 IPs are replaced with `REDACTED_*` placeholders.
- Real, raw documents (per-program findings, evidence, bug reports, agent memory with credentials)
  live in a **private** repository. See [`PRIVATE.md`](PRIVATE.md).

---

## 📚 References

- LostSec / coffinxp methodology (Mar 2026): `CHAOS → HTTPX → NAABU → NMAP → NUCLEI → FFUF`
- ProjectDiscovery toolchain: chaos, httpx, naabu, nuclei, katana
- PortSwigger Academy + CWE/CVSS 3.1 for severity classification

---

**License**: Research/educational use. No warranty. Use responsibly and only on systems you own or
are authorized to test.
