# CLAUDE.md

Guidance for AI assistants (Claude Code and others) working in this repository.

## Current state of the repository

**This repository is a fresh skeleton — it contains no application code yet.**

As of this writing, the entire tracked contents are:

```
.
├── README.md   # single line: "# f2"
└── CLAUDE.md   # this file
```

There is no source code, no build system, no dependency manifest
(`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc.), no tests,
and no CI configuration. Any description of "codebase structure,"
"architecture," or "development workflow" below is therefore **forward-looking
guidance**, not a description of code that exists.

> **Keep this file honest.** When real code lands, update this document to
> describe what is actually present. Do not let it drift into describing an
> imagined project. If you add a language, framework, build tool, or test
> runner, document the real commands here at the same time.

## Working conventions

### Git branch workflow

- The default/integration branch is **`main`**.
- Feature work happens on dedicated branches. The convention seen so far uses
  the `claude/` prefix with a short kebab-case description and a suffix, e.g.
  `claude/claude-md-docs-08nu51`.
- **Never push directly to `main`** unless explicitly asked. Develop on a
  feature branch and push there.
- Push with upstream tracking: `git push -u origin <branch-name>`.
- Write clear, descriptive commit messages in the imperative mood
  (e.g. "Add CLAUDE.md documentation").
- Do **not** open a pull request unless the user explicitly requests one.

### If a branch's PR was already merged

Treat follow-up work as a fresh change. Restart the branch from the latest
`main` rather than stacking new commits on already-merged history:

```bash
git fetch origin main
git checkout -B <branch-name> origin/main
```

## Bootstrapping the project (when code is first added)

When the first real code is introduced, do these things together so this file
and the repository stay in sync:

1. **Add the toolchain manifest** for the chosen language/stack and commit it.
2. **Document the real commands** in this file — replace the placeholders
   below with the actual install / build / run / test / lint commands.
3. **Add a `.gitignore`** appropriate to the stack (dependencies, build
   output, environment files, editor cruft).
4. Consider adding CI (e.g. a GitHub Actions workflow) that runs the build,
   tests, and linter on pull requests.

### Command reference (fill in when real)

| Purpose        | Command                    |
| -------------- | -------------------------- |
| Install deps   | _not yet defined_          |
| Build          | _not yet defined_          |
| Run / dev      | _not yet defined_          |
| Test           | _not yet defined_          |
| Lint / format  | _not yet defined_          |

## Notes for AI assistants

- Verify the repository's actual contents before acting — this file may lag
  behind reality. Prefer inspecting the tree (`git ls-files`) over trusting
  documentation, and reconcile the two if they disagree.
- Because there is no build or test tooling yet, there is nothing to run to
  validate changes. Once tooling exists, run it before committing.
- Keep changes minimal and scoped to what the user asks for.
