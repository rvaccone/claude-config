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

# Format a Unix epoch reset time using the given date(1) format string.
fmt_reset() {
	local epoch="$1" fmt="$2"
	[ -n "$epoch" ] || return
	date -r "$epoch" "+$fmt" 2>/dev/null | tr '[:upper:]' '[:lower:]'
}

parts=()

if [ -n "$model" ]; then
	parts+=("$model")
fi

if [ -n "$effort" ]; then
	parts+=("effort: $effort")
fi

if [ -n "$used" ] && [ -n "$remaining" ]; then
	used_int=$(printf "%.0f" "$used")
	ctx_str="ctx: ${used_int}%"
	parts+=("$ctx_str")
fi

if [ -n "$five_hr" ]; then
	str="5h: $(printf '%.0f' "$five_hr")%"
	r=$(fmt_reset "$five_reset" '%-I:%M%p')
	[ -n "$r" ] && str="$str (resets $r)"
	parts+=("$str")
fi
if [ -n "$seven_day" ]; then
	str="7d: $(printf '%.0f' "$seven_day")%"
	r=$(fmt_reset "$seven_reset" '%a %-I%p')
	[ -n "$r" ] && str="$str (resets $r)"
	parts+=("$str")
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
