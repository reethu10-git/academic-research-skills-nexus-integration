# Academic Research Skills (ARS)
## Student Implementation Guide — Claude Code CLI and Nexus AI

**Project category:** AI-assisted academic research  
**Platform:** Windows 10/11, PowerShell and Visual Studio Code  
**Primary interface:** Claude Code CLI  
**AI gateway:** Nexus AI  
**Configured model:** `nova-micro`

---

## 1. Project overview

The Academic Research Skills (ARS) project supports research planning, literature exploration, systematic screening, paper drafting and peer review.

It includes five core skills:

| Skill | Purpose |
|---|---|
| `deep-research` | Explore research topics and synthesise literature |
| `sr-screener` | Screen papers against review criteria |
| `academic-paper` | Structure and draft academic papers |
| `academic-paper-reviewer` | Review papers and provide structured feedback |
| `academic-pipeline` | Coordinate the research-to-paper workflow |

The project also includes slash commands, agent instructions, templates and supporting scripts. Review sources and generated content; ARS does not replace researcher's judgement.

## 2. Requirements

- Windows 10/11
- Git for Windows
- Visual Studio Code
- Claude Code CLI
- Internet connection
- Authorised Nexus virtual API key with access to `nova-micro`

**Node.js is not required** for the core ARS workflows. Python is optional for some additional scripts.

