#!/bin/bash

yPath=/space/code/YCSB
logFile=/space/code/scriptYCSB/logs/load_0-12M.log
mServer=ip-10-158-95-60
insertCount=10185693

rm $logFile
$yPath/bin/ycsb   \
  load mongodb \
  -P $yPath/workloads/workloada \
  -p mongodb.url=mongodb://$mServer:27017 \
  -p recordcount=128000000 \
  -s -threads 64 \
  -p mongodb.maxconnections=128 \
  -p measurementtype=timeseries \
  -p timeseries.granularity=2000 \
  -p mongodb.writeConcern=acknowledged \
  -p insertstart=0 \
  -p insertcount=$insertCount \
  | tee $logFile