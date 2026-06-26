#!/usr/bin/env bash
log_step()  { printf "\n${C_BCYAN}[%s]${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$1" "$2"; }
log_ok()    { printf "  ${C_GREEN}✓${C_RESET}  %s\n" "$1"; }
log_skip()  { printf "  ${C_DIM}—  %s${C_RESET}\n" "$1"; }
log_info()  { printf "  ${C_CYAN}→${C_RESET}  %s\n" "$1"; }
log_warn()  { printf "  ${C_YELLOW}⚠${C_RESET}  %s\n" "$1"; }
log_err()   { printf "  ${C_RED}✗${C_RESET}  %s\n" "$1" >&2; }
log_done()  { printf "  ${C_GREEN}✓ DONE${C_RESET}  %s\n\n" "$1"; }
log_section(){ printf "\n${C_ORANGE}═══ %s ═══${C_RESET}\n" "$1"; }
