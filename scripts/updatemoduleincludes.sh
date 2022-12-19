#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./updatemoduleincludes.sh path/to/user/module source-folder-name(optional)
Scans through the src folder of the user module and updates the includes in the main module .h and .cpp files based on its content.
The second argument is optionally the name of the source folder inside the module folder. Defaults to src when it is not passed in.
'
    exit
fi

main() {
    cd "$1"
    moduleName=$(echo ${PWD##*/})
    echo "Module is called $moduleName"
    
    sourceFolder=${2:-"src"}
    
    headerFiles=($(find $sourceFolder -name "*.h"))
    cppFiles=($(find $sourceFolder -name "*.cpp"))

    echo "" >> $moduleName.h
    echo "" >> $moduleName.cpp

    for h in "${headerFiles[@]}"
    do
        if [[ -z $(cat "$moduleName.h" | grep $h) ]];
        then
            echo "Adding $h to $moduleName.h"
            echo "#include \"${h}\"" >> $moduleName.h
        fi
    done

    for cpp in "${cppFiles[@]}"
    do
        if [[ -z $(cat "$moduleName.cpp" | grep $cpp) ]];
        then
            echo "Adding $cpp to $moduleName.cpp"
            echo "#include \"${cpp}\"" >> $moduleName.cpp
        fi
    done
}

main "$@"