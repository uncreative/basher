if command -v brew &>/dev/null
        then
            if [ -f `brew --prefix`/etc/autojump ]; then
              . `brew --prefix`/etc/autojump
            fi
fi

