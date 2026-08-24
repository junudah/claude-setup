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

# ask_choice_inline "Question" "opt1 opt2 opt3" "default" → prints the chosen option
ask_choice_inline() {
  local prompt="$1" default="${3:-}"
  local -a opts=($2)
  local answer
  while true; do
    printf "  ${C_CYAN}?${C_RESET}  $prompt (${opts[*]}) [$default] : " >&2
    read -r answer </dev/tty
    answer="${answer:-$default}"
    for o in "${opts[@]}"; do
      if [ "$answer" = "$o" ]; then echo "$o"; return 0; fi
    done
    printf "  ${C_CYAN}!${C_RESET}  Réponse attendue : ${opts[*]}\n" >&2
  done
}
