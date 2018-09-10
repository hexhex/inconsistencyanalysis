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
	$bmscripts/runinsts.sh "instances/*.graph" "$mydir/run.sh" "$mydir" "$to" "" "" "$req"
else
	mydir=$(dirname $0)
	confstr="dlvhex2 checkNon3ColorabilityPlain.hex $instance;dlvhex2 --plugindir=$mydir/../../../core/testsuite checkNon3ColorabilityExtSat.hex $instance;$mydir/../../Queries/evaluateProgramWithQueries_EiterPolleres06.sh checkNon3ColorabilityExtSatQueries.hex $instance;$mydir/../../Queries/evaluateProgramWithQueries_Redl18.sh checkNon3ColorabilityExtSatQueries.hex $instance;dlvhex2 --plugindir=$mydir/../../../core/testsuite checkNon3ColorabilityOutsourced.hex $instance;$mydir/../../Queries/evaluateProgramWithQueries_EiterPolleres06.sh checkNon3ColorabilityOutsourcedQueries.hex $instance;$mydir/../../Queries/evaluateProgramWithQueries_Redl18.sh checkNon3ColorabilityOutsourcedQueries.hex $instance"

	$bmscripts/runconfigs.sh "CONF" "$confstr" "$instance" "$to" "$bmscripts/ansctimeoutputbuilder.sh"
fi

