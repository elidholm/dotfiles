# Copilot Instructions

## Overview

Ansible-based dotfiles manager targeting Ubuntu/Debian. Running `dotfiles` (or `bash bin/dotfiles`) bootstraps and idempotently applies the full environment. The `bin/dotfiles` script handles prerequisites (Ansible, Python, SSH keys), clones the repo, updates Galaxy dependencies, and runs `main.yml`.

## Lint & Check Commands

```bash
# Ansible lint
ansible-galaxy install -r requirements/common.yml
ansible-lint

# YAML lint
yamllint .

# Shell scripts
shellcheck -e SC1091 -e SC1090 bin/dotfiles

# Python (callback_plugins only)
ruff check callback_plugins/
```

There are no automated tests — validate changes by running the playbook with `--check` or against a live system.

## Running the Playbook

```bash
# Full run
dotfiles

# Single role/tag
dotfiles -- --tags git

# Multiple tags
dotfiles -- --tags "git,neovim"

# Debug (verbose + show commands)
dotfiles --debug

# Skip git pull
dotfiles --skip-update
```

## Architecture

```text
main.yml               # Top-level playbook (localhost, connection: local)
group_vars/
  all.yml              # User config: default_roles, vault-encrypted secrets, bash_public/bash_private
  work.yml             # Optional work config; loaded automatically if present
pre_tasks/             # Version guard + host user detection (run with `always` tag)
roles/                 # One directory per tool (30+ roles)
requirements/
  common.yml           # Ansible Galaxy dep: community.general
bin/dotfiles           # Bootstrap script (also the CLI entry point post-install)
callback_plugins/
  beautiful_output.py  # Custom stdout callback for formatted playbook output
```

**Role execution flow** in `main.yml`:

1. Pre-tasks always run (Ansible version check, optional `work.yml` inclusion, user detection).
2. `run_roles` is computed: if specific tags were passed they are used directly; otherwise `default_roles` minus `exclude_roles`.
3. Roles are included dynamically via `include_role` with a matching tag applied, so `--tags <name>` runs exactly that role.

## Role Conventions

Every role follows the same two-file task pattern:

```text
roles/<name>/
  tasks/
    main.yml      # Entry point; imports ubuntu.yml when ansible_os_family == 'Debian'
    ubuntu.yml    # Debian/Ubuntu-specific installation steps
  files/          # Static files (often symlinked into $HOME or $XDG_CONFIG_HOME)
  templates/      # Jinja2 templates rendered from group_vars variables
  meta/           # Galaxy metadata / dependencies
  handlers/       # (optional) Service restart/reload handlers
```

**Dotfile delivery pattern:**

- Config files are **symlinked** (not copied) from `roles/<name>/files/` into `~/.config/<name>/` or `~/.*`. Use `ansible.builtin.file` with `state: link` and `force: true`.
- Templates (`.j2`) are rendered from `group_vars` vars and written to `~/.config/bash/` — used for `bash_public` / `bash_private` env files.

## Configuration Variables (`group_vars/all.yml`)

| Variable | Purpose |
| -------- | ------- |
| `default_roles` | Ordered list of roles to run by default |
| `exclude_roles` | Roles to skip (user-overridable) |
| `git_user_name` / `git_user_email` | Required; passed to git config tasks |
| `ssh_key` | Dict of `<filename>: !vault \|` entries → written to `~/.ssh/` |
| `bash_public` | Key-value pairs rendered into `~/.config/bash/.bash_public` |
| `bash_private` | Vault-encrypted key-value pairs → `~/.config/bash/.bash_private` |
| `system_host` | Entries appended to `/etc/hosts` |
| `neovim_verison` | Neovim release channel (note: typo in variable name is intentional/existing) |

**Optional work config:** `group_vars/work.yml` is loaded when it exists. Defines `work_env` (triggers the bash work config block) and optionally overrides any `all.yml` variable.

## Ansible Vault

Secrets use the `!vault |` YAML tag. The vault password file lives at `~/.ansible-vault/vault.secret` and is auto-detected by the `bin/dotfiles` script.

To encrypt a new secret:

```bash
ansible-vault encrypt_string --vault-password-file ~/.ansible-vault/vault.secret "mysecret" --name "MY_VAR"
```

Tasks that handle secrets must set `no_log: true`.

## YAML Style

- Max line length: 160 (warning only).
- Truthy values: `true`/`false`, `yes`/`no`, `on`/`off` are all permitted.
- Inline comments require only 1 space before `#`.
- All YAML files must start with `---`.

## Adding a New Role

