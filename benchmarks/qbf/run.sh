#!/bin/bash

runheader=$(which run_header.sh)
if [[ $runheader == "" ]] || [ $(cat $runheader | grep "run_header.sh Version 1." | wc -l) == 0 ]; then
        echo "Could not find run_header.sh (version 1.x); make sure that the benchmark scripts directory is in your PATH"
        exit 1
fi
source $runheader

# run instances
if [[ $all -eq 1 ]]; then
	# run all instances using the benchmark script run insts
	$bmscripts/runinsts.sh "instances/*.inst" "$mydir/run.sh" "$mydir" "$to" "" "" "$req"
else
	mydir=$(dirname $0)
#	confstr="dlvhex2 qbfPlain.hex $instance;dlvhex2 --plugindir=$mydir/../../../core/testsuite qbfExt.hex $instance;$mydir/../../Queries/evaluateProgramWithQueries_EiterPolleres06.sh qbfQueries.hex $instance;$mydir/../../Queries/evaluateProgramWithQueries_Redl18.sh qbfQueries.hex $instance"
	confstr="clingo qbfPlain.hex $instance;$mydir/../../Queries/evaluate.sh dlvhex2 external qbfQueries.hex $instance;$mydir/../../Queries/evaluate.sh potassco eiterpolleres06 qbfQueries.hex $instance;$mydir/../../Queries/evaluate.sh potassco redl18 qbfQueries.hex $instance"

	$bmscripts/runconfigs.sh "CONF" "$confstr" "$instance" "$to" ""
fi

