# Quick Start Guide (Windows)

Get from zero to your first research session in 3 steps.

---

## Step 1: Open the Project in VS Code

1. Extract `tool integration.zip` to a local folder (e.g., `C:\Projects\academic-research-skills`).
2. Open VS Code, select **File > Open Folder...**, and select the extracted `academic-research-skills` folder.

---

## Step 2: Configure Your Nexus AI API Key

Open the integrated terminal in VS Code (`Ctrl + ~`) and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_env.ps1
```

- When prompted, paste your **Nexus Virtual Key** (starts with `sk-`).
- The script automatically writes your `.env` configuration file with the active model: `gemini-3.1-flash-lite`.

---

## Step 3: Launch Academic Research Skills

Run:

```powershell
.\start-nexus-claude.ps1
```

Claude Code will launch in your terminal configured with the Nexus AI gateway.

---

## Your First Research Prompt

Try typing:

```text
/ars-plan
```

Claude will start a Socratic scoping session to help you define your research question and methodology.
