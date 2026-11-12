# execute_phase2_suite.ps1
param(
    [string]$Group = "ALL" # Options: SKILLS, AGENTS, COMMANDS, WORKFLOW, ALL
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot

. (Join-Path $ScriptDir "test_phase2_runner.ps1")

$suiteResults = [System.Collections.Generic.List[PSObject]]::new()

# ========================================================
# GROUP 1: THE REMAINING FOUR ARS SKILLS
# ========================================================
if ($Group -eq "ALL" -or $Group -eq "SKILLS") {
    Write-Host "`n>>> EXECUTING GROUP 1: REMAINING FOUR ARS SKILLS <<<" -ForegroundColor Yellow

    # Skill 1: academic-paper
    $t1 = Execute-Phase2Test -TestId "SKILL_ACADEMIC_PAPER" `
        -Category "Skill" `
        -Description "Generate IMRaD outline with objectives and methodology guidance" `
        -PromptText "Load the academic-paper skill from .claude/skills/academic-paper. Generate a comprehensive IMRaD research paper outline for the study: 'Impact of Quantization on Reasoning Capabilities of Small Language Models Under 3 Billion Parameters'. Include: 1. Section structure (Introduction, Methodology, Results, Discussion, Conclusion), 2. Explicit objectives per section, 3. Methodology guidance on hardware benchmarks and evaluation metrics, 4. Word count allocations (target: 6,000-8,000 words)."
    $suiteResults.Add($t1)

    # Skill 2: academic-paper-reviewer
    $t2 = Execute-Phase2Test -TestId "SKILL_ACADEMIC_PAPER_REVIEWER" `
        -Category "Skill" `
        -Description "Review sample research abstract across 5 reviewer perspectives" `
        -PromptText "Load the academic-paper-reviewer skill from .claude/skills/academic-paper-reviewer. Perform a structured 5-seat peer review of this abstract: 'We evaluate 4-bit and 8-bit post-training quantization (PTQ) on Gemma-2B and Llama-3.2-1B across GSM8K and ARC benchmarks. Our results indicate a 34% drop in multi-step reasoning accuracy under 4-bit quantization, while 8-bit quantization retains 96% of FP16 accuracy with a 1.8x throughput increase.' Provide: 1. Journal-Fit Reviewer (EIC), 2. Methodology Reviewer, 3. Domain Reviewer, 4. Perspective Reviewer, 5. Devil's Advocate critique, and 6. Concrete Revision Roadmap."
    $suiteResults.Add($t2)

    # Skill 3: academic-pipeline
    $t3 = Execute-Phase2Test -TestId "SKILL_ACADEMIC_PIPELINE" `
        -Category "Skill" `
        -Description "Initialize 10-stage academic research pipeline with dependencies and handoffs" `
        -PromptText "Load the academic-pipeline skill from .claude/skills/academic-pipeline. Initialize the complete research pipeline for 'Impact of Quantization on Reasoning Capabilities of Small Language Models Under 3B Parameters'. Explicitly detail: 1. All ten pipeline stages (Stage 1 Research to Stage 6 Process Summary), 2. Input/output artifact handoffs between skills, 3. Mandatory Stage 2.5 and Stage 4.5 integrity gate requirements, 4. User confirmation checkpoints."
    $suiteResults.Add($t3)

    # Skill 4: sr-screener
    $t4 = Execute-Phase2Test -TestId "SKILL_SR_SCREENER" `
        -Category "Skill" `
        -Description "Execute study screening on sample records with dual-blind review and adjudication" `
        -PromptText "Load the sr-screener skill from .claude/skills/sr-screener. Screen the following three records for a review on 'Quantization of Small Language Models (<3B parameters) for Reasoning Tasks': Inclusion: Empirical evaluation of quantized SLMs under 3B parameters on reasoning benchmarks; Exclusion: Non-empirical papers, models >3B parameters, non-reasoning evaluations. Record 1: 'Evaluating 4-bit AWQ on Phi-3-mini (3.8B) for code generation'. Record 2: 'Quantization-Aware Training of 1.1B TinyLlama for mathematical reasoning'. Record 3: 'A survey of reasoning capabilities in large generative foundation models'. Output: Independent decisions for Reviewer A and Reviewer B, final Adjudication, and explicit exclusion codes."
    $suiteResults.Add($t4)
}

# ========================================================
# GROUP 2: ALL FOUR CUSTOM AGENTS
# ========================================================
if ($Group -eq "ALL" -or $Group -eq "AGENTS") {
    Write-Host "`n>>> EXECUTING GROUP 2: FOUR CUSTOM AGENTS (model: inherit) <<<" -ForegroundColor Yellow

    # Agent 1: research_architect_agent
    $t5 = Execute-Phase2Test -TestId "AGENT_RESEARCH_ARCHITECT" `
        -Category "Agent" `
        -Description "Design Phase 1 Scoping methodology blueprint" `
        -PromptText "Adopting the persona and strict Phase 1 boundary of agents/research_architect_agent.md (model: inherit), design the Methodology Blueprint for: 'Impact of Quantization on Reasoning Capabilities of Small Language Models Under 3B Parameters'. Specify: 1. Research Paradigm, 2. Comparative Method (Within-Subjects design across FP16, INT8, INT4), 3. Data & Benchmark Strategy, 4. Analytical Framework (Accuracy vs. Latency/VRAM Pareto frontier), 5. Validity Criteria and hash-pinned integrity checks."
    $suiteResults.Add($t5)

    # Agent 2: synthesis_agent
    $t6 = Execute-Phase2Test -TestId "AGENT_SYNTHESIS" `
        -Category "Agent" `
        -Description "Synthesize conflicting quantization findings and map research gaps" `
        -PromptText "Adopting the persona and role constraints of agents/synthesis_agent.md (model: inherit), synthesize findings between two conflicting studies: Study 1 claims Post-Training Quantization to 4-bit causes catastrophic collapse on multi-step math reasoning in 2B models; Study 2 claims Quantization-Aware Training to 4-bit preserves 95% of reasoning performance when fine-tuned with chain-of-thought demonstrations. Provide: 1. Convergence/divergence mapping, 2. Evidence conflict resolution via technical mechanisms, 3. Three prioritized research gaps."
    $suiteResults.Add($t6)

    # Agent 3: screening_reviewer_agent
    $t7 = Execute-Phase2Test -TestId "AGENT_SCREENING_REVIEWER" `
        -Category "Agent" `
        -Description "Execute Reviewer A blinded record screening decision" `
        -PromptText "Adopting the persona and constraints of agents/screening_reviewer_agent.md (model: inherit), act as Reviewer A applying the confirmed protocol: Include empirical evaluations of quantized models under 3B parameters tested on reasoning tasks. Screen Record: 'Benchmarking FP8 vs INT4 precision for on-device reasoning on Llama-3.2-1B'. Return the structured decision record with exact criteria checks."
    $suiteResults.Add($t7)

    # Agent 4: report_compiler_agent
    $t8 = Execute-Phase2Test -TestId "AGENT_REPORT_COMPILER" `
        -Category "Agent" `
        -Description "Compile APA 7.0 Abstract and Methodology section" `
        -PromptText "Adopting the persona of agents/report_compiler_agent.md (model: inherit), format the following into an APA 7.0 compliant Abstract and Methodology section: Research Question: How does INT4 vs INT8 quantization impact reasoning on SLMs under 3B? Experimental Design: Within-subjects comparison on Gemma-2B and Llama-3.2-1B across GSM8K and ARC-Challenge. Metrics: Pass@1 accuracy, latency (ms/token), and peak VRAM (MiB)."
    $suiteResults.Add($t8)
}

# ========================================================
# GROUP 3: SLASH COMMANDS VERIFICATION
# ========================================================
if ($Group -eq "ALL" -or $Group -eq "COMMANDS") {
    Write-Host "`n>>> EXECUTING GROUP 3: SLASH COMMANDS <<<" -ForegroundColor Yellow

    # Command: /ars-plan
    $t9 = Execute-Phase2Test -TestId "CMD_ARS_PLAN" `
        -Category "Command" `
        -Description "Execute /ars-plan command from .claude/commands/ars-plan.md" `
        -PromptText "Read the command file .claude/commands/ars-plan.md and execute its instructions for the project 'Quantization in Edge SLMs'. Trigger the academic-paper skill in plan mode using the skill located at .claude/skills/academic-paper to initiate the Socratic planning dialogue."
    $suiteResults.Add($t9)

    # Command: /ars-outline
    $t10 = Execute-Phase2Test -TestId "CMD_ARS_OUTLINE" `
        -Category "Command" `
        -Description "Execute /ars-outline command from .claude/commands/ars-outline.md" `
        -PromptText "Read the command file .claude/commands/ars-outline.md and execute its instructions for 'Quantization of Small Language Models'. Trigger the academic-paper skill in outline-only mode using .claude/skills/academic-paper to generate the paper outline."
    $suiteResults.Add($t10)
}

# ========================================================
# GROUP 4: FULL WORKFLOW INTEGRATION TEST
# ========================================================
if ($Group -eq "ALL" -or $Group -eq "WORKFLOW") {
    Write-Host "`n>>> EXECUTING GROUP 4: FULL WORKFLOW INTEGRATION TEST <<<" -ForegroundColor Yellow

    $t11 = Execute-Phase2Test -TestId "FULL_ARS_WORKFLOW_E2E" `
        -Category "Workflow" `
        -Description "Execute end-to-end multi-stage research planning workflow" `
        -PromptText "Execute a complete controlled academic research workflow following the 10-stage academic-pipeline for the topic: 'Impact of Quantization on Reasoning Capabilities of Small Language Models Under 3 Billion Parameters'. Demonstrate the sequential flow: Stage 1 (Research Scoping & RQ Brief via deep-research) -> Stage 2 (Architecture & Outline via academic-paper) -> Screening Stage (Eligibility rules via sr-screener) -> Stage 3 (Multi-perspective review preview via academic-paper-reviewer) -> Synthesis & Gap Mapping (via synthesis_agent) -> Stage 5 Report Preparation (via report_compiler_agent). Explicitly note that this is a research proposal and that empirical data will be gathered in subsequent experimental phases without fabricating citations."
    $suiteResults.Add($t11)
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "PHASE 2 VALIDATION SUMMARY" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
$suiteResults | Format-Table TestId, Category, ExitCode, ElapsedMs -AutoSize
