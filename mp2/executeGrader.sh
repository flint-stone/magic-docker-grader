#! /bin/bash

# Coursera deletes all environment variables set inside 'Dockerfile'. If any environment varables
# need to be set, they must be set inside a wrapper bash script.
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

# Switch to the grader directory
cd /grader

# Unique Part Ids for each assignment part that will be graded using this grader.
# These are exposed in Coursera's authoring tools for each programming assignment part.
CREATE_TEST_GRADER_PART_ID="PH3Q7"
DELETE_TEST_GRADER_PART_ID="PIXym"
READ_TEST_GRADER_PART_ID="mUKdC"
UPDATE_TEST_GRADER_PART_ID="peNB6"


# Parse the command line arguments supplied by Coursera.
while [[ $# > 1 ]]
  do
    key="$1"
    case $key in
      partId)
        # Unique Id associated with the part which is being graded.
        PARTID="$2"
        shift
        ;;
      userId)
        # Unique integer Id of the learner that made this submission.
        USERID="$2"
        shift
        ;;
      filename)
        # Original filename as uploaded by the learner before it was renamed to the suggested filename.
        ORIGINAL_FILENAME="$2"
        shift
        ;;
    esac
  shift
done

# Use the parsed partId to know which part is being graded in the current run.
if [ "$PARTID" == "$CREATE_TEST_GRADER_PART_ID" ]; then
  #GRADER_DIRECTORY=FactoringGrader
  #SUBMISSION_CLASS=Factoring
  bash createtest_grader.sh /shared/submission/*
elif [ "$PARTID" == "$DELETE_TEST_GRADER_PART_ID" ]; then
  #GRADER_DIRECTORY=PrimeGrader
  #SUBMISSION_CLASS=Prime
  bash deletetest_grader.sh /shared/submission/*
elif [ "$PARTID" == "$READ_TEST_GRADER_PART_ID" ]; then
  #GRADER_DIRECTORY=PrimeGrader
  #SUBMISSION_CLASS=Prime
  bash readtest_grader.sh /shared/submission/*
  
elif [ "$PARTID" == "$UPDATE_TEST_GRADER_PART_ID" ]; then
  #GRADER_DIRECTORY=PrimeGrader
  #SUBMISSION_CLASS=Prime
  bash updatetest_grader.sh /shared/submission/*
else
  # Exiting with status 1. Coursera will expose these errors to instructors via a dashboard.
  # Learner will be prompted to try again after some time and the grader is under maintenance.
  echo "No PartId matched!" 1>&2
  exit 1
fi

# Compile the learner's program in the current directory. We can safely assume that there
# would be a single submission file in this directory.
#javac -d . /shared/submission/*

# Note: Nothing except Json object containing 'fractionalScore' and 'feedback' should be written
# to stdout.

# Check if the compilation was successful
#if [ ! $? -eq 0 ]; then
#  echo "{ \"fractionalScore\":0.0, \"feedback\":\"Compile Error\" }"
#  exit 0
#fi

# Run the learner's submission with testCases and capture stdout produced in learnerOutput.txt
#cat "$GRADER_DIRECTORY"/testCases.txt | java "$SUBMISSION_CLASS" 1> learnerOutput.txt

# Check if the learner's program ran successfully
#if [ ! $? -eq 0 ]; then
#	echo "{ \"fractionalScore\": 0.0, \"feedback\":\"Your submission produced runtime errors\" }"
#	exit 0
#fi

# Compile Grader.java
#javac Grader.java


# Use Grader.java to compare learnerOutput.txt and solution.txt
#java Grader "$GRADER_DIRECTORY"/solution.txt learnerOutput.txt
