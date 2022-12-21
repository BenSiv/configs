
# Adding julia to PATH global variable
export PATH="/home/bensiv/julia-1.8.2/bin/:$PATH"
export JULIA_DIR="/home/bensiv/julia-1.8.2/"
# Adding python to PATH global variable
export PATH="$PATH:/home/bensiv/Python-3.11.0/"
# Adding go to PATH global variable
export PATH="$PATH:/usr/local/go/bin"

# <<< usefull aliases >>>
# update on one command
alias update='sudo apt-get update && sudo apt-get upgrade'

alias shutdown='sudo /sbin/shutdown'

# run jupyter lab in the background
alias jupyter-lab='nohup jupyter lab >/dev/null 2>&1 &'

# my pretty print
alias readdir='ls --format=single-column --almost-all --group-directories-first'
alias rd=readdir

# go to the itc directory
alias itc='cd ~/Documents/ITC/Main'

alias docker='sudo docker'
# alias docker='sudo newgrp docker'