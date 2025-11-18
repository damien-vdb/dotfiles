# Go configuration
# This file is sourced by .profile

# set PATH so it includes Go binaries if they exist
if [ -d "/usr/local/go/bin" ] ; then
    PATH="/usr/local/go/bin:$PATH"
fi

if [ -d "$HOME/go/bin" ] ; then
    PATH="$HOME/go/bin:$PATH"
fi

# Go environment
export GOPATH="$HOME/go"
