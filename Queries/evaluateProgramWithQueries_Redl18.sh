#!/bin/bash

mydir=$(dirname $0)
tmpfile=$(mktemp)
$mydir/inlineQueries.sh $1 > $tmpfile
dlvhex2 ${@:2} $mydir/meta.encoding.redl18 $tmpfile
rm $tmpfile
