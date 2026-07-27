#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

# Format a Unix epoch reset time using the given date(1) format string.
fmt_reset() {
	local epoch="$1" fmt="$2"
	[ -n "$epoch" ] || return
	date -r "$epoch" "+$fmt" 2>/dev/null | tr '[:upper:]' '[:lower:]'
}

# Colorize a percentage by how alarming it is. Under 50% stays theme-default so
# the common case adds no visual noise.
PCT_WARN=50
PCT_CRIT=80
ANSI_WARN=$'\033[38;5;179m' # muted gold
ANSI_CRIT=$'\033[38;5;203m' # soft red
ANSI_OFF=$'\033[0m'

color_pct() {
	local value="$1" text="$2"
	if [ "$value" -ge "$PCT_CRIT" ]; then
		printf '%s%s%s' "$ANSI_CRIT" "$text" "$ANSI_OFF"
	elif [ "$value" -ge "$PCT_WARN" ]; then
		printf '%s%s%s' "$ANSI_WARN" "$text" "$ANSI_OFF"
	else
		printf '%s' "$text"
	fi
}

# Current branch, or short SHA when detached. Resolved via git rather than the
# payload so it stays correct inside worktrees.
git_branch() {
	local dir="$1" branch
	[ -n "$dir" ] || return
	branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null) || return
	if [ "$branch" = "HEAD" ]; then
		branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null) || return
	fi
	printf '%s' "$branch"
}

# Nerd Font glyphs (Font Awesome legacy range — stable across Nerd Font versions).
GLYPH_DIR=$''     # folder
GLYPH_BRANCH=$''  # code-fork
GLYPH_MODEL=$''   # cube
GLYPH_EFFORT=$''  # bolt
GLYPH_CTX=$''     # pie-chart
GLYPH_5H=$''      # clock
GLYPH_7D=$''      # calendar
GLYPH_RESET=$''   # refresh

parts=()

if [ -n "$model" ]; then
	parts+=("$GLYPH_MODEL $model")
fi

if [ -n "$effort" ]; then
	parts+=("$GLYPH_EFFORT $effort")
fi

if [ -n "$used" ] && [ -n "$remaining" ]; then
	used_int=$(printf "%.0f" "$used")
	ctx_str="$GLYPH_CTX $(color_pct "$used_int" "${used_int}%")"
	parts+=("$ctx_str")
fi

if [ -n "$five_hr" ]; then
	five_int=$(printf '%.0f' "$five_hr")
	str="$GLYPH_5H $(color_pct "$five_int" "${five_int}%")"
	r=$(fmt_reset "$five_reset" '%-I:%M%p')
	[ -n "$r" ] && str="$str $GLYPH_RESET $r"
	parts+=("$str")
fi
if [ -n "$seven_day" ]; then
	seven_int=$(printf '%.0f' "$seven_day")
	str="$GLYPH_7D $(color_pct "$seven_int" "${seven_int}%")"
	r=$(fmt_reset "$seven_reset" '%a %-I%p')
	[ -n "$r" ] && str="$str $GLYPH_RESET $r"
	parts+=("$str")
fi

if [ -n "$cwd" ]; then
	parts+=("$GLYPH_DIR $(basename "$cwd")")
fi

branch=$(git_branch "$cwd")
if [ -n "$branch" ]; then
	parts+=("$GLYPH_BRANCH $branch")
fi

result=""
for part in "${parts[@]}"; do
	if [ -n "$result" ]; then
		result="$result | $part"
	else
		result="$part"
	fi
done
printf "%s" "$result"
