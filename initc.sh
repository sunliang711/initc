#!/bin/bash
if [ -z "${BASH_SOURCE}" ]; then
    this=${PWD}
else
    rpath="$(readlink ${BASH_SOURCE})"
    echo "rpath: $rpath"
    if [ -z "$rpath" ]; then
        rpath=${BASH_SOURCE}
    fi
    echo "rpath: $rpath"
    this="$(cd $(dirname $rpath) && pwd)"
fi

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

user="${SUDO_USER:-$(whoami)}"
home="$(eval echo ~$user)"

# export TERM=xterm-256color

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors 2>/dev/null)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    CYAN="$(tput setaf 5)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
else
    RED=""
    GREEN=""
    YELLOW=""
    CYAN=""
    BLUE=""
    BOLD=""
    NORMAL=""
fi

_err(){
    echo "$*" >&2
}

_command_exists(){
    command -v "$@" > /dev/null 2>&1
}

rootID=0

_runAsRoot(){
    local trace=0
    local subshell=0
    local nostdout=0
    local nostderr=0

    local optNum=0
    for opt in ${@};do
        case "${opt}" in
            --trace|-x)
                trace=1
                ((optNum++))
                ;;
            --subshell|-s)
                subshell=1
                ((optNum++))
                ;;
            --no-stdout)
                nostdout=1
                ((optNum++))
                ;;
            --no-stderr)
                nostderr=1
                ((optNum++))
                ;;
            *)
                break
                ;;
        esac
    done

    shift $(($optNum))
    local cmd="${*}"
    bash_c='bash -c'
    if [ "${EUID}" -ne "${rootID}" ];then
        if _command_exists sudo; then
            bash_c='sudo -E bash -c'
        elif _command_exists su; then
            bash_c='su -c'
        else
            cat >&2 <<-'EOF'
			Error: this installer needs the ability to run commands as root.
			We are unable to find either "sudo" or "su" available to make this happen.
			EOF
            exit 1
        fi
    fi

    local fullcommand="${bash_c} ${cmd}"
    if [ $nostdout -eq 1 ];then
        cmd="${cmd} >/dev/null"
    fi
    if [ $nostderr -eq 1 ];then
        cmd="${cmd} 2>/dev/null"
    fi

    # (set -x; $bash_c "${cmd}" >> ${logfile} )
    if [ $subshell -eq 1 ];then
        if [ $trace -eq 1 ];then
            (set -x; ${bash_c} "${cmd}")
        else
            (${bash_c} "${cmd}")
        fi
    else
        if [ $trace -eq 1 ];then
            set -x; ${bash_c} "${cmd}";set +x;
        else
            ${bash_c} "${cmd}"
        fi
    fi
}

function _insert_path(){
    if [ -z "$1" ];then
        return
    fi
    echo -e ${PATH//:/"\n"} | grep -c "^$1$" >/dev/null 2>&1 || export PATH=$1:$PATH
}

_run(){
    local trace=0
    local subshell=0
    local nostdout=0
    local nostderr=0

    local optNum=0
    for opt in ${@};do
        case "${opt}" in
            --trace|-x)
                trace=1
                ((optNum++))
                ;;
            --subshell|-s)
                subshell=1
                ((optNum++))
                ;;
            --no-stdout)
                nostdout=1
                ((optNum++))
                ;;
            --no-stderr)
                nostderr=1
                ((optNum++))
                ;;
            *)
                break
                ;;
        esac
    done

    shift $(($optNum))
    local cmd="${*}"
    bash_c='bash -c'

    local fullcommand="${bash_c} ${cmd}"
    if [ $nostdout -eq 1 ];then
        cmd="${cmd} >/dev/null"
    fi
    if [ $nostderr -eq 1 ];then
        cmd="${cmd} 2>/dev/null"
    fi

    # (set -x; $bash_c "${cmd}" >> ${logfile} )
    if [ $subshell -eq 1 ];then
        if [ $trace -eq 1 ];then
            (set -x; ${bash_c} "${cmd}")
        else
            (${bash_c} "${cmd}")
        fi
    else
        if [ $trace -eq 1 ];then
            set -x; ${bash_c} "${cmd}";set +x;
        else
            ${bash_c} "${cmd}"
        fi
    fi
}

function _root(){
    if [ ${EUID} -ne ${rootID} ];then
        echo "Requires root privilege."
        exit 1
    fi
}

ed=vi
if _command_exists vim; then
    ed=vim
fi
if _command_exists nvim; then
    ed=nvim
fi
# use ENV: editor to override
if [ -n "${editor}" ];then
    ed=${editor}
fi
###############################################################################
# write your code below (just define function[s])
# function is hidden when begin with '_'
create(){
    # default project type: cpp
    local typ=cpp
    while getopts ":ch" opt;do
        case "$opt" in
            c)
                typ=c
                ;;
            h)
                _help
                ;;
            \?)
                echo "Unknown option: \"$OPTARG\""
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    projects=$@
    for p in "$@";do
        echo "${green}Create project: $p .. ${reset}"
        _create "$p" "$typ"
    done
}

function _help(){
    cat<<EOF
Usage:
    -h      for help
    -c      create c project (default cpp project)
EOF
    exit 0
}

function _create(){
    local projectName=${1}
    local typ=${2}

    if [ -z "${projectName}" ];then
        echo -n "Enter project name: "
        read projectName
    fi
    if [ -z "${projectName}" ];then
        echo "Input error!"
        exit 1
    fi

    if [ -d "${projectName}" ];then
        echo "${red}${projectName} exists${reset}"
        exit 1
    fi

    mkdir -pv "${projectName}"
    cd "${projectName}"
    git init .

    sed -e "s|<PROJECTNAME>|${projectName}|g" ${thisDir}/rootfs/CMakeLists.txt > CMakeLists.txt
    cp -r ${thisDir}/rootfs/src .
    cat>.gitignore<<EOF
.DS_Store
*.swp
.idea/
build/
.vscode/
EOF
    case "${typ}" in
        cpp)
            ;;
        c)
            mv src/main.cpp src/main.c
            sed -e "s|main.cpp|main.c|g" src/CMakeLists.txt >/tmp/CMakeLists.txt
            mv /tmp/CMakeLists.txt src/CMakeLists.txt
            ;;
    esac
    cd - >/dev/null 2>&1
}

# write your code above
###############################################################################

em(){
    $ed $0
}

function _help(){
    cd "${this}"
    cat<<EOF2
Usage: $(basename $0) ${bold}CMD${reset}

${bold}CMD${reset}:
EOF2
    perl -lne 'print "\t$2" if /^\s*(function)?\s*(\S+)\s*\(\)\s*\{$/' $(basename ${BASH_SOURCE}) | perl -lne "print if /^\t[^_]/"
}

case "$1" in
     ""|-h|--help|help)
        _help
        ;;
    *)
        "$@"
esac
