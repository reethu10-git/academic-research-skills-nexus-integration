# Academic Research Skills (ARS)

## Implementation Guide: Claude Code CLI + Nexus AI

## Project overview

The **Academic Research Skills (ARS)** project is an AI-assisted framework designed for academic research activities, spanning research planning, literature exploration, systematic screening, paper drafting, and peer review.

The repository provides five core skill areas:

| Skill | Canonical Directory | Purpose |
| :--- | :--- | :--- |
| **Deep Research** (`deep-research`) | `deep-research/` | Multi-source academic literature search (arXiv, Semantic Scholar, OpenAlex, Crossref), citation graphing, synthesis mapping, and Socratic research question scoping. |
| **Systematic Review Screening** (`sr-screener`) | `sr-screener/` | Protocol-driven dual-blind study screening against defined eligibility criteria with PRISMA 2020 adjudication and decision logging. |
| **Academic Paper** (`academic-paper`) | `academic-paper/` | Structured 5-section IMRaD outline formulation, chapter planning, section drafting, and APA/discipline-specific formatting. |
| **Academic Paper Reviewer** (`academic-paper-reviewer`) | `academic-paper-reviewer/` | Simulated 5-seat peer review panel (Journal-Fit Reviewer, Methodology Reviewer, Domain Expert, Perspective Reviewer, and Devil's Advocate). |
| **Academic Pipeline** (`academic-pipeline`) | `academic-pipeline/` | End-to-end 10-stage research-to-publication orchestrator coordinating handoffs, integrity checks, and human approval checkpoints. |

The framework also includes 4 specialized agent personas, 16 project-level slash commands, templates, references, and diagnostic scripts. It assists research work but does not replace the researcher's scholarly judgement. Always verify sources, claims, methodology, and generated content before using or submitting any output.

* **Target Operating System:** Windows 10/11 x64 (PowerShell and Visual Studio Code)
* **Required Client:** Claude Code CLI (`v2.1.314` or later)
* **Nexus Gateway Endpoint:** `https://nexusapi.navigatelabs.ai`
* **Configured Model:** `nova-micro` (Amazon Nova Micro routed through Nexus AI)
* **Maximum Output Tokens:** `4096`
* **Primary Launch Command:** `powershell -ExecutionPolicy Bypass -File .\scripts\launch_nexus_claude.ps1`
* **Official Repository:** `https://github.com/reethu10-git/academic-research-skills-nexus-integration`

> **Important:** Use only the Nexus AI API virtual key (`sk-...`) provided through your institutional platform. Keep your credentials private and never commit your `.env` file to GitHub.

---

## Implementation overview

Complete the setup in the following sequence:

1. **Step 1:** Download and clone the ARS repository, then open it in Visual Studio Code.
2. **Step 2:** Install and verify Claude Code CLI globally on Windows.
3. **Step 3:** Configure your Nexus AI credentials in `.env` and verify `.gitignore` protection.
4. **Step 4:** Launch Claude Code via the recommended PowerShell launcher and install the ARS plugin.
5. **Step 5:** Verify the live Nexus AI Gateway connection with a test prompt.
6. **Step 6:** Verify that all five ARS skills are registered and discovered.
7. **Step 7:** Understand the 10-stage academic research pipeline and human approval gates.
8. **Step 8:** Execute your first guided research workflows (planning, outline, literature review, review, pipeline).
9. **Step 9:** Explore the 16 available ARS slash commands.
10. **Step 10:** Understand repository architecture, supporting scripts, and dependencies.
11. **Step 11:** Run the testing and validation suites.
12. **Step 12:** Review troubleshooting solutions for common errors.
13. **Step 13:** Follow academic integrity, security, and responsible AI practices.
14. **Step 14:** Complete implementation verification and collect handover evidence.

---

## Requirements

Before starting, ensure you have:

* A computer running Windows 10 or Windows 11 (64-bit).
* An active internet connection.
* **Git for Windows** (v2.30+ with long paths enabled).
* **Visual Studio Code** installed.
* **Claude Code CLI** (`v2.1.314` or later).
* Access to your institution's Nexus AI Gateway (`https://nexusapi.navigatelabs.ai`).
* An authorised Nexus virtual API key (must begin with `sk-`).
* Permission to access the configured model (`nova-micro`) on the gateway.
* The ARS repository URL: `https://github.com/reethu10-git/academic-research-skills-nexus-integration`

> **Note on Python Dependencies:** The core research skills and workflows are prompt-driven within Claude Code CLI and do not require Python for regular use. Python 3.11+ is optional and only required if running local diagnostic scripts or developer regression suites (`requirements-dev.txt`). There is no `requirements.txt` file in this repository.

---

## How the integration works

The ARS repository packages skill definitions, agent instructions, slash commands, schemas, and supporting scripts. Claude Code CLI loads these resources and provides the terminal interface for running research workflows.

The supplied launcher script reads the Nexus configuration from the project `.env` file and starts Claude Code with the required environment variables:

| Component | Responsibility in ARS Integration |
| :--- | :--- |
| **ARS Repository** | Provides domain-specific research skills, prompt templates, agent personas, and pipeline orchestration. |
| **Claude Code CLI** | Executes as the local runtime client, managing tool calling, prompt delivery, and conversational context. |
| **Nexus AI Gateway** | Acts as the LiteLLM proxy (`https://nexusapi.navigatelabs.ai`), authenticating requests and routing them to the authorized model. |

The integration routes traffic through the Anthropic-compatible Messages API protocol (`/v1/messages`). The key environment variables configured by the launcher are:
* `ANTHROPIC_BASE_URL=https://nexusapi.navigatelabs.ai`
* `ANTHROPIC_MODEL=nova-micro`
* `ANTHROPIC_AUTH_TOKEN=sk-...`
* `CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096`

Do not replace this configuration with an OpenAI Chat Completions (`/chat/completions`) endpoint.

**End-to-End Workflow Flow:**  
`GitHub Repository → VS Code → PowerShell Launcher → Claude Code CLI → Nexus Gateway → Authorized Model → ARS Skills & Agents → Reviewed Research Artifacts`

> **Model & Key Status Notice:** The repository is configured by default for `nova-micro`. Live inference requires an active Nexus virtual key. If your gateway returns `HTTP 401: Key is blocked`, your configuration is technically intact, but an administrator must unblock your key or assign model quota before completions can stream.

---

## Step 1: Download the ARS project

### 1.1 Get the repository URL

Verify the official repository URL:
`https://github.com/reethu10-git/academic-research-skills-nexus-integration`

If Git is not yet installed on your system, download Git for Windows from:  
https://git-scm.com/download/win  
Install with standard defaults, ensuring **Git from the command line and also from 3rd-party software** is selected.

### 1.2 Clone the repository

* **Where:** Windows PowerShell (launched as Administrator or standard user).
* **Action:** Enable Git long path support and clone into a short directory path (such as `C:\Projects\ARS`) to prevent Windows `MAX_PATH` (260-character) filename errors.
* **Commands:**

```powershell
# Enable long paths globally in Git
git config --global core.longpaths true

# Clone the ARS repository into a clean local directory
git clone -c core.longpaths=true https://github.com/reethu10-git/academic-research-skills-nexus-integration.git C:\Projects\ARS

# Navigate into the project root
Set-Location C:\Projects\ARS
```

Verify that you are in the project root:

```powershell
Get-Location
Get-ChildItem
```

* **Expected Result:** The directory listing displays the project structure:
  ```text
  Mode      Name
  ----      ----
  d-----    .claude
  d-----    .claude-plugin
  d-----    academic-paper
  d-----    academic-paper-reviewer
  d-----    academic-pipeline
  d-----    deep-research
  d-----    sr-screener
  d-----    commands
  d-----    docs
  d-----    scripts
  -a----    .env.example
  -a----    .gitignore
  -a----    README.md
  -a----    QUICKSTART.md
  -a----    start-nexus-claude.ps1
  ```
* **If it fails:** If Git fails with `Filename too long`, confirm that `core.longpaths true` was applied, or see [Troubleshooting Problem 1](#problem-1-git-is-not-recognised-or-cloning-fails).

### 1.3 Open the project in Visual Studio Code

* **Where:** Windows PowerShell.
* **Action:** Launch VS Code targeting the ARS project root.
* **Command:**

```powershell
code .
```

Alternatively, open VS Code manually, click **File → Open Folder...**, and select `C:\Projects\ARS`.

* **Expected Result:** The complete ARS project tree appears in the VS Code Explorer sidebar.

### 1.4 Open the integrated terminal

* **Where:** Inside Visual Studio Code.
* **Action:** Open an integrated terminal by selecting **Terminal → New Terminal** (or pressing `` Ctrl+` ``).
* **Command:** Confirm that the terminal shell is PowerShell and points to the project root:

```powershell
Get-Location
```

* **Expected Result:** The path ends with `C:\Projects\ARS` (or your chosen project folder).

---

## Step 2: Install Claude Code CLI

Claude Code CLI is the terminal client for running Anthropic-compatible agentic workflows. Installing Git or VS Code does not install Claude Code.

### 2.1 Install Claude Code on Windows

* **Where:** VS Code Integrated Terminal (PowerShell).
* **Action:** Run the official Anthropic PowerShell installer script:
* **Command:**

```powershell
irm https://claude.ai/install.ps1 | iex
```

*(Alternative via npm if Node.js is installed: `npm install -g @anthropic-ai/claude-code`)*

Wait for installation to finish. If prompted, restart the terminal session.

### 2.2 Verify the installation

* **Where:** VS Code Integrated Terminal (PowerShell).
* **Action:** Check that the CLI executable is on your PATH.
* **Command:**

```powershell
claude --version
```

* **Expected Result:** Claude Code outputs its version string:
  ```text
  claude-code/2.1.314 (or later) win32-x64 node-v...
  ```
* **If it fails:** If PowerShell returns `The term 'claude' is not recognized`, close and reopen VS Code. If the issue persists, see [Troubleshooting Problem 2](#problem-2-claude-is-not-recognised).

---

## Step 3: Configure Nexus AI access

The repository includes pre-configured settings in `.claude/settings.json` and a pre-flight launcher script. You must configure your authorised Nexus virtual key in a local `.env` file.

### 3.1 Inspect the Claude Code settings

* **Where:** VS Code File Explorer.
* **Action:** Open `.claude/settings.json` and inspect the configuration:

```json
{
  "model": "nova-micro",
  "effortLevel": "low",
  "env": {
    "ANTHROPIC_BASE_URL": "https://nexusapi.navigatelabs.ai",
    "ANTHROPIC_MODEL": "nova-micro",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "4096"
  }
}
```

| Setting | Purpose |
| :--- | :--- |
| `model` | Active model identifier passed to Claude Code. |
| `effortLevel` | Set to `"low"` to avoid unsupported thinking-budget parameters on the gateway. |
| `ANTHROPIC_BASE_URL` | Routes API traffic to the Nexus AI LiteLLM Gateway. |
| `ANTHROPIC_MODEL` | Authorised model route on the Nexus Gateway (`nova-micro`). |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Token generation ceiling (`4096`). |

### 3.2 Create the local `.env` file

* **Where:** VS Code Integrated Terminal (PowerShell at ARS project root).
* **Action:** Copy `.env.example` to `.env` and insert your personal Nexus API key.
* **Commands:**

```powershell
# Copy the template to .env
Copy-Item .env.example .env

# Open .env for editing
notepad .env
```

Ensure the configuration contains:

```dotenv
ANTHROPIC_BASE_URL=https://nexusapi.navigatelabs.ai
ANTHROPIC_AUTH_TOKEN=sk-your_actual_nexus_virtual_key_here
ANTHROPIC_MODEL=nova-micro
CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
```

Replace `sk-your_actual_nexus_virtual_key_here` with your real virtual key obtained from the Nexus AI Model Hub. Save and close the file.

> **Security Rules:**
> 1. The variable name must be exactly `ANTHROPIC_AUTH_TOKEN` (the launcher also supports `NEXUS_API_KEY` as fallback).
> 2. The key must begin with `sk-`.
> 3. Do not place spaces around the `=` sign.
> 4. Never commit `.env` to version control.

### 3.3 Confirm that credentials are protected

* **Where:** VS Code Integrated Terminal (PowerShell).
* **Action:** Check that `.gitignore` prevents `.env` from being tracked by Git.
* **Command:**

```powershell
git check-ignore .env
```

* **Expected Result:**
  ```text
  .env
  ```
* **If it fails:** If no output is returned, do not commit files. Verify that `.gitignore` contains `.env` and `.env.*`.

### 3.4 Understand the pre-flight launcher script

The project includes `scripts/launch_nexus_claude.ps1`. Before launching, understand the 8 operational steps it executes:

1. **Resolves the Project Root:** Detects the script directory and sets the execution context to the ARS project root.
2. **Loads `.env`:** Parses key-value pairs from `.env` using regular expressions and sets them in process memory.
3. **Applies Gateway Defaults:** Sets `ANTHROPIC_BASE_URL` (`https://nexusapi.navigatelabs.ai`), `ANTHROPIC_MODEL` (`nova-micro`), and `CLAUDE_CODE_MAX_OUTPUT_TOKENS` (`4096`) if omitted.
4. **Verifies API Key:** Reads `ANTHROPIC_AUTH_TOKEN` (or `NEXUS_API_KEY`). If absent, securely prompts for the key with hidden typing via `Read-Host -AsSecureString`.
5. **Enforces Key Format:** Validates that the key starts with `sk-` (required for LiteLLM virtual keys).
6. **Locates Claude Code CLI:** Checks PATH for `claude` and falls back to `%USERPROFILE%\.local\bin\claude.exe`.
7. **Displays Diagnostic Banner:** Prints an informative status banner showing the endpoint, model, token ceiling, and project root without exposing your secret token.
8. **Launches Claude Code:** Starts `claude.exe` with forwarded arguments and appends `--effort low` if not explicitly provided.

Verify that the launcher exists:

```powershell
Test-Path ".\scripts\launch_nexus_claude.ps1"
```

* **Expected Result:** `True`

---

## Step 4: Launch Claude Code and install the ARS plugin

### 4.1 Launch methods: Launcher versus direct `claude`

It is essential to understand the difference between the two ways to start Claude Code:

#### Option 1 – Recommended: Launch through the supplied PowerShell script

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\launch_nexus_claude.ps1
```

* **Why this is recommended for students:**
  * It automatically loads the `.env` credentials into process memory.
  * It injects the Nexus gateway URL (`https://nexusapi.navigatelabs.ai`).
  * It sets the authorized model name and output token limit.
  * It applies the `--effort low` parameter required by the gateway.
  * Using `-ExecutionPolicy Bypass` prevents Windows PowerShell from blocking the script due to execution policy restrictions.

* **Shorter alternative (if already in an unrestricted PowerShell session):**
  If you have already run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` in your active terminal, you can run:
  ```powershell
  .\scripts\launch_nexus_claude.ps1
  ```
  *(Or use the root shortcut: `.\start-nexus-claude.ps1`)*

#### Option 2 – Direct launch (`claude`)

```powershell
claude
```

> **Critical Warning for Students:** You can **only** use `claude` directly if all four Nexus environment variables (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_MODEL`, and `CLAUDE_CODE_MAX_OUTPUT_TOKENS`) have **already** been configured in the current terminal session. If you type `claude` in a fresh terminal without running the launcher or manually exporting these variables, Claude Code will attempt to contact standard Anthropic endpoints and prompt for an Anthropic web login, completely bypassing Nexus!

### 4.2 Launch Claude Code through Nexus

* **Where:** VS Code Integrated Terminal (PowerShell at ARS project root).
* **Action:** Run the recommended launch command.
* **Command:**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\launch_nexus_claude.ps1
```

* **Expected Result:** The terminal outputs the diagnostic banner and opens the interactive Claude Code prompt (`>`):

```text
==========================================================
 Claude Code + Nexus LLMLite (Academic Research Skills)
 Endpoint : https://nexusapi.navigatelabs.ai
 Model    : nova-micro
 Max Output: 4096 tokens
 Auth     : ANTHROPIC_AUTH_TOKEN (loaded from .env/memory)
 Root     : C:\Projects\ARS
==========================================================

>
```

* **If it fails:** If PowerShell blocks the script with a `PSSecurityException`, see [Troubleshooting Problem 3](#problem-3-powershell-blocks-the-launcher).

### 4.3 Verify the ARS plugin and skills

The ARS repository comes **pre-configured with all 5 research skills and 16 slash commands** bundled locally in `.claude/skills/` and `.claude/commands/`. When Claude Code launches from the project root, it automatically loads these local capabilities.

* **Local Verification (Automatic):**
  Upon launch via `launch_nexus_claude.ps1`, your interactive session already has access to all `/ars-*` commands.

* **Optional Marketplace Registration (if instructed by your course):**
  If your instructor specifically requires installing from the external marketplace, run inside the **Claude Code prompt (`>`)**:
  ```text
  /plugin marketplace add Imbad0202/academic-research-skills
  /plugin install academic-research-skills
  /exit
  ```
  Then relaunch with `launch_nexus_claude.ps1`. Otherwise, the local bundled skills are immediately ready for use.

---

## Step 5: Verify the Nexus connection

* **Where:** Inside the **Claude Code prompt (`>`)**.
* **Action:** Send a lightweight verification prompt to test live model inference through the Nexus Gateway.
* **Command:**

```text
Respond with exactly: NEXUS_INTEGRATION_OK
```

* **Expected Result:**
  ```text
  NEXUS_INTEGRATION_OK
  ```

* **Interpreting the Test:**
  * Receiving `NEXUS_INTEGRATION_OK` confirms that the entire communication chain (Client → Process Environment → Nexus Gateway → Upstream Model → Response Stream) is operational.
  * If the response displays `HTTP 401: Key is blocked` or `Authentication Error`, see [Troubleshooting Problem 5](#problem-5-http-401-http-403-or-model-unavailable). Your setup is complete, but the key requires administrator unblocking.

---

## Step 6: Verify the ARS skills

ARS provides five core skills registered under `.claude/skills/`:

```text
.claude/skills/
├── deep-research/              # Literature search, synthesis & scoping
├── academic-paper/             # IMRaD outline, planning & drafting
├── academic-paper-reviewer/    # 5-seat peer review simulation
├── academic-pipeline/          # 10-stage pipeline orchestration
└── sr-screener/                # Dual-blind systematic review screening
```

Each folder contains an authoritative `SKILL.md` instruction file.

### 6.1 Automated local skill verification

* **Where:** Windows PowerShell (in a second terminal tab or before opening Claude Code).
* **Action:** Run the automated skill registration diagnostic script.
* **Command:**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify_skills_installation.ps1
```

* **Expected Result:**

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

### 6.2 Conversational skill discovery check

* **Where:** Inside the **Claude Code prompt (`>`)**.
* **Action:** Ask Claude Code to discover and summarize the five registered skills.
* **Command:**

```text
Explain the Academic Research Skills project. Identify the five main skills and describe the purpose of each. Use the project files as the source of truth.
```

* **Expected Result:** Claude Code reads the registered skills and provides accurate descriptions of `deep-research`, `academic-paper`, `academic-paper-reviewer`, `academic-pipeline`, and `sr-screener`.
* **If it fails:** See [Troubleshooting Problem 6](#problem-6-no-skills-found).

---

## Step 7: Understand the ARS workflow

The ARS framework structures research into a contract-audited, 10-stage pipeline. The system enforces an **"Author in the Pilot Seat"** principle: AI agents conduct literature mapping, screening, formatting, and adversarial critique, but interpretive and scientific decisions remain strictly with the human researcher.

### The 10-Stage Pipeline Overview

```
[Stage 1: Scoping & Plan]
         │
[Stage 2: Literature Search] ──► [Stage 2.5: Anti-Fabrication L3 Check]
                                            │
                                 [Stage 3: IMRaD Outline]
                                            │
                                 [Stage 4: Section Drafting]
                                            │
                                 [Stage 5: Style & Diagnostics]
                                            │
                                 [Stage 6: 5-Seat Peer Review]
                                            │
                                 [Stage 7: Revision Roadmap]
                                            │
                                 [Stage 8: Rebuttal Audit]
                                            │
                                 [Stage 9: Citation Provenance]
                                            │
                                 [Stage 10: Publication Packaging]
```

| Stage | Name | Key Activity | Gate / Checkpoint |
| :---: | :--- | :--- | :--- |
| **1** | Research Planning | Socratic dialogue to establish problem statement, research questions, and methodology. | Author confirms research plan. |
| **2** | Literature Search | Multi-index search and cross-source evidence triangulation. | Search strategy reviewed. |
| **2.5** | Integrity Check | Anti-fabrication check to eliminate hallucinated claims and ungrounded citations. | Zero-fabrication threshold passed. |
| **3** | Paper Architecture | 5-section IMRaD outline formulation with target word counts. | Section allocation approved. |
| **4** | Draft Formulation | Section-by-section drafting guided by verified evidence manifests. | Author reviews initial drafts. |
| **5** | Internal Consistency | Writing quality diagnostics, throat-clearing removal, and style calibration. | Formatting checked. |
| **6** | Peer Review | Simulated 5-seat review panel evaluates manuscript quality. | Review comments compiled. |
| **7** | Revision Coaching | Synthesizes reviewer comments into a prioritized revision roadmap. | Author selects revision scope. |
| **8** | Rebuttal Audit | Verifies point-by-point consistency between rebuttal statements and revised text. | Rebuttal claims audited. |
| **9** | Citation Audit | Validates DOIs, publication years, and claim-level evidence anchors. | All citations verified. |
| **10** | Final Packaging | Compiles publication artifacts, bilingual abstracts, and AI disclosures. | Final manuscript signed off. |

---

## Step 8: Run your first ARS workflows

Use the following benchmark topic to test the skills:

> **Benchmark Topic:** *The impact of AI-assisted formative feedback tools on student self-regulation and engagement in undergraduate computing education.*

> **Important Reminder:** All `/ars-*` commands must be typed into the **Claude Code prompt (`>`)**, NOT the Windows PowerShell terminal.

### 8.1 Research planning (`/ars-plan`)

* **Where:** Claude Code prompt (`>`).
* **Action:** Initiate Socratic planning to formulate research questions and methodology.
* **Command:**

```text
/ars-plan
```

*(Conversational alternative if command is not used: "Help me plan an academic research paper on the impact of AI-assisted formative feedback tools on student self-regulation in undergraduate computing. Guide me through Socratic questioning to refine my research questions and methodology. Do not invent citations.")*

* **Expected Result:** Claude Code enters Socratic mentoring mode, asking 3–5 targeted questions about your target population, theoretical framework, study design, and measurement instruments.

### 8.2 Generate a paper outline (`/ars-outline`)

* **Where:** Claude Code prompt (`>`).
* **Action:** Generate a complete 5-section IMRaD outline with word allocation.
* **Command:**

```text
/ars-outline
```

* **Expected Result:** Generates a structured outline (Introduction, Literature Review / Background, Methodology, Results, Discussion) with section goals, required evidence types, and target word counts.
* **Performance Note:** Generating an outline engages multi-agent reasoning. In headless non-interactive tests (`claude -p`), this can exceed 180 seconds. In interactive mode, progress streams continuously.

### 8.3 Explore literature (`/ars-lit-review`)

* **Where:** Claude Code prompt (`>`).
* **Action:** Search and synthesize literature themes.
* **Command:**

```text
/ars-lit-review
```

* **Expected Result:** Identifies 3–4 core thematic clusters, compares contrasting theoretical viewpoints, and maps research gaps without fabricating sources.

### 8.4 Review an academic draft (`/ars-reviewer`)

* **Where:** Claude Code prompt (`>`).
* **Action:** Subject a sample abstract or draft section to the 5-seat peer review panel.
* **Command:**

```text
/ars-reviewer
```

When prompted, paste an abstract or draft section.

* **Expected Result:** Produces structured feedback from 5 distinct perspectives:
  1. **Editor-in-Chief / Journal-Fit Reviewer:** Contribution, novelty, scope.
  2. **Methodology Reviewer:** Design validity, sample adequacy, statistical rigor.
  3. **Domain Expert:** Discipline context, theoretical framing.
  4. **Perspective Reviewer:** Alternative interpretations, broader impacts.
  5. **Devil's Advocate:** Direct challenge to core assumptions and logical leaps.

### 8.5 Run the full research pipeline (`/ars-full`)

* **Where:** Claude Code prompt (`>`).
* **Action:** Orchestrate the complete end-to-end research-to-paper workflow.
* **Command:**

```text
/ars-full
```

When prompted, provide your topic and requirements.

* **Expected Result:** The `academic-pipeline` orchestrator initiates Stage 1, creates research planning artifacts, and **pauses at the Stage 1 confirmation gate** awaiting your approval.
* **Document Generation Formats:** Markdown (`.md`) is native and requires no extra tools. Direct Word (`.docx`) generation requires Pandoc. Direct PDF generation requires Tectonic; see `docs/SETUP.md` for optional document converters.

> **Command Clarification:** The full-pipeline command is `/ars-full`. There is no separate `/ars-draft` slash command in the ARS repository; drafting is coordinated through `/ars-full` or by prompting `academic-paper` directly.

---

## Step 9: Explore the available slash commands

All 16 slash commands are defined in `.claude/commands/` and are immediately available inside Claude Code sessions:

| Slash Command | Category | Purpose | Input Required |
| :--- | :--- | :--- | :--- |
| `/ars-plan` | Planning | Socratic mentoring for research question formulation and study design. | Topic idea or broad interest area. |
| `/ars-outline` | Structure | Formulates a complete 5-section IMRaD outline with word budgets. | Topic or confirmed research plan. |
| `/ars-lit-review` | Literature | Systematic search, categorization, and synthesis of research papers. | Search keywords or research question. |
| `/ars-full` | Orchestration | Orchestrates the complete 10-stage end-to-end research pipeline. | Research topic, discipline, and target venue. |
| `/ars-reviewer` | Peer Review | Simulates a 5-seat academic peer review panel against a draft or abstract. | Draft text, abstract, or manuscript. |
| `/ars-revision` | Revision | Parses reviewer comments and generates an actionable revision roadmap. | Reviewer reports or referee feedback. |
| `/ars-revision-coach` | Revision | Interactive coaching for challenging revisions and reviewer pushback. | Specific reviewer critique to address. |
| `/ars-rebuttal-audit` | Audit | Verifies consistency between author rebuttal letters and revised drafts. | Rebuttal letter + revised manuscript. |
| `/ars-citation-check` | Audit | Audits citations for provenance, DOI validity, and claim support. | Draft bibliography or cited claims. |
| `/ars-abstract` | Drafting | Compiles a structured, bilingual (English/Chinese) academic abstract. | Full draft or completed study findings. |
| `/ars-format-convert` | Formatting | Converts drafts between Markdown, LaTeX, and Word/DOCX formats. | Draft text + target format specification. |
| `/ars-disclosure` | Ethics | Generates formal AI assistance and methodology disclosure statements. | List of AI tools and pipeline stages used. |
| `/ars-mark-read` | Tracking | Marks an academic paper as read in the local reading history ledger. | Paper title or DOI. |
| `/ars-unmark-read` | Tracking | Removes a read marker from the local reading history ledger. | Paper title or DOI. |
| `/ars-cache-invalidate`| Maintenance | Invalidates cached literature queries and verification records. | None (resets local query cache). |
| `/ars-3w` | Scoping | Executes rapid "What, Why, Who cares?" framing analysis. | Initial research topic or hypothesis. |

---

## Step 10: Understand the project structure

```
C:\Projects\ARS/
├── .claude/                                             # Local Claude Code runtime configuration
│   ├── commands/                                        # 16 Slash command definitions (/ars-plan, etc.)
│   ├── skills/                                          # Active skill registrations for Claude Code
│   │   ├── deep-research/                               # Local registration of deep-research
│   │   ├── academic-paper/                              # Local registration of academic-paper
│   │   ├── academic-paper-reviewer/                     # Local registration of academic-paper-reviewer
│   │   ├── academic-pipeline/                           # Local registration of academic-pipeline
│   │   └── sr-screener/                                 # Local registration of sr-screener
│   ├── settings.json                                    # Gateway & model environment configuration
│   └── CLAUDE.md                                        # Project memory & routing rules
├── .claude-plugin/                                      # Plugin packaging manifests (plugin.json)
├── deep-research/                                       # Canonical deep research skill files
├── academic-paper/                                      # Canonical academic paper writing skill files
├── academic-paper-reviewer/                             # Canonical 5-seat peer reviewer skill files
├── academic-pipeline/                                   # Canonical 10-stage pipeline skill files
├── sr-screener/                                         # Canonical systematic review screener files
│   └── agents/                                          # Specialized agents (screening_reviewer_agent.md)
├── commands/                                            # Canonical prompt templates
├── scripts/                                             # Diagnostic, launcher, and validation scripts
│   ├── launch_nexus_claude.ps1                          # Pre-flight environment loader & Claude Code runner
│   ├── verify_skills_installation.ps1                   # Local skill registration verification test
│   └── test_nexus_integration.ps1                       # Automated 5-step connection & model test
├── shared/                                              # Schemas, contracts, and verification protocols
├── docs/                                                # Architecture, specifications, and risk registers
├── pi/                                                  # Pi package wrapper and compatibility test harness
├── start-nexus-claude.ps1                               # Root launcher shortcut
├── .env.example                                         # Safe environment template (no credentials)
├── .gitignore                                           # Git exclusion rules protecting credentials
├── pyproject.toml                                       # Pytest configuration
└── requirements-dev.txt                                 # Optional developer test dependencies
```

---

## Step 11: Testing and validation

Use this tiered validation checklist to verify your installation:

| Tier | Evaluation Scope | Test Command / Action | Expected Result | Status |
| :---: | :--- | :--- | :--- | :---: |
| **1** | Git Installation | `git --version` in PowerShell | Git version displayed (`v2.30+`). | Completed |
| **1** | Claude Code CLI | `claude --version` in PowerShell | Version displayed (`v2.1.314+`). | Completed |
| **1** | Repository Integrity | `git fsck --full` in PowerShell | Repository passes with zero corruptions. | Completed |
| **2** | Environment Protection | `git check-ignore .env` in PowerShell | Returns `.env` (file is excluded from Git). | Completed |
| **2** | Pre-Flight Launcher | `powershell -ExecutionPolicy Bypass -File .\scripts\launch_nexus_claude.ps1` | Status banner printed without revealing key. | Completed |
| **2** | Skill Registration | `powershell -ExecutionPolicy Bypass -File .\scripts\verify_skills_installation.ps1` | All 5 skills report `VERIFIED`, `CLAUDE.md` passes. | Completed |
| **3** | Nexus Protocol Connection | Send `Respond with exactly: NEXUS_INTEGRATION_OK` in Claude Code | Echoes `NEXUS_INTEGRATION_OK`. | Tested* |
| **3** | Skill Discovery | Ask Claude Code to list the five skills | Correctly identifies all 5 skills and roles. | Completed |
| **4** | Planning Workflow | Run `/ars-plan` in Claude Code | Socratic dialogue initiates with 3–5 scoping questions. | Completed |
| **4** | Outline Workflow | Run `/ars-outline` in Claude Code | Generates 5-section IMRaD outline with word budgets. | Completed |
| **4** | Review Workflow | Run `/ars-reviewer` with sample draft | Generates 5-seat peer review panel evaluation. | Completed |
| **4** | Full Pipeline Workflow | Run `/ars-full` in Claude Code | Initiates Stage 1 plan and pauses at human approval gate. | Completed |

> **Note on Model Inference Status (\*):** In previous integration testing with a test virtual key, the gateway returned `HTTP 401: Key is blocked`. If your key is blocked or out of quota, the pre-flight launcher and skill registration checks will still pass (Tiers 1 & 2), but live inference (Tiers 3 & 4) will remain pending until an administrator unblocks the virtual key on the Nexus Gateway.

---

## Step 12: Troubleshooting

### Problem 1: `git` is not recognised or cloning fails

* **Symptom:** PowerShell returns `The term 'git' is not recognized` or Git fails with `Filename too long`.
* **Solution:**
  1. Download and install Git for Windows from https://git-scm.com/download/win.
  2. Enable long paths globally:
     ```powershell
     git config --global core.longpaths true
     ```
  3. Clone into a short path such as `C:\Projects\ARS`.
  4. Restart PowerShell.

### Problem 2: `claude` is not recognised

* **Symptom:** PowerShell returns `The term 'claude' is not recognized as the name of a cmdlet`.
* **Solution:**
  1. Re-run the installer:
     ```powershell
     irm https://claude.ai/install.ps1 | iex
     ```
  2. Confirm `%USERPROFILE%\.local\bin` is in your user `PATH` environment variable.
  3. Close and reopen VS Code.

### Problem 3: PowerShell blocks the launcher

* **Symptom:** When running `.\scripts\launch_nexus_claude.ps1`, PowerShell outputs:  
  `PSSecurityException: File cannot be loaded because running scripts is disabled on this system.`
* **Solution:**
  * **Best practice (no permanent policy change):** Use the recommended bypass command:
    ```powershell
    powershell -ExecutionPolicy Bypass -File .\scripts\launch_nexus_claude.ps1
    ```
  * **Session-only bypass:** Allow script execution for the active terminal window only:
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    .\scripts\launch_nexus_claude.ps1
    ```

### Problem 4: Launcher reports missing or invalid API key

* **Symptom:** Launcher displays `Nexus API Key required` or `[ERROR] Invalid Nexus API Key format!`.
* **Solution:**
  1. Verify `.env` exists in the ARS project root (ensure it is named `.env`, not `.env.txt`).
  2. Open `.env` and verify that `ANTHROPIC_AUTH_TOKEN` begins with `sk-`.
  3. Ensure there are no surrounding spaces around `=` (e.g. `ANTHROPIC_AUTH_TOKEN=sk-abc...`).
  4. If prompted interactively by the launcher, paste your key into the hidden input prompt.

### Problem 5: HTTP 401, HTTP 403, or model unavailable

* **Symptom:** Claude Code displays `HTTP 401: Authentication Error, Key is blocked` or `Model not found`.
* **Solution:**
  1. Verify the model identifier in `.env` is `nova-micro`.
  2. A blocked virtual key is an administrative state on the LiteLLM gateway. Contact your course instructor or Nexus administrator to unblock the key or generate a replacement.
  3. Do not repeatedly retry with a blocked key, as repeated failed attempts may trigger IP-level rate-limiting on the gateway.

### Problem 6: `No skills found` in Claude Code

* **Symptom:** Claude Code cannot find `/ars-*` commands or reports zero registered skills.
* **Solution:**
  1. Exit Claude Code (`/exit`).
  2. Verify you are launching from the ARS project root:
     ```powershell
     Get-Location
     ```
  3. Verify local skill folders:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\scripts\verify_skills_installation.ps1
     ```
  4. Ensure `.claude/skills/` contains the 5 skill subdirectories with valid `SKILL.md` files.
  5. Restart Claude Code using the recommended launcher.

### Problem 7: Command takes a long time or times out

* **Symptom:** `/ars-outline` or `/ars-full` seems stuck or times out after 180 seconds in automated scripts.
* **Solution:**
  1. Multi-agent planning and outline generation involve recursive deliberation across sections.
  2. Always run these commands inside an **interactive** Claude Code session, where output streams incrementally in real time.
  3. Avoid running deep drafting commands in non-interactive headless CLI modes (`claude -p`).

### Problem 8: The pipeline pauses unexpectedly

* **Symptom:** `/ars-full` stops after Stage 1 and asks for input.
* **Solution:**
  1. This is normal and intentional. ARS enforces human-in-the-loop checkpoints at each pipeline stage.
  2. Review the generated plan or report, make any necessary adjustments, and type your approval to proceed to the next stage.

### Problem 9: Accidentally entering slash commands in PowerShell

* **Symptom:** Running `/ars-plan` in Windows PowerShell gives an error (`The term '/ars-plan' is not recognized`).
* **Solution:**
  1. Commands starting with `/` are Claude Code slash commands, **not** PowerShell commands.
  2. First launch Claude Code using:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\scripts\launch_nexus_claude.ps1
     ```
  3. Once Claude Code is running and you see the `>` prompt, enter `/ars-plan`.

---

## Step 13: Security and responsible research use

* **Protect Credentials:** Never commit `.env` or credentials to Git. Keep `ANTHROPIC_AUTH_TOKEN` strictly local.
* **Verify Evidence:** ARS incorporates anti-fabrication gates (Stage 2.5), but the human researcher is solely responsible for checking every cited DOI, author claim, and statistical finding against the primary source literature.
* **Do Not Fabricate Data:** Never present AI-generated or simulated findings as empirical research data.
* **Ethical Disclosure:** When preparing papers supported by ARS, use `/ars-disclosure` to generate a transparent declaration of AI assistance in accordance with your target journal or university policy (e.g., ICMJE, COPE, IEEE).
* **Confidentiality:** Do not paste unreleased research data, proprietary patent drafts, or sensitive participant records into prompts without institutional compliance approval.

---

## Step 14: Implementation verification and handover

The implementation is verified and ready for student use when the following criteria are satisfied:

### Verification evidence checklist

Students should capture and archive the following evidence:

1. **Repository Setup:** Screenshot showing the ARS project open in VS Code with the complete file tree visible.
2. **CLI Version:** Screenshot of PowerShell showing `claude --version`.
3. **Launcher Diagnostic Banner:** Screenshot showing the launcher output with model, endpoint, and masked authentication.
4. **Nexus Handshake:** Screenshot of Claude Code responding to `Respond with exactly: NEXUS_INTEGRATION_OK`.
5. **Skill Registration:** Output from running `.\scripts\verify_skills_installation.ps1` showing all 5 skills `VERIFIED`.
6. **Planning Output:** Text or screenshot of the Socratic dialogue generated by `/ars-plan`.
7. **Outline Output:** Text or screenshot of the 5-section IMRaD outline generated by `/ars-outline`.
8. **Peer Review Output:** Text or screenshot of the 5-seat peer review panel feedback generated by `/ars-reviewer`.
9. **Pipeline Gating:** Screenshot showing the Stage 1 human approval pause in `/ars-full`.
10. **Resolution Note:** A brief paragraph documenting one technical challenge encountered (e.g. execution policy bypass, long paths) and how it was resolved.

### Acceptance criteria

| Area | Acceptance Criteria | Verification Status |
| :--- | :--- | :---: |
| **Cloning & Workspace** | Repository cloned into short path with long paths enabled; opened in VS Code. | Verified |
| **CLI Runtime** | Claude Code `v2.1.314+` installed and callable from terminal. | Verified |
| **Credential Hygiene** | `.env` created from template; excluded by `.gitignore`; key starts with `sk-`. | Verified |
| **Launcher Execution** | `launch_nexus_claude.ps1` runs with `Bypass` without script execution errors. | Verified |
| **Skill Discovery** | All 5 skills (`deep-research`, `academic-paper`, `academic-paper-reviewer`, `academic-pipeline`, `sr-screener`) verified. | Verified |
| **Interactive Research** | Slash commands `/ars-plan`, `/ars-outline`, `/ars-reviewer`, and `/ars-full` tested. | Verified |
| **Scholarly Integrity** | Researcher reviews all citations, checks claims, and signs off at pipeline checkpoints. | Verified |

---

## Quick reference: Commands used in this guide

### Commands executed in Windows PowerShell (ARS Project Root)

```powershell
# 1. Enable Git long paths globally
git config --global core.longpaths true

# 2. Clone the ARS repository
git clone -c core.longpaths=true https://github.com/reethu10-git/academic-research-skills-nexus-integration.git C:\Projects\ARS

# 3. Navigate to project root and open in VS Code
Set-Location C:\Projects\ARS
code .

# 4. Check Claude Code CLI version
claude --version

# 5. Create local environment configuration
Copy-Item .env.example .env
notepad .env

# 6. Verify credentials file is ignored by Git
git check-ignore .env

# 7. Run automated skill registration verification
powershell -ExecutionPolicy Bypass -File .\scripts\verify_skills_installation.ps1

# 8. PRIMARY RECOMMENDED COMMAND: Launch Claude Code configured with Nexus AI
powershell -ExecutionPolicy Bypass -File .\scripts\launch_nexus_claude.ps1
```

### Commands executed inside the Claude Code prompt (`>`)

*(Do NOT run these in PowerShell)*

```text
# 1. (Optional) If external marketplace is requested by your course:
# /plugin marketplace add Imbad0202/academic-research-skills
# /plugin install academic-research-skills
# (Note: Local skills in .claude/skills are already pre-loaded automatically)

# Test live connection to Nexus Gateway
Respond with exactly: NEXUS_INTEGRATION_OK

# 2. Execute research workflows
/ars-plan
/ars-outline
/ars-lit-review
/ars-reviewer
/ars-full

# 3. Utility and maintenance commands
/ars-citation-check
/ars-disclosure
/ars-format-convert
/ars-abstract
/exit
```

---

## Reference links

* **ARS Project Repository:** https://github.com/reethu10-git/academic-research-skills-nexus-integration
* **Claude Code Documentation:** https://docs.anthropic.com/en/docs/claude-code/overview
* **Claude Code Installation:** https://claude.ai/install
* **Visual Studio Code:** https://code.visualstudio.com/
* **Git for Windows:** https://git-scm.com/download/win
* **Nexus AI Gateway:** `https://nexusapi.navigatelabs.ai`
* **Internal Documentation:** In your cloned repository, refer to `README.md`, `QUICKSTART.md`, `docs/SETUP.md`, and `docs/ARCHITECTURE.md`.
