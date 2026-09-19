# Source this file from an interactive Bash session.
[[ $- == *i* ]] || return 0

# Rounded Powerline separator (Hurmit / Nerd Font).
_FANCYBASH_SEPARATOR=$'\ue0b4'

_fancybash_segment() {
    local background=$1 foreground=$2 label=$3
    if [[ -n $_FANCYBASH_BACKGROUND ]]; then
        PS1+="\[\e[38;5;${_FANCYBASH_BACKGROUND};48;5;${background}m\]"
        PS1+='${_FANCYBASH_SEPARATOR}'
    fi
    PS1+="\[\e[38;5;${foreground};48;5;${background}m\] ${label} "
    _FANCYBASH_BACKGROUND=$background
}

_fancybash_git_status() {
    local record branch= oid= xy old_path ahead=0 behind=0
    local staged=0 modified=0 untracked=0 conflicts=0
    _FANCYBASH_GIT=
    _FANCYBASH_GIT_COLOR=70
    command -v git >/dev/null 2>&1 || return 0
    # NUL records also handle filenames with newlines and rename source paths.
    while IFS= read -r -d '' record; do
        case $record in
            '# branch.head '*) branch=${record#\# branch.head } ;;
            '# branch.oid '*) oid=${record#\# branch.oid } ;;
            '# branch.ab '*)
                read -r ahead behind <<< "${record#\# branch.ab }"
                ahead=${ahead#+}; behind=${behind#-}
                ;;
            '1 '*|'2 '*)
                xy=${record:2:2}
                [[ ${xy:0:1} != . ]] && ((staged+=1))
                [[ ${xy:1:1} != . ]] && ((modified+=1))
                [[ $record == '2 '* ]] && IFS= read -r -d '' old_path
                ;;
            'u '*) ((conflicts+=1)) ;;
            '? '*) ((untracked+=1)) ;;
        esac
    done < <(git --no-optional-locks status --porcelain=v2 -z --branch \
        --untracked-files=all 2>/dev/null)
    [[ -n $branch ]] || return 0
    [[ $branch == '(detached)' ]] && branch="@${oid:0:7}"
    # Expand repository-controlled text only as data in PS1.
    _FANCYBASH_GIT=${branch//[[:cntrl:]]/}
    (( staged > 0 )) && _FANCYBASH_GIT+=" +$staged"
    (( modified > 0 )) && _FANCYBASH_GIT+=" ~$modified"
    (( untracked > 0 )) && _FANCYBASH_GIT+=" ?$untracked"
    (( ahead > 0 )) && _FANCYBASH_GIT+=$' \uf01b'"$ahead"
    (( behind > 0 )) && _FANCYBASH_GIT+=$' \uf01a'"$behind"
    (( conflicts > 0 )) && _FANCYBASH_GIT+=$' \uef5b'"$conflicts"
    (( staged + modified + untracked > 0 )) && _FANCYBASH_GIT_COLOR=178
    (( conflicts > 0 )) && _FANCYBASH_GIT_COLOR=160
    return 0
}

_fancybash_prompt() {
    local last_status=$?
    _fancybash_git_status

    _FANCYBASH_STATUS=
    (( last_status != 0 )) && _FANCYBASH_STATUS="✗ $last_status"

    PS1='\[\e[0m\]'
    _FANCYBASH_BACKGROUND=
    if (( last_status != 0 )); then
        _fancybash_segment 160 255 '${_FANCYBASH_STATUS}'
    fi
    if (( EUID == 0 )); then
        _fancybash_segment 238 196 '\u@\h #'
    else
        _fancybash_segment 238 250 '\u@\h'
    fi
    _fancybash_segment 31 255 '\w'
    if [[ -n $_FANCYBASH_GIT ]]; then
        # Expand branch text as data, never as shell code.
        _fancybash_segment "$_FANCYBASH_GIT_COLOR" 232 $'\ue0a0 ${_FANCYBASH_GIT}'
    fi
    PS1+="\[\e[0;38;5;${_FANCYBASH_BACKGROUND}m\]"
    PS1+='${_FANCYBASH_SEPARATOR}\[\e[0m\] '
    return "$last_status"
}

# Refresh functions on source, but install the hook only once.
[[ ${_FANCYBASH_LOADED:-} == 1 ]] && return 0
_FANCYBASH_LOADED=1

# Run first to capture the command status; retain existing prompt hooks.
if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == 'declare -a '* ]]; then
    PROMPT_COMMAND=(_fancybash_prompt "${PROMPT_COMMAND[@]}")
else
    PROMPT_COMMAND=(_fancybash_prompt "${PROMPT_COMMAND:-}")
fi
