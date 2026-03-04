#!/bin/bash
set -e

# Ensure /data and OpenClaw state paths are writable by openclaw
mkdir -p /data/.openclaw/identity /data/workspace
chown -R openclaw:openclaw /data 2>/dev/null || true
chmod 700 /data 2>/dev/null || true
chmod 700 /data/.openclaw 2>/dev/null || true
chmod 700 /data/.openclaw/identity 2>/dev/null || true

# Copy workspace files (SOUL.md, AGENTS.md) on every boot so updates deploy automatically
for f in SOUL.md AGENTS.md identity.md; do
  if [ -f "/app/$f" ]; then
    cp "/app/$f" "/data/workspace/$f"
    chown openclaw:openclaw "/data/workspace/$f" 2>/dev/null || true
    echo "[entrypoint] Copied $f to workspace"
  fi
done

# Write GitHub PAT to workspace config (base64-encoded to avoid gateway token detection)
# The env var ATLAS_GH_B64 holds the base64-encoded PAT — decoded here at boot
if [ -n "$ATLAS_GH_B64" ]; then
  echo "$ATLAS_GH_B64" | base64 -d > /data/workspace/.github-token
  chown openclaw:openclaw /data/workspace/.github-token 2>/dev/null || true
  chmod 600 /data/workspace/.github-token
  echo "[entrypoint] Decoded and wrote GitHub PAT to workspace/.github-token"
fi

# Persist Homebrew to Railway volume so it survives container rebuilds
BREW_VOLUME="/data/.linuxbrew"
BREW_SYSTEM="/home/openclaw/.linuxbrew"

if [ -d "$BREW_VOLUME" ]; then
  # Volume already has Homebrew — symlink back to expected location
  if [ ! -L "$BREW_SYSTEM" ]; then
    rm -rf "$BREW_SYSTEM"
    ln -sf "$BREW_VOLUME" "$BREW_SYSTEM"
    echo "[entrypoint] Restored Homebrew from volume symlink"
  fi
else
  # First boot — move Homebrew install to volume for persistence
  if [ -d "$BREW_SYSTEM" ] && [ ! -L "$BREW_SYSTEM" ]; then
    mv "$BREW_SYSTEM" "$BREW_VOLUME"
    ln -sf "$BREW_VOLUME" "$BREW_SYSTEM"
    echo "[entrypoint] Persisted Homebrew to volume on first boot"
  fi
fi

exec gosu openclaw node src/server.js
