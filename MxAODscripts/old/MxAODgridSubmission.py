#!/usr/bin/env python
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                             #
# Grid Submission Script for Making MxAODs using HGam Framework               #
# Author : Tony Thompson <athompso@cern.ch>                                   #
# Date   : June 2015                                                          #
# Description: This script works by copying a base config file and            # 
# adding a GridDS and OutputDS to the copy for each dataset specfied          #
# in the input files txt file.  It then uses these config files in            #
# calling the "runHGamCutflowAndMxAOD" command to create the MxAOD on         #
# the grid.  It could easily be modified for analysis submission to the grid. #
#                                                                             #
# Notes:                                                                      #
# mc15 file names are truncated for the output file because they are too long #
#   for grid submission.  The current trucation leaves only the p-tag and     #
#   changes "PowhegPythia" to "PP" and removes "EvtGen"                       #
#                                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
import shutil, os, subprocess, re
from sys import exit

hTag = "002"

baseDir         = os.getcwd() 
configsFolder   = baseDir + "/configs/"
baseConfigName  = "baseConfig.cfg"
baseConfigPath  = configsFolder+baseConfigName
inputFileName   = "inputFiles.txt"
gridUserName    = "athompso"

# mc15 MxAOD renaming 2d list, insert rule as list like [pattern, replacement]
# can include regex
rules = [
[r'e\d\d\d\d_s\d\d\d\d_s\d\d\d\d_r\d\d\d\d_r\d\d\d\d_',""],
["EvtGen",""],
]

with open(inputFileName) as f:
    content = f.readlines()

if len(content) == 0:
    print "warning! no input files.  Exiting..."
    exit(0)

configs= []
for DSname in content:
    newDSname = ""
    gridFileName = ""
    GridDS   = "GridDS: " + DSname[:-1]

    if "data15" in DSname:
        newDSname = DSname[13:-2]
        gridFileName = "user."+gridUserName+".MxAOD." + newDSname +"_h" + hTag
        OutputDS = "OutputDS: " + gridFileName
    elif "mc15" in DSname:
        newDSname = DSname[11:-2]
        for rule in rules: newDSname = re.sub(rule[0],rule[1],newDSname)
        gridFileName = "user."+gridUserName+".MxAOD." + newDSname +"_h" + hTag
        OutputDS = "OutputDS: " + gridFileName
    else:
        print "wtf u doin, not data15 or mc15 file? skipping file " + DSname
        continue

    newConfigName = newDSname +".cfg"
    newConfigPath = configsFolder + newConfigName
    shutil.copy2(baseConfigPath, newConfigPath)
    with open(newConfigPath, "a") as myfile:
        myfile.write(GridDS + "\n" + OutputDS +"\n")
    with open("gridFileNames.txt", "a") as myfile:
        myfile.write(gridFileName + "\n")
    configs.append(newConfigName)

# current logic is to make the config files, then try to submit them.
#   This easier allows resubmission of specific files
for config in configs:
    command = "runHGamCutflowAndMxAOD configs/"+config
    print command
    subprocess.call(command,shell=True)
