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

Create symbolic links for AI prompt files.

This script can be run from:
1. The root directory of the .prompts repository itself (for development)
2. The root directory of a project that includes this repository as a submodule at .prompts/

'"
Usage:
  $CURRENT_SOURCE_FILE_NAME -h

Options:
  -h                Show this help message and exit."

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

# Function to create GitHub Copilot symlinks
function create_github_symlinks() {
	local github_dir=".github"
	local prompts_github_dir

	# Determine the source directory based on whether we're in .prompts repo or external repo
	if [[ -d "github-copilot" ]]; then
		# We're in the .prompts repository itself
		prompts_github_dir="github-copilot"
	else
		# We're in an external repository with .prompts as submodule
		prompts_github_dir=".prompts/github-copilot"
	fi

	if [[ ! -d "$prompts_github_dir" ]]; then
		log "[ERROR] Directory %s does not exist. Make sure the prompts submodule is properly initialized." "$prompts_github_dir"
		return 1
	fi

	log "[INFO] Creating GitHub Copilot symlinks in %s..." "$github_dir"
	mkdir -p "$github_dir"

	pushd "$github_dir" > /dev/null

	# Remove existing prompt files (but keep other files like workflows/)
	for file in *.md; do
		if [[ -f "$file" && -L "$file" ]]; then
			rm "$file"
		fi
	done

	# Only create symlink for copilot-instructions.md, not .prompt.md files
	local instructions_file
	if [[ -d "../github-copilot" ]]; then
		instructions_file="../$prompts_github_dir/copilot-instructions.md"
	else
		instructions_file="../$prompts_github_dir/copilot-instructions.md"
	fi

	if [[ -f "$instructions_file" ]]; then
		ln -s "$instructions_file" "copilot-instructions.md"
		log "[INFO] Created symlink: %s -> %s" "$github_dir/copilot-instructions.md" "$instructions_file"
	fi

	popd > /dev/null

	# Create VS Code prompts directory
	local vscode_prompts_dir=".github/prompts"
	mkdir -p "$vscode_prompts_dir"

	pushd "$vscode_prompts_dir" > /dev/null

	# Remove existing VS Code prompt files
	for file in *.prompt.md; do
		if [[ -f "$file" && -L "$file" ]]; then
			rm "$file"
		fi
	done

	# Create symlinks to prompt.md files only in the prompts directory
	local prompt_files_pattern
	if [[ -d "../../github-copilot" ]]; then
		prompt_files_pattern="../../$prompts_github_dir/*.prompt.md"
	else
		prompt_files_pattern="../../$prompts_github_dir/*.prompt.md"
	fi

	for file in $prompt_files_pattern; do
		if [[ -f "$file" ]]; then
			local basename
			basename=$(basename "$file")
			ln -s "$file" "$basename"
			log "[INFO] Created symlink: %s -> %s" "$vscode_prompts_dir/$basename" "$file"
		fi
	done

	popd > /dev/null
}

# Function to create Cursor symlinks
function create_cursor_symlinks() {
	local cursor_rules_dir=".cursor/rules"
	local prompts_cursor_dir

	# Determine the source directory based on whether we're in .prompts repo or external repo
	if [[ -d "cursor" ]]; then
		# We're in the .prompts repository itself
		prompts_cursor_dir="cursor"
	else
		# We're in an external repository with .prompts as submodule
		prompts_cursor_dir=".prompts/cursor"
	fi

	if [[ ! -d "$prompts_cursor_dir" ]]; then
		log "[ERROR] Directory %s does not exist. Make sure the prompts submodule is properly initialized." "$prompts_cursor_dir"
		return 1
	fi

	log "[INFO] Creating Cursor symlinks in %s..." "$cursor_rules_dir"
	mkdir -p "$cursor_rules_dir"

	pushd "$cursor_rules_dir" > /dev/null

	# Remove existing mdc files
	for file in *.mdc; do
		if [[ -f "$file" && -L "$file" ]]; then
			rm "$file"
		fi
	done

	# Create symlinks to all mdc files in the prompts directory
	local mdc_files_pattern
	if [[ -d "../../cursor" ]]; then
		mdc_files_pattern="../../$prompts_cursor_dir/*.mdc"
	else
		mdc_files_pattern="../../$prompts_cursor_dir/*.mdc"
	fi

	for file in $mdc_files_pattern; do
		if [[ -f "$file" ]]; then
			local basename
			basename=$(basename "$file")
			ln -s "$file" "$basename"
			log "[INFO] Created symlink: %s -> %s" "$cursor_rules_dir/$basename" "$file"
		fi
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

	# Check if we're in the right directory
	# Either we're in .prompts repo itself (has rules/ directory)
	# Or we're in external repo with .prompts/ submodule
	if [[ ! -d "rules" && ! -d ".prompts" ]]; then
		log "[ERROR] Neither rules/ nor .prompts/ directory found. This script should be run from either:"
		log "[ERROR] 1. The root of the .prompts repository itself, or"
		log "[ERROR] 2. The root of a project that includes the prompts repository as a submodule."
		exit 1
	fi

	# If we're in external repo, check if the prompts submodule is initialized
	if [[ -d ".prompts" && ! -f ".prompts/README.md" ]]; then
		log "[ERROR] The .prompts/ submodule appears to be uninitialized. Please run 'git submodule update --init' first."
		exit 1
	fi

	create_github_symlinks
	create_cursor_symlinks

	log "[INFO] Symbolic links created successfully!"
}

main "$@"
