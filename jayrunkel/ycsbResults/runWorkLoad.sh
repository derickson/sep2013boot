#!/bin/bash

yPath=/space/code/YCSB
mServer=ip-10-158-95-60
opCount=1000000
tStart=13
tEnd=17
tInc=2
cStart=1
cEnd=17
cInc=2
logFile=/space/code/scriptYCSB/logs/regression12GB$tStart-$tInc-${tEnd}_$cStart-$cInc-$cEnd.log


rm $logFile

for threads in `seq $tStart $tInc $tEnd`;
do
    for connections in `seq $cStart $cInc $cEnd`;
    do
	echo "==================================================================="
        echo "RUNNING TEST> threads: $threads,  connections: $connections"
       
	$yPath/bin/ycsb \
	    run mongodb \
	    -P $yPath/workloads/workloadc \
	    -p mongodb.url=mongodb://$mServer:27017 \
	    -p recordcount=128000000 \
	    -s -threads $threads \
	    -p operationcount=$opCount \
	    -p mongodb.maxconnections=$connections \
	    -p measurementtype=timeseries \
	    -p timeseries.granularity=2000 \
	    -p mongodb.writeConcern=acknowledged \
	    -p insertstart=0 \
	    -p insertcount=2000000 \
	    | tee -a $logFile
    done
done    
