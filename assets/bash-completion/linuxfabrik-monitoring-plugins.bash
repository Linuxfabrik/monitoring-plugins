# shellcheck shell=bash
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.
#
# Bash completion for the Linuxfabrik Monitoring Plugins.
#
# Completes the command line options of every plugin in the plugin directory, plus the
# allowed values of the options that take a fixed set of them. A plugin's options are read
# from its own `--help` output the first time that plugin is completed and are kept for the
# rest of the shell session, so what is offered can never disagree with what is installed,
# and no second copy of the option list has to be maintained anywhere.
#
# Set LFMP_PLUGIN_DIR before sourcing this file to complete plugins installed somewhere
# other than the default directory.


# Read the options of a single plugin into the session cache.
#
# The option block that argparse prints is machine-generated and unambiguous: an option
# starts in column three, its help text follows after at least two spaces, and wrapped help
# text is indented far deeper. That makes a single awk pass enough, and it keeps prose that
# happens to mention an option (`Example: --critical=5`) out of the result.
#
# Both argparse layouts are handled: `-c CRIT, --critical CRIT` (Python up to 3.12) and
# `-c, --critical CRIT` (Python 3.13 and newer). Each line of the cached table holds one
# option name and its argument spec, separated by a tab:
#
#   --always-ok
#   -c<TAB>CRIT
#   --critical<TAB>CRIT
#   --no-match-severity<TAB>{ok,warn,crit,unknown}
#
# Options the plugins hide with argparse.SUPPRESS (the deprecated ones and the internal
# test hook) never reach the help output, so they are never offered.
_lfmp_load() {
    local cmd="$1" target='' help=''

    [ -n "${_lfmp_cache[${cmd}]+set}" ] && return 0

    # A plugin called by its bare name cannot be asked directly: the plugin directory is
    # deliberately not in PATH, so the name resolves to nothing. Ask the copy in the plugin
    # directory instead, which is the one that name refers to.
    target="${cmd}"
    [ "${target}" = "${target#*/}" ] && target="${_lfmp_dir}/${target}"

    # `--help` leaves the plugins with the UNKNOWN exit code, not 0, so the status says
    # nothing about success and must not be treated as an error. The timeout keeps a plugin
    # that hangs on startup from freezing the shell; not every host has it installed.
    if [ -n "${_lfmp_timeout}" ]; then
        help=$(timeout 5s "${target}" --help 2>/dev/null) || :
    else
        help=$("${target}" --help 2>/dev/null) || :
    fi

    # No output at all means the command could not be run, for example because it is not a
    # plugin at all. That is not a result worth remembering: caching it would keep the
    # completion silent for the rest of the session even after the cause is fixed. An answer
    # without options, on the other hand, is a real answer and is cached like any other.
    [ -n "${help}" ] || return 0

    _lfmp_cache[${cmd}]=$(awk '
        /^  -/ {
            line = substr($0, 3)
            sub(/[ \t][ \t]+.*$/, "", line)   # cut the help text
            arg = ""
            n = split(line, parts, ", ")
            for (i = 1; i <= n; i++) {
                m = split(parts[i], token, " ")
                name[i] = token[1]
                if (m > 1) arg = token[2]     # metavar or {choice,choice}
            }
            for (i = 1; i <= n; i++) print name[i] "\t" arg
        }
    ' <<< "${help}")
}


# Complete one plugin invocation.
_lfmp() {
    # `words` and `cword` look unused here, but _init_completion assigns them and expects
    # the caller to have declared them local, so they do not leak into the shell.
    # shellcheck disable=SC2034
    local cur prev words cword split
    if declare -F _init_completion >/dev/null; then
        # -s splits `--option=value` into prev and cur for us.
        _init_completion -s || return
    else
        # Stand-in for a shell where bash-completion itself is not loaded.
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD - 1]}"
        split=false
    fi

    local cmd="${COMP_WORDS[0]}" name arg opts='' long_opts='' prev_arg=''
    _lfmp_load "${cmd}"

    while IFS=$'\t' read -r name arg; do
        [ -n "${name}" ] || continue
        opts="${opts} ${name}"
        case "${name}" in --*) long_opts="${long_opts} ${name}" ;; esac
        [ "${name}" = "${prev}" ] && prev_arg="${arg}"
    done <<< "${_lfmp_cache[${cmd}]-}"

    # The word before the cursor is an option that expects a value. Offer the allowed values
    # where the plugin names them, file names where the option asks for a path, and nothing
    # at all otherwise: a threshold or a host name has no candidates, and dumping the current
    # directory there is noise, not help.
    if [ -n "${prev_arg}" ]; then
        case "${prev_arg}" in
            \{*\})
                prev_arg="${prev_arg#\{}"
                prev_arg="${prev_arg%\}}"
                mapfile -t COMPREPLY < <(compgen -W "${prev_arg//,/ }" -- "${cur}")
                return 0
                ;;
        esac
        case "${prev}" in
            --*file | --*path | --*dir | --*device | --*cert | --*key)
                declare -F _filedir >/dev/null && _filedir
                ;;
        esac
        return 0
    fi

    ${split} && return 0

    if [ -z "${cur}" ]; then
        # Nothing typed yet. The plugins take no positional arguments, so an option is the
        # only thing that can follow. Only the long form is offered: every short option has
        # a long twin, and listing both doubles the menu without adding a choice.
        mapfile -t COMPREPLY < <(compgen -W "${long_opts}" -- '')
    elif [ "${cur#-}" != "${cur}" ]; then
        mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
    fi
    return 0
}


# Report whether a command of that name is reachable through PATH, ignoring the plugin
# directory itself in case someone added it to PATH.
_lfmp_shadowed() {
    local name="$1" candidate
    local IFS=:

    for candidate in ${PATH}; do
        [ -n "${candidate}" ] || candidate='.'
        [ "${candidate}" = "${_lfmp_dir}" ] && continue
        [ -f "${candidate}/${name}" ] && [ -x "${candidate}/${name}" ] && return 0
    done
    return 1
}


# Register the completion for every plugin found in the plugin directory.
#
# The plugin directory is not in PATH, so a plugin is usually called by its full path. Bash
# looks for a completion of the full path first and falls back to the part after the last
# slash, which is why both spellings are registered: the full path covers `/usr/lib64/...`,
# the bare name covers `./load` from inside the plugin directory and `load` on a host that
# put the directory in PATH. The bare name is skipped whenever a real command of that name
# exists (about ten plugins are named after the tool they check, among them `ping`, `uptime`
# and `users`), so the completions those commands ship with keep working.
_lfmp_register() {
    local plugin name

    [ -d "${_lfmp_dir}" ] || return 0

    for plugin in "${_lfmp_dir}"/*; do
        [ -f "${plugin}" ] && [ -x "${plugin}" ] || continue
        name="${plugin##*/}"
        complete -F _lfmp -- "${plugin}"
        _lfmp_shadowed "${name}" || complete -F _lfmp -- "${name}"
    done
}


declare -A _lfmp_cache
_lfmp_dir="${LFMP_PLUGIN_DIR:-/usr/lib64/nagios/plugins}"
_lfmp_timeout=''
type -P timeout >/dev/null 2>&1 && _lfmp_timeout='timeout'

_lfmp_register
unset -f _lfmp_register _lfmp_shadowed
