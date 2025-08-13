

# Challenge 1 Echo Echo

## Description

The objective of this challenge is analyze ICMP packets to find a hidden message (hence ICMP Echo). The message is base64 encoded. 

# Solution
**1. Analyzing the PCAP**

In wireshark filter for ICMP using the filter 'ICMP' 
Notice how packets 272 and 274 contain the following payloads 
 
     0000   00 50 56 c0 00 02 00 0c 29 5a af 31 08 00 45 00   .PV.....)Z.1..E.
    0010   00 38 00 01 00 00 40 01 e4 ea c0 a8 0a 88 c0 a8   .8....@.........
    0020   0a 01 08 00 91 cd 00 00 00 00 59 6f 75 20 61 72   ..........You ar
    0030   65 20 76 65 72 79 20 6f 62 73 65 72 76 65 6e 74   e very observent
    0040   2c 20 79 6f 75 72                                 , your
    
    0000   00 50 56 c0 00 02 00 0c 29 5a af 31 08 00 45 00   .PV.....)Z.1..E.
    0010   00 32 00 01 00 00 40 01 e4 f0 c0 a8 0a 88 c0 a8   .2....@.........
    0020   0a 01 08 00 ff 90 00 00 00 01 63 6c 6f 73 65 21   ..........close!
    0030   20 4b 65 65 70 20 64 69 67 67 69 6e 67 2e 2e 2e    Keep digging...

**2. Inspect the remaining ICMP requests**


Filter for ICMP request packets to remove duplicate Request/Reply packets using the Filter "icmp.type == 8".
The following packets 619, 621 and 623 contain the following payloads  

    0000   00 50 56 c0 00 02 00 0c 29 5a af 31 08 00 45 00   .PV.....)Z.1..E.
    0010   00 3c 00 01 00 00 40 01 e4 e6 c0 a8 0a 88 c0 a8   .<....@.........
    0020   0a 01 08 00 75 a4 00 00 00 00 62 27 56 32 39 33   ....u.....b'V293
    0030   49 48 64 6c 49 47 68 68 64 6d 55 67 59 53 42 7a   IHdlIGhhdmUgYSBz
    0040   62 57 46 79 64 48 6b 67 63 47                     bWFydHkgcG
    
    0000   00 50 56 c0 00 02 00 0c 29 5a af 31 08 00 45 00   .PV.....)Z.1..E.
    0010   00 3c 00 01 00 00 40 01 e4 e6 c0 a8 0a 88 c0 a8   .<....@.........
    0020   0a 01 08 00 b2 22 00 00 00 01 46 75 64 48 4d 73   ....."....FudHMs
    0030   49 47 5a 73 59 57 64 37 61 56 39 6c 59 58 52 66   IGZsYWd7aV9lYXRf
    0040   61 57 4e 74 63 46 39 77 59 57                     aWNtcF9wYW
    
    0000   00 50 56 c0 00 02 00 0c 29 5a af 31 08 00 45 00   .PV.....)Z.1..E.
    0010   00 33 00 01 00 00 40 01 e4 ef c0 a8 0a 88 c0 a8   .3....@.........
    0020   0a 01 08 00 4a da 00 00 00 02 4e 72 5a 58 52 7a   ....J.....NrZXRz
    0030   58 32 5a 76 63 6c 39 6b 61 57 35 75 5a 58 4a 39   X2Zvcl9kaW5uZXJ9
    0040   27                                                '

**3. Isolate the encoded message** 

Isolating the Base64 payload from the three payloads above which is: `"b'V293IHdlIGhhdmUgYSBzbWFydHkgcGFudHMsIGZsYWd7aV9lYXRfaWNtcF9wYWNrZXRzX2Zvcl9kaW5uZXJ9'`

**4. Decode Message**  

Decode the Base64 payload using your choice of tool such as CyberChef or the Base64 command 

    └─$ echo V293IHdlIGhhdmUgYSBzbWFydHkgcGFudHMsIGZsYWd7aV9lYXRfaWNtcF9wYWNrZXRzX2Zvcl9kaW5uZXJ9 | base64 --decode 
    Wow we have a smarty pants, flag{i_eat_icmp_packets_for_dinner} 

The challenge is solved!


# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

**1. Prepare the hints and flag**

In this challenge the hint was: 

    “You are very observant, your close! Keep digging...”
and the string containing the flag is:

    Wow we have a smarty pants, flag{i_eat_icmp_packets_for_dinner}

**2. Modify the following python script**

In the provided Python script 'ICMP_messages.py', modify the target IP to be the IP of MachineA, hint and message to reflect your environment and the hint and message as appropriate. To increase the complexity of this challenge, you can select a different encoding algorithm or chain several encoding and/or encryption algorithms together. However for this we will just encode in Base64 as shown:

    from scapy.all import IP, ICMP, send
    import textwrap, base64, time
    
    # Target IP
    target_ip = "192.168.10.1"
    
    # hint message in plane text
    hint = "You are very observent, your close! Keep digging..."
    message = "Wow we have a smarty pants, flag{i_eat_icmp_packets_for_dinner}"
    
    # convert string to bytes 
    message_bytes = message.encode('utf-8')
    # convert bytes to base64
    base64_message = base64.b64encode(message_bytes)
    
    print(str(base64_message))
    
    def icmp_message(message):
    	# Split message into chunks (e.g., 32 bytes each)
    	chunk_size = 32
    	chunks = textwrap.wrap(message, chunk_size)
    
    	# Send each chunk in an ICMP packet
    	for i, chunk in enumerate(chunks):
        		packet = IP(dst=target_ip)/ICMP(seq=i)/chunk.encode()
        		send(packet)
    
    print("sending hint")
    icmp_message(hint)
    time.sleep(15)
    print("sending encoded message")
    icmp_message(str(base64_message))

**3. Begin network capture using Wireshark. This requires two machines, machineA and machineB.**

(optional step) to create arbitrary network traffic run tool 'noisy' https://github.com/1tayH/noisy. Be sure to modify the configuration file to remove unwanted URLs. 

**4. From machineB execute the script using the following command**

The script will take about 30 seconds to finish, be patient. 
on MachineB:

    └─$ sudo python3 ICMP_messages.py
    b'V293IHdlIGhhdmUgYSBzbWFydHkgcGFudHMsIGZsYWd7aV9lYXRfaWNtcF9wYWNrZXRzX2Zvcl9kaW5uZXJ9'
    sending hint
    .
    Sent 1 packets.
    .
    Sent 1 packets.
    sending encoded message
    .
    Sent 1 packets.
    .
    Sent 1 packets.
    .
    Sent 1 packets.

**5. Stop and save packet capture.**

Verify that the packet capture contins the ICMP packets as expected. Perform the steps from the solution to validate that this challenge has been successfully created.

This completes the recreation of this CTF Challenge. 



