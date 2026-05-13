#!/usr/bin/env bash
set -euo pipefail

plugins=(
  "superpowers@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "playwright@claude-plugins-official"
  "code-review@claude-plugins-official"
  "frontend-design@claude-plugins-official"
  "context7@claude-plugins-official"
  "pyright-lsp@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "ralph-loop@claude-plugins-official"
  "jdtls-lsp@claude-plugins-official"
  "claude-code-setup@claude-plugins-official"
  "qodo-skills@claude-plugins-official"
  "skill-creator@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "feature-dev@claude-plugins-official"
)

for plugin in "${plugins[@]}"; do
  echo "Installing ${plugin}..."
  claude plugin install "$plugin"
done

echo "All plugins installed."
