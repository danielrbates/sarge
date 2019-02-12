#!/bin/bash

# Set the filepath for the input and output files, and create the output file.
FilePath=$PWD
InputFile="NMAP_all_hosts.txt"
OutputFile="${FilePath}/Enumerated_NMAP.txt"
:> $OutputFile

# Import text from file and replace all newline characters with '#NEWLINE#'.
FullText=$(cat $FilePath/$InputFile | sed 's/$/#NEWLINE#/' | tr -d '\n')

# Parse the text for blocks matching individual scan reports and add each block
# to a variable named $ScanReports.
ScanReports=$(echo $FullText | \
	grep -Po '(Nmap scan report for).*?(Network Distance: \d+ hops?)')

# Find all IPv4 addresses:
OrderedIPs=$(echo $ScanReports | grep -Po '(\d{1,3}\.){3}\d{1,3}' | sort)

# Find an ordered list of all ports (any text between SERVICE and MAC Address).
# Restore newline characters.
# Select the PORT and SERVICE and output with a colon delimiter.
# Sort and filter for unique results.
OrderedPortsAndServices=$(
    echo "$ScanReports" | \
    grep -Po '(?<=SERVICE#NEWLINE#).*?(?=#NEWLINE#MAC Address)' | \
    sed 's/#NEWLINE#/\n/g' | \
    awk '{print $1 " : " $3}' | \
    sort -n | uniq \
    )
OrderedPorts=$(echo "$OrderedPortsAndServices" | awk '{print $1}')

# Define a function that will look up a service name, given a port.
lookup_service () {
    echo "$OrderedPortsAndServices" | grep -P "^$1" | awk '{print $3}'
    }

# Define a function that will count the number of instances of a given open
# port within the Nmap output.
count_hosts_by_port () {
    echo $ScanReports | grep -Po "(#NEWLINE#)($1)(\s+open)" | wc -l
    }

# Define a function that will take a port, grep for the preceding IP address
# (if one exists before the start of the scan report block), and return the
# IP address within each match.
list_hosts_by_port () {
    echo $ScanReports | \
    grep -Po "(?<=scan report for )(?:.(?!scan report))*(#)($1)(\s+open)" | \
    grep -Po '(\d{1,3}\.){3}\d{1,3}'
    }

# Loop through the lines in $OrderedPorts to count the number of hosts for
# each port.  Store in a variable to enable sorting.
echo "Count of hosts by port:" >> $OutputFile
CountOfHosts=$(
    echo "$OrderedPorts" | while IFS=
        read -r line
        do
            echo "$(count_hosts_by_port $line) $line ($(lookup_service $line))"
        done
    )
echo "$CountOfHosts" | sort -k1,1nr -k2,2 -k3,3 >> $OutputFile

# Spacing between output blocks.
echo "" >> $OutputFile
echo "" >> $OutputFile

# Loop through the lines in $OrderedPorts to find all hosts with that port.
echo "List of hosts by service:" >> $OutputFile
echo "$OrderedPorts" | while IFS=
    read -r line
    do
        echo "$(lookup_service $line) : $line"
        echo "--------------------"
        list_hosts_by_port $line
        echo ""
    done >> $OutputFile

# Exit successfully
exit 0