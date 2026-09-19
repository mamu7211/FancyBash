[[ $- == *i* ]] || return 0

_fancybash_visit_file() {
    printf '%s/fancybash/directories' "${XDG_DATA_HOME:-$HOME/.local/share}"
}

# A subshell keeps the lock, umask and cleanup traps local to this write.
_fancybash_record_visit() (
    local database directory temporary= entry lock_fd
    database=$(_fancybash_visit_file)
    directory=${database%/*}
    umask 077
    mkdir -p -- "$directory" || return
    exec {lock_fd}>"$database.lock" || return
    flock -x "$lock_fd" || return
    temporary=$(mktemp "$directory/.directories.XXXXXX") || return
    trap 'rm -f -- "$temporary"' EXIT
    trap 'exit 1' HUP INT TERM
    {
        printf '%s\0' "$PWD" || return
        if [[ -f $database ]]; then
            while IFS= read -r -d '' entry; do
                if [[ $entry != "$PWD" ]]; then
                    printf '%s\0' "$entry" || return
                fi
            done < "$database"
        fi
    } > "$temporary" || return
    # Readers see either the old complete file or the new complete file.
    mv -f -- "$temporary" "$database"
)

_fancybash_visit_hook() {
    local last_status=$?
    if [[ ${_FANCYBASH_LAST_DIRECTORY-} != "$PWD" ]]; then
        if _fancybash_record_visit; then
            _FANCYBASH_LAST_DIRECTORY=$PWD
        fi
    fi
    return "$last_status"
}

_fancybash_visit_candidates() {
    local database entry
    database=$(_fancybash_visit_file)
    [[ -f $database ]] || return 0
    while IFS= read -r -d '' entry; do
        [[ -d $entry ]] && printf '%s\0' "$entry"
    done < "$database"
    return 0
}

c() {
    if ! command -v fzf >/dev/null 2>&1; then
        printf 'FancyBash: Für c bitte fzf installieren.\n' >&2
        return 127
    fi
    local selection_file selected result
    local -a options=(--read0 --print0 --no-sort --exit-0
        --height=40% --layout=reverse --border=rounded --prompt='Verzeichnis > ')
    # No argument always offers a choice, even when only one directory exists.
    if (( $# > 0 )); then
        options+=(--select-1 --query="$*")
    fi
    selection_file=$(mktemp "${TMPDIR:-/tmp}/fancybash-selection.XXXXXX") || return
    # Keep global fzf options from changing output format or auto-selection.
    if FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE='' \
        fzf "${options[@]}" < <(_fancybash_visit_candidates) > "$selection_file"; then
        result=0
    else
        result=$?
    fi
    IFS= read -r -d '' selected < "$selection_file"
    rm -f -- "$selection_file"
    case $result in
        0) [[ -n $selected ]] && builtin cd -- "$selected" ;;
        1) printf 'FancyBash: Kein passendes besuchtes Verzeichnis.\n' >&2; return 1 ;;
        130) return 0 ;; # Escape / Ctrl+C: leave the current directory unchanged.
        *) return "$result" ;;
    esac
}

[[ ${_FANCYBASH_NAVIGATION_LOADED:-} == 1 ]] && return 0
_FANCYBASH_NAVIGATION_LOADED=1
if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == 'declare -a '* ]]; then
    PROMPT_COMMAND+=(_fancybash_visit_hook)
else
    PROMPT_COMMAND=("${PROMPT_COMMAND:-}" _fancybash_visit_hook)
fi
