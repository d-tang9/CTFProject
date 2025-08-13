

# Challenge 3 - Too Wavy 

## Description

The objective of this challenge is extract an audio file from the PCAP which when looking at the spectogram returns the flag. 


# Solution
**1. Analyzing the PCAP**

In Wireshark analyzing the Protocol Hierarchy feature under statistics results in 77% of the packets consisting of TCP traffic and 18.8% of the packets consisting of UDP packets. Analysis of the TCP packets using the filter `tcp` reveals that most of this traffic is from a host to an external IP associated to Github.com. This can be ignored. 

Analysis of the UDP traffic reveals that it is made up of DNS, ICMP, RTCP and UDP traffic. The RTCP indicates the presence of RTP packets. 
 
**2. Enable RTP_UDP**

Based on the RTCP we can enable the protocol RTP_UDP such that Wireshark can begin to analyze these packets to reveal if they are RTP. To do this enable `rtp_udp` in `Enabled Protocols` under the `Analyze` tab or press  `CNTRL+SHIFT+E`.

From the new window search and enable all of the `RTP`options. 


**3. Analyzing the RTP Traffic**

Now with the protocol enabled, we can see that the UDP packets are now being classified as RTP between `192.168.10.136` and `192.168.10.128`.  Below is an example of these packets. 

    No. Time 		Source			 Destination	 	Protocol 	Length 	Info  
    157	7.916990	192.168.10.136	192.168.10.128		RTP			1062	PT=ITU-T G.711 PCMU, SSRC=0x1A71A9F4, Seq=1450, Time=2927666988
    158	7.917012	192.168.10.136	192.168.10.128		RTP			1078	PT=ITU-T G.711 PCMU, SSRC=0x1A71A9F4, Seq=1451, Time=2927667996
    159	7.917035	192.168.10.136	192.168.10.128		RTP			1078	PT=ITU-T G.711 PCMU, SSRC=0x1A71A9F4, Seq=1452, Time=2927669020
    160	7.917188	192.168.10.136	192.168.10.128		RTP			1078	PT=ITU-T G.711 PCMU, SSRC=0x1A71A9F4, Seq=1453, Time=2927670044

**4. Extract Audio** 

By selecting any of the RTP packets and selecting the `RTP Player` under  `Telephony > RTP > RTP Player` we can see that the RTP is associated with digital audio. When played, the audio does not return any meaningful data and indicates to some encoded data. 

Save this audio stream by selecting the stream, then `Export > Stream Synchronized Audio`. Below is the expected Stream

    Play    Source Address   Source Port  Destination Address  Destination Port  SSRC         Setup Frame  Packets  Time Span (s)       SR (Hz)  PR (Hz)  Payloads
    L       192.168.10.136   38201        192.168.10.128       5004              0x1a71a9f4   RTP 157      48       7.92 - 13.31 (5.39)  8000     8000     g711U


**5. Analyze the audio file in Audacity**

In Audacity open the audio file and change the view from `Waveform` to `Spectogram`. The spectogram appears to contain some image. 
Increase the resolution of this image by resampling the audio track by selecting `track` then `resample` and use the default value `44100 Hz`. 


**6. Finding the flag**
Zooming out in Audacity to make the spectograph dense reveals an image of the Mona Lisa as well as the flag as:

    flag{pls_hire_me}

Thus completing this challenge.



# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

**1. Create an image containing the flag**
Using whichever photo editing software create an image containing the flag. Ensure that the image is around 225 x 250 pixels large. Use the provided `mona_lisa.jpg` file if you wish to use the same flag. 
This image contains the flag `flag{pls_hire_me}. 

**2. Prepare Audio file containing spectograph art.**

The first step is to create an audio file which contains spectorgraph art. There are many ways to achieve this, the easiest is use the resource:
https://nsspot.herokuapp.com/imagetoaudio/

Play around with the player within this resource to optimize the resolution of the image within the audio. Participants can also resample the audio file to increase the resolution as done in the solution. Save the audio file as `flag.wav`


**3. On MachineB start the RTP receiver**

We will use `ffmpeg` to transmit and receive the audio. Install `ffmpeg` if not already installed. 
Run the following command to start to receive this audio file:

    ffmpeg -i rtp://<machineA-IP-address>:5004 -ar 8000 -ac 1 flag.wav
 
Where:

    -i rtp://<IP address>:5004	The address of the RTP server 
    -ar 8000 					Sets the sample rate to 8000Hz which is the max sample rate accepted by Wireshark's RTP streaming functionality
    -ac 1 						Sets the channel to mono 
    flag.wav					The name of the streamed file
    

**4. Begin network capture using Wireshark on MachineB**

(optional step) to create arbitrary network traffic run tool 'noisy' https://github.com/1tayH/noisy. Be sure to modify the configuration file to remove unwanted URLs. 


**5. On MachineA Stream the Audio**

Now that we are capturing the network traffic, we can begin to stream the audio using the following command:

    ffmpeg -re -i flag.wav -ar 8000 -ac 1 -f rtp "rtp://<machineB-IP-address>:5004"

Where:

    -re 						reads the file in real time
    -i flag.wav					specifies the input file 
    -ar 8000 					Sets the sample rate to 8000Hz which is the max sample rate accepted by Wireshark's RTP streaming functionality
    -ac 1 						Sets the channel to mono 
    -f rtp 						Specifies the Destination RTP address 

**6. Verify that the file has been captured on Machine B**

On machineB verify that the flag.wav file was downloaded successfully. 

**7. Stop, confirm and save traffic capture on Wireshark**

Verify that the packet capture of this traffic was captured successfully. Perform the steps from the solution to validate that this challenge has been successfully created. 

This completes the recreation of this CTF Challenge. 












