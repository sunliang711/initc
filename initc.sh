#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
thisDir="$(cd $(dirname $rpath) && pwd)"
# cd "$thisDir"

user="${SUDO_USER:-$(whoami)}"
home="$(eval echo ~$user)"

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 5)
        bold=$(tput bold)
reset=$(tput sgr0)
function runAsRoot(){
    verbose=0
    while getopts ":v" opt;do
        case "$opt" in
            v)
                verbose=1
                ;;
            \?)
                echo "Unknown option: \"$OPTARG\""
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    cmd="$@"
    if [ -z "$cmd" ];then
        echo "${red}Need cmd${reset}"
        exit 1
    fi

    if [ "$verbose" -eq 1 ];then
        echo "run cmd:\"${red}$cmd${reset}\" as root."
    fi

    if (($EUID==0));then
        sh -c "$cmd"
    else
        if ! command -v sudo >/dev/null 2>&1;then
            echo "Need sudo cmd"
            exit 1
        fi
        sudo sh -c "$cmd"
    fi
}
###############################################################################
# write your code below (just define function[s])
# function with 'function' is hidden when run help, without 'function' is show
###############################################################################
create(){
    if [ $# -eq 0 ];then
        echo "Usage: $(basename $0) <project1> [project2] ..."
        return 1
    fi
    projects=$@
    for p in "$@";do
        echo "${green}Create project: $p .. ${reset}"
        create_ "$p"
    done

}

function create_(){
    projectName=${1}
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
    cat<<EOF>.gitignore
.DS_Store
*.swp
.idea/
build/
.vscode/
EOF
cd - >/dev/null 2>&1
}



###############################################################################
# write your code above
###############################################################################
function help(){
    cat<<EOF2
Usage: $(basename $0) ${bold}CMD${reset}

${bold}CMD${reset}:
EOF2
    perl -lne 'print "\t$1" if /^\s*(\w+)\(\)\{$/' ${BASH_SOURCE} | grep -v runAsRoot
}

case "$1" in
     ""|-h|--help|help)
        help
        ;;
    *)
        "$@"
esac
