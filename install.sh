#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

FILES=(settings.json keybindings.json .prettierrc)

mkdir -p "$CLAUDE_DIR"

copied=()
backed_up=()

for file in "${FILES[@]}"; do
	src="$SCRIPT_DIR/$file"
	dst="$CLAUDE_DIR/$file"

	if [[ ! -f "$src" ]]; then
		echo "  skip  $file (not in repo)"
		continue
	fi

	if [[ -f "$dst" ]] && ! diff -q "$src" "$dst" >/dev/null 2>&1; then
		backup="$dst.bak.$TIMESTAMP"
		cp "$dst" "$backup"
		backed_up+=("$file → $(basename "$backup")")
	fi

	cp "$src" "$dst"
	copied+=("$file")
done

echo ""
if [[ ${#backed_up[@]} -gt 0 ]]; then
	echo "Backed up:"
	for b in "${backed_up[@]}"; do echo "  $b"; done
fi

echo "Copied to ~/.claude/:"
for f in "${copied[@]}"; do echo "  $f"; done

echo ""
echo "Done. Re-run ./install.sh after pulling changes."
