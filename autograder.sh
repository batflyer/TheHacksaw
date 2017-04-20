#!/bin/bash

# BoostSRL-AutoGrader v0.01
# Written by Alexander L. Hayes
# hayesall@indiana.edu
# Last updated: 4/20/2017

RED='\033[0;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m'
BOLD='\e[1m'
ITAL='\e[3m'
UNDL='\e[4m'

# It will be pretty straightforward to establish that testing is consistent. Training is more difficult.

# java -jar v1-0.jar -l -train datasets/Father/train/ -target father -trees 25 > trainlog.txt
# java -jar v1-0.jar -i -model datasets/Father/train/models/ -test datasets/Father/test/ -target father -trees 25 > testlog.txt

# Sample call:
# $ bash autograder.sh [JAR-FILE]

NUMBEROFERRORS=0

function name {
    printf "${BOLD}NAME${NC}\n"
    printf "       autograder - AutoGrader: check for consistency between versions of BoostSRL.\n\n"
}

function synopsis {
    printf "${BOLD}SYNOPSIS${NC}\n"
    printf "       bash autograder.sh [${UNDL}OPTIONS${NC}]... [${UNDL}JAR${NC}]\n\n"
}

function hlp {
    name; synopsis;
}

if [[ ! -z $1 ]]; then
    JAR=$1
    if [[ ! -e $JAR ]]; then
	printf "${RED}A jar file was specified, but could not be found, here is the help menu:${NC}\n"
    fi
else
    printf "${RED}A jar file was not specified, here is the help menu:${NC}\n"
    hlp
    exit 2
fi

# Father dataset:

NAMES=(
    "RDN-Boost"
    "RDN-Boost with -noBoost"
    "Soft Margin with alpha(0.5) and beta(-2)"
    "Soft Margin with alpha(2) and beta(-10)"
    "MLN-Boost"
    "MLN-Boost with -mlnClause"
    "LSTree Boosting Regression"
)

ECHOS=(
    "Testing default functionality with boosted regression trees..."
    "Testing with boosting disabled (-noBoost)..."
    "Testing soft margin with alpha(0.5) and beta(-2)..."
    "Testing soft margin with alpha(2) and beta(-10)..."
    "Testing MLN-Boost..."
    "Testing MLN-Boost via clausal representation..."
    "Testing LSTree Boosting Regression (this dataset was not preprocessed for regression)..."
)

TRAINS=(
    "java -jar $JAR -l -train datasets/Father/train/ -target father -trees 25"
    "java -jar $JAR -l -noBoost -train datasets/Father/train -target father"
    "java -jar $JAR -l -softm -alpha 0.5 -beta -2 -train datasets/Father/train -target father -trees 25"
    "java -jar $JAR -l -softm -alpha 2 -beta -10 -train datasets/Father/train -target father -trees 25"
    "java -jar $JAR -l -mln -train datasets/Father/train/ -target father -trees 25"
    "java -jar $JAR -l -mln -mlnClause -train datasets/Father/train -target father -trees 25"
    "java -jar $JAR -l -reg -train datasets/Father/train -target father -trees 25"
)

TESTS=(
    "java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father -trees 25"
    "java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father"
    "java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father -trees 25"
    "java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father -trees 25"
    "java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father -trees 25"
    "java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father -trees 25"
    "java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father -trees 25"
)

COMPARES=(
    "python compare.py datasets/Father/test/results_father.db static/Father/results_rdn.db"
    "python compare.py datasets/Father/test/results_father.db static/Father/results_rdn_noboost.db"
    "python compare.py datasets/Father/test/results_father.db static/Father/results_softmA0.5B-2.db"
    "python compare.py datasets/Father/test/results_father.db static/Father/results_softmA2B-10.db"
    "python compare.py datasets/Father/test/results_father.db static/Father/results_mln.db"
    "python compare.py datasets/Father/test/results_father.db static/Father/results_mln_mlnClause.db"
    "python compare.py datasets/Father/test/results_father.db static/Father/results_regression.db"
)

for ((i=0; i<${#ECHOS[*]}; i++)); do
    printf "\n"
    echo ${ECHOS[i]}
    ${TRAINS[i]} > trainlog.txt
    if [[ "$?" = 0 ]]; then
	printf " - ${LIGHTGREEN}Training completed without errors.${NC}\n"
	${TESTS[i]} > testlog.txt
	if [[ "$?" = 0 ]]; then
	    printf " - ${LIGHTGREEN}Testing completed without errors.${NC}\n"
	    ${COMPARES[i]}
	else
	    printf " - ${RED}Errors encountered during testing for ${NAMES[i]}.${NC}\n"
	fi
    else
	printf " - ${RED}Errors encountered during training for ${NAMES[i]}.${NC}\n"
    fi
done

exit 0

# RDN-Boost
echo "Testing default functionality with boosted regression trees..."
java -jar $JAR -l -train datasets/Father/train/ -target father -trees 25 > trainlog.txt
if [[ "$?" = 0 ]]; then
    printf " - ${LIGHTGREEN}Training completed without errors.${NC}\n"
    java -jar $JAR -i -model datasets/Father/train/models -test datasets/Father/test/ -target father -trees 25 > testlog.txt
    if [[ "$?" = 0 ]]; then
	printf " - ${LIGHTGREEN}Testing completed without errors.${NC}\n"
	python compare.py datasets/Father/test/results_father.db static/Father/results_rdn.db
    else
	printf " - ${RED}Errors encountered during testing for RDN-Boost.${NC}\n"
    fi
else
    printf " - ${RED}Errors encountered during training for RDN-Boost.${NC}\n"
fi

exit 0

#if [[ -e datasets/Father/test/results_father.db ]]; then
# check if the file is the same as static/Father/results_father.db
#    X=$(md5sum datasets/Father/test/results_father.db | cut -f 1 -d ' ')
#    Y=$(md5sum static/Father/results_father.db | cut -f 1 -d ' ')
#    if [[ "$X" = "$Y" ]]; then
#	printf "${LIGHTGREEN}Success${NC}\n"
#    else
#	printf "${RED}Error, outcome does not match expected outcome.${NC}\n"
#	NUMBEROFERRORS=$((NUMBEROFERRORS+1))
#    fi
#fi
