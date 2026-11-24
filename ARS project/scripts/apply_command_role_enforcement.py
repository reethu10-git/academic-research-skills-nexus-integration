"""Enforce selective role loading directly in commands/*.md and SKILL.md.
"""
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]

COMMAND_ACTIVE_ROLES = {
    "commands/ars-outline.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active roles: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/intake_agent.md` "
        "and `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/structure_architect_agent.md`. "
        "Do not load draft_writer_agent.md, formatter_agent.md, or other agent files."
    ),
    "commands/ars-citation-check.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active role: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/citation_compliance_agent.md`. "
        "Do not load any other agent files."
    ),
    "commands/ars-format-convert.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active role: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/formatter_agent.md`. "
        "Do not load any other agent files."
    ),
    "commands/ars-rebuttal-audit.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active role: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/revision_coach_agent.md`. "
        "Do not load any other agent files."
    ),
    "commands/ars-revision-coach.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active role: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/revision_coach_agent.md`. "
        "Do not load any other agent files."
    ),
    "commands/ars-revision.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active roles: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/revision_coach_agent.md` "
        "and `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/draft_writer_agent.md`. "
        "Do not load other agent files."
    ),
    "commands/ars-disclosure.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active role: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/formatter_agent.md`. "
        "Do not load any other agent files."
    ),
    "commands/ars-lit-review.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active roles: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/intake_agent.md` "
        "and `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/literature_strategist_agent.md`. "
        "Do not load other agent files."
    ),
    "commands/ars-plan.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.\n"
        "Active roles: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/intake_agent.md`, "
        "`${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/socratic_mentor_agent.md`, "
        "`${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/structure_architect_agent.md`, "
        "and `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/argument_builder_agent.md`. "
        "Do not load draft_writer_agent.md, formatter_agent.md, or peer_reviewer_agent.md."
    ),
    "commands/ars-3w.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/deep-research/SKILL.md`.\n"
        "Active roles: load ONLY `${CLAUDE_PLUGIN_ROOT}/deep-research/agents/bibliography_agent.md` "
        "and `${CLAUDE_PLUGIN_ROOT}/deep-research/agents/synthesis_agent.md`. "
        "Do not load the other 12 deep-research agent files."
    ),
    "commands/ars-reviewer.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper-reviewer/SKILL.md`.\n"
        "Active roles: load reviewer panel roles per phase on demand (field_analyst_agent in Phase 0; "
        "then panel reviewers in Phase 1; editorial_synthesizer_agent in Phase 2). "
        "Do not pre-load prompt roles from external skills."
    ),
    "commands/ars-full.md": (
        "Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-pipeline/SKILL.md`.\n"
        "Active roles: load pipeline orchestrator per stage on demand. "
        "Do not pre-load all 43 prompt roles at session start."
    ),
}


def apply():
    for rel_path, new_block in COMMAND_ACTIVE_ROLES.items():
        cmd_file = REPO_ROOT / rel_path
        if not cmd_file.exists():
            continue
        text = cmd_file.read_text(encoding="utf-8")
        if "Active role" in text:
            continue
        # Find Skill entry line
        for line in text.splitlines():
            if line.startswith("Skill entry:"):
                text = text.replace(line, new_block)
                cmd_file.write_text(text, encoding="utf-8")
                print(f"Updated {rel_path}")
                break


if __name__ == "__main__":
    apply()
