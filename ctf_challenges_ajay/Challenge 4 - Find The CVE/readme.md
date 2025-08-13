

# Challenge 4 Find the CVE

## Description

The objective of this challenge is analyze the packet capture of a port scan against a server. The objective is to identify the services existing on the server and find CVE with the highest CVSS score. That CVE is the flag for this challenge. 

# Solution
**1. Analyze the captured network traffic.**

analyzing the TCP traffic using the 'conversations' feature within Wireshark results in a interesting finding. Most conversations are equal to 2 packets. Each of these conversation is on a unique port. This indicates that the ports with two associated packets are closed, whereas ports with more than 2 packets are open.  The following are ports where the TCP stream contains more than 2 packets:

    443
    110
    80
    25
    21

 
**2. Determine services on these ports**

Use the filter `tcp.port == #` where # is the ports identified in the previous step  

    tcp.port == 21
    No 		Time 		Source 			Destination 	Protocol 	Length 	Info
    2037	2.077208	192.168.10.130	192.168.10.128	FTP			86		Response: 220 (vsFTPd 3.0.3) 

    tcp.port == 25
    No 		Time 		Source 			Destination 	Protocol 	Length 	Info 
    2044	2.092533	192.168.10.130	192.168.10.128	SMTP		120		S: 220 localhost.localdomain ESMTP Postfix (Debian/GNU)

    tcp.port == 110
    No 		Time 		Source 			Destination 	Protocol 	Length 	Info
    2042	2.086291	192.168.10.130	192.168.10.128	POP			95		S: +OK Dovecot (Debian) ready.

For port 80, analyzing the headers within the TCP stream provides the service and version 

    GET /nmaplowercheck1754342666 HTTP/1.1
    Connection: close
    Host: 192.168.10.130
    User-Agent: Mozilla/5.0 (compatible; Nmap Scripting Engine; https://nmap.org/book/nse.html)
    
    HTTP/1.1 404 Not Found
    Date: Mon, 04 Aug 2025 21:24:26 GMT
    Server: Apache/2.4.62 (Debian)
    Content-Length: 276
    Connection: close
    Content-Type: text/html; charset=iso-8859-1

From this analysis we have determined that there are the following services running on the Destination server:

    vsFTPd 3.0.3
    ESMTP Postfix (Debian/GNU)
    Dovecot (Debian)
    Apache/2.4.62 (Debian)

Of these services only the following have available versions:

    vsFTPd 3.0.3
    Apache/2.4.62 (Debian)

**3. Perform an investigation to the find the CVE with the highest severity among the two services.** 
 
 vsFTPd 3.0.3 

     CVE-2021-30047  Max CVSS: 7.5.
    Source https://nvd.nist.gov/vuln/detail/CVE-2021-30047  

  
  Apache/2.4.62 

    CVE-2025-53020   Max CVSS: 7.5
    CVE-2025-49812  Max CVSS: 7.4
    CVE-2025-49630  Max CVSS: 7.5
    CVE-2025-23048  Max CVSS: 9.1
    CVE-2024-47252  Max CVSS: 7.5
    CVE-2024-43394  Max CVSS: 7.5
    CVE-2024-43204  Max CVSS: 7.5
    CVE-2024-42516  Max CVSS: 7.5
    Source: https://www.cvedetails.com/vulnerability-list/vendor_id-45/product_id-66/version_id-1801384/Apache-Http-Server-2.4.62.html

**4. Finding the flag**
 As shown above the Apache Server v2.4.62 is affected by CVE-2025-23048 which has the highest CVSS Score as such this is the flag. 

    flag{CVE-2025-23048}
    
The challenge is solved!


# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

**1. Prepare the vulnerable server on MachineB.**

Recreating this challenge requires a webserver hosting these vulnerable services. This can easily be done using Docker. On MachineB host these build and run the DockerFile provided in the artifacts. All of the required configuration files provided. After running this Docker container, no additional configuration is required. 

    docker compose build 
    docker compose up 


**2. Begin network capture using Wireshark on MachineA**
(optional step) to create arbitrary network traffic run tool 'noisy' https://github.com/1tayH/noisy. Be sure to modify the configuration file to remove unwanted URLs. 

**3. Initiate a Nmap Service scan from MachineA**

Execute the following nmap command. 

    └─$ nmap -sV <machineB_IP_address>
                                                                                                                                                                                                         

**6. Stop and confirm traffic capture**

Once the Nmap has completed scanning, verify from both the nmap scan results that it has identified the services as well as verify if the network activity from the scan has been captured within Wireshark. 

**7. Stop and save packet capture.** 

This completes the recreation of this CTF Challenge. 


