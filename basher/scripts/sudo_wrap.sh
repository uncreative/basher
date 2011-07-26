# Wrap sudo to handle aliases and functions
# Wout.Mertens@gmail.com
#
# Comments and improvements welcome

echo "sourcing sudo_wrap"
sudo () 
{
        echo "[[[[[[[[[[[[ sudo_wrap"
        local c o t parse

        # Parse sudo args
        OPTIND=1
        while getopts xVhlLvkKsHPSb:p:c:a:u: t; do
                if [ "$t" = x ]; then
                        parse=true
                else
                        o="$o -$t"
                        [ "$OPTARG" ] && o="$o $OPTARG"
                fi
        done
        shift $(( $OPTIND - 1 ))

        # If no arguments are left, it's a simple call to sudo
        if [ $# -ge 1 ]; then
                c="$1";
                shift;
                case $(type -t "$c") in 
                "")
                        echo No such command "$c"
                        return 127
                        ;;
                alias)
                        c="$(type "$c"|sed "s/^.* to \`//;s/.$//")"
                        ;;
                function)
                        c=$(type "$c"|sed 1d)";\"$c\""
                        ;;
                *)
                        c="\"$c\""
                        ;;
                esac
                if [ -n "$parse" ]; then
                        # Quote the rest once, so it gets processed by bash.
                        # Done this way so variables can get expanded.
                        while [ -n "$1" ]; do
                                c="$c \"$1\""
                                shift
                        done
                else
                        # Otherwise, quote the arguments. The echo gets an extra
                        # space to prevent echo from parsing arguments like -n
                        # Note the lovely interactions between " and ' ;-)
                        while [ -n "$1" ]; do
                                c="$c '$(echo " $1"|sed -e "s/^ //" -e "s/'/'\"'\"'/")'"
                                shift
                        done
                fi
                # Run the command with verbose options
                echo Executing sudo $o -- bash -x -v -c "$c" >&2
                command sudo $o bash -xvc "$c"
        else
                echo sudo $o >&2
                command sudo $o
        fi
}