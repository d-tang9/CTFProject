

# Challenge 6 - Secret Comms 

## Description

The objective of this challenge is to extract SSL keys within the PCAP, then decrypt the TLS traffic within the PCAP to find a flag. 


# Solution
**1. Analyzing the PCAP**

In Wireshark analyzing the Protocol Hierarchy feature under statistics results in 97.3% of the traffic being TCP of which we can see that there are 4 packets for HTTP data. 
 
**2. Extract HTTP Objects - SSL Keys**

Using the filter `HTTP` we can see that there is a file called `SSLKeys.zip` being sent as a result of a GET request from `192.168.10.128` to `192.168.19.130`. 

From `File` tab, select `Export Objects` and choose `HTTP Data`. Download and extract this `SSLKeys.zip` file.  

**3.Decrypt TLS traffic**

We can now proceed to decrypt the TLS traffic by selecting the `Edit` tab, >`preferences` > `protocols` > `TLS` and select the `SSLKeys.log` file as the `(Pre)-Master-Secret log filename`.  
Also ensure that for `TCP` traffic `reassemble out-of-order segements` option is enabled. 

**4. Analyze decrypted SMTP packets** 
Use the filter `SMTP` to isolate SMTP packets. 

    No.	Time			Source 			Destination		Proto	Length	Info
    67	14.470439747	192.168.10.130	192.168.10.128	SMTP	129		S: 220 srt888-group9-lab Python SMTP 1.4.6
    70	14.471238422	192.168.10.130	192.168.10.128	SMTP	111		S: 250-srt888-group9-lab
    75	14.504137135	192.168.10.128	192.168.10.130	SMTP	117		C: mail FROM:<ajay@group9.com>
    77	14.504745699	192.168.10.128	192.168.10.130	SMTP	118		C: rcpt TO:<dickson@group9.com> 

Select any SMTP packet and analyze the TLS Stream which should look like the following:

    220 srt888-group9-lab Python SMTP 1.4.6
    ehlo [127.0.1.1]
    250-srt888-group9-lab
    250-8BITMIME
    250-SMTPUTF8
    250 HELP
    mail FROM:<ajay@group9.com>
    250 OK
    rcpt TO:<dickson@group9.com>
    250 OK
    data
    354 End data with <CR><LF>.<CR><LF>
    Subject: The NIST document you requested
    From: ajay@group9.com
    To: dickson@group9.com
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="===============0564313142997548653=="
    
    --===============0564313142997548653==
    Content-Type: text/plain; charset="utf-8"
    Content-Transfer-Encoding: quoted-printable
    
    Hello!
    
    I have attached the NIST document that you wanted. Let me know if you need an=
    ything else!.
    
    --===============0564313142997548653==
    Content-Type: application/pdf
    Content-Transfer-Encoding: base64
    Content-Disposition: attachment; filename="nist_csf_updated.pdf"
    MIME-Version: 1.0
    
    JVBERi0xLjYNJeLjz9MNCjE0NzAgMCBvYmoNPDwvTGluZWFyaXplZCAxL0wgMTUxODg1OC9PIDE0
    NzMvRSAzNzQ5OTYvTiAzMi9UIDE1MTgwNjgvSCBbIDU0MyA2ODFdPj4NZW5kb2JqDSAgICAgICAg
    DQoxNDg3IDAgb2JqDTw8L0RlY29kZVBhcm1zPDwvQ29sdW1ucyA1L1ByZWRpY3RvciAxMj4+L0Zp
    bHRlci9GbGF0ZURlY29kZS9JRFs8RTVCNTc3RTM4MkFDQTc0MkE2NUM3MjgxMERDNkFCOTA+PEJG
    MzIyMjdFQjVFNzBBNDVBQzVDNTQ5ODY5MThBQkJBPl0vSW5kZXhbMTQ3MCA1N10vSW5mbyAxNDY5
    IDAgUi9MZW5ndGggMTA0L1ByZXYgMTUxODA2OS9Sb290IDE0NzEgMCBSL1NpemUgMTUyNy9UeXBl
    L1hSZWYvV1sxIDMgMV0+PnN0cmVhbQ0KaN5iYmRgEGBgYmBg2QEimd6DSAYbMLsSLH4CTJaASOZC
    ....
    Cj4+DQpzdHJlYW0NCgAAAAAA//8BABctIAAAAQAXSNgAAAEAF0z6AAANCmVuZHN0cmVhbQ0KZW5k
    b2JqDQolRW5kRXhpZlRvb2xVcGRhdGUgMTUxODg1OA0Kc3RhcnR4cmVmDQoxNTI3MDM0DQolJUVP
    Rg0K
    
    --===============0564313142997548653==--
    .
    250 Message accepted for delivery
    QUIT
    221 Bye


