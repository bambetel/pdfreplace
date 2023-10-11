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

lenA=$(pdfLength "$docA")
lenB=$(pdfLength "$docB")
echo "document length $lenA, $lenB"

# TODO check valid numbers
readarray -t ins < <(printf "%d\n" ${ins[*]} | sort -n)
echo "sorted ${ins[*]}"
n=${#ins[*]}

if (( n > lenB)); then
	echo "Replacement numbers exceeded, greater than document length!"
	exit 1
fi

start=1
last=0
lastins=0

for ((i=0; i<$n; i++ )); do	
	if (( ${ins[$i]} != lastins + 1 )); then 
		last=$((${ins[$i]} - 1))
		out+=("A$start-$last")
		lastins=${ins[$i]}
	fi
	out+=("B$((i + 1))")
	start=$((ins[i] + 1))
done

if ((ins[$n-1]+1 <= $lenA)); then
	out+=("A$((ins[$n-1] + 1))-end")
fi

cmd="pdftk A=""$docA"" B=""$docB"" cat ${out[*]}  output ""$resultDoc"""
$($cmd)

