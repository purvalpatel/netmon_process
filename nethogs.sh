#!/bin/bash
#perl -le 'open(P,"sudo nethogs -t -v3 |");  $|=1; while(<P>){ print "------>>","$_"; }' | tee logs/nethogs.log
if [ ! -d /var/log/net_usage ]; then
	mkdir -p /var/log/net_usage
	chmod 0777 /var/log/net_usage
fi
logfile_name="net_usage.log"
logfile_path="/var/log/net_usage"
current_time=`date +%d-%m-%Y.%H.%M`

nethogs -t -v3 >/var/log/net_usage/net_usage.log
echo "Stopping process"

cd $logfile_path
echo "---------------- $current_time -------------- " >> $logfile_path/final_details.log
cat $logfile_name | tr -d '\0' > $logfile_name.1 && > $logfile_name
grep -i  ^java /var/log/net_usage/net_usage.log.1 | tail -n1 | awk '{print "comserver,"$2","$3}' | head -1 >> $logfile_path/final_details.log
grep -i  "/usr/bin/java" /var/log/net_usage/net_usage.log.1 | tail -n1 | awk '{print "tomcat,"$2","$3}' | head -1>> $logfile_path/final_details.log
echo "Stopped."
