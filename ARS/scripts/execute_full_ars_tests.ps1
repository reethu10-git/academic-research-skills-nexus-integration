# execute_full_ars_tests.ps1
param([string]$targetTest = "ALL")

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot

. (Join-Path $ScriptDir "test_all_components.ps1")

$results = [System.Collections.Generic.List[PSObject]]::new()

# TEST 1: Terminal Execution & File Access
if ($targetTest -eq "ALL" -or $targetTest -eq "TERMINAL") {
    $t1 = Execute-Test -TestId "T1_TERMINAL_GIT" `
        -Component "Claude Code Terminal" `
        -Description "Run git status and directory inspection via Bash tool" `
        -PromptText "Use your Bash tool to run git status and list the files in the current directory. Output the exact branch and files found."
    $results.Add($t1)

    $t2 = Execute-Test -TestId "T2_FILE_IO" `
        -Component "Claude Code File IO" `
        -Description "Read CITATION.cff and create a temporary verification file" `
        -PromptText "Read the file CITATION.cff, report the title and authors, then write a file named test_nexus_rw.tmp with content 'NEXUS_VERIFIED_GEMINI' and confirm it was written."
    $results.Add($t2)
    
    # Cleanup temp file
    $tmpFile = Join-Path $ProjectRoot "test_nexus_rw.tmp"
    if (Test-Path $tmpFile) {
        Remove-Item $tmpFile -Force
    }
}

