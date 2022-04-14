# 
ROWS=$1

if [ -z "$ROWS" ] 
then
 echo
 echo "How mach processes for analyze"
 echo "usage:"
 echo " ./get_pg_hard_queries.sh 10 "
 echo " ls -ls /tmp/reports"
 echo
 exit
fi 

LIST=''
test -d /tmp/reports || mkdir /tmp/reports
OUTFILE=/tmp/reports/top_running_sessions_`date +%d.%m.%Y_%H-%M-%S`.html

echo "<pre>">> $OUTFILE
ps raux --sort=-pcpu |grep -e ^postgres -e CPU |grep -ve grep -ve "ps raux" |head -n $ROWS >> $OUTFILE
echo "</pre>">> $OUTFILE

for OUTPUT in $(ps raux --sort=-pcpu |grep -e ^postgres -e CPU |grep -ve grep -ve "ps raux" |head -n $ROWS  |awk '{print $2}');
do  
	LIST=$LIST','$OUTPUT;
done;

LIST=${LIST#*,PID,}

psql -U postgres --host=localhost --port=5432 -d postgres -H -c \
"select datname, pid, usename, query from pg_stat_activity where pid in ($LIST)" >> $OUTFILE