#!/bin/bash


###
# Global variables
###
SUCCESS=0
FAILURE=-1
RF=3
RFPLUSONE=4
CREATE_OPERATION="CREATE OPERATION"
CREATE_SUCCESS="create success"
GRADE=0
DELETE_OPERATION="DELETE OPERATION"
DELETE_SUCCESS="delete success"
DELETE_FAILURE="delete fail"
INVALID_KEY="invalidKey"
READ_OPERATION="READ OPERATION"
READ_SUCCESS="read success"
READ_FAILURE="read fail"
QUORUM=2
QUORUMPLUSONE=3
UPDATE_OPERATION="UPDATE OPERATION"
UPDATE_SUCCESS="update success"
UPDATE_FAILURE="update fail"



UPDATE_TEST1_STATUS="${FAILURE}"
UPDATE_TEST1_SCORE=0
UPDATE_TEST2_STATUS="${FAILURE}"
UPDATE_TEST2_SCORE=0
UPDATE_TEST3_PART1_STATUS="${FAILURE}"
UPDATE_TEST3_PART1_SCORE=0
UPDATE_TEST3_PART2_STATUS="${FAILURE}"
UPDATE_TEST3_PART2_SCORE=0
UPDATE_TEST4_STATUS="${FAILURE}"
UPDATE_TEST4_SCORE=0
UPDATE_TEST5_STATUS="${FAILURE}"
UPDATE_TEST5_SCORE=0

update_operations=`grep -i "${UPDATE_OPERATION}" ${1}  | cut -d" " -f3 | tr -s ']' ' '  | tr -s '[' ' ' | sort`

