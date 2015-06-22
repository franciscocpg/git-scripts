#!/bin/bash
#

readopt='getopts $opts opt;rc=$?;[ $rc$opt == 0? ]&&exit 1;[ $rc == 0 ]||{ shift $[OPTIND-1];false; }'

opts=vfdo:

# Enumerating options
while eval $readopt
do
	# echo "$opt=$OPTARG"
	eval "$opt=$OPTARG"
done

echo "$o"

# Enumerating arguments
for arg
do
    echo ARG:$arg
done