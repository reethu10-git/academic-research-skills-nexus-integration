---
disable-model-invocation: true
name: ars-reviewer
description: ARS academic-paper-reviewer `full` mode — simulated peer-review panel
---

First invoke the Skill tool with `skill: "academic-research-skills:academic-paper-reviewer"`. Pass the mode and the user's request described below as its arguments. Use the loaded skill and its supporting files before producing the result.

Trigger the `academic-paper-reviewer` skill in `full` mode. Honor explicit alternate modes when present: `quick`, `methodology-focus`, `re-review`, `guided`, or `calibration`. Runs on the inherited session model — the v3.7.0 `opus` frontmatter floor was retired in the 2026-06 harness pass so a stronger session model is never silently downgraded.

Mode reference: `${CLAUDE_PLUGIN_ROOT}/MODE_REGISTRY.md` § academic-paper-reviewer.
Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper-reviewer/SKILL.md`.
Active roles: load reviewer panel roles per phase on demand (field_analyst_agent in Phase 0; then panel reviewers in Phase 1; editorial_synthesizer_agent in Phase 2). Do not pre-load prompt roles from external skills.

Resolve plugin resources from `${CLAUDE_PLUGIN_ROOT}`, not from the paper project's working directory. If the skill or a required file cannot be loaded, report the loading failure and stop; do not substitute this command summary for the mode instructions.
