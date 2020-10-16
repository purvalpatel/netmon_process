# netmon_process
Network Monitoring per process

Monitor network incoming and outgoing traffic process wise.

Dependencies:
apt-get install nethogs screen

How to start:
netfilter.sh Filter

restart:
netfilter.sh restart

List total bandwidth usage per process.
netfilter.sh total

Logs:
/var/log/net_usage/
net_usage.log - every process logs stored in this file.
net_details - bandwidth during filter logs are stored in this file.
final_details.log - service restart time logs stored in this file.
total_usage.txt - total-usage till date stored in this file.

