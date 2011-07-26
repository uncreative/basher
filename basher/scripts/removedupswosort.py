#!/usr/bin/python
from __future__ import generators
import os, sys
import shutil


#from collections import defaultdict
#cd ~ && rm -rf bashconfig && tar xvf bashconfig.tar && cd ~/bashconfig && sh ./installjustforme.sh
#rsync -av --exclude=*.svn* /local/keepsvndir/code/scripts/bashconfig alpha: && ssh alpha cd ~/bashconfig && sh ./installjustforme.sh && echo "bash" >> ~/.zshrc
#rsync -av --exclude=*.svn* /local/keepsvndir/code/scripts/bashconfig gamma: && ssh gamma 'cd ~/bashconfig && sh ./installjustforme.sh && echo "bash" >> ~/.zshrc'
#rsync -av --exclude=*.svn* /local/keepsvndir/code/scripts/bashconfig prod: && ssh prod 'cd ~/bashconfig && sh ./installjustforme.sh && echo "bash" >> ~/.zshrc'


True, False = 1, 0

def enumerate(obj):
    for i, item in zip(range(len(obj)), obj):
        yield i, item

def main(filename):
    print "copying %s -> %s" % (filename, filename + '.bak')
    shutil.copyfile(filename, filename + '.bak')

    #dread = defaultdict(list)
    dread = {}
    #with open(filename) as inp:
    inp = None
    try:
        inp = open(filename)
        lread = inp.readlines()
    finally:
        if inp is not None:
            inp.close()

    for i,l in enumerate(lread):
        dread.setdefault(l.strip(), []).append(i)


    #with open(filename, 'w') as out:
    
    out = None
    try:
        out = open(filename, 'w')
        for i,l in enumerate(lread):
            latest = dread[l.strip()][-1]
            #print "%s at %d, latest = %d" % (l, i, latest)
            if latest == i:
                out.write(l.strip() + os.linesep)
    finally:
        if inp is not None:
            out.close()

    print "cleaned up %s from %d lines to %d lines" % (filename, len(lread), len(dread.keys()))

if __name__=="__main__":
    args = sys.argv[1:]
    if len(args) == 0:
        sys.stderr.write("Please provide a file from which to remove duplicates!")
    if len(args) > 1: 
        sys.stderr.write("Too many arguments. Please provide one file from which to remove duplicates!")
    main(args[0])