cnt=1
for time in ${update_operations}
do
	if [ ${cnt} -eq 1 ]
	then
		update_op_test1_time="${time}"
		update_op_test1_key=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test1_time}" | cut -d" " -f7`
		update_op_test1_value=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test1_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 2 ]
	then
		update_op_test2_time="${time}"
		update_op_test2_key=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test2_time}" | cut -d" " -f7`
		update_op_test2_value=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test2_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 3 ]
	then
		update_op_test3_part1_time="${time}"
		update_op_test3_part1_key=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test3_part1_time}" | cut -d" " -f7`
		update_op_test3_part1_value=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test3_part1_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 4 ]
	then
		update_op_test3_part2_time="${time}"
		update_op_test3_part2_key=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test3_part2_time}" | cut -d" " -f7`
		update_op_test3_part2_value=`grep -i "${UPDATE_OPERATION}" ${1} | grep "${update_op_test3_part2_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 5 ]
	then
		update_op_test4_time="${time}"
		update_op_test4_key="${update_op_test1_key}"
		update_op_test4_value="${update_op_test1_value}"
	elif [ ${cnt} -eq 6 ]
	then
		update_op_test5_time="${time}"
	fi
	cnt=$(( ${cnt} + 1 ))
done

update_test1_success_count=0
update_test2_success_count=0
update_test3_part2_success_count=0
update_test4_success_count=0

update_successes=`grep -i "${UPDATE_SUCCESS}" ${1} | grep ${update_op_test1_key} | grep ${update_op_test1_value}`
while read success
do
	time_of_this_success=`echo "${success}" | cut -d" " -f2 | tr -s '[' ' ' | tr -s ']' ' '`
	if [ "${time_of_this_success}" -ge "${update_op_test1_time}" -a "${time_of_this_success}" -lt "${update_op_test2_time}" ]
	then
		update_test1_success_count=`expr ${update_test1_success_count} + 1`
	elif [ "${time_of_this_success}" -ge "${update_op_test2_time}" -a "${time_of_this_success}" -lt "${update_op_test3_part1_time}" ] 
	then
		update_test2_success_count=`expr ${update_test2_success_count} + 1`
	elif [ "${time_of_this_success}" -ge "${update_op_test3_part2_time}" -a "${time_of_this_success}" -lt "${update_op_test4_time}" ]  
	then
		update_test3_part2_success_count=`expr ${update_test3_part2_success_count} + 1`
	elif [ "${time_of_this_success}" -ge "${update_op_test4_time}" ]
	then
		update_test4_success_count=`expr ${update_test4_success_count} + 1`
	fi
done <<<"${update_successes}"

update_test3_part1_fail_count=0
update_test5_fail_count=0

update_fails=`grep -i "${UPDATE_FAILURE}" ${1}`
while read fail
do
	time_of_this_fail=`echo "${fail}" | cut -d" " -f2 | tr -s '[' ' ' | tr -s ']' ' '`
	if [ "${time_of_this_fail}" -ge "${update_op_test3_part1_time}" -a "${time_of_this_fail}" -lt "${update_op_test3_part2_time}" ]
	then
		actual_key=`echo "${fail}" | grep "${update_op_test3_part1_key}" | wc -l`
		if [ "${actual_key}"  -eq 1 ]
		then	
			update_test3_part1_fail_count=`expr ${update_test3_part1_fail_count} + 1`
		fi
	elif [ "${time_of_this_fail}" -ge "${update_op_test5_time}" ]
	then
		actual_key=`echo "${fail}" | grep "${INVALID_KEY}" | wc -l`
		if [ "${actual_key}" -eq 1 ]
		then
			update_test5_fail_count=`expr ${update_test5_fail_count} + 1`
		fi
	fi
done <<<"${update_fails}"

if [ "${update_test1_success_count}" -eq "${QUORUMPLUSONE}" -o "${update_test1_success_count}" -eq "${RFPLUSONE}" ]
then
	UPDATE_TEST1_STATUS="${SUCCESS}"
fi
if [ "${update_test2_success_count}" -eq "${QUORUMPLUSONE}" ]
then
	UPDATE_TEST2_STATUS="${SUCCESS}"
fi
if [ "${update_test3_part1_fail_count}" -eq 1 ]
then
	UPDATE_TEST3_PART1_STATUS="${SUCCESS}"
fi
if [ "${update_test3_part2_success_count}" -eq "${QUORUMPLUSONE}" -o "${update_test3_part2_success_count}" -eq "${RFPLUSONE}" ]
then
	UPDATE_TEST3_PART2_STATUS="${SUCCESS}"
fi
if [ "${update_test4_success_count}" -eq "${QUORUMPLUSONE}" -o "${update_test4_success_count}" -eq "${RFPLUSONE}" ]
then
	UPDATE_TEST4_STATUS="${SUCCESS}"
fi
if [ "${update_test5_fail_count}" -eq "${QUORUMPLUSONE}" -o "${update_test5_fail_count}" -eq "${RFPLUSONE}" ]
then
	UPDATE_TEST5_STATUS="${SUCCESS}"
fi

if [ "${UPDATE_TEST1_STATUS}" -eq "${SUCCESS}" ]
then
	UPDATE_TEST1_SCORE=3
fi
if [ "${UPDATE_TEST2_STATUS}" -eq "${SUCCESS}" ]
then
	UPDATE_TEST2_SCORE=9
fi
if [ "${UPDATE_TEST3_PART1_STATUS}" -eq "${SUCCESS}" ]
then
	UPDATE_TEST3_PART1_SCORE=9
fi
if [ "${UPDATE_TEST3_PART2_STATUS}" -eq "${SUCCESS}" ]
then
	UPDATE_TEST3_PART2_SCORE=10
fi
if [ "${UPDATE_TEST4_STATUS}" -eq "${SUCCESS}" ]
then
	UPDATE_TEST4_SCORE=6
fi
if [ "${UPDATE_TEST5_STATUS}" -eq "${SUCCESS}" ]
then
	UPDATE_TEST5_SCORE=3
fi

# Add to grade
GRADE=`echo ${GRADE} ${UPDATE_TEST1_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${UPDATE_TEST2_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${UPDATE_TEST3_PART1_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${UPDATE_TEST3_PART2_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${UPDATE_TEST4_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${UPDATE_TEST5_SCORE} | awk '{print $1 + $2}'`

#echo ${GRADE}

if [ $GRADE -eq 40 ]; then
  echo {\"fractionalScore\": 1.0, \"feedback\": \"Congratulations! You got it right!\"}
elif [ $GRADE -eq 0 ]; then
  echo {\"fractionalScore\": 0, \"feedback\": \"Sorry, your answer was incorrect.\"}
else
  full=40
  DECI_RESULTS=$( echo "scale=2;x=${GRADE}/${full}; if(x<1) print 0; x"| bc -l )
  echo {\"fractionalScore\": $DECI_RESULTS, \"feedback\": \"Almost there! You got some test cases right.\"}
fi