**5. Extract the Base64 Data**

From the TLS stream we can observe that one user has emailed another user a PDF file named "nist_csf_updated.pdf". The content of this PDF file is stored as Base64 data within this TLS Stream. 

Save this this TLS stream as ASCII to a text file. 

Within this text file we want to remove all the data which is non-base64 encoded including everything up until the file data and the remaining data at the end. 

The text file should look something like this:

    JVBERi0xLjYNJeLjz9MNCjE0NzAgMCBvYmoNPDwvTGluZWFyaXplZCAxL0wgMTUxODg1OC9PIDE0
    NzMvRSAzNzQ5OTYvTiAzMi9UIDE1MTgwNjgvSCBbIDU0MyA2ODFdPj4NZW5kb2JqDSAgICAgICAg
    DQoxNDg3IDAgb2JqDTw8L0RlY29kZVBhcm1zPDwvQ29sdW1ucyA1L1ByZWRpY3RvciAxMj4+L0Zp
    .....
    Cj4+DQpzdHJlYW0NCgAAAAAA//8BABctIAAAAQAXSNgAAAEAF0z6AAANCmVuZHN0cmVhbQ0KZW5k
    b2JqDQolRW5kRXhpZlRvb2xVcGRhdGUgMTUxODg1OA0Kc3RhcnR4cmVmDQoxNTI3MDM0DQolJUVP
    Rg0K

Consisting of a total of 26797 lines in total. 

**6. Extracting the PDF**

Using Cyberchef upload the file as the input and use the module `From Base64`. The output should be a PDF file which you should download.   The file will be saved as `download.pdf` by Cyberchef

**6. Analyze PDF Metadata**

using `Exiftool` analyze the metadata of this file:

    └─$ exiftool download.pdf  
    ExifTool Version Number         : 13.00
    File Name                       : download.pdf
    Directory                       : .
    File Size                       : 1527 kB
    File Modification Date/Time     : 2025:08:12 12:56:35-04:00
    File Access Date/Time           : 2025:08:12 12:56:35-04:00
    File Inode Change Date/Time     : 2025:08:12 12:56:35-04:00
    File Permissions                : -rw-rw-r--
    File Type                       : PDF
    File Type Extension             : pdf
    MIME Type                       : application/pdf
    PDF Version                     : 1.6
    Linearized                      : No
    Author                          : National Institute of Standards and Technology
    Category                        : 
    Comments                        : 
    Company                         : 
    Content Type Id                 : 0x01010039BCE524E722AC4882B40135ECFFCA17
    Create Date                     : 2024:03:06 15:46:45-05:00
    DOI Machine-readable Pub ID     : NIST.CSWP.29
    DOI Value                       : NIST.CSWP.29
    Media Service Image Tags        : 
    Modify Date                     : 2025:06:04 10:58:23-04:00
    Pub ID                          : NIST CSWP 29
    Pub ID DOI                      : NIST.CSWP.29
    Pub ID Human-readable           : NIST CSWP 29
    Publication Date                : Month DD, 2024
    Short Title Line 1              : The NIST Cybersecurity Framework (CSF) 2.0
    Short Title Line 2              : 
    Source Modified                 : 
    Has XFA                         : No
    Language                        : EN-US
    Tagged PDF                      : Yes
    XMP Toolkit                     : Image::ExifTool 13.00
    Creator                         : National Institute of Standards and Technology
    Format                          : application/pdf
    Subject                         : "FLAG{nist-this-nist-that}"
    Title                           : The NIST Cybersecurity Framework 2.0
    Producer                        : Adobe PDF Library 23.8.53
    DOI0020 Value                   : NIST.CSWP.29
    DOI00200028 Machine-readable 0020 Pub ID0029: NIST.CSWP.29
    Pub ID00200028 DOI0029          : NIST.CSWP.29
    Pub ID00200028 Human-readable 0029: NIST CSWP 29
    Publication 0020 Date           : Month DD, 2024
    Creator Tool                    : Acrobat PDFMaker 23 for Word
    Metadata Date                   : 2025:06:04 10:58:23-04:00
    Document ID                     : uuid:b3e5db79-3fc1-419e-8795-117f12c23b4c
    Instance ID                     : uuid:aad63db6-5809-4392-a6c8-eedf05d3621a
    Page Layout                     : OneColumn
    Page Mode                       : UseOutlines
    Page Count                      : 32

