# Sourced by bashrc in the devenv container (teken unit celleste).
alias python=python3
alias sqlite=sqlite3
alias query="sqlite3 $HOME/database/celleste-lab.db -column -header"
[ -f /root/pyenv/bin/activate ] && . /root/pyenv/bin/activate