**Repository:** [academic-research-skills-nexus-integration](https://github.com/reethu10-git/academic-research-skills-nexus-integration)

**Download ZIP:** [Download the ARS project](https://github.com/reethu10-git/academic-research-skills-nexus-integration/archive/refs/heads/main.zip)

## 3. Download and open the project

Download the ZIP from the link above and extract it, or clone the repository using Git.

### Clone using Git (recommended)

Open PowerShell and run:

```powershell
git config --global core.longpaths true
New-Item -ItemType Directory -Force C:\Projects | Out-Null
git clone -c core.longpaths=true git@github.com:reethu10-git/academic-research-skills-nexus-integration.git C:\Projects\ARS
Set-Location C:\Projects\ARS
code .
```

If `code` is not recognised, open VS Code and select **File → Open Folder**. Choose `C:\Projects\ARS`.

Run the remaining commands from the project root.

## 4. Install Claude Code CLI

In the VS Code PowerShell terminal, run:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Restart the terminal and verify:

```powershell
claude --version
```

## 5. Configure Nexus AI

The supplied project is configured to route Claude Code requests through the Nexus AI gateway using the Anthropic-compatible Messages API.

### 5.1 Create the environment file

From the project root, run:

```powershell
Copy-Item .env.example .env
notepad .env
```

Set the following values:

```dotenv
ANTHROPIC_BASE_URL=https://nexusapi.navigatelabs.ai
ANTHROPIC_MODEL=nova-micro
CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
ANTHROPIC_AUTH_TOKEN=YOUR_NEXUS_VIRTUAL_KEY
```

Replace `YOUR_NEXUS_VIRTUAL_KEY` with your authorised Nexus key. In `.claude/settings.json`, set the model to `nova-micro` as well. The model name must match in both files.

### 5.2 Protect the API key

Check that Git ignores the environment file:

```powershell
git check-ignore .env
```

Expected output:

```text
.env
```

Never commit or share `.env`, API keys, or credentials.

## 6. Launch Claude Code through Nexus

From the project root, run:

```powershell
.\scripts\launch_nexus_claude.ps1
```

If PowerShell blocks the script, allow it for the current terminal session and retry:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\launch_nexus_claude.ps1
```

The launcher loads `.env`, configures the Nexus endpoint and model, checks the API key, and starts Claude Code.

The launcher summary should show:

- Endpoint: `https://nexusapi.navigatelabs.ai`
- Model: `nova-micro`
- Maximum output: `4096`

## 7. Install the ARS plugin

The repository includes local skill and command files. The `/ars-*` commands use the `academic-research-skills` plugin namespace, so install the plugin from inside the Claude Code prompt (`>`).

Enter these commands one at a time:

```text
/plugin marketplace add Imbad0202/academic-research-skills
/plugin install academic-research-skills
/exit
```

Back in PowerShell, launch Claude Code again:

```powershell
.\scripts\launch_nexus_claude.ps1
```

Enter slash commands only inside the Claude Code prompt, not in PowerShell.

## 8. Verify the Nexus connection and ARS skills

### Test the Nexus connection

At the Claude Code prompt (`>`), enter:

```text
Respond with exactly: NEXUS_INTEGRATION_OK
```

Expected response:

```text
NEXUS_INTEGRATION_OK
```

This confirms that a model response was received through the configured route.

### Verify the five skills

Ask Claude Code:

```text
Explain the Academic Research Skills project. Identify the five main skills and describe the purpose of each. Use the project files as the source of truth.
```

Claude Code should identify `deep-research`, `sr-screener`, `academic-paper`, `academic-paper-reviewer` and `academic-pipeline`.

## 9. Run the research workflows

Use the following sample topic to test the project:

**Sample topic:** Impact of AI-assisted learning tools on engagement in undergraduate education.

Run these commands inside the Claude Code prompt (`>`):

| Command | Purpose |
|---|---|
| `/ars-plan` | Plan the research question and methodology |
| `/ars-outline` | Generate a structured paper outline |
| `/ars-lit-review` | Explore and organise relevant literature |
| `/ars-reviewer` | Review an academic draft |
| `/ars-full` | Start the complete research-to-paper workflow |

For `/ars-reviewer`, provide a sample abstract or draft when prompted. For `/ars-full`, provide your topic and requirements. The pipeline includes human approval checkpoints; review each stage before continuing.

The `/ars-full` command coordinates the full workflow, including drafting, review and revision. There is no separate `/ars-draft` command in the supplied project.

## 10. Project structure

```text
ARS/
├── .claude/
│   ├── commands/       # ARS slash commands
│   ├── skills/         # Five research skills
│   ├── settings.json   # Nexus model settings
│   └── CLAUDE.md       # Project instructions
├── .claude-plugin/     # Plugin configuration
├── deep-research/
├── academic-paper/
├── academic-paper-reviewer/
├── academic-pipeline/
├── sr-screener/
├── commands/           # Plugin command definitions
├── scripts/            # Nexus launcher and support scripts
├── docs/               # Project documentation
├── .env.example
├── .gitignore
├── README.md
└── QUICKSTART.md
```

## 11. Troubleshooting

| Issue | What to check |
|---|---|
| `git` is not recognised | Install Git for Windows and reopen PowerShell |
| Clone fails with path-length error | Enable `core.longpaths` and clone to `C:\Projects\ARS` |
| `claude` is not recognised | Reopen VS Code or run the Claude Code installer again |
| PowerShell blocks the launcher | Use the session-only execution policy command in Step 6 |
| API key is missing or invalid | Check the project-root `.env` and `ANTHROPIC_AUTH_TOKEN` |
| HTTP 401 or 403 | Check key status and model permissions with the Nexus administrator |
| ARS commands are unknown | Confirm plugin installation, project root and restart Claude Code |
| Workflow takes a long time | Use the interactive session; avoid repeated retries that consume quota |
| `/ars-full` pauses | This is expected; review the output and approve the next stage |

**Model access note:** Live responses require an active Nexus key with access to `nova-micro`. This guide retains the existing Claude Code Anthropic-compatible gateway configuration; confirm that `nova-micro` is enabled for this API route in your Nexus environment. If the gateway does not expose Nova Micro through the Anthropic Messages API, the launcher configuration alone will not make it compatible.

## 12. Completion checklist

- [ ] Repository downloaded and opened in VS Code
- [ ] Claude Code CLI installed
- [ ] Nexus settings added to `.env`
- [ ] `.env` confirmed as ignored by Git
- [ ] Claude Code launched using the Nexus launcher
- [ ] ARS plugin installed and Claude Code restarted
- [ ] Nexus response test completed
- [ ] Five ARS skills identified
- [ ] Research workflows tested
- [ ] API key kept private

**Submission evidence:** Provide the launcher summary (without credentials), Nexus connection test, skill discovery result and sample workflow outputs. Verify all references, claims and generated content before submission.

---

## Reference links

- [ARS GitHub repository](https://github.com/reethu10-git/academic-research-skills-nexus-integration)
- [Claude Code installation](https://claude.ai/install)
- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git for Windows](https://git-scm.com/download/win)
- Nexus AI Gateway: `https://nexusapi.navigatelabs.ai`
