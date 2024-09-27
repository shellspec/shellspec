#shellcheck shell=sh

shellspec_copy_array() {
    # $1: from array name
    # $2: to array name
    # eval sees: to_array=("${from_array[@]")
    #    ____#######____########
    eval "$2"'=("${'"$1"'[@]}")'
}