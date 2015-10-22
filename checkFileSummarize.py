#!/usr/bin/env python

# @file:    checkFileSummarize.py
# @date:    June 2015
# @author   Tony Thompson <athompso@cern.ch
#
# usage:   ./checkFileSummarize aod.pool.root
#          ./checkFileSummarize aod.pool.root*  (works with multiple files)
# must setup AthAnalysisBase first! 
# e.g. asetup AthAnalysisBase,2.1.30,here

from optparse import OptionParser
import subprocess, sys, time


parser = OptionParser(usage="usage: %prog [-f] my.file.pool")
p = parser.add_option

p("-f" , "--file" , dest = "fileName", help = "The path of the POOL file to analyze")

(options,args) = parser.parse_args()

fileNames = []

if len(args) > 0:
    fileNames =  [arg for arg in args if arg[0] != "-"]
    pass
if options.fileName == None and len(fileNames) == 0:
    str(parser.print_help() or "")
    sys.exit(1)

print "================================================================================\n"
for inputDataset in fileNames:
    
    cTime = time.strftime("%H%M%S")
    output = "output"+cTime+".txt"
    
    if( subprocess.call("checkFile.py "+inputDataset+" >"+output,shell=True) != 0):
        print "Error calling checkFile.py! Did you run asetup?"
        print "Ex: asetup AthAnalysisBase,2.1.30,here"
        subprocess.call("rm "+output,shell=True)
        sys.exit(1)
      
    with open(output) as f:
        content = f.readlines()
    subprocess.call("rm "+output,shell=True)
    
    print "\nfile: " + inputDataset
    
    lines = content[13:]
    
    info = []
    for line in lines:
        if  "================================================================================" not in line:
            info.append(line)
        else:
            break
    sizes = []
    names = []
    
    tempLine = info[1]
    Nevents  = int( tempLine[60:71].replace(" ","") )
    
    for line in info:
        sizes.append( float( (  line[16:38].replace(" ","")      ).replace("kb","") )   )
        names.append(line[75:-1])
    #print sizes
    #print names
    # Note: Please don't add variable strings that are subsets of other variable strings    
    catNames =  ["EventFormat","EventInfo", "HGamEventInfo", "HGamPhotons", "HGamElectrons",  "HGamMuons", "HGamAntiKt4EMTopoJets" , "Total of these categories","Total of file"]
    totalSizes= [0] * len(catNames)
    totalNvar = [0] * len(catNames)

    for name in names:
        with open("variables.txt", "a") as f:
            f.write("="+name+"= <br />\n")
    
    
    for i in range(0, len(sizes)):
        for j in range( 0, len(catNames)-1  ):
          if names[i].startswith(catNames[j]):
              totalSizes[j]  += sizes[i]
              totalNvar[j]   += 1
              totalSizes[-2] += sizes[i] 
              totalNvar[-2]  +=1
        totalSizes[-1] += sizes[i]
        totalNvar[-1]  += 1
    fmt ='{0:35} {1:>6} {2:>30}'
    print fmt.format("", "Nvar", "disk space (kb/kevt)")
    for i in range(0, len(catNames)):
        print fmt.format( catNames[i]  ,totalNvar[i]   ,'%.3f'  % (totalSizes[i]/(Nevents/1000))   )
    
    if not totalSizes[-1] == totalSizes[-2]:
        print "Warning! The total of these categories does not match"
        print "  the total of the file!  Need to add new category to catNames!"

    print "================================================================================\n"
