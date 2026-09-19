[[ $- == *i* ]] || return 0
[[ ${_FANCYBASH_FZF_LOADED:-} == 1 ]] && return 0
command -v fzf >/dev/null 2>&1 || return 0

_fancybash_load_fzf() {
    # Enable history search, leaving Ctrl+T and Alt+C available as before.
    local FZF_CTRL_T_COMMAND='' FZF_ALT_C_COMMAND='' integration
    if integration=$(fzf --bash 2>/dev/null); then
        eval "$integration"
    elif [[ -r /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash
    elif [[ -r /usr/share/fzf/key-bindings.bash ]]; then
        source /usr/share/fzf/key-bindings.bash
    else
        return 1
    fi
}

if _fancybash_load_fzf; then
    export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS---height=40% --layout=reverse --border=rounded}"
    _FANCYBASH_FZF_LOADED=1
fi
unset -f _fancybash_load_fzf