# TEST 2: Genuine Skill Invocations
if ($targetTest -eq "ALL" -or $targetTest -eq "SKILLS") {
    # 2.1 deep-research
    $t3 = Execute-Test -TestId "T3_SKILL_DEEP_RESEARCH" `
        -Component "Skill: deep-research" `
        -Description "Execute deep-research quick mode to generate a query expansion strategy" `
        -PromptText "Load and execute the deep-research skill in 'quick' mode for the topic: 'Mitigating Hallucinations in Small Language Models under 3B Parameters'. Formulate the primary research questions, 5 keyword expansion sets, and source inclusion criteria as specified by the deep-research protocol."
    $results.Add($t3)

    # 2.2 academic-paper
    $t4 = Execute-Test -TestId "T4_SKILL_ACADEMIC_PAPER" `
        -Component "Skill: academic-paper" `
        -Description "Execute academic-paper outline-only mode" `
        -PromptText "Load and execute the academic-paper skill in 'outline-only' mode for an empirical paper titled 'Parameter-Efficient Fine-Tuning of Small Language Models for Edge AI'. Produce a complete outline following the academic-paper structural standards with section headings, proposed subsections, and word count allocations."
    $results.Add($t4)

    # 2.3 academic-paper-reviewer
    $t5 = Execute-Test -TestId "T5_SKILL_ACADEMIC_REVIEWER" `
        -Component "Skill: academic-paper-reviewer" `
        -Description "Execute 5-seat review panel on a sample abstract" `
        -PromptText "Load and execute the academic-paper-reviewer skill to review this sample abstract: 'We evaluate LoRA and QLoRA on 1B parameter models across 5 reasoning benchmarks. Results indicate a 12% drop in latency with negligible loss in accuracy.' Provide evaluations from all 5 reviewer seats: Journal-Fit (EIC), Methodology Reviewer, Domain Reviewer, Perspective Reviewer, and Devil's Advocate according to the reviewer rubric."
    $results.Add($t5)

    # 2.4 academic-pipeline
    $t6 = Execute-Test -TestId "T6_SKILL_ACADEMIC_PIPELINE" `
        -Component "Skill: academic-pipeline" `
        -Description "Execute academic-pipeline stage initialization" `
        -PromptText "Load and execute the academic-pipeline orchestrator to initialize a new research project on 'Comparative Efficiency of LoRA vs Prompt Tuning'. Outline the 10 pipeline stages, identify the entry stage, specify required artifacts for Stage 1, and define the Stage 2.5 integrity gate requirements."
    $results.Add($t6)

    # 2.5 sr-screener
    $t7 = Execute-Test -TestId "T7_SKILL_SR_SCREENER" `
        -Component "Skill: sr-screener" `
        -Description "Execute sr-screener dual-blind screening on test records" `
        -PromptText "Load and execute the sr-screener skill to screen these two test records against inclusion criteria (Inclusion: empirical study on SLMs <3B parameters; Exclusion: non-empirical or models >3B): Record 1: 'LoRA fine-tuning of 1.5B Qwen model for clinical QA' Record 2: 'Survey of prompt engineering techniques for GPT-4'. Provide blinded decisions for Reviewer A and Reviewer B, and final adjudication with explicit exclusion reasons."
    $results.Add($t7)
}

# TEST 3: Custom Agents Execution (model: inherit)
if ($targetTest -eq "ALL" -or $targetTest -eq "AGENTS") {
    # 3.1 research_architect_agent
    $t8 = Execute-Test -TestId "T8_AGENT_RESEARCH_ARCHITECT" `
        -Component "Agent: research_architect_agent" `
        -Description "Execute Phase 1 Scoping methodology blueprint" `
        -PromptText "Adopting the persona and role constraints of agents/research_architect_agent.md (model: inherit), design the Phase 1 Methodology Blueprint for: 'Comparing LoRA and Prompt-Tuning in Small Language Models (<3B parameters)'. Specify research paradigm, method, data strategy, analytical framework, and validity criteria within Phase 1 boundaries."
    $results.Add($t8)

    # 3.2 synthesis_agent
    $t9 = Execute-Test -TestId "T9_AGENT_SYNTHESIS" `
        -Component "Agent: synthesis_agent" `
        -Description "Execute cross-source integration and gap analysis" `
        -PromptText "Adopting the persona and role constraints of agents/synthesis_agent.md (model: inherit), synthesize findings between these two studies: Study A finds prompt tuning matches LoRA on classification tasks for 1B models; Study B finds prompt tuning fails on multi-step reasoning tasks for 1B models. Provide convergence/divergence mapping, evidence conflict resolution, and identified research gaps."
    $results.Add($t9)

    # 3.3 screening_reviewer_agent
    $t10 = Execute-Test -TestId "T10_AGENT_SCREENING_REVIEWER" `
        -Component "Agent: screening_reviewer_agent" `
        -Description "Execute blinded record screening decisions" `
        -PromptText "Adopting the persona and role constraints of agents/screening_reviewer_agent.md (model: inherit), act as Reviewer A applying the confirmed protocol: Include only empirical evaluations of parameter-efficient fine-tuning on open-weight models under 3B. Screen Record: 'An empirical benchmark of LoRA, Prefix-Tuning, and IA3 on Gemma-2B and Llama-3.2-1B'. Return the structured decision record."
    $results.Add($t10)

    # 3.4 report_compiler_agent
    $t11 = Execute-Test -TestId "T11_AGENT_REPORT_COMPILER" `
        -Component "Agent: report_compiler_agent" `
        -Description "Execute APA 7.0 report compilation" `
        -PromptText "Adopting the persona and role constraints of agents/report_compiler_agent.md (model: inherit), format the following findings into an APA 7.0 compliant Abstract and Methodology section: Research Question: How does LoRA compare to Prompt Tuning on 1B parameter models? Sample: 5 reasoning benchmarks. Metric: Accuracy and latency."
    $results.Add($t11)
}

# TEST 4: Slash Command /ars-plan
if ($targetTest -eq "ALL" -or $targetTest -eq "COMMAND_ARS_PLAN") {
    $t12 = Execute-Test -TestId "T12_CMD_ARS_PLAN" `
        -Component "Command: /ars-plan" `
        -Description "Execute /ars-plan command prompt execution" `
        -PromptText "Execute the command instructions in commands/ars-plan.md for the research project 'Edge LLM Fine-Tuning'. Trigger academic-paper in plan mode to produce the Chapter Plan outline and initial Socratic inquiry."
    $results.Add($t12)
}

# TEST 5: Full ARS Research Planning Workflow
if ($targetTest -eq "ALL" -or $targetTest -eq "WORKFLOW") {
    $t13 = Execute-Test -TestId "T13_FULL_ARS_WORKFLOW" `
        -Component "Workflow: Full ARS Research Plan" `
        -Description "Execute complete Phase 1 Research Planning workflow" `
        -PromptText "Execute the complete Phase 1 Academic Research Planning Workflow for the study: 'Comparative Evaluation of Parameter-Efficient Fine-Tuning (PEFT) vs. Prompt-Tuning in Small Language Models (<3B parameters)'. Follow academic-pipeline Stage 1 and research_architect_agent blueprint. Include: 1. Research Question and Scope, 2. Methodological Blueprint (Paradigm, Method, Analytical Framework, Validity Criteria), 3. Execution Plan (3 Phases). Explicitly note that this is a methodological blueprint and that empirical literature will be gathered in subsequent phases without fabricating citations."
    $results.Add($t13)
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "TEST SUITE EXECUTION SUMMARY" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
$results | Format-Table TestId, Component, ExitCode, ElapsedMs -AutoSize

