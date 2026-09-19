# Main entry point; source from ~/.bashrc.
[[ $- == *i* ]] || return 0

_fancybash_load() {
    local directory
    directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || return
    source "$directory/history.bash"
    source "$directory/prompt.bash"
    source "$directory/fzf.bash"
    source "$directory/navigation.bash"
}
_fancybash_load
unset -f _fancybash_load
