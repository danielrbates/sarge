	• Check for python:
		$ dpkg -l | grep python
		dpkg -l | grep python
		ii  dh-python                          2.20151103ubuntu1.1             all          Debian helper tools for packaging Python libraries and applications
		ii  libpython3-stdlib:i386             3.5.1-3                         i386         interactive high-level object-oriented language (default python3 version)
		ii  libpython3.5:i386                  3.5.2-2ubuntu0~16.04.1          i386         Shared Python runtime library (version 3.5)
		ii  libpython3.5-minimal:i386          3.5.2-2ubuntu0~16.04.1          i386         Minimal subset of the Python language (version 3.5)
		ii  libpython3.5-stdlib:i386           3.5.2-2ubuntu0~16.04.1          i386         Interactive high-level object-oriented language (standard library, version 3.5)
		ii  python-apt-common                  1.1.0~beta1build1               all          Python interface to libapt-pkg (locales)
		ii  python3                            3.5.1-3                         i386         interactive high-level object-oriented language (default python3 version)
		(Note: Full output truncated for readability)
    
	• Improve shell with python:
		python3 -c 'import pty; pty.spawn("/bin/bash")'
    
	• Improve shell with stty
		Ctrl+Z
		#echo $TERM (and note the TERM type - xterm-256color)
		#stty -a (and note the rows and columns info - 33, 150)
		#stty raw -echo
		#fg
		#reset
		#export SHELL=bash
		#export TERM=xterm256-color
		#stty rows 33 columns 150
