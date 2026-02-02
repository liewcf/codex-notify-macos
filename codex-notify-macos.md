# Codex CLI completion sound + macOS notification (iTerm2 friendly)

This guide shows how to make **OpenAI Codex CLI** play a **sound** and show a **macOS notification** when a task completes, using the Codex CLI **`notify` hook**.

It’s designed for people running Codex CLI inside **iTerm2** (or any terminal on macOS).

---

## What you’ll get

When Codex finishes a task, you’ll get:

- A **reliable audible sound** (via `afplay`)
- A **Notification Center banner** (via `osascript`)

Why both?
- `afplay` is the most consistent way to ensure you actually hear something.
- `osascript` gives you a visible alert.

---

## Requirements

- macOS (tested on recent macOS versions)
- Codex CLI installed and working
- A shell like `zsh` or `bash`

---

## Step 1) Create a notify script

Create a script at:

- `~/.codex/notify-macos.sh`

You can do it with:

```bash
mkdir -p ~/.codex
nano ~/.codex/notify-macos.sh
```

Paste this script:

```bash
#!/bin/bash
set -euo pipefail

# Codex passes a JSON payload to the notify hook (often as the last argument).
# Keep it around if you want to log/parse later.
payload=""
if [ "$#" -gt 0 ]; then
  payload="${!#}"
fi

TITLE="Codex CLI"
BODY="Task finished"
SOUND_FILE="/System/Library/Sounds/Submarine.aiff"

# 1) Play a sound (reliable, non-blocking)
if command -v afplay >/dev/null 2>&1 && [ -f "$SOUND_FILE" ]; then
  afplay "$SOUND_FILE" >/dev/null 2>&1 &
fi

# 2) Show a macOS notification
/usr/bin/osascript -e "display notification \"$BODY\" with title \"$TITLE\"" >/dev/null 2>&1
```

### Notes
- The `&` runs `afplay` in the background so your hook returns immediately.
- `>/dev/null 2>&1` hides errors (for example, if a sound file can’t be played).
- If you’re debugging, you can log `payload` (but avoid dumping sensitive content).

---

## Step 2) Make the script executable

```bash
chmod +x ~/.codex/notify-macos.sh
```

---

## Step 3) Configure Codex CLI to call the script

Open your Codex config:

```bash
code ~/.codex/config.toml
```

Add (or update) this line:

```toml
notify = ["/bin/bash", "/Users/<your-username>/.codex/notify-macos.sh"]
```

### Important: `~` expansion
If the hook doesn’t fire, it’s often because `~` wasn’t expanded.

If `~` works in your setup, this is equivalent:

```toml
notify = ["/bin/bash", "~/.codex/notify-macos.sh"]
```

**Mask your username** when you publish docs or screenshots:
- Use `/Users/<your-username>/...` or `$HOME/...`
- Avoid showing your real macOS account name

---

## Step 4) Test it

### 4.1 Test the script directly

```bash
~/.codex/notify-macos.sh '{}'
```

You should hear a sound and see a notification.

### 4.2 Test via Codex

Run a short Codex task (anything that completes quickly). When the task finishes, you should get the sound + notification.

---

## Customization

### Change the sound file used by `afplay`

List available system sounds:

```bash
ls /System/Library/Sounds
```

Then swap the file:

```bash
afplay /System/Library/Sounds/Ping.aiff >/dev/null 2>&1 &
```

### Change the notification title and body

Edit this line:

```bash
/usr/bin/osascript -e 'display notification "Task finished" with title "Codex CLI"'
```

Examples:

```bash
/usr/bin/osascript -e 'display notification "Agent turn complete" with title "Codex"'
```

### Add a notification sound (less reliable than `afplay`)

Some systems will also play a notification sound via AppleScript:

```bash
/usr/bin/osascript -e 'display notification "Task finished" with title "Codex CLI" sound name "Submarine"' >/dev/null 2>&1
```

### Remove the notification sound (keep banner, keep `afplay`)

```bash
/usr/bin/osascript -e 'display notification "Task finished" with title "Codex CLI"' >/dev/null 2>&1
```

### Make it blocking (generally not recommended)

Remove the `&`:

```bash
afplay /System/Library/Sounds/Submarine.aiff 2>/dev/null
```

This makes the notify hook wait until the sound finishes before returning.

---

## Troubleshooting

### No sound plays
1. Try playing the sound manually:

   ```bash
   afplay /System/Library/Sounds/Submarine.aiff
   ```

2. Check macOS output device:
   - System Settings → Sound → Output

3. Check Focus / Do Not Disturb:
   - Focus can suppress notifications, and sometimes associated sounds.

4. Ensure the script is executable:

   ```bash
   ls -l ~/.codex/notify-macos.sh
   ```

You should see `-rwx...` (the `x` means executable).

### Notification appears but no sound
- Keep `afplay` enabled if you want reliable audio regardless of notification settings.

### No notification appears
1. Try a notification manually:

   ```bash
   /usr/bin/osascript -e 'display notification "Test" with title "Codex CLI"'
   ```

2. Check notification settings:
   - System Settings → Notifications (the banner may show up under **Script Editor** or **Terminal**, depending on macOS).

3. Check Focus / Do Not Disturb:
   - Focus can suppress notifications (and associated sounds).

### The hook doesn’t run at all
1. Ensure the `notify` line is actually in `~/.codex/config.toml`.
2. Try using an absolute path in the TOML (no `~`).
3. Add logging to confirm execution:

   ```bash
   echo "$(date) notify fired" >> /tmp/codex-notify.log
   ```

   Put that line at the top of the script, run Codex once, then check:

   ```bash
   tail -n 20 /tmp/codex-notify.log
   ```

### Lots of “done” job messages in your terminal
That’s your shell reporting background jobs finishing (because of `&`). This is uncommon when Codex runs the hook (non-interactive), but you might see it when testing in an interactive shell.

If you find it noisy, you can silence job notifications in `zsh`:

```bash
setopt NO_NOTIFY
```

Put it in your `~/.zshrc` if you want it permanently.

---

## Security & privacy notes

- The script runs locally on your Mac and only triggers a sound + notification.
- If you add logging, avoid writing sensitive prompt content to logs.
- When publishing, mask paths:
  - Use `$HOME` or `/Users/<your-username>/...`

---

## License

Use any license you like. For a tiny script guide, many people choose MIT.
