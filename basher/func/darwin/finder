# this command changes the working dir to the front-most window of the Finder
cdf()
{
eval cd "`osascript -e 'tell app "Finder" to return the quoted form of the POSIX path of (target of window 1 as alias)' 2>/dev/null`"
pwd
}