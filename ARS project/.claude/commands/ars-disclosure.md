---
disable-model-invocation: true
name: ars-disclosure
description: ARS academic-paper `disclosure` mode â€” venue applicability/status bundle or policy-anchor render
---

First invoke the Skill tool with `skill: "academic-research-skills:academic-paper"`. Pass the mode and the user's request described below as its arguments. Use the loaded skill and its supporting files before producing the result.

Trigger the `academic-paper` skill in standalone `disclosure` mode. Agent 9 must load `${CLAUDE_PLUGIN_ROOT}/academic-paper/references/disclosure_mode_protocol.md` before rendering; the generic formatter disclosure is not a fallback. The default venue path returns `REQUIRED`, `ACTION_ONLY`, `NOT_REQUIRED`, or `UNKNOWN` applicability plus an explicit typed halt status when needed (15 policy targets supported: ICLR / NeurIPS / Nature / Science / ACL / EMNLP plus medical-publishing targets â€” ICMJE / NEJM / The Lancet / JAMA / BMJ / PLOS / Frontiers / publisher-wide ä¸­åŽæŠ¤ç†æ‚å¿—ç¤¾ / journal-level å›½é™…çœ¼ç§‘æ‚å¿—). The `--policy-anchor` path uses its separate anchor-specific renderer. Fidelity spectrum, low oversight.

Mode reference: `${CLAUDE_PLUGIN_ROOT}/MODE_REGISTRY.md` Â§ academic-paper.
Skill entry: `${CLAUDE_PLUGIN_ROOT}/academic-paper/SKILL.md`.
Active role: load ONLY `${CLAUDE_PLUGIN_ROOT}/academic-paper/agents/formatter_agent.md`. Do not load any other agent files.

Resolve plugin resources from `${CLAUDE_PLUGIN_ROOT}`, not from the paper project's working directory. If the skill or a required file cannot be loaded, report the loading failure and stop; do not substitute this command summary for the mode instructions.
