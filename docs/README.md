# Recon Reports

```
recon_reports/
├── README.md                 ← You are here
├── CONSOLIDATED_FINDINGS.md  ← Only reportable findings (Neon CSP)
├── SCOPE_REFERENCE.md        ← Verified scope for all 6 programs
├── METHODOLOGIES.md          ← Techniques reference (544 lines)
│
├── targets/                  ← Organized by target program
│   ├── neon/                 ★ ACTIVE TARGET — CSP finding reportable
│   ├── nba/                  ✗ OOS (webmail not in 206 assets)
│   ├── twitter/              △ Wildcard scope, no finding yet
│   ├── meesho/               ✗ All findings OOS
│   ├── shopify/              ✗ GCS buckets OOS
│   ├── namecheap/            ? Unverified scope
│   ├── razorpay/             ? Unverified scope
│   ├── razer/                ✗ Program closed
│   └── ionity/               ✗ No bounty program
│
└── archive/                  ← Old reports, guides, non-bounty stuff
```

### Status
- **Reportable:** 1 (Neon CSP on console-stage.neon.build)
- **Out of scope:** 11 findings across 6 programs
- **Uncertain:** 2 (Namecheap, Razorpay)

### Quick start
```bash
# Active target - Neon staging
cat targets/neon/api_findings.md

# Scope reference
cat SCOPE_REFERENCE.md

# Only reportable findings
cat CONSOLIDATED_FINDINGS.md
```
