# HISTORY

export HISTFILE=$HOME/.history/`date +%Y%m`.hist

if [[ ! -e $HISTFILE ]]; then
	LASTHIST=`find ~/.history/ -type f -maxdepth 1 -name '[!.]*' -print|tail -1`
	echo "removing dups from ${LASTHIST} (last history file)"
    python $BASHSCRIPTS/removedupswosort.py $LASTHIST
    mkdir -p ~/.history
	touch $HISTFILE
    if [[ -e $LASTHIST ]]; then
		echo "getting last 1500 lines from ${LASTHIST}"
        tail -1500 $LASTHIST > $HISTFILE
        # Write a divider to identify where the prior day's session history ends
        echo "##########################################################" >> $HISTFILE
    fi
fi
export HISTSIZE=100000


export HISTCONTROL="erasedups:ignoreboth" # don't include duplicates
export HISTFILESIZE=500000
#export HISTTIMEFORMAT="%a,%y-%m-%d,%T %z"
#unset HISTFILESIZE
#export HISTSIZE=100000


# suppress history recording for the specified commands
export HISTIGNORE="ls:[bf]g:history*:clear:clear_screen:exit"

shopt -s histverify     # expand & edit a command before running it by entering [return]
shopt -s histappend # ensure that the histories from the different terms will not overwrite themselves
shopt -s cmdhist # multi-line commands are stored in the history as a single command


#### LEAVE ctrl-s to freeze terminal hopefully. also this causes "stty: stdin isn't a terminal" error when sourcing bashrc and not in a terminal
# case $OSTYPE in
#     cygwin*)
#     ;;
#     darwin*)
#         /bin/stty stop "" # enable [ctrl-s] (opposite of [ctrl-r])
#     ;;
#     linux*)
#         /bin/stty stop "" # enable [ctrl-s] (opposite of [ctrl-r])
#     ;;
#     *)
#     ;;
# esac
