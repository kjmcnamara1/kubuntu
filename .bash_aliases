#!/usr/bin/env bash

# Python
alias py="python3"

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'             # raw control characters
alias whence='type -a'           # where, of a sort
alias grep='grep --color'        # show differences in colour
alias egrep='egrep --color=auto' # show differences in colour
alias fgrep='fgrep --color=auto' # show differences in colour

# Some shortcuts for different directory listings
alias ls='ls -h --color=auto --group-directories-first' # classify files in colour
alias l='ls -l'                                         # non hidden list
alias ll='ls -al'                                       # long list including hidden
alias la='ls -A'                                        # all but . and ..
