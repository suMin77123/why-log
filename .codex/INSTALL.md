# Installing Why Log for Codex

Enable why-log skills in Codex via native skill discovery. Just clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the why-log repository:**
   ```bash
   git clone https://github.com/suMin77123/why-log.git ~/.codex/why-log
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/why-log/skills ~/.agents/skills/why-log
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\why-log" "$env:USERPROFILE\.codex\why-log\skills"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## Verify

```bash
ls -la ~/.agents/skills/why-log
```

You should see a symlink (or junction on Windows) pointing to your why-log skills directory.

## Updating

```bash
cd ~/.codex/why-log && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/why-log
```

Optionally delete the clone: `rm -rf ~/.codex/why-log`.
