#!/bin/bash
DataDir=/data
cd $DataDir

# read RepolistArray from first parameter 
getArray() {
   RepolistArray=() # Create array
    while IFS= read -r line # Read a line
    do
        RepolistArray+=("$line") # Append line to the array
    done < "$1"
}

# get repoid
if [[ $# -gt 0 ]]
then
# get one repoid from command line
 RepolistArray[0]=$1
else
# get multiple repoids from file repolist.txt
 getArray "repolist.txt"
fi

# start reposync and create repo for each repoid from RepolistArray
for RepoName in "${RepolistArray[@]}"
do
 echo "Start Download repo: $RepoName"
 reposync -n -g --repoid=$RepoName -d -p $DataDir > $DataDir/$RepoName.log 
# calculate workers  number for create repo 
 WorkersNumber=$(ls -1R $RepoName | wc -l | awk '{print 1 + int($result/100)}')
 echo Start create repodata for $RepoName with worker number $WorkersNumber
# some difference between downloads paths of RHEL packages and other
 ls $DataDir/$RepoName | grep Packages
 if (( $? == 0 ))
 then
  createrepo -s sha --workers=$WorkersNumber $DataDir/$RepoName/Packages >> $DataDir/$RepoName.log & 
 else 
  createrepo -s sha --workers=$WorkersNumber $DataDir/$RepoName >> $DataDir/$RepoName.log &
 fi
 echo "#############################################"
done
