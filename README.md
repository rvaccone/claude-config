# claude-config

Personal [Claude Code](https://claude.ai/code) configuration. Versioned so it can be reproduced on a new machine in one command.

## Install

```sh
git clone git@github.com:rvaccone/claude-config.git
cd claude-config
./install.sh
```

`install.sh` copies tracked files into `~/.claude/`. If a destination file already exists and differs, it's backed up as `<file>.bak.<timestamp>` before being overwritten.

## What's tracked

| File               | Purpose                                                             |
| ------------------ | ------------------------------------------------------------------- |
| `settings.json`    | Permissions allowlist, model, vim editor mode, Prettier hook, theme |
| `keybindings.json` | Custom key bindings (tab → cycle mode, ctrl+j/k → scroll)           |
| `.prettierrc`      | Prettier config (tabs, tabWidth 4) — drives the PostToolUse hook    |

## What's not tracked

-   `~/.claude.json` — MCP server credentials live here, **not** under `~/.claude/`. Never commit it.
-   `backups/`, `cache/`, `projects/`, `plugins/`, `todos/`, and all other runtime/ephemeral state — see `.gitignore`.
-   `settings.local.json` — machine-local overrides if you ever need them.
-   Skills (`~/.claude/skills/`) — managed separately at `~/.agents/skills/`.

## Updating

Edit files in the repo, then:

```sh
./install.sh
git add -p
git commit -m "..."
git push
```

## Security note

MCP server tokens (Neon, etc.) live in `~/.claude.json`, which is outside this directory and is gitignored. Never commit `~/.claude.json` or anything from `backups/` — those files contain live API credentials.
