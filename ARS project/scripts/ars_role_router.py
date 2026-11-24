"""ARS Selective Role Router (Token Optimization Layer).

Provides lightweight metadata routing and selective prompt role loading across the 43 ARS prompt roles.
Enforces:
  1. Routing via compact metadata (ID, name, description, trigger, stage, file).
  2. Loading complete prompt contents strictly on-demand for active roles only.
  3. Context bounds to prevent monolithic 300k+ token dumps into conversational context.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

REPO_ROOT = Path(__file__).resolve().parents[1]
REGISTRY_FILE = REPO_ROOT / "shared" / "role_registry.json"

COMMAND_TO_MODE = {
    "ars-3w": ("deep-research", "three-way-scan"),
    "ars-abstract": ("academic-paper", "abstract-only"),
    "ars-citation-check": ("academic-paper", "citation-check"),
    "ars-disclosure": ("academic-paper", "disclosure"),
    "ars-format-convert": ("academic-paper", "format-convert"),
    "ars-full": ("academic-pipeline", "(pipeline)"),
    "ars-lit-review": ("academic-paper", "lit-review"),
    "ars-outline": ("academic-paper", "outline-only"),
    "ars-plan": ("academic-paper", "plan"),
    "ars-rebuttal-audit": ("academic-paper", "rebuttal-audit"),
    "ars-reviewer": ("academic-paper-reviewer", "full"),
    "ars-revision-coach": ("academic-paper", "revision-coach"),
    "ars-revision": ("academic-paper", "revision"),
    "ars-mark-read": None,
    "ars-unmark-read": None,
    "ars-cache-invalidate": None,
}


def load_registry() -> Dict[str, Any]:
    if not REGISTRY_FILE.exists():
        raise FileNotFoundError(f"Role registry not found at {REGISTRY_FILE}. Run generate_role_registry.py first.")
    with open(REGISTRY_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def get_all_roles() -> List[Dict[str, Any]]:
    reg = load_registry()
    return list(reg["roles"].values())


def select_roles(
    skill: Optional[str] = None,
    mode: Optional[str] = None,
    stage: Optional[float] = None,
    command: Optional[str] = None,
    required_only: bool = False
) -> List[Dict[str, Any]]:
    """Select minimum active prompt roles based on skill, mode, stage, or command."""
    if command:
        cmd_clean = command.replace("/", "").strip()
        mapping = COMMAND_TO_MODE.get(cmd_clean)
        if mapping:
            skill, mode = mapping
        else:
            return []

    roles = get_all_roles()
    selected = []

    for r in roles:
        # Filter by skill if provided
        if skill and r["skill"] != skill and r["skill"] != "shared":
            continue

        # Filter by stage if provided
        if stage is not None:
            if stage not in r["applicable_stages"]:
                continue

        # Filter by mode if provided
        if mode:
            if mode not in r["applicable_modes"]:
                continue
            if required_only and mode not in r["required_in"]:
                continue

        selected.append(r)

    return selected


def load_role_prompt(role_id: str, skill: Optional[str] = None) -> str:
    """Load the full prompt content of a specific role strictly on-demand."""
    roles = get_all_roles()
    for r in roles:
        if r["role_id"] == role_id:
            if skill and r["skill"] != skill:
                continue
            prompt_path = REPO_ROOT / r["prompt_file"]
            if prompt_path.exists():
                return prompt_path.read_text(encoding="utf-8")
            else:
                raise FileNotFoundError(f"Prompt file missing: {prompt_path}")
    raise KeyError(f"Role {role_id} not found in registry")


def audit_workflow_tokens(skill: str, mode: str) -> Dict[str, Any]:
    """Calculate baseline monolithic token load vs selective role token load for a mode."""
    all_roles = get_all_roles()
    # Baseline: all roles belonging to that skill loaded into context
    skill_roles = [r for r in all_roles if r["skill"] == skill]
    baseline_bytes = sum(r["size_bytes"] for r in skill_roles)
    baseline_tokens = baseline_bytes // 4
    baseline_count = len(skill_roles)

    # Selective: only roles required/applicable for that specific mode
    active_roles = select_roles(skill=skill, mode=mode)
    selective_bytes = sum(r["size_bytes"] for r in active_roles)
    selective_tokens = selective_bytes // 4
    selective_count = len(active_roles)

    saved_bytes = max(0, baseline_bytes - selective_bytes)
    saved_tokens = max(0, baseline_tokens - selective_tokens)
    pct_savings = (saved_bytes / baseline_bytes * 100) if baseline_bytes > 0 else 0.0

    return {
        "skill": skill,
        "mode": mode,
        "baseline_roles_count": baseline_count,
        "baseline_bytes": baseline_bytes,
        "baseline_tokens_approx": baseline_tokens,
        "selective_roles_count": selective_count,
        "selective_bytes": selective_bytes,
        "selective_tokens_approx": selective_tokens,
        "saved_bytes": saved_bytes,
        "saved_tokens_approx": saved_tokens,
        "reduction_pct": round(pct_savings, 1),
        "selected_role_ids": [r["role_id"] for r in active_roles]
    }


def run_full_token_audit() -> Dict[str, Any]:
    """Run token audit across 5 representative core workflows required by Phase 6."""
    representative_workflows = [
        ("deep-research", "socratic", "1. Research Scoping (Socratic Guided Discovery)"),
        ("academic-paper", "outline-only", "2. Paper Drafting (Outline-Only Scaffolding)"),
        ("academic-paper-reviewer", "methodology-focus", "3. Paper Reviewing (Methodology Focus)"),
        ("sr-screener", "ta-screen", "4. Systematic Review Screening (Title/Abstract)"),
        ("academic-pipeline", "(pipeline)", "5. End-to-End Orchestrated Pipeline (Per Stage)"),
    ]

    results = []
    total_baseline_tokens = 0
    total_selective_tokens = 0

    for skill, mode, desc in representative_workflows:
        res = audit_workflow_tokens(skill, mode)
        res["description"] = desc
        total_baseline_tokens += res["baseline_tokens_approx"]
        total_selective_tokens += res["selective_tokens_approx"]
        results.append(res)

    overall_savings_pct = (
        ((total_baseline_tokens - total_selective_tokens) / total_baseline_tokens * 100)
        if total_baseline_tokens > 0 else 0.0
    )

    return {
        "suite": "Academic Research Skills",
        "total_cataloged_roles": 43,
        "representative_workflows": results,
        "overall_baseline_tokens": total_baseline_tokens,
        "overall_selective_tokens": total_selective_tokens,
        "overall_token_savings": total_baseline_tokens - total_selective_tokens,
        "overall_reduction_pct": round(overall_savings_pct, 1)
    }


def main():
    parser = argparse.ArgumentParser(description="ARS Selective Role Router & Token Optimization Layer")
    parser.add_argument("--list-all", action="store_true", help="List all 43 prompt roles with metadata")
    parser.add_argument("--mode", nargs=2, metavar=("SKILL", "MODE"), help="Select roles for skill and mode")
    parser.add_argument("--command", type=str, help="Select roles for a slash command (e.g. /ars-outline)")
    parser.add_argument("--stage", type=float, help="Select roles for an academic pipeline stage (1-6)")
    parser.add_argument("--get-prompt", type=str, help="Load complete prompt content for role_id on demand")
    parser.add_argument("--audit", action="store_true", help="Run token audit across representative workflows")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")

    args = parser.parse_args()

    if args.list_all:
        roles = get_all_roles()
        if args.json:
            print(json.dumps(roles, indent=2))
        else:
            print(f"ARS Prompt Role Catalog ({len(roles)} roles):")
            print(f"{'Role ID':<35} | {'Skill':<23} | {'Size (Tokens)':<14} | {'Stages'}")
            print("-" * 85)
            for r in roles:
                print(f"{r['role_id']:<35} | {r['skill']:<23} | ~{r['size_tokens_approx']:<13,} | {r['applicable_stages']}")

    elif args.mode:
        skill, mode = args.mode
        roles = select_roles(skill=skill, mode=mode)
        audit = audit_workflow_tokens(skill, mode)
        if args.json:
            print(json.dumps({"audit": audit, "selected_roles": roles}, indent=2))
        else:
            print(f"Selected {len(roles)} active role(s) for {skill} in '{mode}' mode:")
            for r in roles:
                print(f"  * {r['role_id']} (~{r['size_tokens_approx']:,} tokens): {r['short_description']}")
            print(f"\nToken Impact: Baseline {audit['baseline_tokens_approx']:,} -> Selective {audit['selective_tokens_approx']:,} tokens ({audit['reduction_pct']}% reduction)")

    elif args.command:
        roles = select_roles(command=args.command)
        if args.json:
            print(json.dumps(roles, indent=2))
        else:
            print(f"Selected {len(roles)} active role(s) for command '{args.command}':")
            for r in roles:
                print(f"  * {r['role_id']} ({r['skill']}): {r['short_description']}")

    elif args.stage is not None:
        roles = select_roles(stage=args.stage)
        if args.json:
            print(json.dumps(roles, indent=2))
        else:
            print(f"Selected {len(roles)} active role(s) for Pipeline Stage {args.stage}:")
            for r in roles:
                print(f"  * {r['role_id']} ({r['skill']}): {r['short_description']}")

    elif args.get_prompt:
        try:
            content = load_role_prompt(args.get_prompt)
            print(content)
        except Exception as e:
            print(f"Error loading prompt: {e}", file=sys.stderr)
            sys.exit(1)

    elif args.audit:
        audit_res = run_full_token_audit()
        if args.json:
            print(json.dumps(audit_res, indent=2))
        else:
            print("================================================================================")
            print("   ARS TOKEN OPTIMIZATION AUDIT — SELECTIVE PROMPT ROLE LOADING")
            print("================================================================================")
            print(f"Cataloged Prompt Roles: {audit_res['total_cataloged_roles']}")
            print(f"Overall Representative Token Savings: {audit_res['overall_token_savings']:,} tokens ({audit_res['overall_reduction_pct']}% reduction)\n")
            print(f"{'Workflow / Mode':<40} | {'Baseline':<10} | {'Selective':<10} | {'Saved Tokens':<13} | {'Reduction'}")
            print("-" * 88)
            for w in audit_res["representative_workflows"]:
                print(f"{w['description'][:40]:<40} | {w['baseline_tokens_approx']:<10,} | {w['selective_tokens_approx']:<10,} | {w['saved_tokens_approx']:<13,} | {w['reduction_pct']}%")
            print("-" * 88)

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
