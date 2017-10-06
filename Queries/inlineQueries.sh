#!/bin/bash

prog=$(cat $1 |
	sed 's/CHEX *\[ *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *\] *( *)/noAS(S=pos, T=cautious, F=\1, Q=\3)/g' |
	sed 's/BHEX *\[ *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *\] *( *)/noAS(S=pos, T=brave, F=\1, Q=\3)/g')

queries=$(echo $prog | grep -o "noAS(S=[[:alpha:]]*, T=[[:alpha:]]*, F=[[:alpha:]]*, Q=[[:alpha:]]*)")
echo $queries |
while read -r line
do
	sign=$(echo $line | sed 's/.*S=\([[:alpha:]]*\).*/\1/')
	querytype=$(echo $line | sed 's/.*T=\([[:alpha:]]*\).*/\1/')
	filename=$(echo $line | sed 's/.*F=\([[:alpha:]]*\).*/\1/')
	queryatom=$(echo $line | sed 's/.*Q=\([[:alpha:]]*\).*/\1/')
	./encodeProgram.sh $filename $filename
	if [[ $querytype == "brave" ]]; then
		echo "head($filename,query,queryconstraintatom)."
		echo "bodyN($filename,query,queryconstraintatom)."
		if [[ $sign == "pos" ]]; then
			echo "bodyN($filename,query,$queryatom)."
		else
			echo "bodyP($filename,query,$queryatom)."
		fi
	fi
        if [[ $querytype == "cautious" ]]; then
                echo "head($filename,query,queryconstraintatom)."
                echo "bodyN($filename,query,queryconstraintatom)."
                if [[ $sign == "pos" ]]; then
                        echo "bodyP($filename,query,$queryatom)."
                else
                        echo "bodyN($filename,query,$queryatom)."
                fi
        fi
done

cat $1 |
        sed 's/CHEX *\[ *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *\] *( *)/noAS(\1)/g' |
        sed 's/BHEX *\[ *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *, *\([[:alpha:]]*\) *\] *( *)/not noAS(\1)/g'
