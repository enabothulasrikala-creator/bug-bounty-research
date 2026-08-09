# scripts/ — Automation Tooling

All helper scripts used across the bug-bounty workflow. Run with `bash <script>` (shell) or `python3 <script>` (python).

| Script | Purpose |
|--------|---------|
| `agents_launcher.sh` | Launches the multi-agent opencode session (hunter/verifier/reporter/plan/debug/auditor). |
| `alienvault.sh` | Pulls URLs for a domain from AlienVault OTX (passive recon). |
| `coordinate.py` | Coordination client — shares findings between laptop + PC instances of the research setup. |
| `coordination_server.py` | Backend server that lets two opencode instances share targets/findings and avoid duplicate work. |
| `dorking.py` | Google dork automation for recon (file types, exposed panels, subdomains). |
| `forever_agent.sh` | Watchdog loop that keeps the local agent process alive and restarts it if it dies. |
| `fuzz_wordlist.txt` | Fuzzing wordlist (hidden files, .git paths, backup names, common dirs) for ffuf/dirb-style attacks. |
| `naabutonmap.py` | Converts naabu port-scan output into an nmap command/scan run. |
| `nextjs_chunk_extractor.sh` | Downloads and mines a Next.js webpack manifest for all JS chunk files (endpoint + secret hunting). |
| `passive_fuzzer.sh` | LostFuzzer pipeline: gau → uro → httpx → nuclei (passive URL fuzzing + DAST). |
| `punycode_gen.py` | Generates punycode/IDN homograph payloads (email lookalike attacks). |
| `report_agent.sh` | BugBase-format report generator from verified findings. |
| `restart_agent.sh` | Cron watchdog that restarts the discovery agent and ensures output dirs exist. |
| `sast_fuzzer.py` | Fuzzes security tool CLIs (naabu, nuclei, ffuf, httpx, gau, waybackurls, subfinder) with malformed flags/buffers/null bytes. |
| `urlscan.py` | URLScan.io API client — fetches scan results/URLs for a domain. |
| `verify_agent.sh` | Verification workflow — re-checks a finding (baseline diff, 3-request rule) before reporting. |
| `virustotal.sh` | VirusTotal API scanner (multi-key rotation). |
| `wayback.sh` | Wayback Machine URL fetcher for a domain. |

> ⚠️ **Disclaimer**: For authorized testing only. Use responsibly and legally.
