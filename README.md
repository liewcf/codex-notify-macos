# codex-notify-macos

A small, copy-pasteable guide to make **OpenAI Codex CLI** play a **completion sound** and show a **macOS notification** using the Codex CLI `notify` hook.

## What's inside

- `setup-codex-notify.sh` — **Auto-setup script** (recommended)
  - Interactive feature selection (sound / notification / both)
  - Automatic backup of existing scripts
- `codex-notify-macos.md` — Full step-by-step guide (manual setup + troubleshooting)

## Quick start (Auto-setup)

Run the setup script to automatically configure everything:

```bash
chmod +x setup-codex-notify.sh
./setup-codex-notify.sh
```

### Prereqs

- macOS
- OpenAI Codex CLI installed and working

### What it does

1. **Select features** — choose which notifications to enable:
   - Sound notification (via `afplay`)
   - macOS notification banner (via `osascript`)

2. **Backup existing** — backs up your current script before overwriting

3. **Configure** — creates/updates `~/.codex/config.toml`

4. **Test** — optionally sends a test notification

## Manual setup

If you prefer to set up manually:

1. Create the script:

   ```bash
   mkdir -p ~/.codex
   nano ~/.codex/notify-macos.sh
   ```

   Use your editor of choice if you prefer.

2. Paste the script from `codex-notify-macos.md`, then:

   ```bash
   chmod +x ~/.codex/notify-macos.sh
   ```

3. Add to `~/.codex/config.toml`:

   ```toml
   notify = ["/bin/bash", "/Users/<your-username>/.codex/notify-macos.sh"]
   ```

   (If `~` expansion works in your setup, `~/.codex/notify-macos.sh` is equivalent. `$HOME/.codex/notify-macos.sh` is also OK.)

4. Test:

   ```bash
   ~/.codex/notify-macos.sh '{}'
   ```

## Uninstallation

To remove the setup:

1. Remove the hook from `~/.codex/config.toml`

2. Delete the script:

   ```bash
   rm -f ~/.codex/notify-macos.sh
   ```

3. (Optional) Remove backups created by the setup script:

   ```bash
   rm -f ~/.codex/notify-macos.sh.bak*
   rm -f ~/.codex/config.toml.backup.*
   ```

## Contributing

PRs welcome for:
- more robust payload parsing
- alternate notification methods
- Linux equivalents

## License

MIT License — see [LICENSE](LICENSE) file.
