# Does an svn up and then displays the changelog between your previous
# version and what you just updated to.
svn_up_and_log()
{
  local old_revision=`svn_revision $@`
  local first_update=$((${old_revision} + 1))
  svn up -q $@
  if [ $(svn_revision $@) -gt ${old_revision} ]; then
    svn log -v -rHEAD:${first_update} $@
  else
    echo "No changes."
  fi
}


grep_exclude_svn()
{
#http://www.microshell.com/sysadmin/unix/customizing-grep-tool-to-exclude-svn/
if [ $# = 1 ]
then
	grep -iR "$1" * | grep -v "\.svn\/"
elif [ $# = 2 ]
then
	grep -iR "$1" $2/* | grep -v "\.svn\/"
else
	echo "Too many parameters"
fi
}



wc_find_grep(){
#http://rhubbarb.wordpress.com/2011/02/05/svn-tip-findgrep/
### Find and Grep for Working Copies
### $1 = start directory
### $2 = file glob
### $3 = string pattern

if [ "$3" == "" ] ; then
 echo "working-copy find and grep"
 echo "syntax: ./wc_find_grep \${start_dir} \${file_glob} \${string_pattern}"
else
 find "$1" -regextype posix-extended \
 -regex ".*(\.svn)" \
 -prune -or \
 -iname "$2" \
 -exec grep --with-filename --line-number "$3" \{\} \;
fi
may be used to find strings within files with names matching a certain pattern, using a command

#better_grep . "filename_glob" "string_regex"
}