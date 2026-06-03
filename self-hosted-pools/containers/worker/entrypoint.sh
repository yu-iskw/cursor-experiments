#!/usr/bin/env bash
set -euo pipefail

: "${CURSOR_API_KEY:?CURSOR_API_KEY is required}"
: "${REPO_URL:?REPO_URL is required}"

AGENT_BIN="${AGENT_BIN:-/root/.cursor/bin/agent}"
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace/repo}"
PORT="${PORT:-8080}"

if [[ ! -x "$AGENT_BIN" ]]; then
  echo "error: agent CLI not found at $AGENT_BIN" >&2
  exit 1
fi

if [[ -n "${GIT_TOKEN:-}" ]]; then
  git config --global credential.helper store
  printf 'https://oauth2:%s@github.com\n' "$GIT_TOKEN" > "${HOME}/.git-credentials"
  chmod 600 "${HOME}/.git-credentials"
  export GIT_TERMINAL_PROMPT=0
fi

mkdir -p "$(dirname "$WORKSPACE_DIR")"
if [[ ! -d "$WORKSPACE_DIR/.git" ]]; then
  echo "Cloning ${REPO_URL} into ${WORKSPACE_DIR}..."
  git clone "$REPO_URL" "$WORKSPACE_DIR"
fi

cd "$WORKSPACE_DIR"

POOL_ARGS=(worker start --api-key "$CURSOR_API_KEY" --management-addr ":${PORT}" --pool)

if [[ -n "${CURSOR_WORKER_POOL_NAME:-}" ]]; then
  POOL_ARGS+=(--pool-name "$CURSOR_WORKER_POOL_NAME")
fi

if [[ -n "${CURSOR_WORKER_IDLE_RELEASE_TIMEOUT:-}" ]]; then
  POOL_ARGS+=(--idle-release-timeout "$CURSOR_WORKER_IDLE_RELEASE_TIMEOUT")
else
  POOL_ARGS+=(--idle-release-timeout 600)
fi

if [[ $# -gt 0 ]]; then
  POOL_ARGS+=("$@")
fi

echo "Starting Cursor pool worker in $(pwd)..."
exec "$AGENT_BIN" "${POOL_ARGS[@]}"
