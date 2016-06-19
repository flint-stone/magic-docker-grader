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


DELETE_TEST1_STATUS="${SUCCESS}"
DELETE_TEST2_STATUS="${SUCCESS}"
DELETE_TEST1_SCORE=0
DELETE_TEST2_SCORE=0

delete_count=`grep -i "${DELETE_OPERATION}" ${1} | wc -l`
valid_delete_count=$(( ${delete_count} - 1 ))
expected_count=$(( ${valid_delete_count} * ${RFPLUSONE} ))
delete_success_count=`grep -i "${DELETE_SUCCESS}" ${1} | wc -l`

if [ "${delete_success_count}" -ne "${expected_count}" ]
then
	DELETE_TEST1_STATUS="${FAILURE}"
else 
	keys=""
	keys=`grep -i "${DELETE_OPERATION}" ${1} | cut -d" " -f7`
	for key in ${keys}
	do 
		if [ $key != "${INVALID_KEY}" ]
		then
			key_delete_success_count=`grep -i "${DELETE_SUCCESS}" ${1} | grep "${key}" | wc -l`
			if [ "${key_delete_success_count}" -ne "${RFPLUSONE}" ]
			then
				DELETE_TEST1_STATUS="${FAILURE}"
				break
			fi
		fi
	done
fi

delete_fail_count=`grep -i "${DELETE_FAILURE}" ${1} | grep "${INVALID_KEY}" | wc -l`
if [ "${delete_fail_count}" -ne 4 ]
then
	DELETE_TEST2_STATUS="${FAILURE}"
fi

if [ "${DELETE_TEST1_STATUS}" -eq "${SUCCESS}" ]
then
	DELETE_TEST1_SCORE=3
fi

if [ "${DELETE_TEST2_STATUS}" -eq "${SUCCESS}" ]
then
	DELETE_TEST2_SCORE=4
fi

# Add to grade
GRADE=$(( ${GRADE} + ${DELETE_TEST1_SCORE} ))
GRADE=$(( ${GRADE} + ${DELETE_TEST2_SCORE} ))

#echo ${GRADE}

if [ $GRADE -eq 7 ]; then
  echo {\"fractionalScore\": 1.0, \"feedback\": \"Congratulations! You got it right!\"}
elif [ $GRADE -eq 0 ]; then
  echo {\"fractionalScore\": 0, \"feedback\": \"Sorry, your answer was incorrect.\"}
else
  full=7
  DECI_RESULTS=$( echo "scale=2;x=${GRADE}/${full}; if(x<1) print 0; x"| bc -l )
  echo {\"fractionalScore\": $DECI_RESULTS, \"feedback\": \"Almost there! You got some test cases right.\"}
fi
