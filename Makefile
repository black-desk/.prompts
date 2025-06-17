# SPDX-FileCopyrightText: 2025 Chen Linxuan <me@black-desk.cn>
#
# SPDX-License-Identifier: MIT

.PHONY: all test

all:
	./scripts/generate.sh

test:
	./scripts/test.sh
