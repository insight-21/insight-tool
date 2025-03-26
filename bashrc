#export DFT_WIDTH=115

#export LC_ALL=zh_CN.utf8
#export LANG=zh_CN.utf8
export LESSCHARSET=utf-8alias ll='ls -alF'
# export GIT_EDITOR='vim +startinsert!'
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWCONFLICTSTATE='yes'
export GIT_MERGE_AUTOEDIT='no'
export TERM=xterm-256color

alias grep='grep --color'
alias ll='ls -alF --color'
alias gd="git diff ':(exclude)*.pb.go' ':(exclude)*.pb.micro.go' ':(exclude)go.sum' ':(exclude)go.mod'"
alias gdc="git diff --cached"
alias gap="git add -p"
alias gst="git st ':(exclude)*.pb.go' ':(exclude)*.pb.micro.go' ':(exclude)go.sum' ':(exclude)go.mod'"
alias gsl="git stash list"
alias gsp="git stash pop"
alias gdck="git diff --check"
alias curbr="git br --show-current"
alias cpb="gcp beta"
alias cpa="gcp alpha"
alias cpm="gcp main"
alias sqcmlog2="cpm && ck2prebr && git rebase -i --autosquash main"
alias br="git branch --list '*elliot*'"
alias lg="git showlog -12"
alias cm="git cm && git push"
alias cma="git cma && git pf"
alias mcm="git cm -a --no-edit && git pull && git push && gck"
alias vimbashrc="code ~/.bashrc"
alias rebashrc="source ~/.bashrc"

alias cduser="cd ~/Desktop/user/"
alias cdusergo="cd ~/Desktop/Go/src/usergo"
alias cdesign="cd ~/Desktop/workspace/esign/Application"
alias cdesigngo="cd ~/Desktop/Go/src/esigngo"
alias cdgate="cd ~/Desktop/workspace/gate/Application"
alias updateBr="cpm && br | xargs -I % sh -c 'gck % && git merge main && git push'"

alias php="/e/wamp64/bin/php/php7.1.33/php.exe"
alias tig="tig status"
alias autogen-web="~/Desktop/Go/bin/./autogen-web_autogen-web.sh"

alias run="./run"

# open tunnel
alias tunnel-beta="ssh -NTC -L 2222:192.168.0.39:36000 jump"
alias tunnel-beta-web="ssh -NTC -L 2223:192.168.5.86:36000 jump"
alias tunnel-cxbeta="ssh -NTC -L 2224:10.10.6.185:36000 jump"
alias tunnel-cxbeta-web="ssh -NTC -L 2225:10.10.5.44:36000 jump"
alias tunnel-alpha="ssh -NTC -L 2226:192.168.5.119:36000 jump"
alias tunnel-cx-script="ssh -NTC -L 2227:10.10.5.37:36000 jump"
alias tunnel-xysidc-script="ssh -NTC -L 2227:172.16.19.16:36000 xysidcjump"
alias tunnel-cxidc-script="ssh -NTC -L 2227:10.11.5.108:36000 cxidcjump"
alias tunnel-dev="ssh -NTC -L 2228:192.168.0.30:36000 jump"

function pre-cm() {
    files=$(git status -s | awk '{print $2}')
    succ=true
    for file in "${files[@]}"; do
        /e/wamp64/bin/php/php8.0.13/php.exe -l $file | grep "No syntax errors" > /dev/null
        if [ $? -ne 0 ]; then
            echo "$file have syntax errors"
            succ=false
        fi
    done
    return $succ
}

function stash_if_have_local_changes() {
    git diff --quiet
    have_local_changes=$?
    if [ $have_local_changes -ne 0 ]; then
        curBr=`curbr`
        git stash -m "checkout to $1"
    fi
    return $have_local_changes
}

function new-br() {
    brname=$2
    [ ! $brname ] && echo "branch name is empty" && return
    brtype=$1
    br=$brtype"_elliot_"$brname"_`(date +%Y%m%d)`"

    have_local_changes=$(stash_if_have_local_changes $br)

    gcp main && git ck -b $br && git push

    if [ $have_local_changes -ne 0 ]; then
        gsp
    fi
}

function new-fix-br() {
    new-br fix $1
}

function new-feat-br() {
    new-br feat $1
}

function basecm-cnt() {
    stcm=`curbr|xargs -n 1 git merge-base main`
    cm-cnt $stcm
}

function gck2() {
    [ ! $1 ] && git ck - && return
    git ck $1 && git pull
}

function del-merged-br() {
    gcp main
    ret=`git br --merged | grep elliot`
    brCnt=`echo "$ret" | grep -v '^\s*$' | wc -l`
    [ $brCnt == 0 ] && echo "no br need clean" && ck2prebr && return
    echo "$ret"
    read -r -p "clean the br above?[y/n]: " input
    [[ $input != "y" ]] && ck2prebr && return
    for br in $(git br --merged | grep elliot); do
        del-br-local-remote $br
    done
    git remote prune origin
    # git br --merged | grep elliot | xargs -I {} sh -c 'del-br-local-remote {}'
    # git br --merged | grep elliot | xargs -n 1 git push --delete origin
    # git br --merged | grep elliot | xargs -n 1 git br -d
    # git remote prune origin
}

function m2a() {
    mergeBr alpha
}

function mergeBr() {
    brName=`curbr`
    [ ! $brName ] && echo "source branch is empty" && return
    targetBr=$1
    gcp $targetBr
    # read -r -p "confirm merge $brName to $targetBr ? [y/n]: " input
    # [[ $input != "y" ]] && ck2prebr && return

    git merge $brName --no-edit && git push && git ck $brName
    if [ $? -ne 0 ]; then
        echo -e '\nConflict files:'
        gdck
    fi
}

