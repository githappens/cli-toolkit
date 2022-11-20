#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./generatejucemodule.sh module_name source_path dependency_1 ... dependency_n
    It should be called from where the module folder needs to be created.
    Recursively scans the source path and moves all code files into the new module folder.
    Generates the juce user module header and .cpp file.
    Includes all source code files, as well as headers of the named dependencies. 
'
    exit
fi

main()
{
    moduleName=$1
    sourceFolder=$2

    # Fetch .h and .cpp files
    headerFiles=($(find $sourceFolder -name "*.h"))
    cppFiles=($(find $sourceFolder -name "*.cpp"))

    # Move files to module src folder and remove juce header includes
    modSrcDir="$moduleName/src"
    mkdir -p "$modSrcDir"
    if [[ ${#headerFiles[@]} > 0 ]]
    then
        for h in "${headerFiles[@]}"
        do
            gsed -i 's/#include <JuceHeader.h>//g' "$h"
            mv "$h" "$modSrcDir"
    done
    fi
    
    if [[ ${#cppFiles[@]} > 0 ]]
    then
        for cpp in "${cppFiles[@]}"
        do
            gsed -i 's/#include <JuceHeader.h>//g' "$cpp"
            mv "$cpp" "$modSrcDir"
        done
    fi
    
    headerPath="$moduleName/$moduleName.h"
    cppPath="$moduleName/$moduleName.cpp"

    # Create comma separated list of dependencies
    dependencies=""
    if [[ $# > 2 ]]
    then
        for dep in "${@:3}"
        do
            dependencies+=$dep
            if [[ $dep != ${@: -1} ]]
            then
                dependencies+=", "
            fi
        done
    fi
    
    modCaps=$(echo "$moduleName" | gsed 's/[a-z]/\U&/g')
    
    # Create main module header
    echo "/** BEGIN_JUCE_MODULE_DECLARATION
ID:               $moduleName
vendor:           githappens
version:          1.0.0
name:             $moduleName
description:      <Description>
website:          https://github.com/githappens
license:          <License>
dependencies:     $dependencies
END_JUCE_MODULE_DECLARATION
*/
#pragma once
#define ${modCaps}_H_INCLUDED" > $headerPath

    # Include headers of dependencies
    
    if [[ $# > 2 ]]
    then
        for dep in "${@:3}"
        do
            echo "#include <$dep/$dep.h>" >> $headerPath
        done
    fi
    
    # Include headers of module
    modSrcDir="src"
    headerFiles=($(cd $moduleName;find $modSrcDir -name "*.h"))

    if [[ ${#headerFiles[@]} > 0 ]]
    then
        for h in "${headerFiles[@]}"
        do
            echo "#include \"${h}\"" >> $headerPath
        done
    fi

    # Create main code file
    echo "#ifdef ${modCaps}_H_INCLUDED
 /* When you add this cpp file to your project, you mustn't include it in a file where you've
    already included any other headers - just put it inside a file on its own, possibly with your config
    flags preceding it, but don't include anything else. That also includes avoiding any automatic prefix
    header files that the compiler may be using.
 */
#error \"Incorrect use of module cpp file\"
#endif
#include \"$headerPath\"
" > $cppPath

    # Include cpp files of module
    cppFiles=($(cd $moduleName;find $modSrcDir -name "*.cpp"))
    
    if [[ ${#cppFiles[@]} > 0 ]]
    then
        for cpp in "${cppFiles[@]}"
        do
            echo "#include \"${cpp}\"" >> $cppPath
        done
    fi
    
}

main "$@"