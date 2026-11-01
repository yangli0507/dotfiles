# Nix-Darwin Upgrade Plan

## Current State

| Component | Current (locked) | Latest Available |
|-----------|------------------|------------------|
| **nix-darwin** | `d31953cf` (2026-10-23) on `nix-darwin-26.05` | `d31953cf` — same (branch stable, no new commits since lock) |
| **nixpkgs** | `4fb45a87` (2026-10-06) on `nixpkgs-26.05-darwin` | `36173dbc` (2026-10-28) — **~22 days of package updates** |
| **home-manager** | `24f21905` (2026-10-22) on `release-26.05` | `24f21905` — same |
| **nix-homebrew** | `c11cccf` (2026-09-20) | `52bc87d` (2026-11-01) — **12 days** |
| **Homebrew (brew)** | `7.0.4` | `7.0.11` (from 7.0.4) — **6 minor releases** |
| **system stateVersion** | 6 | 6 (no change needed) |

### Key package updates in nixpkgs (4fb45a8 → 36173db)
Approximately 22 days of Nixpkgs stable commits including:
- Newer versions of all managed formulae (ripgrep, fd, fzf, git, python, node, etc.)
- Security patches across the board
- Potential library ABI updates (zlib, openssl, libffi, etc.)

### Homebrew 7.0.4 → 7.0.11
- Formulae rebuilds for new brew versions
- No known breaking changes for the brews/casks managed here

### Managed packages (safe to upgrade)

**Homebrew brews:** herdr, ripgrep, btop, fd, tree, nvm, uv, lsd, tldr, tree-sitter, tree-sitter-cli, fastfetch, lazygit, bun, zip, unzip

**Homebrew casks:** wezterm, claude-code, bazecor, iina, rectangle

**Home Manager packages:** treehouse, ripgrep, fd, fzf, jq, lazygit, neovim, nerd-fonts.hack, bat, zoxide, nodejs, python3Packages.huggingface-hub, ollama, ghostty-bin, tuios

**Config modules:** nix-darwin core, nix-homebrew, home-manager (no module API changes in 26.05 branch)

---

## Upgrade Steps

### 0. Pre-flight: create a snapshot (backup)
> **Note:** These commands require your password. Run them in your terminal.

```bash
# Snapshot the current system for rollback (requires sudo)
sudo ln -sfn /nix/var/nix/profiles/system-64-link /nix/var/nix/profiles/system-rollback

# Verify the snapshot points to current system
readlink /nix/var/nix/profiles/system-rollback
# Should point to system-64-link (matching current /nix/var/nix/profiles/system)

# The flake.lock backup is already staged in git:
# ~/github/dotfiles/flake.lock.bak.before_upgrade
```

**Verification checklist (run these yourself):**
```bash
# Confirm the rollback link exists and points correctly:
readlink -f /nix/var/nix/profiles/system-rollback
# Should show: /nix/store/...darwin-system-26.05.d31953c
```

### 1. Update the lock file (already done by `nix flake update --commit-lock-file`)
This was done on branch `nix_upgrade`. The flake.lock now references:
- nixpkgs: `36173dbc` (from `4fb45a87`)
- nix-homebrew: `52bc87d` (from `c11cccf`)
- nix-homebrew/brew-src: `c6069d2` (from `edb70f0`)
- oh-my-pi: `af24c93` (from `6f3fbc9`)
- treehouse: `f168807` (from `a2651e7`)

### 2. Evaluate / dry-run the build
```bash
# This will NOT switch the system — only evaluate and build
sudo darwin-rebuild build --flake ~/.dotfiles#mac
```
If this fails, **do not proceed**. Fix errors in configuration before switching.

### 3. Switch the system
```bash
# Rebuild and activate
sudo darwin-rebuild switch --flake ~/.dotfiles#mac
```

### 4. Post-switch verification
```bash
# Check the system version updated
darwin-version
# Should show: 26.05.36173db (or similar)

# Verify key tools still work
which nvim git node python3 neovim lazygit rg fd fzf

# Check Homebrew packages
brew update
brew list | head -20

# Check cask apps
ls /Applications/ | grep -E 'wezterm|claude|iina|rectangle'

# Restart a shell to pick up new environment
zsh
```

### 5. Commit the updated lock file (if evaluation passed)
```bash
cd ~/github/dotfiles
git add flake.lock
git commit -m "chore: bump nixpkgs to 36173db, nix-homebrew to 52bc87d, homebrew 7.0.4→7.0.11"
git push origin nix_upgrade
```

---

## Rollback Plan

If the upgrade fails (build errors, runtime breakage, package incompatibilities):

### Option A: Quick rollback (restore previous boot entry)
```bash
# Point the system symlink back to the previous version
sudo rm /nix/var/nix/profiles/system
sudo ln -sfn /nix/var/nix/profiles/system-64-link /nix/var/nix/profiles/system

# Boot into the previous system by restarting
sudo reboot
# (GRUB-style boot menu won't apply here — darwin just follows the symlink)
```

### Option B: Rollback using the snapshot (if Option A symlink was lost)
```bash
# Restore from the snapshot created in Step 0
sudo rm /nix/var/nix/profiles/system
sudo ln -sfn /nix/var/nix/profiles/system-rollback /nix/var/nix/profiles/system
sudo reboot
```

### Option C: Revert the flake.lock (if build fails and we need to re-apply the old config)
```bash
cd ~/github/dotfiles
# Restore the original lock file
cp flake.lock.bak.before_upgrade flake.lock
# Then rebuild with the old lock
sudo darwin-rebuild switch --flake ~/.dotfiles#mac
```

### Rollback verification
```bash
# Confirm we're back to the old version
darwin-version
# Should show 26.05.d31953c (the pre-upgrade revision)
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Build fails due to API change | Low | High (can't boot) | flake.lock.bak + rollback symlink |
| Homebrew formula update breaks a formula | Low | Medium (missing tool) | Rollback Homebrew to 7.0.4 by reverting brew-src ref in lock |
| Nixpkgs library ABI bump breaks a binary | Very Low | Medium | Rollback to previous nixpkgs revision |
| home-manager config incompatibility | Very Low | High (no shell) | Current 26.05 branch has no home-manager API changes |
| nix-homebrew module changes | Low | Medium | Tested: no API changes in 52bc87d vs c11cccf |

### Known nix-darwin CHANGELOG changes since current revision (none apply)
- `tmux.splitWindow` bindings change requires `stateVersion ≥ 7` — we're on 6, so no effect
- `homebrew.brewPrefix → homebrew.prefix` rename — **not using this option**, no effect
- Activation running as root — **already compatible** (rebuild.sh already uses `sudo`)
- `nix.enable` toggle — **already set to `false`**, no effect

---

## Files Modified by This Upgrade

| File | Change |
|------|--------|
| `flake.lock` | Updated `nixpkgs`, `nix-homebrew`, `nix-homebrew/brew-src`, `oh-my-pi`, `treehouse` refs |

**No configuration.nix or home.nix changes required.**

---

## Homebrew Packages Not Managed by Nix (rollback note)

The `homebrew.onActivation.cleanup = "zap"` setting means Homebrew will remove any packages NOT in the brews/casks list during activation. This is intentional and documented. No rollback concern for Homebrew-specific packages.
