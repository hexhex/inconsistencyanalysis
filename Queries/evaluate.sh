#!/bin/bash

if [[ "$1" = "-h" ]] | [[ $# -lt 3 ]]; then
	echo -e "Parameters:
  \$1: Solver: dlvhex2 or potassco (ground and solve), or potasscoground (ground only)
  \$2: Encoding: eiterpolleres06orig, eiterpolleres06 or redl18
  \$3: Main program
  \$4: Instance file(s)
  \$5ff: Additional parameters to the solver"
  exit 0
else
	solver=$1
	encoding=$2
	mainprog=$3
	instance=$4
	solverparam=${@:5}
fi

mydir=$(dirname $0)
inlinedprogram=$(mktemp)

if [[ "$encoding" = "eiterpolleres06" ]]; then
	# inline query atoms in the main file
	$mydir/inlineQueries.sh $mainprog > $inlinedprogram
	encodingfile="$mydir/meta.encoding.eiterpolleres06"
elif [[ "$encoding" = "eiterpolleres06orig" ]]; then
        # inline query atoms in the main file
        $mydir/inlineQueries.sh $mainprog > $inlinedprogram
        encodingfile="$mydir/meta.encoding.eiterpolleres06orig"
elif [[ "$encoding" = "redl18" ]]; then
	# inline query atoms in the main file
	$mydir/inlineQueries.sh $mainprog > $inlinedprogram
	encodingfile="$mydir/meta.encoding.redl18"
elif [[ "$encoding" = "external" ]]; then
	if [[ "$solver" != "dlvhex2" ]]; then
		echo "encoding \"externl\" can only be used with solver \"dlvhex2\"" 1>&2 
		rm $inlinedprogram
		exit 1
	fi
	# rewrite query atoms to external atoms
	cat $mainprog | sed 's/CHEX/\&testCautiousQuery/g' | sed 's/BHEX/\&testBraveQuery/g' > $inlinedprogram
	solverparam="--plugindir=$mydir/../../core/testsuite $solverparam"
	encodingfile=""
else
	echo "Unknown encoding: $encoding" 1>&2
	exit 1
fi

if [[ "$solver" = "dlvhex2" ]]; then
	# remove #show directives
	grep -v "#show" $inlinedprogram | sponge $inlinedprogram
	dlvhex2 --silent $solverparam $encodingfile $inlinedprogram $instance
elif [[ "$solver" = "potassco" ]]; then
	clingo -n 0 --project=show $solverparam $encodingfile $inlinedprogram $instance 2>/dev/null | grep "Answer:" -A 1 | grep "Answer:" -v | sed 's/^/\{/; s/ /,/g; s/$/\}/'
elif [[ "$solver" = "potasscoground" ]]; then
        clingo --text -n 0 --project=show $solverparam $encodingfile $inlinedprogram $instance
else
	echo "Unknown solver: $solver" 1>&2
	rm $inlinedprogram
	exit 1
fi

# cleanup
rm $inlinedprogram
