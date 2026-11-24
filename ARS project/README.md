# Academic Research Skills (ARS) — Student Edition

A production-ready, contract-audited suite of **Academic Research Skills (ARS)** running on **Claude Code CLI** and pre-configured for the **Nexus AI Gateway** using **`gemini-3.1-flash-lite`**.

---

## 1. Project Overview

Academic Research Skills (ARS) bridges AI capabilities and scholarly research standards. Rather than generating ungrounded text, ARS acts as an interactive research mentor, literature synthesizer, and peer review simulator. It enforces **citation provenance**, **anti-fabrication safeguards**, and **human-in-the-loop checkpoints** at every stage.

---

## 2. What You Can Accomplish Using ARS

With ARS, you can:
- **Scope Research Questions:** Clarify vague ideas into testable hypotheses through Socratic dialogue.
- **Deep Literature Reviews:** Search across academic indices, synthesize evidence, and map research gaps.
- **Structured Paper Outlines:** Formulate 5-section IMRaD outlines with section word allocations.
- **Systematic Screening (PRISMA):** Conduct dual-blind screening of title/abstract records with adjudication.
- **5-Seat Simulated Peer Review:** Submit draft abstracts or papers to a simulated panel (Editor-in-Chief, Methodology, Domain Expert, Perspective, and Devil's Advocate).
- **Citation Auditing:** Verify DOI accuracy and ensure that every empirical assertion is grounded in real literature.

---

## 3. Requirements

Before using ARS, ensure you have:
1. **Windows 10/11 x64** (or macOS / Linux).
2. **Claude Code CLI** (`v2.1.314` or later).
   ```powershell
   npm install -g @anthropic-ai/claude-code
   ```
3. **Python 3.10+** (standard Python installation for local helper scripts).
4. **Nexus AI Virtual Key:** A valid key starting with `sk-` from your Nexus AI Model Hub account.

---

## 4. Installation & Setup (3 Simple Steps)

### Step 1: Extract the Package
Extract `tool integration.zip` to a convenient folder (e.g., `C:\Projects\academic-research-skills`).

### Step 2: Configure Your Nexus API Key
Open PowerShell inside the extracted folder and run:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_env.ps1
```
When prompted, paste your Nexus virtual key (starts with `sk-`). This automatically creates a secure local `.env` file configured with `gemini-3.1-flash-lite`.

*(Alternatively, copy `.env.example` to `.env` and paste your key into `ANTHROPIC_AUTH_TOKEN`).*

### Step 3: Launch ARS
Run the root launcher:
```powershell
.\start-nexus-claude.ps1
```
Claude Code will start with all 5 ARS skills, 16 slash commands, and Nexus AI routing active.

---

## 5. Available ARS Slash Commands

Type any of the following commands directly inside Claude Code:

| Command | Action | Description |
| :--- | :--- | :--- |
| `/ars-plan` | Socratic Research Scoping | Clarifies research questions, methodology, and scope before writing. |
| `/ars-outline` | IMRaD Outline Formulator | Produces a 5-section outline with targets and literature hooks. |
| `/ars-lit-review`| Literature Synthesis | Searches, categorizes, and synthesizes relevant scholarly evidence. |
| `/ars-reviewer` | 5-Seat Peer Review | Runs a simulated multi-perspective academic peer review on your draft. |
| `/ars-revision` | Revision Roadmap | Organizes reviewer critiques into an actionable revision table. |
| `/ars-citation-check` | Citation Audit | Validates citations for DOI provenance and detects ungrounded claims. |
| `/ars-abstract` | Bilingual Abstract | Generates concise, structured English/Chinese abstract versions. |
| `/ars-3w` | Rapid Framing | Conducts a quick "What, Why, Who cares?" research evaluation. |
| `/ars-full` | End-to-End Pipeline | Orchestrates the full 10-stage research pipeline with human gates. |

---

## 6. Example Workflows

### Example A: Socratic Research Scoping
```text
You: /ars-plan
Claude: "I am ready to help you frame your research. What broad topic or phenomenon are you investigating, and what specific problem or gap motivates this inquiry?"
```
*Claude will ask guided questions rather than generating a generic essay, helping you refine your thesis.*

### Example B: Rapid Paper Outline
```text
You: /ars-outline Quantization effects on small language models under 3B parameters
```
*Claude loads the `academic-paper` skill in outline mode, allocating word budgets and empirical objectives across Introduction, Methods, Results, and Discussion.*

### Example C: Simulated Peer Review
```text
You: /ars-reviewer
(Attach or paste your draft)
```
*Claude executes a 5-perspective review panel analyzing methodological soundness, theoretical novelty, and potential blind spots.*

---

## 7. Generated Outputs & Artifacts

ARS generates transparent research deliverables in your workspace:
- **`outline.md` / `draft.md`:** Structured IMRaD sections with citation anchors.
- **`review_report.md`:** Comprehensive 5-seat peer review evaluation.
- **`prisma_counts.json`:** Quantitative screening inclusion/exclusion metrics.
- **`reading_ledger.json`:** Record of cited papers audited for provenance.

---

## 8. Troubleshooting & FAQ

### Issue: `Claude Code executable ('claude') not found`
- **Solution:** Install Claude Code globally using npm:
  ```powershell
  npm install -g @anthropic-ai/claude-code
  ```
  Restart your PowerShell terminal after installation.

### Issue: `ExecutionPolicy` error running scripts
- **Solution:** Allow local PowerShell script execution:
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```

### Issue: `Authentication Error: Key is blocked` (HTTP 401)
- **Solution:** Your Nexus virtual key has hit a rate limit, budget limit, or has expired. Verify your key in the Nexus Model Hub dashboard.

### Issue: `Missing API Key`
- **Solution:** Re-run `powershell -ExecutionPolicy Bypass -File .\scripts\setup_env.ps1` to re-enter your key.

---

## 9. Security & Privacy

- **Protected Secrets:** Your `.env` file is excluded from Git via `.gitignore`.
- **Zero Hardcoded Keys:** This distribution contains zero personal keys or tokens.
- **Local Control:** All drafts, screening records, and notes remain on your local machine.
