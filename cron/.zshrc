# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git)
export PATH=$HOME/bin:/usr/local/bin:$PATH
source $ZSH/oh-my-zsh.sh

export LANG=ja_JP.UTF-8
alias rb="sudo reboot"
alias sor='source ~/.zshrc'
alias c='cd'
alias ba='s ~/.zshrc'
alias l='ls --color=auto -al'
alias i='ifconfig'
alias ansip='ansible-playbook -i hosts'
alias lso='lsof -i -n -P'
alias slso='sudo lsof -i -n -P'
alias rf='sudo rm -rf'
alias pk='pkill'

function ki(){
sudo kill -9 $1
}

alias cp="cp -R"
alias z="cd -"
alias q="cd .."
alias to="touch"
alias jl="jobs -l"
alias bri="brew install"

function mk(){
mkdir -p $1 && cd $1
}
alias cx='chmod +x'

function gclc(){
    gcl $1
    tmp=`basename $1`
    fname="${tmp%.*}" #ファイル名のみ取り出し
    cd $fname
    s .
}


function psg(){ #open github from current directory
ps -ef | grep $1 | grep -v grep
}

export LC_MESSAGES=UTF-8
export LC_IDENTIFICATION=UTF-8
export LC_COLLATE=UTF-8
export LANG=UTF-8
export LC_MEASUREMENT=UTF-8
export LC_CTYPE=UTF-8
export LC_TIME=UTF-8
export LC_NAME=UTF-8


cd ()
{
builtin cd "$@" && l
}

function gtrc(){
git checkout -b $1 origin/$1
}

alias pa="php artisan"
alias migrate="php artisan migrate && php artisan db:seed"
alias dkco="docker-compose"
alias check="cd /home/ubuntu/laravel-prod-image/build/ && docker-compose logs"
alias dk="docker"
alias dkco="docker-compose"
alias gtr="git log1"


alias gii="git init"

function gagm(){
git add -A
git commit -m "$1"
}