1. Create `roles/<name>/tasks/main.yml` and `roles/<name>/tasks/ubuntu.yml`.
2. Add `<name>` to `default_roles` in `group_vars/all.yml`.
3. Use `become: true` for any task requiring root; use `ansible.builtin.package` for apt installs with `update_cache: true`.
4. Prefer `ansible.builtin.file state: link force: true` over copying config files.
5. Add `no_log: true` to any task that touches vault-encrypted variables.

---

## Role Deep-Dives

### Neovim

**Installation:** installed via `community.general.snap` (classic) — not apt. The `neovim_verison` variable in `group_vars/all.yml` sets the snap channel (default: `stable`). Note the typo in the variable name — do not rename it without updating every reference.

**Config delivery:** `roles/neovim/files/` is symlinked wholesale to `~/.config/nvim/`. Editing any file under `roles/neovim/files/` takes effect immediately in the running editor.

**Config layout:**

```text
roles/neovim/files/
  init.lua                  # Entry point — 10 numbered sections, loaded in order
  nvim-pack-lock.json       # vim.pack lock file (commit changes to this)
  lua/extra/
    config/
      globals.lua           # vim.g settings (leader = <Space>, have_nerd_font = true)
      options.lua           # vim.opt settings
      mappings.lua          # Global keymaps (no plugin dependencies)
      autocmd.lua           # Global autocommands
      work.lua              # Work-specific filetype overrides (currently: Taskfile → yaml)
    plugins/
      colorscheme.lua       # catppuccin mocha, transparent background
      conform.lua           # Formatter config + <leader>f keymap
      gitsigns.lua          # Gitsigns keymaps
      harpoon.lua           # Harpoon keymaps
      lint.lua              # nvim-lint config
      mini.lua              # mini.nvim module config
      render-markdown.lua   # render-markdown.nvim config
      telescope.lua         # Telescope setup and keymaps
      treesitter.lua        # Parser list and FileType autocmd for auto-attach
```

**Plugin manager:** uses Neovim's built-in `vim.pack` (not lazy.nvim or packer). Plugins are added with `vim.pack.add({...})` directly in `init.lua`. Build hooks run via a `PackChanged` autocmd at the top of `init.lua`.

**`init.lua` section order** (preserve when adding plugins):

1. Foundation (core settings, loaded from `extra.config.*`)
2. Plugin manager intro (PackChanged build hooks, `gh()` helper)
3. UI / Core UX (colorscheme, which-key, gitsigns, mini, todo-comments)
4. Search & Navigation (Telescope, Harpoon)
5. LSP (fidget, nvim-lspconfig, Mason, mason-lspconfig, mason-tool-installer)
6. Formatting (conform.nvim)
7. Autocomplete & Snippets (LuaSnip, blink.cmp, copilot.vim)
8. Treesitter
9. Extra plugins (vim-tmux-navigator, lazygit, nvim-autopairs, cloak, trouble, undotree, nvim-lint, render-markdown)
10. Work configs (`require("extra.config.work")`)

**LSP servers** (managed by Mason, configured via `vim.lsp.config` + `vim.lsp.enable`):

- `pyright`, `pylsp` — Python
- `rust_analyzer` — Rust
- `stylua` — Lua formatting tool (installed by mason-tool-installer, not used as LSP)
- `lua_ls` — Lua; formatting disabled (stylua handles it)

**Format-on-save** is opt-in by filetype in `conform.lua`. Currently enabled for: `lua`, `python`, `sh`, `rust`. Formatters: `stylua` (lua), `rustfmt` (rust), `isort` + `black` (python), `shfmt -i 2` (sh).

**Key globals:**

- `vim.g.mapleader = " "` (Space)
- `vim.g.maplocalleader = " "` (Space)
- `vim.g.have_nerd_font = true`

**Notable keymaps** (from `mappings.lua`):

| Key | Action |
| --- | ------ |
| `<leader>pv` | Open netrw (project view) |
| `<leader>y` / `<leader>Y` | Yank to system clipboard |
| `<leader>d` | Delete without yanking |
| `<leader>f` | Format buffer (conform) |
| `<leader>lg` | Open LazyGit |
| `<leader>tt` | Toggle Trouble diagnostics |
| `<leader>u` | Toggle Undotree |
| `<leader><leader>` | Source current file |

**Adding a new plugin:** add `vim.pack.add({ gh("owner/repo") })` in the appropriate section of `init.lua`, then add setup/keymaps inline or extract to a new file under `lua/extra/plugins/` and `require()` it from `init.lua`.

---

### Bash

**Shell config delivery:**

