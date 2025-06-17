# 提示词

zh_CN | [en](./README.md)

本仓库用于集中管理我的个人项目中同时在多个项目使用到的AI提示词。

这个仓库会被作为子模块添加到我的项目中，并通过dependabot保持更新。

## 使用

```bash
git submodule add https://github.com/black-desk/prompts .prompts
.prompts/scripts/create-symlinks.sh
```

## 目录结构

- `rules/` —
  源提示词 Markdown 文件（需手动维护）
  - `rules/Project instructions.md` -
    这个文件生成`copilot-instructions.md`以及规则类型为`Always`的`mdc`文件。
  - `rules/*.md` -
    生成`*.prompt.md`以及规则类型为`Agent Requested`的`mdc`文件，其`description`字段的值是文档的标题。
- `cursor/` —
  由`generate.sh`为Cursor生成的提示词文件（`*.mdc`）
- `github-copilot/` —
  由`generate.sh`为GitHub Copilot生成的提示词文件（`copilot-instructions.md`、`*.prompt.md`）
- `scripts/generate.sh` — 用于转换并输出各平台提示词的脚本
- `scripts/create-symlinks.sh` — 用于在使用该项目的其他项目中创建符号链接的脚本

## 许可证

该项目遵守[REUSE规范](https://reuse.software/spec-3.3/)。

你可以使用[reuse-tool](https://github.com/fsfe/reuse-tool)生成这个项目的SPDX列表：

```bash
reuse spdx
```
