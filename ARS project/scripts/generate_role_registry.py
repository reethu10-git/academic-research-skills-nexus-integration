"""Generate the canonical shared/role_registry.json for ARS 43 prompt roles.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]

# Mapping of applicable modes and stages for each of the 43 roles
ROLE_WORKFLOW_MAPPINGS = {
    # deep-research roles (14 roles)
    "deep-research/research_question_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "quick", "socratic", "lit-review", "three-way-scan"],
        "trigger_conditions": "Topic definition, research question refinement, FINER scoping",
        "required_in": ["full", "socratic"],
        "dependencies": []
    },
    "deep-research/research_architect_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "socratic", "systematic-review"],
        "trigger_conditions": "Methodology blueprint, research paradigm selection, data strategy",
        "required_in": ["full", "socratic"],
        "dependencies": ["research_question_agent"]
    },
    "deep-research/bibliography_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "lit-review", "three-way-scan", "fact-check", "systematic-review"],
        "trigger_conditions": "Database queries, source retrieval, search strings, bibliography curation",
        "required_in": ["full", "lit-review", "three-way-scan"],
        "dependencies": ["research_architect_agent"]
    },
    "deep-research/source_verification_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "lit-review", "fact-check", "systematic-review"],
        "trigger_conditions": "Evidence grading (I-VII), predatory journal screening, COI detection",
        "required_in": ["full", "fact-check"],
        "dependencies": ["bibliography_agent"]
    },
    "deep-research/synthesis_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "lit-review", "three-way-scan", "systematic-review"],
        "trigger_conditions": "Thematic cross-source synthesis, gap analysis, theoretical framing",
        "required_in": ["full", "lit-review"],
        "dependencies": ["source_verification_agent"]
    },
    "deep-research/report_compiler_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "quick", "systematic-review"],
        "trigger_conditions": "Compiling final structured report (APA 7.0 / PRISMA)",
        "required_in": ["full", "quick", "systematic-review"],
        "dependencies": ["synthesis_agent"]
    },
    "deep-research/editor_in_chief_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "review"],
        "trigger_conditions": "Final report review, quality scoring, editorial verdict",
        "required_in": ["full", "review"],
        "dependencies": ["report_compiler_agent"]
    },
    "deep-research/devils_advocate_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "review"],
        "trigger_conditions": "Checkpoint critique, counter-argument stress tests, cherry-picking checks",
        "required_in": ["full"],
        "dependencies": ["research_question_agent", "synthesis_agent"]
    },
    "deep-research/ethics_review_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "systematic-review"],
        "trigger_conditions": "Ethics screening, human subjects administrative status, dual-use checks",
        "required_in": ["full"],
        "dependencies": ["report_compiler_agent"]
    },
    "deep-research/socratic_mentor_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["socratic"],
        "trigger_conditions": "Guided research exploration, cognitive scaffolding, question taxonomy",
        "required_in": ["socratic"],
        "dependencies": []
    },
    "deep-research/risk_of_bias_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["systematic-review"],
        "trigger_conditions": "RoB 2 / ROBINS-I study-level risk assessment in evidence synthesis",
        "required_in": ["systematic-review"],
        "dependencies": ["source_verification_agent"]
    },
    "deep-research/meta_analysis_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["systematic-review"],
        "trigger_conditions": "Quantitative effect size pooling, heterogeneity (I^2), funnel plot asymmetry",
        "required_in": [],
        "dependencies": ["synthesis_agent"]
    },
    "deep-research/monitoring_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full"],
        "trigger_conditions": "Literature update tracking, post-publication alerts, RSS monitoring strategy",
        "required_in": [],
        "dependencies": []
    },
    "deep-research/timeline_extraction_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["full", "lit-review"],
        "trigger_conditions": "Chronological evolution of scientific concepts, discovery timeline mapping",
        "required_in": [],
        "dependencies": ["synthesis_agent"]
    },

    # academic-paper roles (12 roles)
    "academic-paper/intake_agent": {
        "applicable_stages": [2],
        "applicable_modes": ["full", "plan", "outline-only", "lit-review"],
        "trigger_conditions": "Phase 0 configuration interview, target journal/citation selection",
        "required_in": ["full", "plan", "outline-only"],
        "dependencies": []
    },
    "academic-paper/literature_strategist_agent": {
        "applicable_stages": [2],
        "applicable_modes": ["full", "lit-review"],
        "trigger_conditions": "Phase 1 literature search and bibliography construction for paper writing",
        "required_in": ["full", "lit-review"],
        "dependencies": ["intake_agent"]
    },
    "academic-paper/structure_architect_agent": {
        "applicable_stages": [2],
        "applicable_modes": ["full", "plan", "outline-only"],
        "trigger_conditions": "Phase 2 structure selection, detailed section outline, word count budget",
        "required_in": ["full", "plan", "outline-only"],
        "dependencies": ["intake_agent"]
    },
    "academic-paper/argument_builder_agent": {
        "applicable_stages": [2],
        "applicable_modes": ["full", "plan"],
        "trigger_conditions": "Phase 3 Claim-Evidence-Reasoning (CER) chains, thesis defense blueprint",
        "required_in": ["full", "plan"],
        "dependencies": ["structure_architect_agent"]
    },
    "academic-paper/draft_writer_agent": {
        "applicable_stages": [2, 4],
        "applicable_modes": ["full", "revision"],
        "trigger_conditions": "Phase 4 section-by-section writing and revision drafting",
        "required_in": ["full", "revision"],
        "dependencies": ["argument_builder_agent"]
    },
    "academic-paper/citation_compliance_agent": {
        "applicable_stages": [2, 5],
        "applicable_modes": ["full", "citation-check"],
        "trigger_conditions": "Phase 5a in-text citation <-> reference list zero-orphan audit",
        "required_in": ["full", "citation-check"],
        "dependencies": ["draft_writer_agent"]
    },
    "academic-paper/abstract_bilingual_agent": {
        "applicable_stages": [2],
        "applicable_modes": ["full", "abstract-only"],
        "trigger_conditions": "Phase 5b paired bilingual abstract (default zh-TW + EN) generation",
        "required_in": ["full", "abstract-only"],
        "dependencies": ["draft_writer_agent"]
    },
    "academic-paper/peer_reviewer_agent": {
        "applicable_stages": [2],
        "applicable_modes": ["full"],
        "trigger_conditions": "Phase 6 simulated internal double-blind peer review report",
        "required_in": ["full"],
        "dependencies": ["draft_writer_agent"]
    },
    "academic-paper/formatter_agent": {
        "applicable_stages": [5],
        "applicable_modes": ["full", "format-convert", "disclosure"],
        "trigger_conditions": "Phase 7 document formatting (LaTeX, DOCX, PDF) and journal styling",
        "required_in": ["format-convert", "disclosure"],
        "dependencies": ["draft_writer_agent"]
    },
    "academic-paper/socratic_mentor_agent": {
        "applicable_stages": [2],
        "applicable_modes": ["plan"],
        "trigger_conditions": "Plan mode chapter-by-chapter Socratic dialogue and INSIGHT harvesting",
        "required_in": ["plan"],
        "dependencies": ["intake_agent"]
    },
    "academic-paper/visualization_agent": {
        "applicable_stages": [2, 5],
        "applicable_modes": ["full"],
        "trigger_conditions": "Scientific figure and chart script generation (Python/R) with APA styling",
        "required_in": [],
        "dependencies": ["structure_architect_agent"]
    },
    "academic-paper/revision_coach_agent": {
        "applicable_stages": [4],
        "applicable_modes": ["revision-coach", "rebuttal-audit"],
        "trigger_conditions": "Parsing unstructured reviews into Revision Roadmap and Response Skeleton",
        "required_in": ["revision-coach", "rebuttal-audit"],
        "dependencies": []
    },

    # academic-paper-reviewer roles (7 roles)
    "academic-paper-reviewer/field_analyst_agent": {
        "applicable_stages": [3],
        "applicable_modes": ["full", "quick", "guided", "methodology-focus", "calibration"],
        "trigger_conditions": "Phase 0 paper analysis, domain detection, generating Reviewer Cards",
        "required_in": ["full", "quick", "guided", "methodology-focus", "calibration"],
        "dependencies": []
    },
    "academic-paper-reviewer/eic_agent": {
        "applicable_stages": [3],
        "applicable_modes": ["full", "quick", "guided"],
        "trigger_conditions": "Journal-Fit Reviewer: scope, readership, priority, editorial framing",
        "required_in": ["full", "quick"],
        "dependencies": ["field_analyst_agent"]
    },
    "academic-paper-reviewer/methodology_reviewer_agent": {
        "applicable_stages": [3],
        "applicable_modes": ["full", "methodology-focus", "guided"],
        "trigger_conditions": "Peer Reviewer 1: research design rigor, statistics, reproducibility",
        "required_in": ["full", "methodology-focus"],
        "dependencies": ["field_analyst_agent"]
    },
    "academic-paper-reviewer/domain_reviewer_agent": {
        "applicable_stages": [3],
        "applicable_modes": ["full", "guided"],
        "trigger_conditions": "Peer Reviewer 2: domain literature coverage, theoretical contribution",
        "required_in": ["full"],
        "dependencies": ["field_analyst_agent"]
    },
    "academic-paper-reviewer/perspective_reviewer_agent": {
        "applicable_stages": [3],
        "applicable_modes": ["full", "guided"],
        "trigger_conditions": "Peer Reviewer 3: cross-disciplinary potential, policy/social impact",
        "required_in": ["full"],
        "dependencies": ["field_analyst_agent"]
    },
    "academic-paper-reviewer/devils_advocate_reviewer_agent": {
        "applicable_stages": [3],
        "applicable_modes": ["full"],
        "trigger_conditions": "Review seat 5: hardest counter-arguments, cherry-picking, bias audit",
        "required_in": ["full"],
        "dependencies": ["field_analyst_agent"]
    },
    "academic-paper-reviewer/editorial_synthesizer_agent": {
        "applicable_stages": [3],
        "applicable_modes": ["full", "methodology-focus", "re-review", "calibration"],
        "trigger_conditions": "Phase 2 synthesis: Editorial Decision Letter and immutable Revision Roadmap",
        "required_in": ["full", "re-review", "calibration"],
        "dependencies": ["methodology_reviewer_agent", "domain_reviewer_agent"]
    },

    # academic-pipeline roles (5 roles)
    "academic-pipeline/pipeline_orchestrator_agent": {
        "applicable_stages": [1, 2, 3, 4, 5, 6],
        "applicable_modes": ["(pipeline)"],
        "trigger_conditions": "Full multi-stage pipeline orchestration, transitions, and checkpoints",
        "required_in": ["(pipeline)"],
        "dependencies": []
    },
    "academic-pipeline/state_tracker_agent": {
        "applicable_stages": [1, 2, 3, 4, 5, 6],
        "applicable_modes": ["(pipeline)", "resume_from_passport"],
        "trigger_conditions": "Tracking stage deliverables, passport updates, revision loop count",
        "required_in": ["(pipeline)"],
        "dependencies": []
    },
    "academic-pipeline/integrity_verification_agent": {
        "applicable_stages": [2.5, 4.5],
        "applicable_modes": ["(pipeline)"],
        "trigger_conditions": "Stage 2.5 and 4.5 integrity verification gates (claims, data, citations)",
        "required_in": ["(pipeline)"],
        "dependencies": []
    },
    "academic-pipeline/collaboration_depth_agent": {
        "applicable_stages": [1, 2, 3, 4, 5, 6],
        "applicable_modes": ["(pipeline)"],
        "trigger_conditions": "Advisory collaboration scoring at FULL/SLIM checkpoints and Stage 6",
        "required_in": [],
        "dependencies": []
    },
    "academic-pipeline/claim_ref_alignment_audit_agent": {
        "applicable_stages": [2.5, 4.5],
        "applicable_modes": ["(pipeline)"],
        "trigger_conditions": "Opt-in L3 claim-faithfulness audit (ARS_CLAIM_AUDIT=1)",
        "required_in": [],
        "dependencies": []
    },

    # sr-screener roles (4 roles)
    "sr-screener/protocol_architect_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["protocol", "pilot"],
        "trigger_conditions": "Screening protocol design, eligibility criteria, exclusion codes",
        "required_in": ["protocol", "pilot"],
        "dependencies": []
    },
    "sr-screener/screening_reviewer_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["quick", "pilot", "ta-screen", "ft-screen", "adjudicate", "audit"],
        "trigger_conditions": "Independent blinded record screening, conflict adjudication, and QC",
        "required_in": ["quick", "pilot", "ta-screen", "ft-screen", "adjudicate", "audit"],
        "dependencies": ["protocol_architect_agent"]
    },
    "sr-screener/qc_auditor_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["pilot", "ta-screen", "audit"],
        "trigger_conditions": "Senior quality control audit of excluded and borderline records",
        "required_in": ["ta-screen", "audit"],
        "dependencies": ["screening_reviewer_agent"]
    },
    "sr-screener/reporter_agent": {
        "applicable_stages": [1],
        "applicable_modes": ["report", "ta-screen", "ft-screen"],
        "trigger_conditions": "Compiling PRISMA flow numbers, screening log, and methods paragraph",
        "required_in": ["report", "ta-screen", "ft-screen"],
        "dependencies": ["screening_reviewer_agent"]
    },

    # shared roles (1 role)
    "shared/compliance_agent": {
        "applicable_stages": [2, 5],
        "applicable_modes": ["full"],
        "trigger_conditions": "RAISE compliance principles check before paper finalization",
        "required_in": [],
        "dependencies": []
    }
}


def build_registry():
    roles = {}
    for key, meta in ROLE_WORKFLOW_MAPPINGS.items():
        skill, agent_name = key.split("/")
        filename = f"{agent_name}.md"
        if skill == "shared":
            file_path = REPO_ROOT / "shared" / "agents" / filename
        else:
            file_path = REPO_ROOT / skill / "agents" / filename
            if not file_path.exists():
                file_path = REPO_ROOT / ".claude" / "skills" / skill / "agents" / filename

        if not file_path.exists():
            raise FileNotFoundError(f"Agent file not found: {file_path}")

        text = file_path.read_text(encoding="utf-8", errors="ignore")
        fm_name = agent_name
        fm_desc = ""
        if text.startswith("---"):
            parts = text.split("---", 2)
            if len(parts) >= 3:
                fm_text = parts[1]
                m_name = re.search(r"name:\s*(.+)", fm_text)
                m_desc = re.search(r"description:\s*\"?([^\n\"]+)\"?", fm_text)
                if m_name: fm_name = m_name.group(1).strip()
                if m_desc: fm_desc = m_desc.group(1).strip()

        size_bytes = file_path.stat().st_size
        rel_path = file_path.relative_to(REPO_ROOT).as_posix()

        role_record = {
            "role_id": agent_name,
            "role_name": fm_name,
            "skill": skill,
            "prompt_file": rel_path,
            "size_bytes": size_bytes,
            "size_tokens_approx": size_bytes // 4,
            "short_description": fm_desc or f"Academic Research Skills role for {agent_name}",
            "applicable_stages": meta["applicable_stages"],
            "applicable_modes": meta["applicable_modes"],
            "trigger_conditions": meta["trigger_conditions"],
            "required_in": meta["required_in"],
            "dependencies": meta["dependencies"]
        }
        roles[key] = role_record

    assert len(roles) == 43, f"Expected 43 roles, got {len(roles)}"

    output_path = REPO_ROOT / "shared" / "role_registry.json"
    output_path.write_text(json.dumps({
        "version": "1.0.0",
        "suite_version": "3.24.0",
        "description": "Canonical machine-readable metadata registry of the 43 ARS prompt roles for selective role routing and token optimization.",
        "total_roles": len(roles),
        "total_bytes": sum(r["size_bytes"] for r in roles.values()),
        "total_tokens_approx": sum(r["size_tokens_approx"] for r in roles.values()),
        "roles": roles
    }, indent=2), encoding="utf-8")
    print(f"Successfully generated {output_path} with {len(roles)} roles.")


if __name__ == "__main__":
    build_registry()
