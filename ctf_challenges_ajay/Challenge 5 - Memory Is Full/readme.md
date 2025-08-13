

# Challenge 5 - DebugMe!

## Description

The objective of this challenge is to extract and analyze a memory dump of an application from FTP network traffic. 


# Solution
**1. Analyzing the PCAP**

In Wireshark analyzing the Protocol Hierarchy and notice the existence of FTP Data. Using the filter `FTP` we can see multiple FTP packets. Also use the filter `ftp-data` and notice the transfer of the two files `key.txt` and `mems.7129`. 

    No.		Time		Source			Destination 	Proto		Length	Info
    859		44.395140	192.168.10.128	192.168.10.136	FTP-DATA	111		FTP Data: 45 bytes (EPASV) (RETR key.txt)
    1000	55.677871	192.168.10.128	192.168.10.136	FTP-DATA	1514	FTP Data: 1448 bytes (EPASV) (RETR mems.7129)

 
**2. Extract files from FTP-Data**

Select packet 859 as shown above and view the TCP stream, `tcp.stream eq 19`. The following is the content of this stream:

    dont share the super secret XOR key, its: 14

Select packet 1000 as shown above and view the TCP stream, `tcp.stream eq 22`. View and save this stream as `mems.7129` as its the original name. 

**3. Analyze the Mems.7129 file**

This is a memory debug dump created using gcore. Without the original binary it is challenging to analyze this file. 
We can however perform the command `strings` and view data. 

    strings mems.7129

The result of this command returns an extensive list of strings which is nearly impossible to analyze. However we can narrow down the amount of strings by looking for variables in the form of `var = value`. To do this we can use the `strings`  and the `grep` command as shown below:

    strings mems.7129 | grep '='

This narrows down the amount of lines in the result. From these results notice the following few lines:

     DESKTOP_SESSION=xfce
    clue1="why you can look at my memories"
    clue2="do you seen anything interesting"
    plsdecrypt="hboiucwQckca|wQ}{me}s"
    a__g="hboiucwQckca|wQ}{me}s"
    ="hboiucwQckca|wQ}{me}s
The clues variables as well as the variable `plsdecrypt` are very interesting. We can attempt to decrypt the value of `plsdecrypt` with XOR and a key of 14. 

**4. Decrypt the plsdecrypt variable**

Using CyberChef we first add `hboiucwQckca|wQ}{me}s` as the input. Next we select the the `XOR` module and set the value to 14. Initialy the output is gibberish and doesnt provide anything, however setting the configuration to `decimal` returns the flag as the output:

    flag{my_memory_sucks}

This completes this challenge. 


# Recreating this challenge 
Recreating this challenge is pretty simple. 

**1. Encrypt the flag using cyberchef  and create key.txt**

Using the XOR module provide a flag as input and a random decimal number such as 14 as the key. Record the encrypted value such as:

    hboiucwQckca|wQ}{me}s

Record the key into a text file:

    └─$ echo the XOR key is: 14 > key.txt                                              
    └─$ cat key.txt             
    the XOR key is: 14

**2. Create a simple bash script on MachineA**

The objective is to create a memory dump of a simple bash script which contains encrypted flag as a variable and provide additional variables as hints. The following the script arbitrarily named `1ftc.sh`:

    #!/bin/bash
    clue1="why you can look at my memories"
    clue2="do you seen anything interesting"
    f__l__a__g="hboiucwQckca|wQ}{me}s"
    plsdecrypt="hboiucwQckca|wQ}{me}s"
    sleep 600
After saving this script, ensure that it can be executed using the command `chmod +x 1ftc.sh`. 

**3.  Execute the script and dump the process memory to file**

Execute the bash script using the following command:

    └─$ bash ./1ftc.sh

Now in a new terminal record the process number associated to this script by using the following command:

    └─$ ps aux
The following is an example result. Note that the PID associated with your file will be different. 

    USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    kali      654977  0.0  0.0   7076  3300 pts/4    S+   14:58   0:00 bash 1ftc.sh


**4. Dump memory using Gcore**

We can now dump the memory of this process to a file using the following command:

    sudo gcore -o mems <PID>

The following is an example of the output:

    └─$ sudo gcore -o mem 654977    
    [sudo] password for kali: 
    [Thread debugging using libthread_db enabled]
    Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
    0x00007fbcf5b1ba83 in wait4 () from /lib/x86_64-linux-gnu/libc.so.6
    Saved corefile mem.654977
    [Inferior 1 (process 654977) detached]

**5.  Validate memory dump for variables**

We can perform the same steps from the solution above to validate if this memory dump contains the variables or we can also `grep` them with the commands:

    └─$ grep -a 'hboiucwQckca|wQ}{me}s' mem.654977 
    f__l__a__g="hboiucwQckca|wQ}{me}s"
    plsdecrypt="hboiucwQckca|wQ}{me}s"
    "hboiucwQckca|wQ}{me}s"
The output above validates that this memory dump was created as expected. 

**6.  Install and run a simple Python FTP server on MachineA**

The objective is to record network traffic of unencrypted file transfer from one machine to another of the key.txt and memory dump file. 
on MachineA install `pyftpdlib` and start a simple FTP server in the same directory as the two files using the commands below:

    └─$ pip install pyftpdlib
    └─$ python3 -m pyftpdlib -p 21 -w 
    

**7.  Begin network capture using Wireshark on MachineB**

(optional step) to create arbitrary network traffic run tool 'noisy' https://github.com/1tayH/noisy. Be sure to modify the configuration file to remove unwanted URLs. 

**8. On MachineB access the FTP server**

Using the following commands access the FTP server and download the two files to generate `ftp-data` network traffic. 
The following command and results demonstrate how to access this FTP server. 

    $ ftp <machineA-IP-address>
    Connected to 192.168.10.128.
    220 pyftpdlib 2.0.1 ready.
    Name (192.168.10.128:ajay): anonymous
    331 Username ok, send password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.

Using the `dir` command we can list the files within the directory:

    ftp> dir
    200 Active data connection established.
    125 Data connection already open. Transfer starting.
    -rw-------   1 kali     kali          173 Aug 04 19:18 1ftc.sh
    -rw-rw-r--   1 kali     kali           19 Aug 12 19:09 key.txt
    -rw-r--r--   1 root     root       948248 Aug 12 19:00 mem.654977
    -rw-r--r--   1 root     root       948248 Aug 04 19:20 mem.94482
    drwxrwxr-x   5 kali     kali         4096 Aug 04 19:38 venv
    226 Transfer complete.

And finally use the `get` command to download the two files as shown below:

    ftp> get key.txt
    local: key.txt remote: key.txt
    200 Active data connection established.
    125 Data connection already open. Transfer starting.
    226 Transfer complete.
    19 bytes received in 0.00 secs (122.0703 kB/s)

    ftp> get mem.654977
    local: mem.654977 remote: mem.654977
    200 Active data connection established.
    125 Data connection already open. Transfer starting.
    226 Transfer complete.
    948248 bytes received in 0.01 secs (95.2216 MB/s)
    
Verify that both files are expected using the same validation steps above. 


**9. Save and verify the Wireshark Capture**

Save the packet capture and verify that the packet capture recorded the FTP network traffic as expected. Perform the steps from the solution to validate that this challenge has been successfully created. 

This completes the recreation of this CTF Challenge. 















