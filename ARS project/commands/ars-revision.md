---
disable-model-invocation: true
name: ars-revision
description: ARS academic-paper `revision` mode â€” revised draft + R&R responses
---

First invoke the Skill tool with `skill: "academic-research-skills:academic-paper"`. Pass the mode and the user's request described below as its arguments. Use the loaded skill and its supporting files before producing the result.

Trigger the `academic-paper` skill in `revision` mode. Produces a revised draft plus point-by-point response-to-reviewers. Fidelity spectrum, high oversight.

Mode reference: `${CLAUDE_PLUGIN_ROOT}/MODE_REGISTRY.md` Â§ academic-paper.
Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.
Active roles: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/revision_coach_agent.md` and `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/draft_writer_agent.md`. Do not load other agent files.

Resolve plugin resources from `${CLAUDE_PLUGIN_ROOT}`, not from the paper project's working directory. If the skill or a required file cannot be loaded, report the loading failure and stop; do not substitute this command summary for the mode instructions.
