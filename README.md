# Instructions for GitHub Copilot

This is a git repository that stores my personal project's Copilot prompts.
It will be referenced by my other personal projects as a submodule
and kept updated through dependabot.

You can use this repository as follows:

```bash
git submodule add https://github.com/black-desk/copilot-instructions .copilot-instructions
mkdir -p .github
ln -s ../.copilot-instructions/copilot-instructions.md .github/copilot-instructions.md
```
