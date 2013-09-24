#!/usr/bin/env python
# encoding: utf-8
"""
generate a .p4 file with P4CLIENT='correct-p4-client' for every client for given user if that line does not already exist
"""
__author__ = "Ayelet Goldin (ayelet.goldin@gmail.com)"
__version__ = "0.1"
__copyright__ = "Copyright (c) 2011-2011 Ayelet Goldin"
__license__ = "This script is in the public domain, free from copyrights or restrictions"

import logging
import time
from optparse import OptionParser
import subprocess
import re
import os
import sys
# regular expression to match client name to root path from the output of p4 clients
reClientNameToRootPath = re.compile("Client\s+(\S*)\s+\d{4}/\d{2}/\d{2}\s+root\s+([^']*)\s+'.*'")


class ClientSkipException(Exception):
    pass


def ConstructCommand(command):
    path = RunCommand('launchctl getenv PATH')
    return 'export PATH=%s:$PATH && %s' % (path, command)


def RunCommand(command):
    p = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    result, err = p.communicate()

    if len(err) > 0:
        raise Exception("error when running %s: %s " % (command, err))
    return result, err


def getP4ClientsForUser(p4user):
    command = ConstructCommand('p4 clients -u %s' % p4user)
    clientsForUserResult, err = RunCommand(command)
    clientsForUserResult = clientsForUserResult.strip()
    return clientsForUserResult.splitlines(True)


def getHostForClient(p4client):
    command = ConstructCommand('p4 client -o %s|grep "^Host"' % p4client)
    clientHostResult, err = RunCommand(command)
    clientHostResult = clientHostResult.strip()
    if len(clientHostResult) == 0:
        return ''
    clientHostResultWithoutHost = re.search(r'^Host:\s+(.*)', clientHostResult)
    if clientHostResultWithoutHost and len(clientHostResultWithoutHost.groups()) > 0:
        return clientHostResultWithoutHost.groups()[0].lower()
    else:
        raise ClientSkipException("Failed to parse host for client %s found host string: %s" % (p4client, clientHostResultWithoutHost))


def clientPossiblyBelongsToThisHost(p4clientHost, p4host):
    return p4clientHost.lower().strip() == p4host.lower().strip() or p4clientHost == ""


def p4LineNeeded(dotp4path, varToSet, valToSet):
    if os.path.isfile(dotp4path):
        with open(dotp4path) as dotp4in:
            for line in dotp4in:
                match = re.compile('\s*%s\s*=\s*(.*)\s*$' % varToSet).search(line)
                if match:
                    if len(match.groups()) == 1 and match.groups()[0] == valToSet:
                        logging.info("correct file for %s already exists" % valToSet)
                        return False
                    else:
                        raise ClientSkipException("incorrect line %s exists on %s %s should be set to %s" % (line, dotp4path, varToSet, valToSet))
    return True


def generateP4ConfigFiles(p4user, p4host, varsToSet):
    loglevel=logging.DEBUG

    p4files = []
    skipped = []
    skippedForPotentialHost = []

    clientsToProcess = getP4ClientsForUser(p4user)
    logging.info("%d clients to process" % len(clientsToProcess))

    for p4clientParts in clientsToProcess:
        try:
            logging.info("process %s" % p4clientParts)

            match = reClientNameToRootPath.match(p4clientParts)
            p4client, clientRootPath = match.groups()
            # convert all paths to "os.sep" slashes
            convertedClientRootPath = clientRootPath.replace('\\', os.sep).replace('/', os.sep)
            p4clientHost = getHostForClient(p4client)
            logging.info("checking if '%s' matches '%s'" % (p4clientHost, p4host))

            if clientPossiblyBelongsToThisHost(p4clientHost, p4host):
                varsToSet['P4CLIENT'] = p4client
                if not os.path.isdir(convertedClientRootPath):
                    raise ClientSkipException("found potential client %s with host '%s' for path %s, but no matching path. Not writing this p4 file" % (p4client, p4host, convertedClientRootPath))
                else:
                    for varToSet, valToSet in varsToSet.items():
                        p4Line = "%s=%s" % (varToSet, valToSet)
                        dotp4path = os.path.join(convertedClientRootPath, ".p4")

                        if p4LineNeeded(dotp4path, varToSet, valToSet):
                            p4files.append(p4client)
                            with open(dotp4path, 'a+') as dotp4out:
                                dotp4out.write(os.linesep + p4Line)
                        else:
                            logging.debug("client '%s' already has %s" % (p4client, p4Line))
            else:
                skipped.append(p4client)
                logging.info("client %s host '%s' does not match" % (p4client, p4clientHost))
        except ClientSkipException, e:
            logging.warn("skipping %s because of ERROR: %s" % (p4clientParts, e.message))
            skippedForPotentialHost.append(p4client)
    return p4files, skipped, skippedForPotentialHost


def readOptions(argv):
    """
    parse command line options
    """
    parser = OptionParser(usage=globals()['__doc__'], version=__version__,)
    parser.add_option("--debug", action="store_true", dest="debug", default=False, help="make even more noise")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False, help="make lots of noise")
    parser.add_option("-q", "--quiet", action="store_false", dest="verbose", help="be vewwy quiet (I'm hunting wabbits)  [default]")

    try:
        options, args = parser.parse_args(argv)
        if len(args) < 2:  # must provide integer values and command
            raise Exception("You must supply a p4user and p4host")
        if len(args) > 2:  # must provide two arguments
            raise Exception("Too many arguments (%d) %s. Provide a two arguments: p4user and p4host." % (len(args), ','.join("'%s'" % arg for arg in argv)))
        p4user = args[0]
        p4host = args[1]

        if options.verbose:
            loglevel = logging.INFO
        else:
            loglevel = logging.WARNING
        if options.debug:
            loglevel = logging.DEBUG

        logging.basicConfig(level=loglevel)

    except Exception, e:
        parser.error(e)

    return p4user, p4host


def main(argv=None):
    loglevel=logging.WARNING
    if argv is None:
        argv = sys.argv[1:]

    p4user, p4host = readOptions(argv)  # setup any options (verbose / warn or quit on bad input)

    starttime = time.time()
    logging.info("generating %s files for user %s on host %s" % ('.p4', p4user, p4host))
    varsToSet = {}  # for example: {'P4USER': p4user, 'P4HOST': p4host}
    p4files, skipped, skippedForPotentialHost = generateP4ConfigFiles(p4user, p4host, varsToSet)
    logging.info("generated %s" % ', '.join(p4files))
    logging.warn("skipped %s" % ', '.join(skipped))
    logging.warn("skippedForPotentialHost %s", ', '.join(skippedForPotentialHost))

    logging.info("generated in %f seconds" % (time.time() - starttime))
    sys.exit(0)


if __name__ == "__main__":
    sys.exit(main())
