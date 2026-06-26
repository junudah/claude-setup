#!/usr/bin/env bash
# ask "Question" "default" → prints answer to stdout
ask() {
  local prompt="$1" default="${2:-}"
  local label="$prompt"
  [ -n "$default" ] && label="$prompt [$default]"
  printf "  ${C_CYAN}?${C_RESET}  $label : " >&2
  local answer
  read -r answer </dev/tty
  echo "${answer:-$default}"
}

# ask_yes_no "Question" "y" → returns 0 (yes) or 1 (no)
ask_yes_no() {
  local prompt="$1" default="${2:-y}"
  local hint="[Y/n]"
  [ "$default" = "n" ] && hint="[y/N]"
  printf "  ${C_CYAN}?${C_RESET}  $prompt $hint : " >&2
  local answer
  read -r answer </dev/tty
  answer="${answer:-$default}"
  [[ "$answer" =~ ^[Yy]$ ]]
}
