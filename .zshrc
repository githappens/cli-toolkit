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

# Rescan all audio units
alias rescanau="killall -9 AudioComponentRegistrar; auval -al"


# list of paths to add to PATH
export _pathstoappend=("/opt/homebrew/opt/ccache/libexec" "$HOME/scripts")

# initialization steps: load custom paths to PATH
for pathtoadd in "${_pathstoappend[@]}"
do
  if [[ -z $(echo "$PATH" | grep "$pathtoadd") ]]; then
      # append
      path+=("$pathtoadd")
      # export to sub-processes (make it inherited by child processes)
      export PATH
  fi
done

# Remove audio unit build
function rmau()
{
    rm -rf "/Library/Audio/Plug-Ins/Components/$1.component"
}

# Helper function for quickly updating the remote of this file
function saveme()
(
    commitM=${1:-"auto update"}
    repoDir="$HOME/Development/Tools/cli-toolkit/"
    cp "$HOME/.zshrc" "$repoDir"
    cp -r "$HOME/scripts" "$repoDir"
    cd -- "$repoDir" || exit
    sed -i '/^# NONSYNC ZONE START/,/^# NONSYNC ZONE END/d' ".zshrc"
    git add .
    git commit -m $commitM
    git pull
    git push
)

function shallowclone()
{
    if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: $funcstack[1] repo-url branch-or-tag depth

Shortcut for creating a shallow clone of a repo from a specific branch or tag."
    return 0
    fi

    repo=$1
    branch=$2
    nCommits=$3
    git clone -b $2 --single-branch --depth $3 $1
}

function finderror()
{
    if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: $funcstack[1] error-code

Looks up an error code in the macOS SDK."
    return 0
    fi

    grep -r -- $1 /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/System/Library/Frameworks
}

function createscript()
{
    if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: $funcstack[1] script-name

Generates a new shell script from the template."
    return 0
    fi

    scriptDir="$HOME/scripts"
    cat  "$scriptDir/.scripttemplate" > "$scriptDir/$1.sh"
    chmod 755 "$scriptDir/$1.sh"
    code "$scriptDir/$1.sh"
}