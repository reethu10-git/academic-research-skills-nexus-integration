---
disable-model-invocation: true
name: ars-plan
description: ARS academic-paper `plan` mode â€” Socratic chapter-by-chapter planning
---

First invoke the Skill tool with `skill: "academic-research-skills:academic-paper"`. Pass the mode and the user's request described below as its arguments. Use the loaded skill and its supporting files before producing the result.

Trigger the `academic-paper` skill in `plan` mode. Produces a Chapter Plan + INSIGHT collection through Socratic dialogue with the user. Originality-spectrum, very-high oversight.

Mode reference: `${CLAUDE_PLUGIN_ROOT}/MODE_REGISTRY.md` Â§ academic-paper.
Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.
Active roles: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/intake_agent.md`, `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/socratic_mentor_agent.md`, `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/structure_architect_agent.md`, and `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/argument_builder_agent.md`. Do not load draft_writer_agent.md, formatter_agent.md, or peer_reviewer_agent.md.

Resolve plugin resources from `${CLAUDE_PLUGIN_ROOT}`, not from the paper project's working directory. If the skill or a required file cannot be loaded, report the loading failure and stop; do not substitute this command summary for the mode instructions.
