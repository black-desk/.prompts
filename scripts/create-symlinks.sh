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

Create symbolic links in the current project for AI prompt files.

This script should be run from the root directory of a project that includes
this repository as a submodule at .prompts/.

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
	local prompts_github_dir=".prompts/github-copilot"

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

	# Create symlinks to all markdown files in the prompts directory
	for file in ../"$prompts_github_dir"/*.md; do
		if [[ -f "$file" ]]; then
			local basename
			basename=$(basename "$file")
			ln -s "$file" "$basename"
			log "[INFO] Created symlink: %s -> %s" "$github_dir/$basename" "$file"
		fi
	done

	popd > /dev/null
}

# Function to create Cursor symlinks
function create_cursor_symlinks() {
	local cursor_rules_dir=".cursor/rules"
	local prompts_cursor_dir=".prompts/cursor"

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
	for file in ../../"$prompts_cursor_dir"/*.mdc; do
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

	# Check if we're in the right directory (should have .prompts/ subdirectory)
	if [[ ! -d ".prompts" ]]; then
		log "[ERROR] Directory .prompts/ not found. This script should be run from the root of a project that includes the prompts repository as a submodule."
		exit 1
	fi

	# Check if the prompts submodule is initialized
	if [[ ! -f ".prompts/README.md" ]]; then
		log "[ERROR] The .prompts/ submodule appears to be uninitialized. Please run 'git submodule update --init' first."
		exit 1
	fi

	create_github_symlinks
	create_cursor_symlinks

	log "[INFO] Symbolic links created successfully!"
}

main "$@"
