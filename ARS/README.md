# Academic Research Skills (ARS) + Nexus AI Integration

[![License: CC BY-NC 4.0](https://img.shields.io/badge/license-CC%20BY--NC%204.0-lightgrey)](https://creativecommons.org/licenses/by-nc/4.0/)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.1.314%2B-blue)](https://docs.claude.com/en/docs/claude-code/setup)
[![Nexus AI Gateway](https://img.shields.io/badge/Gateway-Nexus%20LiteLLM-purple)](https://nexusapi.navigatelabs.ai)
[![Architecture](https://img.shields.io/badge/Architecture-Flattened%20Clean%20Root-green)](docs/ARCHITECTURE.md)

A production-ready, contract-audited suite of **Academic Research Skills (ARS)** running on **Claude Code CLI** and routed through the **Nexus AI LiteLLM Gateway**. Designed for researchers and developers to execute rigorous, multi-stage academic research workflows—from scoping and deep literature search to systematic screening, draft formulation, peer review, and revision coaching.

---

## Table of Contents

- [1. Project Overview](#1-project-overview)
- [2. Key Features & Five Core ARS Skills](#2-key-features--five-core-ars-skills)
- [3. Architecture Overview](#3-architecture-overview)
- [4. Prerequisites](#4-prerequisites)
- [5. Repository Cloning](#5-repository-cloning)
- [6. Environment Configuration](#6-environment-configuration)
- [7. Nexus AI API Gateway Configuration](#7-nexus-ai-api-gateway-configuration)
- [8. Claude Code CLI Setup](#8-claude-code-cli-setup)
- [9. Model Configuration](#9-model-configuration)
- [10. Plugin & Skill Installation](#10-plugin--skill-installation)
- [11. Available ARS Slash Commands](#11-available-ars-slash-commands)
- [12. How to Launch the Project](#12-how-to-launch-the-project)
- [13. Verification & Validation](#13-verification--validation)
- [14. Troubleshooting](#14-troubleshooting)
- [15. Security & Credential Hygiene](#15-security--credential-hygiene)

---

## 1. Project Overview

The Academic Research Skills suite bridges the gap between AI capabilities and academic publishing rigor. Instead of unverified autonomous text generation, ARS enforces a **human-in-the-loop, contract-audited** methodology. At each stage, the system conducts rigorous verification, enforces citation provenance, flags hallucination risks, and requires author confirmation before proceeding.

### Core Principles
- **Author in the Pilot Seat:** AI handles literature discovery, formatting, citation verification, and adversarial review; scientific reasoning and interpretive decisions remain strictly with the human author.
- **Anti-Fabrication & L3 Verification:** Enforces three-layer citation anchors to prevent citation hallucinations and ungrounded claims.
- **Contract-Audited Handoffs:** Structured JSON and YAML manifests pass evidence between specialized agents across all 10 stages of the pipeline.

---

## 2. Key Features & Five Core ARS Skills

ARS organizes academic workflows into five specialized, discoverable skills:

| Skill Name | Directory | Primary Role |
| :--- | :--- | :--- |
| **`deep-research`** | `deep-research/` | Multi-source academic literature search (arXiv, Semantic Scholar, OpenAlex, Crossref), citation graphing, and synthesis mapping. |
| **`academic-paper`** | `academic-paper/` | Structured IMRaD outline generation, Socratic research question scoping, drafting, and APA/discipline formatting. |
| **`academic-paper-reviewer`** | `academic-paper-reviewer/` | Simulated 5-seat peer review panel (Editor-in-Chief, Methodology Reviewer, Domain Expert, Perspective Reviewer, and Devil's Advocate). |
| **`academic-pipeline`** | `academic-pipeline/` | 10-stage end-to-end pipeline orchestration, state management, and artifact pass-through checkpoints. |
| **`sr-screener`** | `sr-screener/` | Dual-blind systematic review screening protocol with PRISMA-compliant adjudication and decision logging. |

---

## 3. Architecture Overview

```
<your-cloned-ARS-directory>/
├── .claude/                                             # Local Claude Code runtime configuration
│   ├── commands/                                        # 16 Slash command definitions (/ars-plan, etc.)
│   ├── skills/                                          # Active skill registrations for Claude Code
│   ├── settings.json                                    # Gateway & model environment configuration
│   └── CLAUDE.md                                        # Project memory & context-optimized instructions
├── .claude-plugin/                                      # Plugin manifests (plugin.json, marketplace.json)
├── academic-paper/                                      # Canonical skill definitions
├── academic-paper-reviewer/
├── academic-pipeline/
├── deep-research/
├── sr-screener/
├── commands/                                            # Canonical prompt templates
├── scripts/                                             # Launchers, diagnostics, and verification scripts
│   ├── launch_nexus_claude.ps1                          # Pre-flight environment loader & Claude Code runner
│   └── verify_skills_installation.ps1                   # Local skill registration verification test
├── shared/                                              # Schemas, contracts, and verification protocols
├── docs/                                                # Architecture, specifications, and risk registers
├── pi/                                                  # Pi package wrapper and compatibility harness
├── start-nexus-claude.ps1                               # Direct root launcher shortcut
├── .env.example                                         # Safe environment template (no credentials)
└── package.json / pyproject.toml                        # Distribution packaging manifests
```

---

## 4. Prerequisites

1. **Operating System:** Windows 10/11 x64, macOS, or Linux (PowerShell 7+ or Windows PowerShell 5.1).
2. **Git:** v2.30+ with Windows Long Paths enabled (`git config --global core.longpaths true`).
3. **Node.js:** v20+ or v22+ (for running Pi wrapper tests and npm package scripts).
4. **Python:** Python 3.11+ (standard library for verification scripts; optional dev tools in `requirements-dev.txt`).
5. **Claude Code CLI:** v2.1.314 or later installed (`npm install -g @anthropic-ai/claude-code`).
6. **Nexus AI Gateway Access:** An active LiteLLM virtual key (`sk-...`) from your Nexus AI Model Hub account.

---

## 5. Repository Cloning

Clone the repository into a clean local directory:

```powershell
# Ensure Git long paths are enabled before cloning
git config --global core.longpaths true

# Clone into your preferred local directory
# (On Windows, a short path such as C:\Projects\ARS is strongly recommended to prevent MAX_PATH issues)
git clone -c core.longpaths=true https://github.com/reethu10-git/academic-research-skills-nexus-integration.git C:\Projects\ARS

# Navigate into your cloned project directory
Set-Location <your-cloned-ARS-directory>
# Example:
# Set-Location C:\Projects\ARS
```

> **Note for Windows Users:** Keeping the project directory path short (such as `C:\Projects\ARS`) ensures compatibility with legacy Windows tools that do not support paths longer than 260 characters.

---

## 6. Environment Configuration

The repository includes a safe, credentials-free `.env.example` template at the root.

1. **Create your local `.env` file:**
   ```powershell
   Copy-Item .env.example .env
   ```

2. **Open `.env` and add your Nexus API Key:**
   ```env
   # Base URL for Nexus AI Gateway
   ANTHROPIC_BASE_URL=https://nexusapi.navigatelabs.ai

   # Your Nexus Model Hub virtual key (starts with sk-)
   ANTHROPIC_AUTH_TOKEN=sk-your_actual_nexus_virtual_key_here

   # Active model identifier configured on your gateway (Claude Haiku 4.5 recommended)
   ANTHROPIC_MODEL=claude-haiku-4-5
   # Pinned version identifier: claude-haiku-4-5-20251001

   # Output token ceiling for Claude Code
   CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
   ```

> **Security Note:** `.env` and `.claude/.env` are automatically excluded by `.gitignore`. Never commit your real API key to Git.

---

## 7. Nexus AI API Gateway Configuration

ARS routes model completions through the **Nexus AI LiteLLM Gateway** via the Anthropic Messages API protocol (`/v1/messages`).

- **Gateway Endpoint:** `https://nexusapi.navigatelabs.ai`
- **Authentication:** Virtual Bearer token supplied in the `ANTHROPIC_AUTH_TOKEN` environment variable.
- **Diagnostic Tool:** To test your connection to the gateway before launching the full suite, run:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\test_nexus_integration.ps1
  ```

---

## 8. Claude Code CLI Setup

Verify that Claude Code is installed and reachable:

```powershell
claude --version
```

If not installed, install it globally:
```powershell
npm install -g @anthropic-ai/claude-code
```

The launcher script `start-nexus-claude.ps1` injects `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, and `ANTHROPIC_MODEL` directly into the process environment when launching Claude Code.

---

## 9. Model Configuration

The suite supports model routing through Nexus AI:
- **Recommended Model:** Claude Haiku 4.5
  - Model Name: Claude Haiku 4.5
  - Canonical Alias: `claude-haiku-4-5`
  - Pinned Model Identifier: `claude-haiku-4-5-20251001`
- **Fallback / Alternative Models:** `claude-3-5-haiku-20241022` or custom aliases configured via `ANTHROPIC_MODEL` in `.env` or `.claude/settings.json`.
- **Gateway Compatibility Notice:** The live Nexus AI Gateway endpoint routes requests according to your upstream LiteLLM configuration and key permissions. If your key returns `HTTP 401: Key is blocked`, live completion requests remain pending until an administrator unblocks the virtual key or assigns the appropriate model route.

In `.claude/settings.json`:
```json
{
  "model": "claude-haiku-4-5",
  "effortLevel": "low",
  "env": {
    "ANTHROPIC_BASE_URL": "https://nexusapi.navigatelabs.ai",
    "ANTHROPIC_MODEL": "claude-haiku-4-5",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "4096"
  }
}
```

---

## 10. Plugin & Skill Installation

ARS is configured out-of-the-box with native local skill registrations in `.claude/skills/`.

To verify that all five skills are registered and valid:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify_skills_installation.ps1
```

**Expected Output:**
```text
==========================================================
TASK 5: ARS SKILL REGISTRATION LOCAL VERIFICATION
==========================================================

SkillName               InstalledItems HasSkillMd FrontmatterValid Status  
---------               -------------- ---------- ---------------- ------  
deep-research                       57       True             True VERIFIED
academic-paper                      67       True             True VERIFIED
academic-paper-reviewer             32       True             True VERIFIED
academic-pipeline                   35       True             True VERIFIED
sr-screener                         31       True             True VERIFIED

CLAUDE.md length check:
 Characters: 12818 (Limit: 40,000 chars)
 Status    : PASSED (Below limit)
```

---

## 11. Available ARS Slash Commands

All 16 slash commands are located in `.claude/commands/` and are immediately available in Claude Code sessions:

| Slash Command | Description |
| :--- | :--- |
| `/ars-plan` | Socratic planning mentor for paper topic, methodology, and scope. |
| `/ars-outline` | Formulate a complete 5-section IMRaD outline with word allocation. |
| `/ars-lit-review` | Systematic search, categorization, and synthesis of relevant literature. |
| `/ars-full` | Orchestrate the complete end-to-end 10-stage research pipeline. |
| `/ars-reviewer` | Run the 5-seat peer review panel against a draft or abstract. |
| `/ars-revision` | Structure reviewer comments and generate an actionable revision roadmap. |
| `/ars-revision-coach` | Interactive coaching through difficult revisions and reviewer rebuttals. |
| `/ars-rebuttal-audit` | Verify point-by-point rebuttal consistency against the revised draft. |
| `/ars-citation-check` | Audit citations for provenance, DOI accuracy, and L3 claim support. |
| `/ars-abstract` | Compile a concise, structured bilingual (English/Chinese) abstract. |
| `/ars-format-convert` | Convert drafts between Markdown, LaTeX, and Word/DOCX templates. |
| `/ars-disclosure` | Generate standard AI assistance and methodology disclosure statements. |
| `/ars-mark-read` | Mark a cited paper as read and update the reading history ledger. |
| `/ars-unmark-read` | Unmark a paper in the reading history ledger. |
| `/ars-cache-invalidate`| Invalidate cached literature search queries and verification data. |
| `/ars-3w` | Perform rapid "What, Why, Who cares?" framing analysis. |

---

## 12. How to Launch the Project

Launch Claude Code configured with Nexus AI credentials using the root launcher:

```powershell
.\start-nexus-claude.ps1
```

The launcher will:
1. Load environment variables from `.env`.
2. Verify that your Nexus virtual key starts with `sk-`.
3. Set `ANTHROPIC_BASE_URL` to `https://nexusapi.navigatelabs.ai`.
4. Launch `claude.exe` in the project root.

---

## 13. Verification & Validation

Run the automated test suites to ensure everything is functioning correctly:

1. **Skill Registration Verification:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\verify_skills_installation.ps1
   ```

2. **Pi Wrapper Test Suite:**
   ```powershell
   node .\pi\wrapper.test.mjs
   ```

3. **Git Repository Integrity Check:**
   ```powershell
   git fsck --full
   ```

---

## 14. Troubleshooting

### Issue: `Authentication Error, Key is blocked` (HTTP 401)
- **Cause:** Your Nexus AI LiteLLM virtual key has exceeded its assigned budget, hit a rate limit, or been blocked by the gateway administrator.
- **Resolution:** Log in to your Nexus AI Model Hub account, check your key's status, unblock it via `/key/unblock` (or request an administrator to unblock it), or generate a new virtual key and paste it into `.env`.

### Issue: `fatal: Filename too long` or Checkout Failure
- **Cause:** Windows traditional 260-character path limit (`MAX_PATH`).
- **Resolution:** Ensure Git long paths are enabled:
  ```powershell
  git config --global core.longpaths true
  ```
  And clone the project into a short directory path (such as `C:\Projects\ARS`).

### Issue: `No skills found` in Claude Code
- **Cause:** Missing local skill registrations in `.claude/skills/`.
- **Resolution:** Run `powershell -ExecutionPolicy Bypass -File .\scripts\verify_skills_installation.ps1` to verify skill registrations. Ensure `.claude/skills/` contains the five subfolders with valid `SKILL.md` files.

---

## 15. Security & Credential Hygiene

- **Protected Credential Files:** Never commit `.env` or `.claude/.env` to Git. Both are strictly excluded in `.gitignore`.
- **Public Sharing:** Always distribute `.env.example` with placeholders, never real API keys.
- **Secret Scanning:** All commits and tracked files in this repository have been audited to ensure zero exposed credentials, access tokens, or machine-specific absolute paths.
