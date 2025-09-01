<!--
SPDX-FileCopyrightText: 2025 Chen Linxuan <me@black-desk.cn>

SPDX-License-Identifier: MIT
-->

# Contributing Guide

1. All documentation, comments and commit messages
   must be written in English.

2. Follow [Semantic Line Breaks][sembr] principles in your writing:

   > When writing text with a compatible markup language,
   > add a line break after each substantial unit of thought.

3. Respect the code style defined by existing linter configuration files,
   for example .editorconfig, in the project.

4. Adhere to the [Conventional Commits 1.0][conventional-commits] specification
   when crafting commit messages.

5. **Special note for `rules/*.md` files**:
   These files contain natural language paragraphs for GitHub Copilot prompts,
   not complete Markdown documents.
   They should ignore Markdown linting warnings as they only contain content paragraphs
   without standard Markdown document structure (headers, code blocks, etc.).
   This is a requirement from GitHub Copilot for prompt formatting.

[sembr]: https://sembr.org/
[conventional-commits]: https://www.conventionalcommits.org/en/v1.0.0/
