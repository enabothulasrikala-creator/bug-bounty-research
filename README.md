# 🛡️ Bug Bounty Research Workspace — Methodology

> **A full offensive-security research workspace** built on a **community-driven bug-bounty methodology**.
> Everything here is **public, sanitized, and credential-free**. Live findings, credentials, and private
> reports live in a **separate private repository** (see [`PRIVATE.md`](PRIVATE.md)).

---

## 📖 What Is This?

This is a complete, portable **bug-bounty hunting research environment** — methodology, automation
scripts, agent definitions, and a 100+ file security skills library. It was built and used to run
authorized bug-bounty programs (HackerOne/BugBase-style) against Indian fintech and consumer brands.

It implements the exact workflow popularized in early 2026:

```
CHAOS → HTTPX → NAABU → NMAP + PARSERS → NUCLEI → FFUF
```

Plus deep WAF-bypass, secret-hunting, and vulnerability-chaining playbooks.

---

## 🗂️ Repository Layout — **Every File** (full structure)

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
│   └── TOR.md
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
│   ├── android_tv_remote.py
│   ├── c2_orchestrator.py
│   ├── chromecast_control.py
│   ├── dorking.py
│   ├── fernet_keygen.py
│   ├── forever_agent.sh
│   ├── fuzz_wordlist.txt
│   ├── naabutonmap.py
│   ├── nextjs_chunk_extractor.sh
│   ├── openrouter_voice_assistant.py
│   ├── passive_fuzzer.sh
│   ├── punycode_gen.py
│   ├── report_agent.sh
│   ├── restart_agent.sh
│   ├── reverse_shell_client.py
│   ├── reverse_shell_client.spec
│   ├── reverse_shell_client_oneshot.py
│   ├── reverse_shell_client_simple.py
│   ├── reverse_shell_server.nim
│   ├── reverse_shell_server.py
│   ├── reverse_shell_server.spec
│   ├── sast_fuzzer.py
│   ├── solarman_modbus_query.py
│   ├── specter_hub_control.sh
│   ├── specter_serial_hud.sh
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
│   └── TOR.md
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
| **hunter** | Runs the core recon pipeline, continuous probing, WAF bypass, saves findings |
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
cat methodology/WORKFLOW.md
cat methodology/TRAINING_GUIDE.md

# 3. Use the scripts (example: passive URL collection)
cat subs.txt | waybackurls | uro > urls.txt
bash scripts/passive_fuzzer.sh
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

- Community-driven methodology (Mar 2026): `CHAOS → HTTPX → NAABU → NMAP → NUCLEI → FFUF`
- ProjectDiscovery toolchain: chaos, httpx, naabu, nuclei, katana
- PortSwigger Academy + CWE/CVSS 3.1 for severity classification

---

**License**: Research/educational use. No warranty. Use responsibly and only on systems you own or
are authorized to test.
