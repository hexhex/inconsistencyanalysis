#!/bin/bash
clingo -n 0 $@ | grep "Answer:" -A 1 | grep "Answer:" -v | sed 's/^/\{/; s/ /,/g; s/$/\}/'
if [[ $? -eq 10 ]] | [[ $? -eq 20 ]]; then
	exit 0
else
	exit 1
fi
