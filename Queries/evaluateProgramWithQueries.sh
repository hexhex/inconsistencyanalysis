#!/bin/bash

tmpfile=$(mktemp)
./inlineQueries.sh $1 > $tmpfile
cat meta.encoding > p
cat $tmpfile >> p
dlvhex2 ${@:2} meta.encoding $tmpfile
rm $tmpfile
