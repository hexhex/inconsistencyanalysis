#!/bin/bash

mydir=$(dirname $0)
tmpfile=$(mktemp)
$mydir/inlineQueries.sh $1 > $tmpfile
cat $mydir/meta.encoding.redl18 > p
cat $tmpfile >> p
#cat $mydir/meta.encoding $tmpfile
dlvhex2 ${@:2} $mydir/meta.encoding.2 $tmpfile
rm $tmpfile
