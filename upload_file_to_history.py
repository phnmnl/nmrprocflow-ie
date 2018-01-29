#!/usr/bin/python

from bioblend.galaxy import GalaxyInstance
import sys
import os

if len(sys.argv) != 2:
    print('Usage: ./upload_file_to_history.py filename')
    sys.exit(1)

print "Upload file "+sys.argv[1]+" to Galaxy URL "+os.environ['GALAXY_URL']
gi = GalaxyInstance(url=os.environ['GALAXY_URL'], key=os.environ['API_KEY'])
gi.tools.upload_file(sys.argv[1], os.environ['HISTORY_ID'])
