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

READ_TEST1_STATUS="${FAILURE}"
READ_TEST1_SCORE=0
READ_TEST2_STATUS="${FAILURE}"
READ_TEST2_SCORE=0
READ_TEST3_PART1_STATUS="${FAILURE}"
READ_TEST3_PART1_SCORE=0
READ_TEST3_PART2_STATUS="${FAILURE}"
READ_TEST3_PART2_SCORE=0
READ_TEST4_STATUS="${FAILURE}"
READ_TEST4_SCORE=0
READ_TEST5_STATUS="${FAILURE}"
READ_TEST5_SCORE=0

read_operations=`grep -i "${READ_OPERATION}" ${1}  | cut -d" " -f3 | tr -s ']' ' '  | tr -s '[' ' ' | sort`

cnt=1
for time in ${read_operations}
do
	if [ ${cnt} -eq 1 ]
	then
		read_op_test1_time="${time}"
		read_op_test1_key=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test1_time}" | cut -d" " -f7`
		read_op_test1_value=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test1_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 2 ]
	then
		read_op_test2_time="${time}"
		read_op_test2_key=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test2_time}" | cut -d" " -f7`
		read_op_test2_value=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test2_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 3 ]
	then
		read_op_test3_part1_time="${time}"
		read_op_test3_part1_key=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test3_part1_time}" | cut -d" " -f7`
		read_op_test3_part1_value=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test3_part1_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 4 ]
	then
		read_op_test3_part2_time="${time}"
		read_op_test3_part2_key=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test3_part2_time}" | cut -d" " -f7`
		read_op_test3_part2_value=`grep -i "${READ_OPERATION}" ${1} | grep "${read_op_test3_part2_time}" | cut -d" " -f9`
	elif [ ${cnt} -eq 5 ]
	then
		read_op_test4_time="${time}"
		read_op_test4_key="${read_op_test1_key}"
		read_op_test4_value="${read_op_test1_value}"
	elif [ ${cnt} -eq 6 ]
	then
		read_op_test5_time="${time}"
	fi
	cnt=$(( ${cnt} + 1 ))
done

read_test1_success_count=0
read_test2_success_count=0
read_test3_part2_success_count=0
read_test4_success_count=0

read_successes=`grep -i "${READ_SUCCESS}" ${1} | grep ${read_op_test1_key} | grep ${read_op_test1_value}`
while read success
do
	time_of_this_success=`echo "${success}" | cut -d" " -f2 | tr -s '[' ' ' | tr -s ']' ' '`
	if [ "${time_of_this_success}" -ge "${read_op_test1_time}" -a "${time_of_this_success}" -lt "${read_op_test2_time}" ]
	then
		read_test1_success_count=`expr ${read_test1_success_count} + 1`
	elif [ "${time_of_this_success}" -ge "${read_op_test2_time}" -a "${time_of_this_success}" -lt "${read_op_test3_part1_time}" ] 
	then
		read_test2_success_count=`expr ${read_test2_success_count} + 1`
	elif [ "${time_of_this_success}" -ge "${read_op_test3_part2_time}" -a "${time_of_this_success}" -lt "${read_op_test4_time}" ]  
	then
		read_test3_part2_success_count=`expr ${read_test3_part2_success_count} + 1`
	elif [ "${time_of_this_success}" -ge "${read_op_test4_time}" ]
	then
		read_test4_success_count=`expr ${read_test4_success_count} + 1`
	fi
done <<<"${read_successes}"

read_test3_part1_fail_count=0
read_test5_fail_count=0

read_fails=`grep -i "${READ_FAILURE}" ${1}`
while read fail
do
	time_of_this_fail=`echo "${fail}" | cut -d" " -f2 | tr -s '[' ' ' | tr -s ']' ' '`
	if [ "${time_of_this_fail}" -ge "${read_op_test3_part1_time}" -a "${time_of_this_fail}" -lt "${read_op_test3_part2_time}" ]
	then
		actual_key=`echo "${fail}" | grep "${read_op_test3_part1_key}" | wc -l`
		if [ "${actual_key}"  -eq 1 ]
		then	
			read_test3_part1_fail_count=`expr ${read_test3_part1_fail_count} + 1`
		fi
	elif [ "${time_of_this_fail}" -ge "${read_op_test5_time}" ]
	then
		actual_key=`echo "${fail}" | grep "${INVALID_KEY}" | wc -l`
		if [ "${actual_key}" -eq 1 ]
		then
			read_test5_fail_count=`expr ${read_test5_fail_count} + 1`
		fi
	fi
done <<<"${read_fails}"

if [ "${read_test1_success_count}" -eq "${QUORUMPLUSONE}" -o "${read_test1_success_count}" -eq "${RFPLUSONE}" ]
then
	READ_TEST1_STATUS="${SUCCESS}"
fi
if [ "${read_test2_success_count}" -eq "${QUORUMPLUSONE}" ]
then
	READ_TEST2_STATUS="${SUCCESS}"
fi
if [ "${read_test3_part1_fail_count}" -eq 1 ]
then
	READ_TEST3_PART1_STATUS="${SUCCESS}"
fi
if [ "${read_test3_part2_success_count}" -eq "${QUORUMPLUSONE}" -o "${read_test3_part2_success_count}" -eq "${RFPLUSONE}" ]
then
	READ_TEST3_PART2_STATUS="${SUCCESS}"
fi
if [ "${read_test4_success_count}" -eq "${QUORUMPLUSONE}" -o "${read_test4_success_count}" -eq "${RFPLUSONE}" ]
then
	READ_TEST4_STATUS="${SUCCESS}"
fi
if [ "${read_test5_fail_count}" -eq "${QUORUMPLUSONE}" -o "${read_test5_fail_count}" -eq "${RFPLUSONE}" ]
then
	READ_TEST5_STATUS="${SUCCESS}"
fi

if [ "${READ_TEST1_STATUS}" -eq "${SUCCESS}" ]
then
	READ_TEST1_SCORE=3
fi
if [ "${READ_TEST2_STATUS}" -eq "${SUCCESS}" ]
then
	READ_TEST2_SCORE=9
fi
if [ "${READ_TEST3_PART1_STATUS}" -eq "${SUCCESS}" ]
then
	READ_TEST3_PART1_SCORE=9
fi
if [ "${READ_TEST3_PART2_STATUS}" -eq "${SUCCESS}" ]
then
	READ_TEST3_PART2_SCORE=10
fi
if [ "${READ_TEST4_STATUS}" -eq "${SUCCESS}" ]
then
	READ_TEST4_SCORE=6
fi
if [ "${READ_TEST5_STATUS}" -eq "${SUCCESS}" ]
then
	READ_TEST5_SCORE=3
fi

GRADE=`expr ${GRADE} + ${READ_TEST1_SCORE}`
GRADE=`expr ${GRADE} + ${READ_TEST2_SCORE}`
GRADE=`echo ${GRADE} ${READ_TEST3_PART1_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${READ_TEST3_PART2_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${READ_TEST4_SCORE} | awk '{print $1 + $2}'`
GRADE=`echo ${GRADE} ${READ_TEST5_SCORE} | awk '{print $1 + $2}'`

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
