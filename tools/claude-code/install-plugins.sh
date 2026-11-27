#!/usr/bin/env bash
# Installs the personal Claude Code plugin list.
# Safe to re-run: plugins already installed are skipped.
set -uo pipefail

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
  "skill-creator@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "pr-review-toolkit@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
  "hookify@claude-plugins-official"
  "code-modernization@claude-plugins-official"
  "claude-security@claude-plugins-official"
)

failed=()
for plugin in "${plugins[@]}"; do
  echo "Installing ${plugin}..."
  if ! claude plugin install "$plugin"; then
    failed+=("$plugin")
  fi
done

echo
if ((${#failed[@]})); then
  echo "Failed: ${failed[*]}" >&2
  exit 1
fi
echo "All plugins installed."
