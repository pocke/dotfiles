export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
alias -g C='| pbcopy'
ls --help | grep GNU > /dev/null || alias ls="ls -G -F"
