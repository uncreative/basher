#!/usr/bin/python
# example usage: findreplace.py . "2 apparel" "apparel"  --recursive
from optparse import OptionParser
import re, string
import subprocess
import sys, os
from os.path import join
import fileinput
import logging
logging.basicConfig(level=logging.DEBUG)

dry = False

def istext(path):
    return (re.search(r':.* text',
                      subprocess.Popen(["file", '--mime', path], 
                                       stdout=subprocess.PIPE).stdout.read())
            is not None)
            

def validFile(fi, exts):
    global options

    valid =  (not options.skipinvisble or (options.skipinvisble and not os.path.split(fi)[1].startswith('.')))  \
    and (exts is None or exts.count(os.path.splitext(fi)[1]) > 0) \
    and os.path.isfile(fi) \
    and (not options.skipbinary or (options.skipbinary and istext(fi)))
    return valid
    
#    if valid:
#        sys.stdout.write( 'valid %s, isbinary: %r, isvisible: %r, isfile: %r, has extension: %s' % (fi,  istext(fi), not os.path.split(fi)[1].startswith('.'), os.path.isfile(fi), os.path.splitext(fi)[1]) )

    
def locate(exts, root=os.curdir):
    '''Locate all files matching supplied filename pattern in and below
    supplied root directory.'''
    global options
    for path, dirs, files in os.walk(os.path.abspath(root)):
        if options.skipinvisble:
            for d in dirs:
                if d.startswith('.'):
                    dirs.remove(d)
        
        for fi in files:
            fullfipath = os.path.join(path, fi)
            if validFile(fullfipath, exts):                
                yield fullfipath

def searchreplace(startpath,search,replace,exts=None):
    global dry, options
    
    # replace a string in multiple files
    #filesearch.py
    
    sys.stdout.write("\nreplacing %s\twith %s\t in files within: %s\n"% (search, replace, startpath))            
    
    if not options.recursive:
        import glob
        files = glob.glob(startpath + "/*")
        files = [fi for fi in files if validFile(fi, exts)]
    else: 
        files = locate(exts, startpath)
    
    for fi in files:
        replacecount = 0
        #logging.debug("in %s" % fi)
        for line in fileinput.input(fi,inplace=1):
            lineno = 0
            lineno = string.find(line, search)
            if lineno >0:
                replacecount += 1                            
                if not dry:
                    line =line.replace(search, replace)
            sys.stdout.write(line)
                
            #logging.debug("replaced in %s:\t\t%s"% (fi,line))
        if replacecount > 0:
            logging.info("replaced %d\tlines in %s"% (replacecount,fi))            


def readoptions(argv, filearg=True):
    global dry

    usage = '''usage: %prog [options] path search replace extensions|separated|by|pipe'''
    parser = OptionParser(usage=usage)
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=True, help="make lots of noise [default]")
    parser.add_option("-q", "--quiet", action="store_false", dest="verbose", help="be vewwy quiet (I'm hunting wabbits)")
    parser.add_option("--skip_binary_files", action="store_true", dest="skipbinary", default=True, help="Process a binary file as if it did not contain matching data")
    parser.add_option("--include_binary_files", action="store_false", dest="skipbinary", default=True, help="Check a binary file for matching data")
    parser.add_option("--recursive", action="store_true", dest="recursive", default=False, help="Process files in subdirectories as well")
    parser.add_option("--include_invisible_files", action="store_false", dest="skipinvisble", default=True, help="include files that start with a dot")
    parser.add_option("--dry", dest="dry", action="store_true", default=False, help="do no harm")
    
    options, args = parser.parse_args(argv)
    

    if options.verbose:
        loglevel = logging.DEBUG
    else:
        loglevel = logging.WARNING

    logging.basicConfig(level=loglevel)

    if len(args) == 3:
        extensions = None
    elif len(args) == 4:
        extensions = args[3].split('|')
    else:
        raise Exception("there must be 3 or 4 arguments. you provided %d" % len(args))  
        
    dry = options.dry    

    return options, args[0], args[1], args[2], extensions

def main(argv=None):
    global options
    loglevel=logging.DEBUG #logging.WARNING
    if argv is None:
        argv = sys.argv[1:]
    
    options, path, search, replace, extensions = readoptions(argv)
    
    searchreplace(path, search, replace, extensions)
    print "done"
    

if __name__ == "__main__":
    sys.exit(main())