function m2b() {
    mergeBr beta
}

function timetodate() {
    [ ! $1 ] && echo "timestamp is empty" && return
    date -d @$1 +"%Y-%m-%d %H:%M:%S"
}

function datetotime() { 
    dateStr="$*"
    # echo $dateStr
    [ ! "$dateStr" ] && echo "date is empty" && return
    date -d "$dateStr" +%s
}

function timestamp() {
    current=`date "+%Y-%m-%d %H:%M:%S"`
    date -d "$current" +%s
}

function delbr() {
    [ ! $1 ] && echo "branch name is empty" && return
    del-br-local-remote $1
    git remote prune origin
}

function del-br-local-remote() {
    git br -D $1
    git push --delete origin $1
}

function gck-remote() {
    keyword=$1
    brLineNo=$2
    [ ! $keyword ] && ck2prebr && return
	ret=`git br -r | grep -iE $keyword | awk -F '/' '{print $2}'`
	# ret=`git br | grep "elliot" | grep -iE $keyword`
    
    brCnt=`echo "$ret" | grep -v '^\s*$' | wc -l`
    # [ $brCnt == 0 ] && echo "not match any keyword" && git ck $keyword && return
    if [ $brCnt == 0 ]; then
        echo "not match any keyword in remote branch"
        return
    fi
    # [ $brCnt == 1 ] && gcp $ret && return 
    if [ $brCnt == 1 ]; then
        gcp $ret
        return
    fi
    # [ ! $brLineNo ] && echo "$ret" && return
    if [ ! $brLineNo ]; then
        # 双引号可以换行
        echo "$ret"
        return
    fi
    br=`echo "$ret" | sed -n "$brLineNo"p`
    gcp $br
}

function gck() {
    keyword=$1
    brLineNo=$2
    [ ! $keyword ] && ck2prebr && return
	ret=`git br | grep -iE $keyword`
	# ret=`git br | grep "elliot" | grep -iE $keyword`
    
    brCnt=`echo "$ret" | grep -v '^\s*$' | wc -l`
    # [ $brCnt == 0 ] && echo "not match any keyword" && git ck $keyword && return
    if [ $brCnt == 0 ]; then
        echo "not match any keyword in local branch"
        gck-remote $1 $2
        return
    fi
    # [ $brCnt == 1 ] && gcp $ret && return 
    if [ $brCnt == 1 ]; then
        gcp $ret
        return
    fi
    # [ ! $brLineNo ] && echo "$ret" && return
    if [ ! $brLineNo ]; then
        # 双引号可以换行
        echo "$ret"
        return
    fi
    br=`echo "$ret" | sed -n "$brLineNo"p`
    gcp $br
}

function gcp() {
    [ ! $1 ] && echo "branch name is empty" && return
    stash_if_have_local_changes $1
    git ck $1 && git pull
}

function ck2prebr() {
    gcp $(git rev-parse --abbrev-ref @{-1})
}

function elliot_workspace(){
    session='elliot'
    tmux has-session -t $session >/dev/null 2>&1
    if [ $? != 0 ]; then
        tmux new -s $session -d
        tmux split-window -h -t $session:0.0
        tmux new-window -t $session
        tmux previous-window -t $session
        # tmux send -t $session:0.0 'showcode' Enter C-l
    fi
    # tmux send -t $session:0.1 'showlog' Enter C-l
    tmux select-pane -t 0
    tmux a -t $session
    # set -g default-terminal "xterm-256color"
    # # set -ga terminal-overrides ",*256col*:Tc"
    # #set -g window-style 'fg=colour240,bg=colour236'
    # #set -g window-active-style 'fg=colour255,bg=black'
    # set -g status-bg 'black' # background
    # set -g status-fg 'white' # foreground
    # set -g status-justify centre
    # set -g pane-active-border-style 'bg=default,fg=green'
    # set -g display-panes-time 2000
    # set -g mouse on
    # set -g monitor-activity on
    # set -g visual-activity on

    # setw -g window-status-current-bg white
    # setw -g window-status-current-fg black
    # setw -g window-status-bg black
    # setw -g window-status-fg white
    # set -g status-utf8 on
}

# function tmux2() {
#   # execute tmux with script
#   TMUX="command tmux ${@}"
#   SHELL=/e/Git/bin/bash.exe script -qO /dev/null -c "eval $TMUX"
# }

function run_elliot_tool(){
    [ ! $1 ] && echo "func is empty" && return
    sh /alidata/www/xproject/Application/Tools/runFuncWithParameter.sh UnionGate Tools ElliotTool $*
}

function bg_cm() {
    nohup "$@" &>/dev/null &
}

function cmfix() {
    [ ! $1 ] && git cmfix && git push && return
    git cm --fixup=$1 && git pull && git push
}

function sqcmlg() {
    hashid=$1
    [ ! $hashid ] && echo "hashid is empty" && return
    git rebase -i --autosquash "$hashid^" && git pf
}

function rebasemain() {
    cpm && gck && git rebase -i --autosquash main && git pf
}

function rebase-first-commit() {
    mergeBaseHashId=$(git merge-base main $(curbr))
    cpm && gck && echo $mergeBaseHashId && git rebase -i --autosquash $mergeBaseHashId && git pf
}

function cm-cnt() {
    st=$1
    ed=$2
    [ ! $st ] && echo "start commit hash is empty" && return
    [ ! $ed ] && ed=head
    git rev-list $st..$ed --count
}
