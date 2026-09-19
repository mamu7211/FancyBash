[[ $- == *i* ]] || return 0

HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth
HISTTIMEFORMAT='%F %T  '
shopt -s histappend cmdhist

_fancybash_history_sync() {
    local last_status=$?
    # Save this terminal's new commands before importing other terminals.
    if [[ -n ${HISTFILE:-} ]]; then
        builtin history -a
        builtin history -n
    fi
    return "$last_status"
}

[[ ${_FANCYBASH_HISTORY_LOADED:-} == 1 ]] && return 0
_FANCYBASH_HISTORY_LOADED=1
if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == 'declare -a '* ]]; then
    PROMPT_COMMAND+=(_fancybash_history_sync)
else
    PROMPT_COMMAND=("${PROMPT_COMMAND:-}" _fancybash_history_sync)
fi
