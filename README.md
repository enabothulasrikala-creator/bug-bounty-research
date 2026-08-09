<div align="center">

```
██████╗ ██╗   ██╗ ██████╗     ██████╗  ██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
██╔══██╗██║   ██║██╔════╝     ██╔══██╗██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝╚██╗ ██╔╝
██████╔╝██║   ██║██║  ███╗    ██████╔╝██║   ██║██║   ██║██╔██╗ ██║   ██║     ╚████╔╝ 
██╔══██╗██║   ██║██║   ██║    ██╔══██╗██║   ██║██║   ██║██║╚██╗██║   ██║      ╚██╔╝  
██████╔╝╚██████╔╝╚██████╔╝    ██████╔╝╚██████╔╝╚██████╔╝██║ ╚████║   ██║       ██║   
╚═════╝  ╚═════╝  ╚═════╝     ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝       ╚═╝
```

# 🐞 BUG BOUNTY RESEARCH WORKSPACE

**OFFENSIVE SECURITY · RECON · METHODOLOGY · AUTOMATION**

<br>

<a href="#-repository-layout--every-file-full-structure"><img src="https://img.shields.io/badge/STATUS-ACTIVE-00FF41?style=for-the-badge&logo=activity&logoColor=white"></a>
<a href="#-file-by-file-guide"><img src="https://img.shields.io/badge/METHODOLOGY-25%20PLAYBOOKS-00E5FF?style=for-the-badge"></a>
<a href="#-file-by-file-guide"><img src="https://img.shields.io/badge/SKILLS-106%2B-9D00FF?style=for-the-badge"></a>
<a href="#-file-by-file-guide"><img src="https://img.shields.io/badge/SCRIPTS-18-FF6D00?style=for-the-badge"></a>
<a href="#-agent-system"><img src="https://img.shields.io/badge/AGENTS-7-FF003C?style=for-the-badge"></a>
<a href="#-privacy--sanitization"><img src="https://img.shields.io/badge/SANITIZED-TRUE-00FF41?style=for-the-badge"></a>
<a href="#-pipeline"><img src="https://img.shields.io/badge/PIPELINE-CHAOS%20%E2%86%92%20FFUF-FF003C?style=for-the-badge"></a>

<br>

```
┌────────────────────────────────────────────────────────────────────────────┐
│  A full offensive-security research workspace built on a community-driven  │
│  bug-bounty methodology. Public, sanitized, credential-free. Live findings │
│  & credentials live in a separate PRIVATE repository (see PRIVATE.md).     │
└────────────────────────────────────────────────────────────────────────────┘
```

</div>

---

## 🧭 Navigation

