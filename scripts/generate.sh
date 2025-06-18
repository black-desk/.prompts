#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 Chen Linxuan <me@black-desk.cn>
#
# SPDX-License-Identifier: MIT

# NOTE:
# Use /usr/bin/env to find shell interpreter for better portability.
# Reference: https://en.wikipedia.org/wiki/Shebang_%28Unix%29#Portability

# NOTE:
# Exit immediately if any commands (even in pipeline)
# exits with a non-zero status.
set -e
set -o pipefail

# WARNING:
# This is not reliable when using POSIX sh
# and current script file is sourced by `source` or `.`
CURRENT_SOURCE_FILE_PATH="${BASH_SOURCE[0]:-$0}"
CURRENT_SOURCE_FILE_NAME="$(basename -- "$CURRENT_SOURCE_FILE_PATH")"

# shellcheck disable=SC2016
USAGE="$CURRENT_SOURCE_FILE_NAME"'

Generate files for different output types.

'"
Usage:
  $CURRENT_SOURCE_FILE_NAME -h

Options:
  -h                Show this help message and exit."


CURRENT_SOURCE_FILE_DIR="$(dirname -- "$CURRENT_SOURCE_FILE_PATH")"
cd -- "$CURRENT_SOURCE_FILE_DIR"

# This function log messages to stderr works like printf
# with a prefix of the current script name.
# Arguments:
#   $1 - The format string.
#   $@ - Arguments to the format string, just like printf.
function log() {
	local format="$1"
	shift
	# shellcheck disable=SC2059
	printf "$CURRENT_SOURCE_FILE_NAME: $format\n" "$@" >&2 || true
}

function process_cursor() {
	local rules_dir="../rules"
	local output_dir="../cursor"

	rm -f "$output_dir"/*.mdc
	mkdir -p "$output_dir"

	local project_instructions="$rules_dir/Project instructions.md"
	if [[ -f "$project_instructions" ]]; then
		local title
		title=$(basename "$project_instructions" .md)
		local content
		content=$(cat "$project_instructions")
		cat > "$output_dir/Project instructions.mdc" << EOF
---
description: $title
globs:
alwaysApply: true
---

$content
EOF
	fi

	for file in "$rules_dir"/*.md; do
		if [[ "$(basename "$file")" != "Project instructions.md" ]]; then
			local basename
			basename=$(basename "$file" .md)
			local title="$basename"
			local content
			content=$(cat "$file")
			cat > "$output_dir/$basename.mdc" << EOF
---
description: $title
globs:
alwaysApply: false
---

$content
EOF
		fi
	done
}

function process_github_copilot() {
	local rules_dir="../rules"
	local output_dir="../github-copilot"

	rm -f "$output_dir"/copilot-instructions.md
	rm -f "$output_dir"/*.prompt.md
	mkdir -p "$output_dir"

	local project_instructions="$rules_dir/Project instructions.md"
	if [[ -f "$project_instructions" ]]; then
		cat "$project_instructions" > "$output_dir/copilot-instructions.md"
	fi

	for file in "$rules_dir"/*.md; do
		if [[ "$(basename "$file")" != "Project instructions.md" ]]; then
			local basename
			basename=$(basename "$file" .md)
			cp "$file" "$output_dir/$basename.prompt.md"
		fi
	done
}

function update_github_symlinks() {
    local github_dir="../.github"
    local rules_dir="../github-copilot"
    mkdir -p "$github_dir"
    pushd "$github_dir" > /dev/null
    rm -rf ./*.md
    for file in ../github-copilot/*.md; do
        ln -s "$file" .
    done
    popd > /dev/null
}

function update_cursor_rules_symlinks() {
    local cursor_rules_dir="../.cursor/rules"
    mkdir -p "$cursor_rules_dir"
    pushd "$cursor_rules_dir" > /dev/null
    rm -rf ./*.mdc
    for file in ../../cursor/*.mdc; do
        ln -s "$file" .
    done
    popd > /dev/null
}

function main() {
	while getopts ':h' option; do
		case "$option" in
		h)
			echo "$USAGE"
			exit
			;;
		\?)
			log "[ERROR] Unknown option: -%s" "$OPTARG"
			exit 1
			;;
		esac
	done
	shift $((OPTIND - 1))

	if [[ -n "$1" ]]; then
		log "[ERROR] Unknown argument: %s" "$1"
		exit 1
	fi

	log "[INFO] Generating files for cursor..."
	process_cursor

	log "[INFO] Generating files for github-copilot..."
	process_github_copilot

	log "[INFO] Updating .github/ symlinks..."
	update_github_symlinks

	log "[INFO] Updating .cursor/rules/ symlinks..."
	update_cursor_rules_symlinks
}

main "$@"
