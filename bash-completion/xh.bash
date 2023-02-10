_xh() {
    local i cur prev opts cmds
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd=""
    opts=""

    for i in ${COMP_WORDS[@]}
    do
        case "${i}" in
            xh)
                cmd="xh"
                ;;
            
            *)
                ;;
        esac
    done

    case "${cmd}" in
        xh)
            opts=" -j -f -m -h -b -v -q -S -d -c -F -I -V -s -p -P -o -A -a  --json --form --multipart --headers --body --verbose --all --quiet --stream --download --continue --ignore-netrc --offline --check-status --follow --native-tls --https --ignore-stdin --curl --curl-long --no-all --no-auth --no-auth-type --no-bearer --no-body --no-cert --no-cert-key --no-check-status --no-continue --no-curl --no-curl-long --no-default-scheme --no-download --no-follow --no-form --no-headers --no-history-print --no-http-version --no-https --no-ignore-netrc --no-ignore-stdin --no-json --no-max-redirects --no-multipart --no-native-tls --no-offline --no-output --no-pretty --no-print --no-proxy --no-quiet --no-raw --no-response-charset --no-response-mime --no-session --no-session-read-only --no-ssl --no-stream --no-style --no-timeout --no-verbose --no-verify --help --version --raw --pretty --style --response-charset --response-mime --print --history-print --output --session --session-read-only --auth-type --auth --bearer --max-redirects --timeout --proxy --verify --cert --cert-key --ssl --default-scheme --http-version  <[METHOD] URL> <REQUEST_ITEM>... "
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                
                --raw)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --pretty)
                    COMPREPLY=($(compgen -W "all colors format none" -- "${cur}"))
                    return 0
                    ;;
                --style)
                    COMPREPLY=($(compgen -W "auto solarized monokai fruity" -- "${cur}"))
                    return 0
                    ;;
                    -s)
                    COMPREPLY=($(compgen -W "auto solarized monokai fruity" -- "${cur}"))
                    return 0
                    ;;
                --response-charset)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --response-mime)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --print)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                    -p)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --history-print)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                    -P)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --output)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                    -o)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --session)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --session-read-only)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --auth-type)
                    COMPREPLY=($(compgen -W "basic bearer digest" -- "${cur}"))
                    return 0
                    ;;
                    -A)
                    COMPREPLY=($(compgen -W "basic bearer digest" -- "${cur}"))
                    return 0
                    ;;
                --auth)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                    -a)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --bearer)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --max-redirects)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --timeout)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --proxy)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --verify)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --cert)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --cert-key)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ssl)
                    COMPREPLY=($(compgen -W "auto ssl2.3 tls1 tls1.1 tls1.2 tls1.3" -- "${cur}"))
                    return 0
                    ;;
                --default-scheme)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --http-version)
                    COMPREPLY=($(compgen -W "1 1.0 1.1 2" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        
    esac
}

complete -F _xh -o bashdefault -o default xh
