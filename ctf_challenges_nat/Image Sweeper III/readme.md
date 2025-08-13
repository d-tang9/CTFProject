﻿

# Challenge 3 - Image Sweeper III

## Description

This challenge is one in a series of challenges which starts at the image level. In the first challenge (Image Sweeper I), the user is provided an image which can then be used to reverse lookup the owner’s github account via the image file metadata.  From this point the user is expected to thoroughly inspect and review information that can be found on github as well as any other associated accounts or information that can be uncovered to determine the SSID of the WAP network the target was connected to.   

# Solution

After previously discovering the target’s github in the challenge ‘Image Sweeper I’ one can find the target’s Twitter/X handle as seen below.  From here it is expected that users will navigate to the target’s twitter as part of a their OSINT investigation.   


![](https://github.com/nzapras/CTF-Challenges/blob/main/Image%20Sweeper%20III/image1.png)

 

Once the users have navigated to the target’s twitter page they are then expected to navigate to the ‘Posts’ tab where they will find a tweet which states that the target states that they can free wifi from their apartment. Additionally, the target also provides the BSSID of the wifi they are connecting to for free.  This information is outlined in the screenshot below.  

![](https://github.com/nzapras/CTF-Challenges/blob/main/Image%20Sweeper%20III/image2.png)

Lastly, this BSSID can then be looked up on Wigle.net, a free web app.  This will not only reveal the geolocation of the target but also the SSID of the network they are connected to. This is highlighted in the image below. The user then enters the SSID as the flag to complete the challenge. 

![](https://github.com/nzapras/CTF-Challenges/blob/main/Image%20Sweeper%20III/image3.png)

# Recreating this challenge

To recreate this challenge one can continue with the Twitter page made in Image Sweeper I and simply post a tweet revealing a BSSID.

This completes the recreation of this CTF Challenge. 

