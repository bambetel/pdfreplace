#!/bin/bash
# usage % documentA documentB resultDoc n1 n2 ... nN
# replace pages of numbers n1..N in document A with subsequent pages of document B
# output to resultDoc

pdfLength () {
	pdftk "$1" dumpdata | awk '/^NumberOfPages:/ {print $2}'
}

docA=$1
docB=$2
resultDoc=$3
ins=(${@:4})
out=()

if [ ! -f "$docA" ]; then 
	echo "Input file A - not a file: $docA"
	exit 1
fi

if [ ! -f "$docB" ]; then 
	echo "Input file B - not a file: $docB"
	exit 1
fi

lenA=$(pdfLength "$docA")
lenB=$(pdfLength "$docB")

in=$(printf "%d\n" ${ins[*]})
if [[ $? != 0 ]]; then 
	echo "Invalid page number format"
	exit 1
fi

readarray -t ins < <(echo -e "$in" | sort -nu)
n=${#ins[*]}

if ((n > lenB)); then
	echo "Replacement page numbers greater than document B length!"
	exit 1
fi

start=1
lastA=0
lastB=0

for ((i=0; i<$n; i++)); do	
	if ((${ins[$i]} != lastB + 1)); then 
		lastA=$((${ins[$i]} - 1))
		out+=("A$start-$lastA")
	fi
	lastB=${ins[$i]}
	out+=("B$((i + 1))")
	start=$((ins[i] + 1))
done

if ((ins[$n-1]+1 <= $lenA)); then
	out+=("A$((ins[$n-1] + 1))-end")
fi

cmd="pdftk A=""$docA"" B=""$docB"" cat ${out[*]}  output ""$resultDoc"""
$($cmd)

