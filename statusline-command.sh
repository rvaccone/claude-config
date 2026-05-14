#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

parts=()

if [ -n "$model" ]; then
	parts+=("$model")
fi

if [ -n "$used" ] && [ -n "$remaining" ]; then
	used_int=$(printf "%.0f" "$used")
	ctx_str="ctx: ${used_int}%"
	parts+=("$ctx_str")
fi

if [ -n "$five_hr" ]; then
	parts+=("5h: $(printf '%.0f' "$five_hr")%")
fi
if [ -n "$seven_day" ]; then
	parts+=("7d: $(printf '%.0f' "$seven_day")%")
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