| # | Section | # | Section |
|---|---------|---|---------|
| 01 | [Repository Layout (every file)](#-repository-layout--every-file-full-structure) | 06 | [Agent System](#-agent-system) |
| 02 | [File-by-File Guide](#-file-by-file-guide) | 07 | [What the Research Covers](#-what-the-research-covers) |
| 03 | [Core Pipeline](#-pipeline) | 08 | [Quick Start](#-quick-start) |
| 04 | [Key Principles](#-key-principles) | 09 | [Privacy & Sanitization](#-privacy--sanitization) |
| 05 | [References](#-references) | 10 | [License](#-license) |

---

## 📊 Stats

| Metric | Count |
|--------|:-----:|
| 🗂️ Tracked files | **231** |
| 📖 Methodology playbooks | **25** |
| 🧩 Security skills | **106** |
| ⚙️ Automation scripts | **18** |
| 🤖 Agent definitions | **7** |
| 📄 Docs & references | **5** |

---

## 🔗 Pipeline

```
┌────────┐   ┌────────┐   ┌────────┐   ┌─────────────┐   ┌────────┐   ┌────────┐
│ CHAOS  │ → │ HTTPX  │ → │ NAABU  │ → │ NMAP +      │ → │ NUCLEI │ → │ FFUF   │
│ (subs) │   │ (live) │   │ (ports)│   │ PARSERS     │   │ (CVE)  │   │ (fuzz) │
└────────┘   └────────┘   └────────┘   └─────────────┘   └────────┘   └────────┘
```

<details>
<summary><b>▶ View the full one-liner pipeline</b></summary>

```bash
chaos -d target.com -o subs.txt && httpx -l subs.txt -ip -silent | sed -nE 's/.*\[([0-9.]+)\].*//p' | sort -u > ip.txt && httpx -l ip.txt -title -silent | grep -vi "cloudflare\|akamai\|fastly" | awk '{print $1}' > origin_ips.txt && naabu -l origin_ips.txt -top-ports 100 -rate 1500 -verify -silent -o naabu.txt && python3 scripts/naabutonmap.py -i naabu.txt && cat ip.txt | nuclei -tags cve -bs 200 && cat naabu.txt | nuclei -tags cve -bs 200 && ffuf -w naabu.txt:URL -w scripts/fuzz_wordlist.txt:FILE -u https://URL/FILE -mc 200 -rate 50 -fs 0
```

</details>
---

## 🗂️ Repository Layout — **Every File** (full structure)

```
├── .gitignore
├── AGENTS.md
├── PRIVATE.md
├── README.md
├── agents
│   ├── auditor.md
│   ├── debug.md
│   ├── hunter.md
│   ├── plan.md
│   ├── recon.md
│   ├── reporter.md
│   └── verifier.md
├── docs
│   ├── METHODOLOGIES.md
│   ├── METHODS.md
│   ├── TOR.md
│   ├── bugbounty_targets_osint.md
│   └── recon_exe_methodology.md
├── methodology
│   ├── ACTUATOR.md
│   ├── AUTH_SESSION.md
│   ├── BLIND_XSS.md
│   ├── CACHE_DECEPTION.md
│   ├── CHAINING_VULNS.md
│   ├── CRLF_INJECTION.md
│   ├── CT_MONITORING.md
│   ├── CWE_DATABASE.md
│   ├── GITHUB_RECON.md
│   ├── GOOGLE_API_KEYS.md
│   ├── IIS_HACKING.md
│   ├── MASS_ASSIGNMENT.md
│   ├── ORIGIN_IP.md
│   ├── PUNYCODE_ATO.md
│   ├── REACT2SHELL.md
│   ├── REGISTRATION_BUGS.md
│   ├── S3_BUCKETS.md
│   ├── SCOPE_POLICY.md
│   ├── SQLMAP_GHAURI.md
│   ├── SSRF_ADVANCED.md
│   ├── SWAGGER_UI.md
│   ├── TOOLS_REFERENCE.md
│   ├── TRAINING_GUIDE.md
│   ├── WAF_BYPASS_ADVANCED.md
│   └── WORKFLOW.md
├── scripts
│   ├── README.md
│   ├── agents_launcher.sh
│   ├── alienvault.sh
│   ├── coordinate.py
│   ├── coordination_server.py
│   ├── dorking.py
│   ├── forever_agent.sh
│   ├── fuzz_wordlist.txt
│   ├── naabutonmap.py
│   ├── nextjs_chunk_extractor.sh
│   ├── passive_fuzzer.sh
│   ├── punycode_gen.py
│   ├── report_agent.sh
│   ├── restart_agent.sh
│   ├── sast_fuzzer.py
│   ├── urlscan.py
│   ├── verify_agent.sh
│   ├── virustotal.sh
│   └── wayback.sh
└── skills
    ├── 401-403-bypass-techniques
    │   └── SKILL.md
    ├── active-directory-acl-abuse
    │   ├── BLOODHOUND_PATHS.md
    │   └── SKILL.md
    ├── active-directory-certificate-services
    │   ├── ADCS_ESC_MATRIX.md
    │   └── SKILL.md
    ├── active-directory-kerberos-attacks
    │   ├── KERBEROS_ATTACK_CHAINS.md
    │   └── SKILL.md
    ├── ai-ml-security
    │   └── SKILL.md
    ├── android-pentesting-tricks
    │   ├── FRIDA_SCRIPTS.md
    │   └── SKILL.md
    ├── anti-debugging-techniques
    │   ├── ANTI_DEBUG_MATRIX.md
    │   └── SKILL.md
    ├── api-auth-and-jwt-abuse
    │   └── SKILL.md
    ├── api-authorization-and-bola
    │   └── SKILL.md
    ├── api-recon-and-docs
    │   └── SKILL.md
    ├── api-sec
    │   └── SKILL.md
    ├── arbitrary-write-to-rce
    │   └── SKILL.md
    ├── auth-sec
    │   └── SKILL.md
    ├── authbypass-authentication-flaws
    │   └── SKILL.md
    ├── binary-protection-bypass
    │   ├── PROTECTION_BYPASS_MATRIX.md
    │   └── SKILL.md
    ├── browser-exploitation-v8
    │   ├── SKILL.md
    │   └── V8_EXPLOITATION_PATTERNS.md
    ├── bug-bounty
    │   ├── BYPASS_DATABASE.md
    │   ├── SKILL.md
    │   ├── index.json
    │   ├── skillopt_config.yaml
    │   └── versions
    │       ├── v0.md
    │       ├── v0.meta.json
    │       ├── v1.md
    │       └── v1.meta.json
    ├── business-logic-vuln
    │   └── SKILL.md
    ├── business-logic-vulnerabilities
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── classical-cipher-analysis
    │   └── SKILL.md
    ├── clickjacking
    │   └── SKILL.md
    ├── cmdi-command-injection
    │   └── SKILL.md
    ├── code-obfuscation-deobfuscation
    │   └── SKILL.md
    ├── container-escape-techniques
    │   ├── DOCKER_ESCAPE_CHAINS.md
    │   └── SKILL.md
    ├── cors-cross-origin-misconfiguration
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── crlf-injection
    │   └── SKILL.md
    ├── csp-bypass-advanced
    │   └── SKILL.md
    ├── csrf-cross-site-request-forgery
    │   └── SKILL.md
    ├── csv-formula-injection
    │   └── SKILL.md
    ├── dangling-markup-injection
    │   └── SKILL.md
    ├── defi-attack-patterns
    │   └── SKILL.md
    ├── dependency-confusion
    │   └── SKILL.md
    ├── deserialization-insecure
    │   ├── JAVA_GADGET_CHAINS.md
    │   └── SKILL.md
    ├── dns-rebinding-attacks
    │   └── SKILL.md
    ├── dns-recon
    │   └── SKILL.md
    ├── email-header-injection
    │   └── SKILL.md
    ├── expression-language-injection
    │   └── SKILL.md
    ├── file-access-vuln
    │   └── SKILL.md
    ├── format-string-exploitation
    │   └── SKILL.md
    ├── graphql-and-hidden-parameters
    │   └── SKILL.md
    ├── hack
    │   └── SKILL.md
    ├── hash-attack-techniques
    │   └── SKILL.md
    ├── heap-exploitation
    │   ├── HOUSE_OF_TECHNIQUES.md
    │   ├── IO_FILE_EXPLOITATION.md
    │   └── SKILL.md
    ├── http-host-header-attacks
    │   └── SKILL.md
    ├── http-parameter-pollution
    │   └── SKILL.md
    ├── http2-specific-attacks
    │   └── SKILL.md
    ├── idor-broken-object-authorization
    │   └── SKILL.md
    ├── injection-checking
    │   ├── EXTRA_INJECTION_TYPES.md
    │   └── SKILL.md
    ├── insecure-source-code-management
    │   └── SKILL.md
    ├── ios-pentesting-tricks
    │   ├── IOS_RUNTIME_TRICKS.md
    │   └── SKILL.md
    ├── jndi-injection
    │   └── SKILL.md
    ├── js-analysis
    │   └── SKILL.md
    ├── jwt-oauth-token-attacks
    │   └── SKILL.md
    ├── kernel-exploitation
    │   ├── KERNEL_HEAP_TECHNIQUES.md
    │   ├── KERNEL_MITIGATION_BYPASS.md
    │   └── SKILL.md
    ├── kubernetes-pentesting
    │   └── SKILL.md
    ├── lattice-crypto-attacks
    │   └── SKILL.md
    ├── linux-lateral-movement
    │   └── SKILL.md
    ├── linux-privilege-escalation
    │   ├── KERNEL_EXPLOITS_CHECKLIST.md
    │   ├── SKILL.md
    │   └── SUID_CAPABILITIES_TRICKS.md
    ├── linux-security-bypass
    │   └── SKILL.md
    ├── llm-prompt-injection
    │   ├── JAILBREAK_PATTERNS.md
    │   └── SKILL.md
    ├── macos-process-injection
    │   ├── DYLIB_XPC_TECHNIQUES.md
    │   └── SKILL.md
    ├── macos-security-bypass
    │   ├── SKILL.md
    │   └── TCC_BYPASS_MATRIX.md
    ├── memory-forensics-volatility
    │   ├── SKILL.md
    │   └── VOLATILITY_CHEATSHEET.md
    ├── mobile-ssl-pinning-bypass
    │   └── SKILL.md
    ├── network-protocol-attacks
    │   ├── NAME_RESOLUTION_POISONING.md
    │   └── SKILL.md
    ├── nosql-injection
    │   └── SKILL.md
    ├── ntlm-relay-coercion
    │   ├── COERCION_METHODS.md
    │   └── SKILL.md
    ├── oauth-oidc-misconfiguration
    │   └── SKILL.md
    ├── open-redirect
    │   └── SKILL.md
    ├── path-traversal-lfi
    │   └── SKILL.md
    ├── prototype-pollution
    │   └── SKILL.md
    ├── prototype-pollution-advanced
    │   ├── KNOWN_GADGETS.md
    │   └── SKILL.md
    ├── race-condition
    │   └── SKILL.md
    ├── recon-and-methodology
    │   └── SKILL.md
    ├── recon-for-sec
    │   └── SKILL.md
    ├── request-smuggling
    │   ├── H2_SMUGGLING_VARIANTS.md
    │   └── SKILL.md
    ├── reverse-shell-techniques
    │   ├── SHELL_CHEATSHEET.md
    │   └── SKILL.md
    ├── rsa-attack-techniques
    │   ├── RSA_ATTACK_CATALOG.md
    │   └── SKILL.md
    ├── saml-sso-assertion-attacks
    │   └── SKILL.md
    ├── sandbox-escape-techniques
    │   ├── PYTHON_SANDBOX_ESCAPE.md
    │   ├── SECCOMP_BYPASS.md
    │   └── SKILL.md
    ├── scope-guard
    │   ├── SCOPE_ACTIVE.md
    │   ├── SKILL.md
    │   └── scope_init.sh
    ├── skillopt
    │   ├── README.md
    │   ├── SKILL.md
    │   ├── opencode_hook.py
    │   ├── seed_bug_bounty.md
    │   ├── skillopt_cli.py
    │   ├── skillopt_config.yaml
    │   └── skillopt_optimizer.py
    ├── smart-contract-vulnerabilities
    │   ├── SKILL.md
    │   └── SOLIDITY_VULN_PATTERNS.md
    ├── sqli-sql-injection
    │   ├── SCENARIOS.md
    │   ├── SKILL.md
    │   └── SQLMAP_ADVANCED.md
    ├── ssrf-server-side-request-forgery
    │   ├── SCENARIOS.md
    │   ├── SKILL.md
    │   └── URL_PARSER_TRICKS.md
    ├── ssti-server-side-template-injection
    │   ├── ENGINE_PAYLOADS.md
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── stack-overflow-and-rop
    │   ├── ROP_ADVANCED_TECHNIQUES.md
    │   └── SKILL.md
    ├── steganography-techniques
    │   ├── SKILL.md
    │   └── STEGO_TOOLS_GUIDE.md
    ├── subdomain-takeover
    │   └── SKILL.md
    ├── symbolic-execution-tools
    │   ├── ANGR_COOKBOOK.md
    │   └── SKILL.md
    ├── symmetric-cipher-attacks
    │   ├── BLOCK_CIPHER_ATTACKS.md
    │   └── SKILL.md
    ├── traffic-analysis-pcap
    │   └── SKILL.md
    ├── tunneling-and-pivoting
    │   └── SKILL.md
    ├── type-juggling
    │   └── SKILL.md
    ├── unauthorized-access-common-services
    │   ├── PORT_SERVICE_MATRIX.md
    │   └── SKILL.md
    ├── upload-insecure-files
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    ├── vm-and-bytecode-reverse
    │   └── SKILL.md
    ├── waf-bypass-techniques
    │   ├── SKILL.md
    │   └── WAF_PRODUCT_MATRIX.md
    ├── web-cache-deception
    │   ├── CACHE_POISONING_TECHNIQUES.md
    │   └── SKILL.md
    ├── websocket-security
    │   └── SKILL.md
    ├── windows-av-evasion
    │   ├── AMSI_BYPASS_TECHNIQUES.md
    │   └── SKILL.md
    ├── windows-lateral-movement
    │   ├── CREDENTIAL_DUMPING.md
    │   └── SKILL.md
    ├── windows-privilege-escalation
    │   ├── SKILL.md
    │   ├── TOKEN_POTATO_TRICKS.md
    │   └── UAC_BYPASS_METHODS.md
    ├── xslt-injection
    │   └── SKILL.md
    ├── xss-cross-site-scripting
    │   ├── ADVANCED_XSS_TRICKS.md
    │   ├── SCENARIOS.md
    │   └── SKILL.md
    └── xxe-xml-external-entity
        ├── SCENARIOS.md
        └── SKILL.md
```


## 📂 File-by-File Guide

Every file in this repository, explained by directory. Skills appear once per directory (playbook + companion files).

### Root
| File | Purpose |
|------|----------|
| `.gitignore` | Ignores junk: build artifacts, secrets, heavy scan artifacts (.apk/.pcap/.pdf), logs. |
| `AGENTS.md` | Master workspace bible: full agent system, methodology library, OPSEC/anonymity stack, project notes. |
| `PRIVATE.md` | Documents exactly what is hidden from this public repo and where it lives (private repo). |
| `README.md` | This file — overview, file tree, and file-by-file guide. |

### agents/ — opencode agent definitions
| File | Purpose |
|------|----------|
| `auditor.md` | Auditor agent: static code analysis, dependency CVE audit, vuln-pattern matching. |
| `debug.md` | Debug agent: mistake logging, frustration handling, cross-agent learning. |
| `hunter.md` | Hunter agent: core LostSec-style pipeline (recon → WAF bypass → exploitation → findings). |
| `plan.md` | Plan agent: OSINT research + attack-surface analysis → step-by-step attack plan. |
| `recon.md` | Recon subagent: fast subdomain enum, DNS leak checks, tech fingerprinting. |
| `reporter.md` | Reporter agent: BugBase-format report generation from verified findings. |
| `verifier.md` | Verifier agent: zero-false-positive re-checking (baseline diff, 3-request rule, CVSS 3.1). |

### docs/ — methodology & reference
| File | Purpose |
|------|----------|
| `METHODOLOGIES.md` | Complete recon methodologies reference (compiled for revision + AI handoff). |
| `METHODS.md` | Community complete methodology & tool reference (5-min workflow, recon phases, tooling). |
| `TOR.md` | Tor anonymity stack: setup, verification, kill-switch, target list handling. |
| `bugbounty_targets_osint.md` | Top public bug-bounty programs (scope, bounties, policy) + OSINT leaked-data sources. |
| `recon_exe_methodology.md` | Recon.exe methodology: 403/404 handling, GoSpider, JS hunting, stored XSS, admin panels, S3. |

### methodology/ — technique playbooks
| File | Purpose |
|------|----------|
| `ACTUATOR.md` | Spring Boot actuator discovery + exploitation (heapdump/env/jolokia, access bypass). |
| `AUTH_SESSION.md` | Auth & session testing checklist (JWT misconfig, token reuse, session fixation). |
| `BLIND_XSS.md` | Blind XSS + pastejacking: injection vectors, tooling, WAF bypass, reporting. |
| `CACHE_DECEPTION.md` | Web cache deception/poisoning: delimiter tricks, mass hunting. |
| `CHAINING_VULNS.md` | Vulnerability chaining patterns (SSRF→RCE, auth bypass→IDOR→exfil, etc.). |
| `CRLF_INJECTION.md` | CRLF injection: payloads, discovery, impact scenarios. |
| `CT_MONITORING.md` | Real-time certificate-transparency log monitoring for new subdomains. |
| `CWE_DATABASE.md` | CWE/CVSS 3.1 reference + WAF-bypass techniques summary. |
| `GITHUB_RECON.md` | GitHub dorking, .git exposure detection + git-dumper exploitation. |
| `GOOGLE_API_KEYS.md` | Google API key hunting + validation (Gemini, GCP, referer bypass). |
| `IIS_HACKING.md` | Microsoft IIS: shortname (tilde) enum, precision fuzzing, high-value endpoints. |
| `MASS_ASSIGNMENT.md` | Mass-assignment payload catalog (admin flags, prototype pollution, verification bypass). |
| `ORIGIN_IP.md` | Origin-IP discovery behind WAF: 11+ methods (Shodan, historical DNS, SPF, email headers). |
| `PUNYCODE_ATO.md` | Punycode/IDN homograph attacks: 0-click account takeover via email lookalikes. |
| `REACT2SHELL.md` | CVE-2025-55182 React2Shell: unauthenticated RCE in React Server Components. |
| `REGISTRATION_BUGS.md` | 22-item registration vulnerability checklist. |
| `S3_BUCKETS.md` | S3 bucket recon: discovery, permission testing, exploitation. |
| `SCOPE_POLICY.md` | Program scope & policy rules, famous-program reference, scope checks. |
| `SQLMAP_GHAURI.md` | SQLmap + Ghauri WAF-bypass runs (tampers, junk data, origin-IP bypass). |
| `SSRF_ADVANCED.md` | Advanced SSRF: detection, escalation ladder, cloud metadata, protocol bypass. |
| `SWAGGER_UI.md` | Swagger UI XSS + HTML injection (configUrl abuse, fake login). |
| `TOOLS_REFERENCE.md` | Tool installation + usage reference (recon, fuzzing, WAF bypass, JS analysis). |
| `TRAINING_GUIDE.md` | 2026 training battle plan: phased workflow, quick-win checklist, XSS/SQLi deep testing. |
| `WAF_BYPASS_ADVANCED.md` | Extended WAF bypass: vendor-specific evasions, decision tree, automated tools. |
| `WORKFLOW.md` | Core pipeline: chaos → httpx → naabu → nmap → nuclei → ffuf (one-liners). |

### scripts/ — automation tooling
| File | Purpose |
|------|----------|
| `README.md` | See scripts/README.md for scripts/README.md |
| `agents_launcher.sh` | See scripts/README.md for scripts/agents_launcher.sh |
| `alienvault.sh` | See scripts/README.md for scripts/alienvault.sh |
| `coordinate.py` | See scripts/README.md for scripts/coordinate.py |
| `coordination_server.py` | See scripts/README.md for scripts/coordination_server.py |
| `dorking.py` | See scripts/README.md for scripts/dorking.py |
| `forever_agent.sh` | See scripts/README.md for scripts/forever_agent.sh |
| `fuzz_wordlist.txt` | See scripts/README.md for scripts/fuzz_wordlist.txt |
| `naabutonmap.py` | See scripts/README.md for scripts/naabutonmap.py |
| `nextjs_chunk_extractor.sh` | See scripts/README.md for scripts/nextjs_chunk_extractor.sh |
| `passive_fuzzer.sh` | See scripts/README.md for scripts/passive_fuzzer.sh |
| `punycode_gen.py` | See scripts/README.md for scripts/punycode_gen.py |
| `report_agent.sh` | See scripts/README.md for scripts/report_agent.sh |
| `restart_agent.sh` | See scripts/README.md for scripts/restart_agent.sh |
| `sast_fuzzer.py` | See scripts/README.md for scripts/sast_fuzzer.py |
| `urlscan.py` | See scripts/README.md for scripts/urlscan.py |
| `verify_agent.sh` | See scripts/README.md for scripts/verify_agent.sh |
| `virustotal.sh` | See scripts/README.md for scripts/virustotal.sh |
| `wayback.sh` | See scripts/README.md for scripts/wayback.sh |

### skills/ — security skills library
Each skill is a playbook (`SKILL.md`) plus optional companion reference files. Skills are grouped by attack category.

| File | Purpose |
|------|----------|
| `401-403-bypass-techniques/` | 401/403 access-denied bypass playbook (path, method, headers, protocol). |
| `active-directory-acl-abuse/` | AD ACL abuse: GenericAll, WriteDACL, DCSync, GPO abuse, BloodHound paths. — `BLOODHOUND_PATHS.md`: BloodHound-guided attack paths |
| `active-directory-certificate-services/` | AD CS attacks: ESC1–ESC13 template abuse, NTLM relay to enrollment. — `ADCS_ESC_MATRIX.md`: ESC1–13 template abuse matrix |
| `active-directory-kerberos-attacks/` | Kerberos attacks: AS-REP roast, Kerberoast, golden/silver tickets, delegation. — `KERBEROS_ATTACK_CHAINS.md`: Kerberos attack chain reference |
| `ai-ml-security/` | AI/ML security: supply chain, model poisoning/stealing, privacy attacks. |
| `android-pentesting-tricks/` | Android pentesting: SSL pinning, exported components, WebView, tapjacking. — `FRIDA_SCRIPTS.md`: Ready-to-use Frida scripts |
| `anti-debugging-techniques/` | Anti-debugging detection + bypass (ptrace, PEB flags, timing). — `ANTI_DEBUG_MATRIX.md`: Anti-debug detection vs bypass matrix |
| `api-auth-and-jwt-abuse/` | API auth & JWT abuse: tokens, claims trust, header spoofing, rate limits. |
| `api-authorization-and-bola/` | API authorization + BOLA: object IDs, nested resources, weak function auth. |
| `api-recon-and-docs/` | API recon: endpoints, OpenAPI specs, hidden docs, surface mapping. |
| `api-sec/` | API-security entry router: pick recon / auth / token / hidden-param workflow. |
| `arbitrary-write-to-rce/` | Arbitrary-write → RCE: GOT/hooks/io_file/vtable/modprobe_path targets. |
| `auth-sec/` | Auth entry router: login, sessions, JWT/OAuth, CORS, CSRF, SSO. |
| `authbypass-authentication-flaws/` | Auth bypass: login flows, password reset, MFA bypass, token predictability. |
| `binary-protection-bypass/` | Binary protection bypass: ASLR, NX, canary, RELRO, FORTIFY, CET. — `PROTECTION_BYPASS_MATRIX.md`: Binary protection vs bypass matrix |
| `browser-exploitation-v8/` | Browser/V8 exploitation: JIT type confusion, sandbox escape. — `V8_EXPLOITATION_PATTERNS.md`: V8 JIT/bounds-elimination exploit patterns |
| `bug-bounty/` | Security skill — `BYPASS_DATABASE.md`: Huge WAF-bypass / payload database · `index.json`: Skill version index · `skillopt_config.yaml`: SkillOpt config · `v0.md`: Bug-bounty skill v0 snapshot · `v1.md`: Bug-bounty skill v1 snapshot |
| `business-logic-vuln/` | Business-logic entry router: workflow/state/race/price testing. |
| `business-logic-vulnerabilities/` | Business logic vulns: workflows, race conditions, price/coupon abuse. — `SCENARIOS.md`: Scenario walkthroughs |
| `classical-cipher-analysis/` | Classical cipher cryptanalysis (frequency, Kasiski, XOR). |
| `clickjacking/` | Clickjacking: frameability, X-Frame-Options/CSP frame-ancestors, UI redress. |
| `cmdi-command-injection/` | Command injection: shell sinks, blind/OOB, converters/imports. |
| `code-obfuscation-deobfuscation/` | Obfuscation analysis: junk code, opaque predicates, control-flow flattening. |
| `container-escape-techniques/` | Container escape: privileged, docker socket, cgroup, namespace tricks. — `DOCKER_ESCAPE_CHAINS.md`: Container escape chain reference |
| `cors-cross-origin-misconfiguration/` | CORS misconfig: origin reflection, credentialed reads, preflight bugs. — `SCENARIOS.md`: Scenario walkthroughs |
| `crlf-injection/` | CRLF injection: response splitting, header injection, log injection. |
| `csp-bypass-advanced/` | Advanced CSP bypass: trusted endpoints, nonce leak, exfil channels. |
| `csrf-cross-site-request-forgery/` | CSRF: state-changing flows, SameSite, JSON CSRF, OAuth state. |
| `csv-formula-injection/` | CSV/spreadsheet formula injection (DDE, IMPORT*). |
| `dangling-markup-injection/` | Dangling markup: exfiltrate tokens/data when JS execution is blocked. |
| `defi-attack-patterns/` | DeFi attacks: flash loans, oracle manipulation, MEV, bridges. |
| `dependency-confusion/` | Dependency confusion: supply-chain via public-registry name squatting. |
| `deserialization-insecure/` | Insecure deserialization: Java/PHP/Python gadgets → RCE. — `JAVA_GADGET_CHAINS.md`: Java deserialization gadget chains |
| `dns-rebinding-attacks/` | DNS rebinding: origin-check bypass for internal services. |
| `dns-recon/` | DNS recon: subdomain enum, DNS leaks, infrastructure mapping. |
| `email-header-injection/` | Email header injection/spoofing: CRLF in SMTP fields, SPF/DKIM/DMARC. |
| `expression-language-injection/` | EL injection: SpEL/OGNL/MVEL in Spring, Struts2, Confluence. |
| `file-access-vuln/` | File-access entry router: download paths, LFI, uploads, archives. |
| `format-string-exploitation/` | Format string: stack reads, %n writes, GOT overwrite. |
| `graphql-and-hidden-parameters/` | GraphQL: introspection, batching, hidden params, schema abuse. |
| `hack/` | HackSkills entry router: pick the right category before deep testing. |
| `hash-attack-techniques/` | Hash attacks: length extension, collisions, magic hashes. |
| `heap-exploitation/` | Heap exploitation: tcache/fastbin/unsortedbin, UAF, double-free. — `HOUSE_OF_TECHNIQUES.md`: glibc house-of-* technique catalog · `IO_FILE_EXPLOITATION.md`: _IO_FILE vtable exploitation |
| `http-host-header-attacks/` | Host header attacks: password-reset poisoning, cache poisoning, routing. |
| `http-parameter-pollution/` | HTTP parameter pollution: duplicate-key parsing divergence. |
| `http2-specific-attacks/` | HTTP/2 attacks: h2c smuggling, pseudo-header injection, HPACK. |
| `idor-broken-object-authorization/` | IDOR/BOA: object identifiers, tenant boundaries, missing object auth. |
| `injection-checking/` | Injection entry router: XSS/SQLi/SSRF/XXE/SSTI/CMDi/NoSQL routing. — `EXTRA_INJECTION_TYPES.md`: Additional injection type catalog |
| `insecure-source-code-management/` | Source-control exposure: .git/.svn, backups, .env leaks. |
| `ios-pentesting-tricks/` | iOS pentesting: keychain, URL schemes, Universal Links, runtime manipulation. — `IOS_RUNTIME_TRICKS.md`: iOS runtime manipulation tricks |
| `jndi-injection/` | JNDI injection (Log4Shell family): attacker-controlled lookups. |
| `js-analysis/` | JS bundle analysis: API endpoints, secrets, routing. |
| `jwt-oauth-token-attacks/` | JWT/OAuth token attacks: alg confusion, weak keys, claim abuse. |
| `kernel-exploitation/` | Linux kernel exploitation: UAF/OOB/race → LPE (commit_creds, modprobe_path). — `KERNEL_HEAP_TECHNIQUES.md`: Kernel heap exploitation techniques · `KERNEL_MITIGATION_BYPASS.md`: Kernel mitigation bypass catalog |
| `kubernetes-pentesting/` | K8s pentesting: API server, RBAC, service accounts, kubelet, etcd. |
| `lattice-crypto-attacks/` | Lattice cryptanalysis: Coppersmith, nonce bias, LLL. |
| `linux-lateral-movement/` | Linux lateral movement: SSH hijack, credential reuse, pivoting. |
| `linux-privilege-escalation/` | Linux privesc: SUID, capabilities, cron, kernel exploits, misconfigs. — `KERNEL_EXPLOITS_CHECKLIST.md`: Kernel exploit checklist · `SUID_CAPABILITIES_TRICKS.md`: SUID/capabilities abuse tricks |
| `linux-security-bypass/` | Linux security bypass: rbash, noexec, AppArmor/SELinux/seccomp evasion. |
| `llm-prompt-injection/` | LLM prompt injection: direct/indirect, RAG, tool abuse, MCP. — `JAILBREAK_PATTERNS.md`: LLM jailbreak patterns |
| `macos-process-injection/` | macOS process injection: dylib hijack, DYLD, XPC, Mach ports. — `DYLIB_XPC_TECHNIQUES.md`: dylib hijack + XPC exploitation |
| `macos-security-bypass/` | macOS security bypass: TCC, Gatekeeper, SIP, sandbox, entitlements. — `TCC_BYPASS_MATRIX.md`: macOS TCC bypass matrix |
| `memory-forensics-volatility/` | Memory forensics: Volatility 2/3 analysis, credential extraction. — `VOLATILITY_CHEATSHEET.md`: Volatility command cheatsheet |
| `mobile-ssl-pinning-bypass/` | Mobile SSL-pinning bypass (Android/iOS, React Native/Flutter). |
| `network-protocol-attacks/` | Layer 2/3 attacks: ARP, LLMNR/NBT-NS, DHCPv6, VLAN hop, DNS spoof. — `NAME_RESOLUTION_POISONING.md`: Name-resolution poisoning techniques |
| `nosql-injection/` | NoSQL injection: MongoDB operators, JSON query abuse. |
| `ntlm-relay-coercion/` | NTLM relay + coercion: SMB/LDAP relay, PetitPotam, PrinterBug. — `COERCION_METHODS.md`: NTLM coercion method catalog |
| `oauth-oidc-misconfiguration/` | OAuth/OIDC misconfig: redirect URI, state/nonce, PKCE, audience. |
| `open-redirect/` | Open redirect: params, sinks, mass hunting. |
| `path-traversal-lfi/` | Path traversal/LFI: traversal depth, wrappers, filter bypass. |
| `prototype-pollution/` | Prototype pollution: merge sinks, browser/Node gadgets. |
| `prototype-pollution-advanced/` | Advanced prototype pollution: server-side RCE, gadget chains. — `KNOWN_GADGETS.md`: Prototype-pollution gadget catalog |
| `race-condition/` | Race conditions/TOCTOU: one-time ops, concurrent HTTP abuse, gates. |
| `recon-and-methodology/` | Recon & methodology: asset mapping, endpoint discovery, tech fingerprint. |
| `recon-for-sec/` | Recon entry router: scope mapping, assets, fingerprinting, endpoint inventory. |
| `request-smuggling/` | Request smuggling: CL.TE/TE.CL, H2 downgrade, client-side desync. — `H2_SMUGGLING_VARIANTS.md`: HTTP/2 request-smuggling variants |
| `reverse-shell-techniques/` | Reverse shells: one-liners, encrypted shells, web shells, PTY upgrades. — `SHELL_CHEATSHEET.md`: Reverse-shell one-liner cheatsheet |
| `rsa-attack-techniques/` | RSA attacks: weak keys, small exponents, shared factors, padding oracle. — `RSA_ATTACK_CATALOG.md`: RSA attack catalog |
| `saml-sso-assertion-attacks/` | SAML SSO: signature validation, assertion wrapping, audience. |
| `sandbox-escape-techniques/` | Sandbox escape: Python/Lua/seccomp/chroot/container/browser. — `PYTHON_SANDBOX_ESCAPE.md`: Python sandbox escape techniques · `SECCOMP_BYPASS.md`: Seccomp filter bypass techniques |
| `scope-guard/` | Scope enforcement layer: blocks out-of-scope testing (SCOPE_ACTIVE.md generator). — `scope_init.sh`: Generates SCOPE_ACTIVE.md + enforces scope |
| `skillopt/` | SkillOpt: trajectory collection + automated skill optimization tooling. — `README.md`: Usage notes · `opencode_hook.py`: Trajectory-capture hook for SkillOpt · `seed_bug_bounty.md`: Seed prompt for the bug-bounty skill · `skillopt_cli.py`: SkillOpt CLI · `skillopt_config.yaml`: SkillOpt config · `skillopt_optimizer.py`: SkillOpt optimizer engine |
| `smart-contract-vulnerabilities/` | Smart contracts: reentrancy, overflow, access control, delegatecall. — `SOLIDITY_VULN_PATTERNS.md`: Solidity vulnerability patterns |
| `sqli-sql-injection/` | SQL injection: error/union/blind/boolean, DB-specific, OOB. — `SCENARIOS.md`: Scenario walkthroughs · `SQLMAP_ADVANCED.md`: Advanced SQLmap usage |
| `ssrf-server-side-request-forgery/` | SSRF: URL fetch abuse, internal scanning, cloud metadata. — `SCENARIOS.md`: Scenario walkthroughs · `URL_PARSER_TRICKS.md`: URL parser confusion tricks |
| `ssti-server-side-template-injection/` | SSTI: template-engine detection + RCE payloads. — `ENGINE_PAYLOADS.md`: Per-engine SSTI payloads · `SCENARIOS.md`: Scenario walkthroughs |
| `stack-overflow-and-rop/` | Stack overflow + ROP: ret2libc, ret2csu, SROP. — `ROP_ADVANCED_TECHNIQUES.md`: Advanced ROP techniques |
| `steganography-techniques/` | Steganography: LSB, PNG/JPEG, audio, EXIF, polyglots. — `STEGO_TOOLS_GUIDE.md`: Stego tooling guide |
| `subdomain-takeover/` | Subdomain takeover: dangling CNAME/NS, fingerprint + claim. |
| `symbolic-execution-tools/` | Symbolic execution: angr/Z3 for CTF + key recovery. — `ANGR_COOKBOOK.md`: angr cookbook recipes |
| `symmetric-cipher-attacks/` | Symmetric crypto attacks: CBC padding oracle, ECB cut-paste, IV reuse. — `BLOCK_CIPHER_ATTACKS.md`: Block-cipher attack catalog |
| `traffic-analysis-pcap/` | Traffic/PCAP analysis: Wireshark, protocol extraction, TLS decrypt. |
| `tunneling-and-pivoting/` | Tunneling/pivoting: SSH, Chisel, Ligolo-ng, DNS/ICMP tunnels. |
| `type-juggling/` | PHP type juggling: loose `==` comparison bypass (magic hashes). |
| `unauthorized-access-common-services/` | Exposed services: Redis, Rsync, PHP-FPM, AJP/Ghostcat, YARN, H2. — `PORT_SERVICE_MATRIX.md`: Port/service default-cred matrix |
| `upload-insecure-files/` | Insecure file upload: validation bypass, storage, upload→RCE chains. — `SCENARIOS.md`: Scenario walkthroughs |
| `vm-and-bytecode-reverse/` | Custom VM/bytecode reversing: dispatcher loops, mazes. |
| `waf-bypass-techniques/` | Generic WAF bypass: encoding, protocol tricks, vendor weaknesses. — `WAF_PRODUCT_MATRIX.md`: WAF vendor weakness matrix |
| `web-cache-deception/` | Web cache deception/poisoning: cache-key manipulation. — `CACHE_POISONING_TECHNIQUES.md`: Cache-poisoning technique catalog |
| `websocket-security/` | WebSocket security: handshake, CSWSH, message injection. |
| `windows-av-evasion/` | Windows AV/EDR evasion: AMSI, ETW, shellcode, process injection. — `AMSI_BYPASS_TECHNIQUES.md`: AMSI bypass catalog |
| `windows-lateral-movement/` | Windows lateral movement: PsExec, WMI, WinRM, DCOM, pass-the-hash. — `CREDENTIAL_DUMPING.md`: Windows credential-dumping methods |
| `windows-privilege-escalation/` | Windows privesc: tokens, Potato, services, DLL hijack, UAC bypass. — `TOKEN_POTATO_TRICKS.md`: Potato family token attacks · `UAC_BYPASS_METHODS.md`: UAC bypass methods |
| `xslt-injection/` | XSLT injection: XXE, EXSLT write, PHP/Java/.NET RCE surfaces. |
| `xss-cross-site-scripting/` | XSS: reflected/stored/DOM, contexts, WAF bypass, mXSS. — `ADVANCED_XSS_TRICKS.md`: Advanced XSS tricks (mXSS, DOM clobbering) · `SCENARIOS.md`: Scenario walkthroughs |
| `xxe-xml-external-entity/` | XXE: external entities, file read, SSRF, blind/OOB. — `SCENARIOS.md`: Scenario walkthroughs |

---

## 🔑 Key Principles

| # | Principle |
|---|-----------|
| 🟢 | **CDN/WAF filtering is MANDATORY** — only scan origin IPs (skip Cloudflare/Akamai/Fastly). |
| 🟠 | **Non-standard ports matter** — feed `naabu.txt` into nuclei + ffuf, not just 80/443. |
| 🔴 | **403 is gold** — always try bypass techniques (headers, path manipulation, case, double-encoding). |
| 🟡 | **Response-size analysis** — a `200 OK` can be a custom error page; compare size/word counts. |
| 🔵 | **IP dedup** — many subdomains resolve to the same backend; `sort -u` first. |

---

## 🤖 Agent System

The workspace is designed as a **multi-agent pipeline** (opencode agents):

| Agent | Role | Priority |
|-------|------|:-------:|
| 🏹 **hunter** | Runs the core recon pipeline, continuous probing, WAF bypass, saves findings | P0 |
| ✅ **verifier** | Re-checks every finding (3-request rule, baseline diff, CVSS 3.1, false-positive signatures) | P0 |
| 📝 **reporter** | Produces BugBase-format reports (≤120-char title, single URL, live curl PoCs) | P0 |
| 🧠 **plan** | OSINT + attack-surface research → step-by-step plan | P1 |
| 🔎 **recon** | Fast subdomain enumeration + attack-surface discovery | P1 |
| 🐛 **debug** | Self-improvement, mistake logging, cross-agent learning | P1 |
| 🛡️ **auditor** | Static code + dependency vulnerability audit | P1 |

---

## 🎯 What the Research Covers

| Category | Coverage |
|----------|----------|
| 🔭 **Reconnaissance** | Passive subdomain enum (Chaos, subfinder, assetfinder, crt.sh, CT logs), live-host probing (httpx), port scanning (naabu/nmap), JS bundle analysis, source-map mining |
| 💉 **Vulnerability classes** | SQLi, XSS, SSRF, SSTI, LFI, IDOR, CORS, CSRF, open redirect, actuator exposure, cache deception, blind XSS, subdomain takeover, mass assignment, auth/session bugs |
| 🛡️ **WAF bypass** | 15+ techniques (encoding chains, comment injection, HPP, chunked encoding, body padding, protocol downgrade, request smuggling, origin-IP discovery) |
| ☁️ **Cloud** | S3 bucket recon/exploitation, GCP/AWS metadata SSRF, Google API key hunting + validation |
| 🧮 **Business logic** | Race conditions, price manipulation, OTP brute-force, punycode 0-click ATO |
| ⛓️ **Chaining** | SSRF→internal API→RCE, auth bypass→IDOR→data exfiltration, etc. |

---

## 🚀 Quick Start

<kbd>1</kbd> Clone the repo

```bash
git clone https://github.com/enabothulasrikala-creator/bug-bounty-research.git
cd bug-bounty-research
```

<kbd>2</kbd> Read the methodology

```bash
cat methodology/WORKFLOW.md
cat methodology/TRAINING_GUIDE.md
```

<kbd>3</kbd> Use the scripts (example: passive URL collection)

```bash
cat subs.txt | waybackurls | uro > urls.txt
bash scripts/passive_fuzzer.sh
```

> ⚠️ **Ethics**: This methodology is for **authorized** testing only. Every real program tested here was
> in-scope with permission (BugBase / HackerOne style programs). Unauthorized use against any system is
> illegal. All live credentials, test accounts, internal IPs, and unreported findings are **NOT** in this
> repo — they are kept in a private repository.

---

## 🔒 Privacy & Sanitization

- 🔴 This public repo was **auto-redacted**: live API keys (Google, Razorpay, Stripe, AWS, SendGrid,
  OpenRouter), session tokens, JWTs, private keys, TOTP secrets, test credentials, personal email, and
  internal RFC1918 IPs are replaced with `REDACTED_*` placeholders.
- 🔵 Real, raw documents (per-program findings, evidence, bug reports, agent memory with credentials)
  live in a **private** repository. See [`PRIVATE.md`](PRIVATE.md).

---

## 📚 References

| Source | Purpose |
|--------|---------|
| Community methodology (Mar 2026) | `CHAOS → HTTPX → NAABU → NMAP → NUCLEI → FFUF` core pipeline |
| ProjectDiscovery toolchain | chaos, httpx, naabu, nuclei, katana |
| PortSwigger Academy + CWE/CVSS 3.1 | Severity classification |

---

## 🏷️ License

> **Research / educational use. No warranty.**
> Use responsibly and only on systems you own or are authorized to test.

---

<p align="center">
<sub><b>HUNT · DISCOVER · EXPLOIT · REPORT</b> — built with 💚 for the bug-bounty community</sub>
</p>