The subject line contains the flag:

    Subject                         : "FLAG{nist-this-nist-that}"
    
Thus completing this challenge.



# Recreating this challenge 
Recreating this challenge is complicated as it requires several phases.
**Phase 1 - Create SMTP Packet Capture**
**1. Create the PDF**
Select whichever PDF that you want to use for this challenge. We will use the following command to modify the subject line to contain the flag.  

    └─$ exiftool -overwrite_original -Title="The NIST Cybersecurity Framework 2.0" -Subject='"FLAG{nist-this-nist-that}"'  nist.pdf \    
      -o nist_csf_updated.pdf
        1 image files updated


**2.  Begin network capture using Wireshark on MachineB**

(optional step) to create arbitrary network traffic run tool 'noisy' https://github.com/1tayH/noisy. Be sure to modify the configuration file to remove unwanted URLs. 

**3. On MachineB start the SMTP Mock Server Script**

Ensure that you have the files `cert.pem`, `key.pem` and `smtp_server.py` in the same directory. 

Modify the `smtp_server.py` script and replace the IP address `192.168.10.130` with the IP address of the MachineB. 

Use the following command to launch the SMTP server:

    sudo python3 smtp_server.py

**4. Send the traffic to the server on MachineA**

On machineA ensure that the files `send_email.py` and the modified PDF are in the same directory. 
Modify the `send_email.py` file to change the `SMTP_HOST`IP address to that of MachineB as well as ensuring that the `file_path` variable is configured to the filename of the PDF file. 

With Wireshark recording, execute this script, the results should look like the following:

    └─$ python3 send_email.py 
    
    220 srt888-group9-lab Python SMTP 1.4.6
    250-srt888-group9-lab
    250-8BITMIME
    250-SMTPUTF8
    250 HELP
    250 OK
    250 OK
    Done: server saw the DATA begin, end, and the QUIT—no stray bytes were mis-framed.
                                                                                          


**5. Stop smtp server on MachineB **

Stop the server script on machineB. Once stopped verify that the file `SSLKeys.log` was saved within the same directory.    

**6. Save and verify the Wireshark Capture**

Save the packet capture as `part1.pcap` and verify that the packet capture recorded the network traffic as expected. Following the solutions, ensure that you can decrypt the network traffic with the `SSLKeys.log` file and that the SMTP traffic with the application data is recorded as in the solutions. 

**Phase 2 - Create Packet Capture containing SSLKeys.log ZIP file**
**7. On MachineB compress and host SSLKeys.log on a webserver**

Compress the SSLKeys.log as a ZIP file using the following command:

    $ zip SSLKeys.zip SSLKeys.log 
      adding: SSLKeys.log (deflated 60%)
   
   Within the same directory host a simple HTTP web server of the directory using the command:
   
    $ sudo python3 -m http.server 8080 --bind 0.0.0.0
    Serving HTTP on 0.0.0.0 port 8080 (http://0.0.0.0:8080/) ...


**8. Start another Wireshark packet capture**

Again start another wireshark capture. This goal of this capture is to record the network traffic of MachineA downloading the SSLKeys.zip file from MachineB. 

**9. Download SSLKeys.zip from MachineB on MachineA**
On MachineA visit the following website and download the SSLKeys.zip file:

    http://<machineB-IP-address>:8080

**10. Save and verify the Wireshark Capture**

Save the capture as `part2.pcap` and verify that the packet capture recorded HTTP GET request and reply for the SSLKeys.zip. Ensure that you can export this file as an object from the pcap. 

**11. Merge packet captures**
Now that  you have the two packet captures `part1.pcap` and `part2.pcap`, all that is left is to merge the packet captures. To do this perform the following command:

    └─$ mergecap -w challenge6.pcap part1.pcap part2.pcap 




Verify that the PCAPs was merged successfully. Perform the steps from the solution to validate that this challenge has been successfully created. 

This completes the recreation of this CTF Challenge. 













