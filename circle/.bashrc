source ~/.circlerc &>/dev/null

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# The next line updates PATH for the Google Cloud SDK.
source '/opt/google-cloud-sdk/path.bash.inc'

# The next line enables shell command completion for gcloud.
source '/opt/google-cloud-sdk/completion.bash.inc'

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"


alias rb="sudo reboot"
alias sor='source ~/.zshrc'
alias c='cd'
alias ba='s ~/.zshrc'
alias l='ls -Glah'
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

function mk(){
mkdir -p $1 && cd $1
}
alias cx='chmod +x'


cd ()
{
builtin cd "$@" && ls -Glah
}



function gtrc(){
git checkout -b $1 origin/$1
}

# cd web

alias pa="php artisan"
alias migrate="php artisan migrate && php artisan db:seed"
alias dkco="docker-compose"
alias check="cd /home/ubuntu/laravel-prod-image/build/ && docker-compose logs"
alias dk="docker"
alias dkco="docker-compose"
alias gtr="git log1"