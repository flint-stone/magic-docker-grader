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

CREATE_TEST_STATUS="${SUCCESS}"
CREATE_TEST_SCORE=0

create_count=`grep -i "${CREATE_OPERATION}" ${1} | wc -l`
create_success_count=`grep -i "${CREATE_SUCCESS}" ${1} | wc -l`
expected_count=$(( ${create_count} * ${RFPLUSONE} ))

if [ ${create_success_count} -ne ${expected_count} ]
then
        CREATE_TEST_STATUS="${FAILURE}"
else
        keys=`grep -i "${CREATE_OPERATION}" ${1} | cut -d" " -f7`
        for key in ${keys}
        do
                key_create_success_count=`grep -i "${CREATE_SUCCESS}" ${1} | grep "${key}" | wc -l`
                if [ "${key_create_success_count}" -ne "${RFPLUSONE}" ]
                then
                        CREATE_TEST_STATUS="${FAILURE}"
                        break
                fi
        done
fi

if [ "${CREATE_TEST_STATUS}" -eq "${SUCCESS}" ]
then
        CREATE_TEST_SCORE=3
fi

# Add to grade
GRADE=$(( ${GRADE} + ${CREATE_TEST_SCORE} ))

#echo ${GRADE}

if [ $grade -eq 3 ]; then
  echo {\"fractionalScore\": 1.0, \"feedback\": \"Congratulations! You got it right!\"}
elif [ $grade -eq 0 ]; then
  echo {\"fractionalScore\": 0, \"feedback\": \"Sorry, your answer was incorrect.\"}
  else
  full=3
  DECI_RESULTS=$( echo "scale=2;x=${GRADE}/${full}; if(x<1) print 0; x"| bc -l )
  echo {\"fractionalScore\": $DECI_RESULTS, \"feedback\": \"Almost there! You got some test cases right.\"}
fi
