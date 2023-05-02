#!/bin/sh
#Recieves one argument , the ip or the fqdn of the server gitlab is running on
echo Gitlab server status  is using address: $1

health_status=0
readiness_status=0
liveness_status=0

# get the health status of gitlab
health=$(curl http://$1/-/health)

if [ "$health" != "GitLab OK" ]
then
        health_status=$((health_status+1))

fi

echo Health returned $health
# get the readiness status of gitlab
readiness=$(curl http://$1/-/readiness | grep -o '"status":"[^"]*' | grep -o '[^"]*$'| head -1)

if [ "$readiness" != "ok" ]
then
        readiness_status=$((readiness_status+1))
fi
echo Readiness returned $readiness 

# get the liveness status of gitlab
liveness=$(curl http://$1/-/liveness| grep -o '"status":"[^"]*' | grep -o '[^"]*$')

if [ "$liveness" != "ok" ]
then
        liveness_status=$((liveness_status+1))
fi
echo Liveness returned $liveness
#overall status of gilab
#should be 0 for a return of OK in Icinga2 , else it returns 2 which gives a status of CRITICAL in Icinga2
status=$((health_status+readiness_status+liveness_status))

if [ "$status" = 0 ]
then
        return 0
else
        return 2
fi
    
