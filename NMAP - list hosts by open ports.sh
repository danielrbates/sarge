#!/bin/bash

# Set the filepath for the input and output files, and create the output file.
FilePath=$PWD
InputFile="NMAP_all_hosts.txt"
OutputFile="${FilePath}/Enumerated_NMAP.txt"
:> $OutputFile

# Import text from file.
FullText=$(cat $FilePath/$InputFile)

# Parse the text for blocks matching individual scan reports and add each block
# to a variable named $ScanReports.  (Note: we will replace all newlines with
# #NEWLINE# to enable grep to find patterns across multiple lines of input.)
ScanReports=$(
	cat $FullText | sed 's/$/#NEWLINE#/' | tr -d '\n' | \
	grep -Po '(Nmap scan report for).*?(Network Distance: \d+ hops?)'
	)

# Find all open ports, sorted and filtered for unique results, displayed with
# service names.
OrderedPorts=$(
    echo "$FullText" | grep -Po '^(\d{1,5}\/(tcp|udp))\s+(open)\s+(\S+)$' | \
    awk '{print $1 $3}' | sort -n | uniq
    )

# Define a function that will look up a service name, given a port.
lookup_service () {
    echo "$OrderedPorts" | grep -P "^$1" | awk '{print $3}'
    }

# Define a function that will count the number of instances of a given open
# port within the Nmap output.
count_hosts_by_port () {
    echo $FullText | grep -Po "^($1)\s+(open)" | wc -l
    }

# Define a function that will take a port, grep for the preceding IP address
# (if one exists before the start of the scan report block), and return the
# IP address within each match.
list_hosts_by_port () {
    echo $ScanReports | \
    grep -Po "(?<=scan report for )(?:.(?!scan report))*(#)($1)(\s+open)" | \
    grep -Po '(\d{1,3}\.){3}\d{1,3}'
    }

# Loop through the list of ports to count the number of hosts for each port.
echo "Count of hosts by port:" >> $OutputFile
echo "$OrderedPorts" | awk '{print $1}' | \
	while IFS= read -r line; do
        echo "$(count_hosts_by_port $line) $line ($(lookup_service $line))"
        done |\
	sort -k1,1nr -k2,2 -k3,3 >> $OutputFile

# Add spacing between output blocks.
echo ""; echo "" >> $OutputFile

# Loop through the lines in $OrderedPorts to find all hosts with that port.
echo "List of hosts by service:" >> $OutputFile
echo "$OrderedPorts" | awk '{print $1}' | \
	while IFS= read -r line; do
        echo "$(lookup_service $line) : $line"
        echo "--------------------"
        list_hosts_by_port $line
        echo ""
		done >> $OutputFile

# Exit successfully
exit 0