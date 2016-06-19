#echo "============================================"
#echo "Multi Failure Scenario"
#echo "============================"

grade=0

magic=`head -1 ${1}`
if [ ${magic} -ne 131 ]
then
     echo ${grade}
     exit
fi

joincount=`grep joined  $1 | cut -d" " -f2,4-7 | sort -u | wc -l`
if [ $joincount -eq 100 ]; then
	grade=`expr $grade + 10`
else
	joinfrom=`grep joined  $1 | cut -d" " -f2 | sort -u`
	cnt=0
	for i in $joinfrom
	do
		jointo=`grep joined  $1 | grep '^ '$i | cut -d" " -f4-7 | grep -v $i | sort -u | wc -l`
		if [ $jointo -eq 9 ]; then
			cnt=`expr $cnt + 1`
		fi
	done
	if [ $cnt -eq 10 ]; then
		grade=`expr $grade + 10`
	fi
fi
failednode=`grep "Node failed at time" $1 | sort -u | awk '{print $1}'`
tmp=0
cnt=0
for i in $failednode
do
        failcount=`grep removed  $1 | sort -u | grep $i | wc -l`
        if [ $failcount -ge 5 ]; then
                tmp=`expr $tmp + 2`
        fi
        cnt=`expr $cnt + 1`
        if [ $cnt -gt 5 ]; then
                break
        fi
done
grade=`expr $grade + $tmp`
failednode=`grep "Node failed at time" $1 | sort -u | awk '{print $1}'`
tmp=0
for i in $failednode
do
	accuracycount=`grep removed  $1 | sort -u | grep -v $i | wc -l`
	if [ $accuracycount -eq 20 ]; then
		tmp=`expr $tmp + 2`
		grade=`expr $grade + 2`
	fi
	if [ $tmp -gt 9 ]; then
		break
	fi
done
#echo $grade
if [ $grade -eq 30 ]; then
  echo {\"fractionalScore\": 0.33, \"feedback\": \"Congratulations! You got it right!\"}
elif [ $grade -eq 0 ]; then
  echo {\"fractionalScore\": 0, \"feedback\": \"Congratulations! Sorry, your answer was incorrect.\"}
else
  echo {\"fractionalScore\": 0.11, \"feedback\": \"Almost there! You got some test cases right.\"}
fi