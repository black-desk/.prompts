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

Test the basic functionality of this project by creating a temporary git repository,
adding this project as a submodule, running the create-symlinks script, and verifying
that all created symbolic links can access their target files correctly.

'"
Usage:
  $CURRENT_SOURCE_FILE_NAME -h

Options:
  -h                Show this help message and exit."

CURRENT_SOURCE_FILE_DIR="$(dirname -- "$CURRENT_SOURCE_FILE_PATH")"
PROJECT_ROOT_DIR="$(realpath "$CURRENT_SOURCE_FILE_DIR/..")"

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

# Function to clean up temporary directory on exit
function cleanup() {
	if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
		log "[INFO] Cleaning up temporary directory: %s" "$TEMP_DIR"
		rm -rf "$TEMP_DIR"
	fi
}

# Function to verify that a symbolic link points to an existing file
function verify_symlink() {
	local symlink_path="$1"

	if [[ ! -L "$symlink_path" ]]; then
		log "[ERROR] %s is not a symbolic link" "$symlink_path"
		return 1
	fi

	local target_path
	target_path="$(readlink "$symlink_path")"

	if [[ ! -f "$symlink_path" ]]; then
		log "[ERROR] Symbolic link %s points to non-existent file: %s" "$symlink_path" "$target_path"
		return 1
	fi

	log "[INFO] ✓ Verified symlink: %s -> %s" "$symlink_path" "$target_path"
	return 0
}

# Function to recursively verify all symbolic links in a directory
function verify_symlinks_recursive() {
	local dir_path="$1"
	local errors=0

	log "[INFO] Verifying symbolic links in: %s" "$dir_path"

	# Find all symbolic links recursively
	while IFS= read -r -d '' symlink; do
		if ! verify_symlink "$symlink"; then
			((errors++))
		fi
	done < <(find "$dir_path" -type l -print0 2>/dev/null || true)

	if [[ $errors -eq 0 ]]; then
		log "[INFO] ✓ All symbolic links verified successfully in %s" "$dir_path"
		return 0
	else
		log "[ERROR] Found %d broken symbolic links in %s" "$errors" "$dir_path"
		return 1
	fi
}

# Function to run the main test
function run_test() {
	log "[INFO] Starting test of project functionality..."

	# Create temporary directory
	TEMP_DIR="$(mktemp -d -t "prompts-test-XXXXXX")"
	log "[INFO] Created temporary directory: %s" "$TEMP_DIR"

	# Set up cleanup on exit
	trap cleanup EXIT

	# Change to temporary directory
	cd "$TEMP_DIR"

	# Initialize git repository
	log "[INFO] Initializing git repository in temporary directory..."
	git init
	git config user.name "Test User"
	git config user.email "test@example.com"

	# Create a dummy file and initial commit
	echo "# Test Project" > README.md
	git add README.md
	git commit -m "Initial commit"

	# Add prompts repository as submodule (simulate by copying)
	log "[INFO] Copying prompts repository to simulate submodule..."
	cp -r "$PROJECT_ROOT_DIR" .prompts

	# Remove .git directory from the copy to simulate a clean submodule
	rm -rf .prompts/.git

	# Verify that submodule was added correctly
	if [[ ! -f ".prompts/README.md" ]]; then
		log "[ERROR] Submodule was not initialized properly"
		return 1
	fi

	# Generate the prompt files first
	log "[INFO] Generating prompt files..."
	.prompts/scripts/generate.sh

	# Run create-symlinks script
	log "[INFO] Running create-symlinks script..."
	.prompts/scripts/create-symlinks.sh

	# Verify that expected directories were created
	local expected_dirs=(".github" ".cursor/rules")
	for dir in "${expected_dirs[@]}"; do
		if [[ ! -d "$dir" ]]; then
			log "[ERROR] Expected directory %s was not created" "$dir"
			return 1
		fi
		log "[INFO] ✓ Directory %s was created" "$dir"
	done

	# Verify all symbolic links recursively
	local verification_errors=0

	for dir in "${expected_dirs[@]}"; do
		if ! verify_symlinks_recursive "$dir"; then
			((verification_errors++))
		fi
	done

	# Check that we actually have some symlinks to verify
	local total_symlinks
	total_symlinks="$(find .github .cursor/rules -type l 2>/dev/null | wc -l)"

	if [[ $total_symlinks -eq 0 ]]; then
		log "[ERROR] No symbolic links were created"
		return 1
	fi

	log "[INFO] Total symbolic links created: %d" "$total_symlinks"

	if [[ $verification_errors -eq 0 ]]; then
		log "[INFO] ✅ All tests passed successfully!"
		return 0
	else
		log "[ERROR] ❌ Test failed with %d verification errors" "$verification_errors"
		return 1
	fi
}

function main() {
	if [[ -z "$RUN_WITH_BASHCOV" ]] && command -v bashcov >/dev/null 2>&1; then
		log "[INFO] Running with bashcov for coverage reporting"
		export RUN_WITH_BASHCOV=1
		exec bashcov -- "$CURRENT_SOURCE_FILE_PATH" "$@"
	fi

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

	# Check if we're in the right directory (should have scripts/generate.sh)
	if [[ ! -f "$PROJECT_ROOT_DIR/scripts/generate.sh" ]]; then
		log "[ERROR] This script should be run from the prompts project directory"
		exit 1
	fi

	# Check if git is available
	if ! command -v git >/dev/null 2>&1; then
		log "[ERROR] git command is not available"
		exit 1
	fi

	run_test
}

main "$@"
