#!/bin/bash
service postgresql start
service ssh start
sleep 10
ambari-server start
ambari-agent start
sleep 10

/usr/jdk64/jdk1.8.0_112/bin/java -jar /tmp/ambari-shell.jar --ambari.host=sandbox << EOF
blueprint add --file /tmp/single-node-hdfs-yarn
cluster build --blueprint single-node-hdfs-yarn
cluster autoAssign
cluster create --exitOnFinish true
EOF

clear

# echo "\list" >> /tmp/1.txt
# echo "\q" >> /tmp/1.txt
# bash -c ' su -c "psql < /tmp/1.txt" postgres'
bash

lines=1
while [ $lines -gt 0 ]
do
        sleep 5
        lines=`echo tasks | /usr/jdk64/jdk1.8.0_112/bin/java -jar /tmp/ambari-shell.jar --ambari.host=sandbox | egrep '(PENDING)|(QUEUED)|(IN_PROGRESS)' | wc -l`
        echo $lines
done
amount_started=`echo 'services list' | /usr/jdk64/jdk1.8.0_112/bin/java -jar /tmp/ambari-shell.jar --ambari.host=sandbox | egrep -A 1000 'SERVICE\s+STATE' | tail -n +3 | head -n -2 | awk '{print $2}' | grep -v STARTED | wc -l`
if [ $amount_started -eq 0 ]; then
        echo "done"
        exit 0
else
        echo "there was a problem :("
        exit 1
fi

ambari-agent stop
sleep 10
ambari-server stop
sleep 10
