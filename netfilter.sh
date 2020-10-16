#!/bin/bash
##
# /root/network/netfilter.sh Filter - call from crontab in very 5 minutes
#*/5 * * * * /root/network/netfilter.sh Filter

# /root/network/netfilter.sh restart - call from crontab in very 1 hour
#*/59 * * * * /root/network/netfilter.sh restart

# /root/network/netfilter.sh total - Display total Sent and Received network bandwidth
# 
logfile_path="/var/log/net_usage"
if [ "$1" == "Filter" ]; then
	CHK=`ps -ef | grep -i "nethogs -t -v3" | grep -v grep`
	if [ ! -n "$CHK" ]; then
                pids=$(ps -ef | grep -i netmon | grep -v grep | awk '{print$2}' | tr '\n' ' ')
                if [ -n "$pids" ]; then
                        kill -9 $pids
                        screen -wipe
                fi
		screen -X -S netmon quit
		sleep 3
		screen -Sdm netmon
		screen -S netmon -X stuff $'cd /root/network\n'
		screen -S netmon -X stuff $'./nethogs.sh\n'
	fi

	current_time=`date +%d-%m-%Y.%H.%M`
	current_dir=`pwd`
	log_type="net_usage"
	logfile_name="net_usage.log"
	logfile_path="/var/log/net_usage"

	if [ ! -d $logfile_path ]; then
		mkdir -p $logfile_path
		touch $logfile_path/$logfile_name
	fi

	cd $logfile_path

	size_log=`du -k $logfile_name | awk '{print $1}'`
	threshold_log=3000

	if [[ "$size_log" -gt "$threshold_log" ]]; then
		echo "$current_time file size greater than 3mb" >> $logfile_path/check_status.log
		echo "---------------- $current_time -------------- " >> $logfile_path/net_details
		cat $logfile_name | tr -d '\0' > $logfile_name.1 && > $logfile_name
		grep -i  ^java /var/log/net_usage/net_usage.log.1 | tail -n1 | awk '{print "comserver,"$2","$3}' >> $logfile_path/net_details
		grep -i  "/usr/bin/java" /var/log/net_usage/net_usage.log.1 | tail -n1 | awk '{print "tomcat,"$2","$3}' >> $logfile_path/net_details
	else
		echo "$current_time file size less than 1mb" 
	fi

elif [ "$1" == "total" ]; then
	grep -i "tomcat" /var/log/net_usage/final_details.log | cut -d',' -f2 >/tmp/.tom_sent
	grep -i "tomcat" /var/log/net_usage/final_details.log | cut -d',' -f3 >/tmp/.tom_recv

	grep -i "comserver" /var/log/net_usage/final_details.log | cut -d',' -f2 >/tmp/.com_sent
	grep -i "comserver" /var/log/net_usage/final_details.log | cut -d',' -f3 >/tmp/.com_recv


	tts=`perl -nle '$sum += $_ } END { print $sum' /tmp/.tom_sent`
	ttr=`perl -nle '$sum += $_ } END { print $sum' /tmp/.tom_recv`

	tcs=`perl -nle '$sum += $_ } END { print $sum' /tmp/.com_sent`
	tcr=`perl -nle '$sum += $_ } END { print $sum' /tmp/.com_recv`

	echo "========== Tomcat ==========" >$logfile_path/total_usage.txt
	echo "Tomcat_sent=$tts MB" >>$logfile_path/total_usage.txt
	echo "Tomcat_Recv=$ttr MB" >>$logfile_path/total_usage.txt

	echo "========== Comserver ========" >>$logfile_path/total_usage.txt
	echo "Total_sent=$tcs MB" >>$logfile_path/total_usage.txt
	echo "Total_Recv=$tcr MB" >>$logfile_path/total_usage.txt

	cat $logfile_path/total_usage.txt
elif [ "$1" == "restart" ]; then
	echo "Restarting nethogs service"
	logfile_name="net_usage.log"
	logfile_path="/var/log/net_usage"
	current_time=`date +%d-%m-%Y.%H.%M`

	echo "Stopping process"
	cd $logfile_path
	echo "---------------- $current_time -------------- " >> $logfile_path/final_details.log
	cat $logfile_name | tr -d '\0' > $logfile_name.1 && > $logfile_name
	grep -i  ^java /var/log/net_usage/net_usage.log.1 | tail -n1 | awk '{print "comserver,"$2","$3}' | head -1 >> $logfile_path/final_details.log
	grep -i  "/usr/bin/java" /var/log/net_usage/net_usage.log.1 | tail -n1 | awk '{print "tomcat,"$2","$3}' | head -1>> $logfile_path/final_details.log
	echo "Stopped."
	echo "Restarting...."

	/root/network/netfilter.sh total
	pids=`ps -ef | grep -i "nethogs -t" | grep -v grep | awk '{print$2}' | tr '\n' ' '`
	kill -9 $pids

        pids=$(ps -ef | grep -i netmon | grep -v grep | awk '{print$2}' | tr '\n' ' ')
        if [ -n "$pids" ]; then
        	kill -9 $pids
		sleep 2
                screen -wipe

        fi

        screen -X -S netmon quit
        sleep 3
        screen -Sdm netmon
        screen -S netmon -X stuff $'cd /root/network\n'
        screen -S netmon -X stuff $'./nethogs.sh\n'

else
	echo "Invalid parameter"
fi
