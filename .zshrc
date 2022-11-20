# aliases used for quick iterations of editing/reloading this file
alias editme="code ~/.zshrc"
alias refreshme="source ~/.zshrc"

# aliases for text editing
alias sed="gsed"
alias c="code"
alias co="code ."

# aliases for git
alias g="git"
alias gl="git log"
alias gcm="git commit -am"
alias gs="git status"
alias gps="git push"
alias gpl="git pull"
alias gres="git restore"

# add shell script folder to path
export PATH="$HOME/scripts:$PATH"

# Helper function for quickly updating the remote of this file
function saveme()
(
    commitM=${1:-"auto update"}
    repoDir="$HOME/Development/Tools/cli-toolkit/"
    cp "$HOME/.zshrc" "$repoDir"
    cp -r "$HOME/scripts" "$repoDir"
    cd -- "$repoDir" || exit
    git add .
    git commit -m $commitM
    git pull
    git push
)

# Helper function for printing help messages when a command is invoked incorrectly
function _printHelp()
{
    argCount=$1
    requiredArgCount=$2
    helpMessage=$3
    if [ $argCount != $requiredArgCount ]
    then
        echo "Passed in arg count: $1 Required arg count: $2 \nUsage: $funcstack[2] $helpMessage"
        return
    fi

    echo "0"
}

# Shortcut for creating a shallow clone of a repo from a specific branch or tag
function shallowclone()
{
    helpResult=$(_printHelp $# 3 "<repo_url> <branch/tag> <depth>")
    if [ $helpResult != "0" ]
    then
        echo "$helpResult"
        return 1
    fi

    repo=$1
    branch=$2
    nCommits=$3
    git clone -b $2 --single-branch --depth $3 $1
}

# Look up an error code in the macOS SDK
function finderror()
{
    helpResult=$(_printHelp $# 1 "<error code>")
    if [ $helpResult != "0" ]
    then
        echo "$helpResult"
        return 1
    fi

    grep -r -- $1 /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/System/Library/Frameworks
}

# Helper function to recursively look for files with wildcard matching in the given path
function findfilesindir()
{
    helpResult=$(_printHelp $# 2 "<folder_path> <file_name>")
    if [ $helpResult != "0" ]
    then
        echo "$helpResult"
        return 1
    fi

    find $1 -name "$2"
}

# Quickly add a new script in the scripts folder and open it for editing 
function createscript()
{
    helpResult=$(_printHelp $# 1 "<script_name>")
    if [ $helpResult != "0" ]
    then
        echo "$helpResult"
        return 1
    fi

    scriptDir="$HOME/scripts"
    cat  "$scriptDir/.scripttemplate" > "$scriptDir/$1.sh"
    chmod 755 "$scriptDir/$1.sh"
    code "$scriptDir/$1.sh"
}