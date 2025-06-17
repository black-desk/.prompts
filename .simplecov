# SPDX-FileCopyrightText: 2025 Chen Linxuan <me@black-desk.cn>
#
# SPDX-License-Identifier: MIT

require 'simplecov'
require 'simplecov-cobertura'

# Creates a `coverage/coverage.xml` file
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
