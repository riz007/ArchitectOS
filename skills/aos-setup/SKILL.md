---
name: aos-setup
description: One-time setup that configures ArchitectOS for the current project. Detects the stack, writes AI tool configs (.cursorrules, .windsurfrules, copilot-instructions.md), and shows which commands are available. Use when user runs /aos-setup, opens a new project, or wants ArchitectOS standards applied to their codebase.
---

# /aos-setup

Run once when starting a project or adding ArchitectOS to an existing one.

## What it does

1. Detects your stack from existing files (`package.json`, `pyproject.toml`, etc.)
2. Asks which AI tools you use
3. Writes the right config files for each tool
4. Prints your playbook and available commands

## Workflow

### Step 1 — Detect or ask about the stack

Look for stack indicators, then confirm with the user:

- **Frontend**: Vue 3, React, Angular, or none?
- **Backend**: NestJS, FastAPI, Node.js, Java, or none?
- **AI tools**: Cursor, Windsurf, GitHub Copilot, Aider, Continue.dev?

### Step 2 — Write `.architect-os.json`

```json
{
  "stack": { "frontend": "vue", "backend": "nestjs" },
  "version": "1.0.0"
}
```

### Step 3 — Install AI tool configs

| Tool selected | File written |
|---|---|
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Aider | `.aider.conf.yml` |

Content for each file comes from the matching file in `prompts/` **if the ArchitectOS repo
is checked out**. When installed as a standalone skill (no `prompts/` directory present),
generate the config content yourself from `CONTEXT.md` and the non-negotiables below — do
not fail or skip the step:

> Follow ArchitectOS conventions. Logic lives in services; controllers/components stay thin.
> Validate inputs at the boundary and return DTOs, never entities. Auth guard + ownership
> check on sensitive routes. Parameterised queries only. No `any` in TypeScript; type hints
> on every Python def. Feature-based folders. Tests cover error paths, not just happy paths.

Write that (expanded for the detected stack) into each selected tool's config file.

### Step 4 — Print summary

```
✔ Stack: Vue 3 + NestJS
✔ Cursor rules written → .cursorrules
✔ Windsurf rules written → .windsurfrules

Playbook: playbooks/vue/README.md + playbooks/nestjs/README.md
Standards: standards/

Available commands:
  /aos-scaffold  — start a new project from a template
  /aos-review    — review code against ArchitectOS standards
  /aos-feature   — generate a feature (service + controller + tests)
  /aos-audit     — security audit
```

## Notes

- Never modify existing source files — only write config files.
- If `.architect-os.json` already exists, ask whether to update it or just refresh AI tool configs.