```text
roles/bash/files/
  .bashrc                   # Symlinked to ~/.bashrc
  .bash_profile             # Symlinked to ~/.bash_profile
  .inputrc                  # Symlinked to ~/.inputrc
  .dircolors                # Symlinked to ~/.dircolors
  bash/                     # Copied (not symlinked) to ~/.config/bash/
    *.sh                    # All sourced by .bashrc via glob: for file in ~/.config/bash/*.sh
  work/                     # Copied to ~/.config/bash/work/ only if work role files exist
    *.sh                    # Sourced separately after work env vars
```

**`.bashrc` source order:**

1. `/etc/bash.bashrc` (system global)
2. Bash completion
3. `starship init bash` (prompt)
4. `pyenv virtualenv-init -`
5. `dircolors`
6. autojump
7. `~/.config/bash/.bash_private` (vault-rendered env vars)
8. `~/.config/bash/.bash_public` (plain env vars)
9. All `~/.config/bash/*.sh` (alias/function files, glob order)
10. Work env vars and `~/.config/bash/work/*.sh` (only if work dir exists)
11. NVM, Cargo, ghcup, fzf, sdkman (tool-specific inits)

**Auto-launch tmux:** `.bashrc` auto-execs into a tmux session for every new interactive shell that isn't already inside tmux. This means `exec tmux` runs before anything else on login.

**Alias conventions:** each concern gets its own `*.sh` file in `roles/bash/files/bash/`. Notable aliased commands:

- `cat` → `bat`
- `rm` → `trash -v` (not system rm)
- `grep` → `grep --color=always`
- `mkdir` → `mkdir -p`
- `cp` / `mv` → interactive (`-i`)

**Adding a new alias/function file:** create `roles/bash/files/bash/<name>_aliases.sh` or `<name>_functions.sh` — it will be auto-sourced by `.bashrc` on next shell start without any further wiring. No changes to `tasks/main.yml` are needed.

**Environment variables:** do not hardcode env vars in `.bashrc` or the `*.sh` files. Add public vars to `bash_public` in `group_vars/all.yml` and secret vars to `bash_private` (vault-encrypted). They are rendered via Jinja2 templates into `~/.config/bash/.bash_public` / `.bash_private`.

**Work config:** `group_vars/work.yml` must define `work_env: true` to trigger the work bash block in `tasks/main.yml`. Work-specific shell files go in `roles/bash/files/work/`.

---

### Tmux

**Installation:** via `ansible.builtin.apt` (not snap). TPM (Tmux Plugin Manager) is cloned to `~/.tmux/plugins/tpm` via `ansible.builtin.git`. Config is symlinked from `roles/tmux/files/.tmux.conf` to `~/.tmux.conf`.

**Prefix key:** `C-a` (not the default `C-b`). `C-a` also sends the prefix to the underlying terminal; `a` jumps to the last window.

**Key bindings:**

| Key | Action |
| --- | ------ |
| `prefix + \|` | Split horizontal (current path) |
| `prefix + -` | Split vertical (current path) |
| `prefix + r` | Reload `~/.tmux.conf` |
| `prefix + h/j/k/l` | Resize pane (repeatable) |
| `prefix + m` | Toggle maximize pane |
| `prefix + C-p` / `C-n` | Previous / next window |
| `prefix + P` | Paste buffer |
| `v` (copy-mode) | Begin selection |
| `y` (copy-mode) | Copy selection to clipboard |

**Copy mode:** vi-keys (`mode-keys vi`). Mouse yank is enabled (`@yank_with_mouse on`).

**TPM plugins:**

- `tmux-sensible` — sane defaults
- `tmux-yank` — system clipboard integration
- `tmux-open` — open links/files from terminal
- `tmux-resurrect` — persist sessions across restarts (pane contents captured)
- `tmux-continuum` — auto-save and auto-restore sessions (`@continuum-restore on`)
- `vim-tmux-navigator` — unified `C-h/j/k/l` navigation across vim splits and tmux panes
- `catppuccin/tmux` — theme (macchiato flavour, rounded window style)

**Theme:** catppuccin macchiato. Status bar: left empty, right shows hostname. Window text uses `<space>#W` format (nerd font icon + window name).

**Neovim integration:** `vim-tmux-navigator` is installed in **both** tmux (`set -g @plugin 'christoomey/vim-tmux-navigator'`) and Neovim (`vim.pack.add({ gh("christoomey/vim-tmux-navigator") })`). Both must stay in sync.

**Adding/updating TPM plugins:** edit `roles/tmux/files/.tmux.conf`, add a `set -g @plugin '...'` line before the final `run '...tpm'` line, then reload with `prefix + r` and install with `prefix + I` inside a live tmux session.
