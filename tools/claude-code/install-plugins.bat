@echo off
rem Windows counterpart of install-plugins.sh: installs the personal Claude Code plugin list.
rem Safe to re-run: plugins already installed are skipped.
setlocal EnableDelayedExpansion

set "FAILED="

for %%P in (
  superpowers@claude-plugins-official
  code-simplifier@claude-plugins-official
  playwright@claude-plugins-official
  code-review@claude-plugins-official
  frontend-design@claude-plugins-official
  context7@claude-plugins-official
  pyright-lsp@claude-plugins-official
  typescript-lsp@claude-plugins-official
  ralph-loop@claude-plugins-official
  jdtls-lsp@claude-plugins-official
  claude-code-setup@claude-plugins-official
  skill-creator@claude-plugins-official
  security-guidance@claude-plugins-official
  feature-dev@claude-plugins-official
  pr-review-toolkit@claude-plugins-official
  claude-md-management@claude-plugins-official
  hookify@claude-plugins-official
  code-modernization@claude-plugins-official
  claude-security@claude-plugins-official
  session-report@claude-plugins-official
) do (
  echo Installing %%P...
  call claude plugin install "%%P"
  if errorlevel 1 set "FAILED=!FAILED! %%P"
)

echo.
if defined FAILED (
  echo Failed:!FAILED!
  exit /b 1
)
echo All plugins installed.
