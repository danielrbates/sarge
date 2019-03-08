#!/bin/bash

results="10.0.0.0_24.results"
echo "Saving results to $results."
echo "" > $results

for i in {1..254}
    do
        echo "Scanning 10.0.0.$i on ports 21, 22, 23, and 80…"
        nc -w1 -n -v -z 10.0.0.$i 21 22 23 80 >> $results 2>&1
    done

echo "Scan complete."
echo -n "View results: cat $results | awk '/open/ {print "
echo -n '$2 " open on " $4'
echo "}'"
