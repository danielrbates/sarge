#!/bin/bash

# Make sure we are running as root (UID 0); if not, tell the user how to run the
# script using sudo:
if [[ $UID != 0 ]]
	then
		echo "Please run this script as root: sudo $0 $*"
		exit 1
fi

# Generate a random number for our file descriptor, within the range 6-254:
lower=6					# lower limit
upper=254				# upper limit
fd=0					# intialize the variable for the file descriptor
## Set up a loop that will re-generate a random number until we get one that is
## larger than the lower bound:
while [ "$fd" -le $lower ]
	do
		fd=$RANDOM
		let "fd%=$upper"
done

# Create the file descriptor with exec:
# Note - as the shell does not allow variables to specify file descriptors, we
# have to wrap the redirection command within an eval expression.
echo "Creating an SSH session pointing to file descriptor $fd..."
eval exec "${fd}"'<>/dev/tcp/localhost/22'
echo "Done"
echo ""

# Display file descriptor permissions for the SSH pipe:
## First, find the PID of the SSH process (description ending in [accepted]):
ssh_pid=$(ps -elf | grep -P '\[accepted]$' | awk '{print $4}')
## Next, print the extended properties of the socket (3) and pipe (5) file
## descriptors for this PID:
echo "SSH socket and pipe:"
echo $(ls -al /proc/$ssh_pid/fd/3)
echo $(ls -al /proc/$ssh_pid/fd/5)
echo ""
## Next, get the octal permissions for the pipe FD:
octal=$(stat --format=%a /proc/$ssh_pid/fd/5)
## Hash the octal permissions value:
octal_md5=$(echo $octal | md5sum | grep -Eo '^.{32}')
## Display the results:
echo "Octal permissions of the pipe: $octal"
echo "MD5 hash of permissions: $octal_md5"
echo ""

# Close the file descriptor we opened earlier:
echo "Closing file descriptor $fd..."
## Note: wrapping redirection within eval, same as line 27 above.
eval exec "${fd}"'<&-'
echo "Done"

# Exit successfully
exit 0