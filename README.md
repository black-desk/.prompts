<!--
SPDX-FileCopyrightText: 2025 Chen Linxuan <me@black-desk.cn>

SPDX-License-Identifier: MIT
-->

# Prompts

[zh_CN](./README.zh_CN.md) | en

> [!WARNING]
> This English README is translated from the Chinese version
> using AI and may contain errors.

This repository is used to centrally manage AI prompts that are shared across multiple of my personal projects.

This repository is added as a submodule to my projects and kept up to date via dependabot.

## Usage

For external projects:

```bash
git submodule add https://github.com/black-desk/.prompts
.prompts/scripts/generate.sh  # Generate prompt files
.prompts/scripts/create-symlinks.sh  # Create symbolic links
```

For development in this repository:

```bash
scripts/generate.sh  # Generate prompt files
scripts/create-symlinks.sh  # Create symbolic links for testing
```

## Directory Structure

- `rules/` —
  Source prompt Markdown files (maintained manually)
  - `rules/instructions.md` -
    This file generates `copilot-instructions.md` and `mdc` files with rule type `Always`.
  - `rules/*.md` -
    Generates `*.prompt.md` and `mdc` files with rule type `Agent Requested`, where the `description` field is the document title.
- `cursor/` —
  Prompt files generated for Cursor by `generate.sh` (`*.mdc`)
- `github-copilot/` —
  Prompt files generated for GitHub Copilot and VS Code by `generate.sh` (`copilot-instructions.md`, `*.prompt.md` with YAML frontmatter)
- `scripts/generate.sh` — Script for converting source prompts to platform-specific formats
- `scripts/create-symlinks.sh` — Script for creating symbolic links (works in both .prompts repo and external projects)
- `scripts/test.sh` — Script for testing the basic functionality of this project

## License

This project follows the [REUSE Specification](https://reuse.software/spec-3.3/).

You can use the [reuse-tool](https://github.com/fsfe/reuse-tool) to generate the SPDX list for this project:

```bash
reuse spdx
```
