terminal configuration with bash
================================

bash editing in terminal
-------------------------
* up / down searches history
* match all files including hidden files
* when pressing tab for completion, show all the options if there's more than one
* ignore case when completing

prompt
-------------------------
<pre>environment <b>yourusername@yourhost:/path/to/current/dir</b> [lastcommandnumber]$</pre>

* environment:
if current server is production, there will be a red background with gray word saying prod
if current server is test or labs, yellow
otherwise (and by default) it is development and has normal black color
to change environment create a file in ~/.etc/server-role or ~/.server-role

* [lastcommandnumber] yellow if last command exited without error codes, or red if there was a non-zero exit code

* if you have jobs running in the background ( by using & or ctrl-z )
the prompt will indicating how many:
<pre>environment <b>yourusername@yourhost:/path/to/current/dir (numberofjobs)</b> [lastcommandnumber]$</pre>

* if you are in a directory which is a git repository the name of the current branch will show: 
<pre>environment <b>yourusername@yourhost:/path/to/current/dir (nameofbranch)</b> [lastcommandnumber]$</pre>


misc
-------------------------
* confirm before remove / overwrite
* color ls output
* color grep output
* use lesspipe if there
* better autocompletion for ssh, uses .ssh/config and potentially bonjour
* better autocompletion for xcode
* recursively remove from current directories annoying files: rm .svn (rmsvn), DS_Store (rmDS_STORE) and pyc (rmpyc)
* alias for showing python site packages: pysitepackages 
* wrangle : open with textwrangle in OS X
* dashboardkill : kill dashboard screen in OS X
* hibernateon | hibernateoff : allow hibernation sleep mode in OS X

net alias
-------------------------
* scpresume : copy remotely (or locally) using rsync with resume capabilities	
* myip : show my external ip
* ips : show my various local ip (wifi, ethernet etc)

use fancy cd function that allows :
-------------------------
```bash
cd --
# to see a list of recent directories, with a numerical menu
cd -2
# to go to the second-most recent directory.
```

history
-------------------------
* automatically remember last month's history file for every month in ~/.history directory
new file for the current month is created and contains last 1500 lines from last month's file

* maximum file size: 500000
* ensure histories from multiple running terminals don't overwrite themselves
* multi-line commands are stored in the history as a single command

* expand commands and allow editing them before running them: ie, when you type !-1 pressing enter would usually run the previous command, now it will show the previous command allowing you to change it first. 
for instance you can do: 

```bash
$ python snake.py --width 10 --height 10 --timeBetweenUpdates 0.5 --verbose
$ ^snake^worm
# normally this would just run: 
# python worm.py --width 10 --height 10 --timeBetweenUpdates 0.5 --verbose
# instead in our case you'll it'll be expanded in the terminal as a line you are typing to 
$ python worm.py --width 10 --height 10 --timeBetweenUpdates 0.5 --verbose
# and you would verify this is the command you wanted and make edits before running.
```

svn: 
-------------------------
* svnundocommit : merge the previous version from svn
* sup : svn update and show what has changed
* better autocompletion
* svnchangessince.sh script to see log of changes since last update


scripts
-------------------------
* proxy scripts to try and use ipfw natd and ssh tunnels as fake vpn
* ssh-copy-id script so that you don't have to type your passwords when ssh-ing
* xcodeunlockp4: script behavior to tell xcode what to do when a file is locked and you are using xcode


Install
================================

```bash
mkdir ~/Code && cd ~/Code
git clone https://github.com/uncreative/basher.git
mkdir ~/.etc && cd ~/.etc
ln -s ~/Code/basher/bashrc.hostspecific.sh .
ln -s ~/Code/basher .
ln -s ~/Code/.inputrc ~/
ln -s ~/Code/.bashrc ~/
mkdir ~/.history
mkdir ~/.ssh
touch ~/.ssh/config
```

in .bash_profile or whichever file OS X now reads when you start terminal, append:
```bash
        source $HOME/.bashrc # get some extra functions and configs
```

to make additional user specific configurations that are remembered in Dropbox:
```
mkdir -p ~/Dropbox/config
touch ~/Dropbox/config/.bashrc.user.sh
ln -s ~/Dropbox/config/.bashrc.user.sh ~/
# make changes to above with your favorite editor
```
