#!/usr/bin/env python
import os, subprocess
for dirname, dirnames, filenames in os.walk('.'):
    # print path to all subdirectories first.
    for subdirname in dirnames:
        #print(os.path.join(dirname, subdirname))
        #print subdirname
        if "h008_1" in subdirname:
          command = "mv "+subdirname +" "+subdirname[:-12]+subdirname[-10:]
          print command
          #subprocess.call(command, shell=True)
    # print path to all filenames.
