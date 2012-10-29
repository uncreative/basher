# completions

if [ -f /sw/etc/bash_completion ]; then
    source /sw/etc/bash_completion
    COMPLETION_AVAILABLE=1

elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
    COMPLETION_AVAILABLE=1
elif [ -f $ETC/bash_completion ]; then
    source $ETC/bash_completion
    COMPLETION_AVAILABLE=1
fi

if command -v brew &>/dev/null
        then
            if [ -f `brew --prefix`/etc/bash_completion ]; then
                . `brew --prefix`/etc/bash_completion
                COMPLETION_AVAILABLE=1
            fi
fi


if [ "$COMPLETION_AVAILABLE" == "1" ]; then
    for cmd in $BASHINITPATH/completion/* ; do
        source $cmd
    done
fi



if [ -f ~/mule/bin/mule_completion.sh ]; then
    source ~/mule/bin/mule_completion.sh
fi

COMP_CONFIGURE_HINTS=True
shopt progcomp > /dev/null || shopt -s progcomp # make sure Bash programmable completion is enabled


# http://hints.macworld.com/article.php?story=20100113142633883&query=%2525s
complete -o default -o nospace -W "$(/usr/bin/env ruby -ne 'puts $_.split(/[,\s]+/)[1..-1].reject{|host| host.match(/\*|\?/)} if $_.match(/^\s*Host\s+/);' < $HOME/.ssh/config)" scp sftp ssh scpresume rsync


# completion from macports
if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi
