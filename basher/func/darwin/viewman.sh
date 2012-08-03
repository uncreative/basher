# Open a manpage in Preview, which can be saved to PDF
pman()
{
   man -t "${1}" | open -f -a /Applications/Preview.app
}
# this command uses bwana/safari as a manpage viewer: doesn't work
#aman () {
#	open man:$* ; 
#}

