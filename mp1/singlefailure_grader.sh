#echo "============================"
#echo "Single Failure Scenario"
#echo "============================"

grade=0

magic=`head -1 ${1}`
if [ ${magic} -ne 131 ]
then
     echo ${grade}
     exit
fi

joincount=`grep joined $1 | cut -d" " -f2,4-7 | sort -u | wc -l`
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
failednode=`grep "Node failed at time"  $1 | sort -u | awk '{print $1}'`
failcount=`grep removed  $1 | sort -u | grep $failednode | wc -l`
if [ $failcount -ge 9 ]; then
	grade=`expr $grade + 10`
fi
failednode=`grep "Node failed at time" $1 | sort -u | awk '{print $1}'`
accuracycount=`grep removed  $1 | sort -u | grep -v $failednode | wc -l`
if [ $accuracycount -eq 0 ] && [ $failcount -gt 0 ]; then
	grade=`expr $grade + 10`
fi
#echo $grade


if [ $grade -eq 30 ]; then
  echo {\"fractionalScore\": 1.0, \"feedback\": \"Congratulations! You got it right!\"}
elif [ $grade -eq 0 ]; then
  echo {\"fractionalScore\": 0, \"feedback\": \"Sorry, your answer was incorrect.\"}
else
  echo {\"fractionalScore\": 0.33, \"feedback\": \"Almost there! You got some test cases right.\"}
fi
