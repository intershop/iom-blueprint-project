# returns $command if $input is somewhere between $prefix and $command, otherwise false is returned.
_devenv_is_command() {
    local input prefix command
    # remove everything from $input, that cannot be accepted
    input=$(echo "$1" | sed 's/[^a-zA-Z-]//g')
    prefix="$2"
    command="$3"

    if echo "$input" | grep -qi "^$prefix" && echo "$command" | grep -qi "^$input"; then
        echo "$command"
    else
        false
    fi
}

_devenv_dirs() {
    ls -d "$1"* 2> /dev/null | while read LINE; do
        if file "$LINE" | grep -q 'directory$'; then
            echo -n "$LINE/ "
        fi
    done
}

_devenv_cli() {
    local cur prev property_file cmd sub_cmd

    # Array variable storing the possible completions.    
    COMPREPLY=()
    
    cur=${COMP_WORDS[$COMP_CWORD]}
    prev=${COMP_WORDS[$(($COMP_CWORD - 1))]}

    #---------------------------------------------------------------------------
    # investigate arguments, that are already present at the command line
    #---------------------------------------------------------------------------
    
    # according to devenv-cli.sh, the first arg is assumed to be a property file, if a local
    # file with that name exists.
    if [ "$COMP_CWORD" -gt 1 -a -f "${COMP_WORDS[1]}" ]; then
        property_file="${COMP_WORDS[1]}"
    fi

    # determine $cmd 
    if [ -z "$property_file" -a "$COMP_CWORD" -gt 1 ]; then
        cmd="${COMP_WORDS[1]}"
    elif [ ! -z "$property_file" -a "$COMP_CWORD" -gt 2 ]; then
        cmd="${COMP_WORDS[2]}"
    fi

    # expand $cmd (user might have entered an abbrevation)
    if [ ! -z "$cmd" ]; then
        cmd=$(_devenv_is_command $cmd i  info   ||
              _devenv_is_command $cmd c  create ||
              _devenv_is_command $cmd de delete ||
              _devenv_is_command $cmd a  apply  ||
              _devenv_is_command $cmd du dump   ||
              _devenv_is_command $cmd g  get    ||
              _devenv_is_command $cmd l  log)
    fi
        
    # determine $sub_cmd
    if [ -z "$property_file" -a "$COMP_CWORD" -gt 2 ]; then
        sub_cmd="${COMP_WORDS[2]}"
    elif [ ! -z "$property_file" -a "$COMP_CWORD" -gt 3 ]; then
        sub_cmd="${COMP_WORDS[3]}"
    fi

    # expand $sub_cmd (user might have entered an abbrevation)
    if [ ! -z "$sub_cmd" ]; then
        case "$cmd" in
            info)
                sub_cmd=$(_devenv_is_command $sub_cmd i     iom              ||
                          _devenv_is_command $sub_cmd p     postgres         ||
                          _devenv_is_command $sub_cmd m     mailserver       ||
                          _devenv_is_command $sub_cmd s     storage          ||
                          _devenv_is_command $sub_cmd cl    cluster          ||
                          _devenv_is_command $sub_cmd co    config)
                ;;
            create)
                sub_cmd=$(_devenv_is_command $sub_cmd s     storage          ||
                          _devenv_is_command $sub_cmd n     namespace        ||
                          _devenv_is_command $sub_cmd m     mailserver       ||
                          _devenv_is_command $sub_cmd p     postgres         ||
                          _devenv_is_command $sub_cmd i     iom              ||
                          _devenv_is_command $sub_cmd c     cluster)
                ;;
            delete)
                sub_cmd=$(_devenv_is_command $sub_cmd s     storage          ||
                          _devenv_is_command $sub_cmd n     namespace        ||
                          _devenv_is_command $sub_cmd m     mailserver       ||
                          _devenv_is_command $sub_cmd p     postgres         ||
                          _devenv_is_command $sub_cmd i     iom              ||
                          _devenv_is_command $sub_cmd c     cluster)
                ;;
            apply)
                sub_cmd=$(_devenv_is_command $sub_cmd de    deployment       ||
                          _devenv_is_command $sub_cmd m     mail-templates   ||
                          _devenv_is_command $sub_cmd x     xsl-templates    ||
                          _devenv_is_command $sub_cmd sql-s sql-scripts      ||
                          _devenv_is_command $sub_cmd sql-c sql-config       ||
                          _devenv_is_command $sub_cmd j     json-config      ||
                          _devenv_is_command $sub_cmd db    dbmigrate        ||
                          _devenv_is_command $sub_cmd c     cache-reset)
                ;;
            dump)
                sub_cmd=$(_devenv_is_command $sub_cmd c     create           ||
                          _devenv_is_command $sub_cmd l     load)
                ;;
            get)
                sub_cmd=$(_devenv_is_command $sub_cmd c     config           ||
                          _devenv_is_command $sub_cmd g     geb-props        ||
                          _devenv_is_command $sub_cmd w     ws-props         ||
                          _devenv_is_command $sub_cmd s     soap-props       ||
                          _devenv_is_command $sub_cmd b     bash-completion) 
                ;;
            log)
                sub_cmd=$(_devenv_is_command $sub_cmd d     dbaccount        ||
                          _devenv_is_command $sub_cmd c     config           ||
                          _devenv_is_command $sub_cmd i     iom              ||
                          _devenv_is_command $sub_cmd ap    app              ||
                          _devenv_is_command $sub_cmd ac    access)
                ;;
        esac
    fi

    #---------------------------------------------------------------------------
    # provide COMPREPLY for current input
    #---------------------------------------------------------------------------
    
    # First argument might be the name of a property file, an option or the top-level command
    if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "info create delete apply dump get log -h --help -v --version" -G "$cur*.properties" -- $cur) )

        
    # If the first argument is the name of a property file, the second argument has to
    # be the top-level command or an option.
    elif [ "$COMP_CWORD" -eq 2 -a ! -z "$property_file" ]; then
        COMPREPLY=( $(compgen -W "info create delete apply dump get log -h --help -v --version" -- $cur) )

        
    # If no property file was passed, sub-cmd is expected on second position.
    #   OR
    # If a property file was passed, sub-cmd is expeceted on third position.
    elif [ \( "$COMP_CWORD" -eq 2 -a   -z "$property_file" \) -o \
           \( "$COMP_CWORD" -eq 3 -a ! -z "$property_file" \) ]; then
        case "$cmd" in
            get)
                COMPREPLY=( $(compgen -W 'config geb-probs ws-probs soap-probs bash-completion -h --help' -- $cur) )
                ;;
            info)
                COMPREPLY=( $(compgen -W 'iom postgres mailserver storage cluster config -h --help' -- $cur) )
                ;;
            create)
                COMPREPLY=( $(compgen -W 'storage namespace mailserver postgres iom cluster -h --help' -- $cur) )
                ;;
            delete)
                COMPREPLY=( $(compgen -W 'storage namespace mailserver postgres iom cluster -h --help' -- $cur) )
                ;;
            apply)
                COMPREPLY=( $(compgen -W 'deployment mail-templates xsl-templates sql-scripts sql-config json-config dbmigrate cache-reset -h --help' -- $cur) )
                ;;
            dump)
                COMPREPLY=( $(compgen -W 'create load -h --help' -- $cur) )
                ;;
            log)
                COMPREPLY=( $(compgen -W 'dbaccount config iom app access -h --help' -- $cur) )
                ;;
            -h|--help)
                ;;
        esac

        
    # If no property file was passed, first argument for sub-command is expected on third position.
    #   OR
    # If a property file was passed, first argument for sub-command is expected on 4th position.
    elif [ \( "$COMP_CWORD" -eq 3 -a   -z "$property_file" \) -o \
           \( "$COMP_CWORD" -eq 4 -a ! -z "$property_file" \) ]; then
        case "$cmd" in
            apply)
                case "$sub_cmd" in
                    sql-scripts)
                        # "apply sql-scripts" requires sql-file or directory as argument
                        COMPREPLY=( $(compgen -W '-h --help' -- $cur) $(compgen -G "$cur*.sql" -- $cur) $(_devenv_dirs "$cur") )
                        ;;
                    deployment)
                        COMPREPLY=( $(compgen -W '-h --help <regex>' -- $cur) )
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W '-h --help' -- $cur) )
                esac
                ;;
            get)
                case "$sub_cmd" in
                    config)
                        COMPREPLY=( $(compgen -W '-h --help --skip-config --skip-user-config' -- $cur) )
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W '-h --help' -- $cur) )
                        ;;
                esac
                ;;
            log)
                case "$sub_cmd" in
                    dbaccount|config|iom|app)
                        COMPREPLY=( $(compgen -W '-h --help -f fatal error warn info debug trace' -- $cur) )
                        ;;
                    access)
                        COMPREPLY=( $(compgen -W '-h --help -f error all' -- $cur) )
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W '-h --help' -- $cur) )
                esac
                ;;
            *)
                COMPREPLY=( $(compgen -W '-h --help' -- $cur) )
                ;;
                
        esac

        
    # If no property file was passed, second argument for sub-command is expected on 4th position.
    #   OR
    # If a property file was passed, second argument for sub-command is expected on 5th position.
    elif [ \( "$COMP_CWORD" -eq 4 -a   -z "$property_file" \) -o \
           \( "$COMP_CWORD" -eq 5 -a ! -z "$property_file" \) ]; then
        case "$cmd" in
            log)
                case "$sub_cmd" in
                    dbaccount|config|iom|app)
                        case "$prev" in
                            -f)
                                COMPREPLY=( $(compgen -W 'fatal error warn info debug trace' -- $cur) )
                                ;;
                            *)
                                COMPREPLY=( $(compgen -W '-f' -- $cur) )
                        esac
                        ;;
                    access)
                        case "$prev" in
                            -f)
                                COMPREPLY=( $(compgen -W 'error all' -- $cur) )
                                ;;
                            *)
                                COMPREPLY=( $(compgen -W '-f' -- $cur) )
                                ;;
                        esac
                        ;;
                esac
                ;;
        esac
    fi
    
    return 0
}


complete -F _devenv_cli devenv-cli.sh
