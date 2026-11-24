# Compact Stage Context Protocol — Token Optimization Across Workflow Transitions

## 1. Overview & Objective

To prevent conversational context exhaustion during multi-stage academic workflows, this protocol governs inter-stage communication across the Academic Research Skills (ARS) suite.

**The Golden Rule:** 
*Pass compact structured summary artifacts between conversational stages. Keep full evidence, raw manuscripts, and comprehensive logs on disk. Downstream stages load full disk artifacts selectively only when performing deep verification.*

---

## 2. Instruction Hierarchy (Preventing Repeated Prompt Injections)

ARS establishes a four-tier instruction hierarchy to avoid duplicating identical rules into multiple prompt files:

```
Level 0: CLAUDE.md (Session Root)
  └── Global suite invariants, routing discipline, and core escape hatches.
      Loaded ONCE at session start.

Level 1: SKILL.md (Skill Entry Point)
  └── Mode overview, stage checklist, handoff definitions.
      Does NOT inline prompt roles; routes via shared/role_registry.json.

Level 2: Active Role Prompt (agents/{role}.md)
  └── Pure role persona, specific inputs, and execution rules.
      Loaded ON DEMAND only for the active role(s) required for the task.

Level 3: Shared References (shared/references/*.md)
  └── Domain-specific schemas, citation style guides, and formal rubrics.
      Referenced by pointer; read by tools only when explicitly triggered.
```

---

## 3. Compact Structured Artifact Specifications

| Workflow Stage Transition | Legacy Full-Context Transfer (Heavy) | Compact Structured Transfer (Optimized) | Disk Evidence Location |
| :--- | :--- | :--- | :--- |
| **Stage 1 → Stage 2 (Research → Writing)** | Full 10,000-word literature corpus, complete synthesis narrative, and all search logs dumped into conversation memory. | **RQ Brief + Blueprint Pointer:** Final RQ, 2-3 sub-questions, methodology type, and relative file path to `literature_corpus.yaml`. | `work/literature_corpus.yaml`, `work/synthesis_report.md` |
| **Stage 2 → Stage 2.5 (Writing → Integrity)** | Full text of paper + all cited sources pasted into context. | **Paper Path + Reference List:** Target draft file path, citation keys list, and word count. | `manuscript.md`, `references.bib` |
| **Stage 2.5 → Stage 3 (Integrity → Reviewer)** | Full integrity diagnostic log + paper text + reviewer instructions. | **Integrity Status Gate + Review Target:** `{status: PASS, open_issues: 0, criteria_binding: <manifest_path>}`. | `integrity_report.md`, `submission_packet_manifest.json` |
| **Stage 3 → Stage 4 (Reviewer → Revision)** | 5 complete verbose reviewer reports pasted in memory. | **Structured Reviewer Findings:** Array of `{seat, dimension, finding, severity, evidence_quote, recommendation}` + Editorial Letter summary. | `review_reports/seat_*.md`, `editorial_decision.md` |
| **Stage 4 → Stage 3' / 4.5 (Revision → Re-Review)** | Full revised paper + full previous paper + all past discussions. | **Revision Diff / Patch + Itemized R&R:** Changed section references and point-by-point response summary. | `revision_patch.diff`, `response_to_reviewers.md` |
| **Screening (sr-screener)** | Hundreds of raw database records and full abstracts in context. | **Batch Identifier + Decision Records:** Array of `{id: "R00001", d: "include", code: "INC", why: "..."}`. | `batches/bNNN.txt`, `records.json`, `identification.json` |
| **QC & Reporting** | Complete screening history, all reviewer deliberations, and logs. | **PRISMA Counts Object:** `{identified, duplicates_removed, screened, excluded_by_code, advanced}`. | `screening_log.xlsx`, `TA_prisma_counts.json` |

---

## 4. Disk vs Memory Boundaries

1. **Memory Budget Limit:** Conversational transfers between stages MUST remain under **2,500 tokens** per transition.
2. **Deterministic File Pointers:** Instead of repeating text, agents emit and pass relative file paths (`work/...`, `deliverables/...`, `passport.yaml`).
3. **Lazy Loading:** A downstream agent (e.g. `integrity_verification_agent` or `editorial_synthesizer_agent`) inspects the summary first. If an issue requires verifying a specific citation or paragraph, it reads ONLY the targeted byte/line offset on disk rather than reloading the entire corpus.
