#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./addmoduledep.sh path/to/module dep-name

Adds module dependency to a JUCE user module.
Dependency: gsed
'
    exit
fi

main() {
    cd "$1"
    moduleName=$(echo ${PWD##*/})
    echo "Module is called $moduleName"

    headerFile="$moduleName.h"
    dependencies=$(cat $headerFile | grep dependencies)

    echo "Header file is $headerFile"
    echo "$dependencies"
    newDep=$2

    gsed -i "s/${dependencies}/${dependencies}, $newDep/" "$headerFile"
    lastIncludeLineNum=$(grep -n ".h>" "$headerFile" | cut -f1 -d: | tail -1)
    newDepInclLineNum="$((lastIncludeLineNum + 1))"
    
    gsed -i "${newDepInclLineNum}i\#include <$newDep/$newDep.h>" "$headerFile"
    cat "$headerFile"
}

main "$@"