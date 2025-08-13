﻿

# Challenge 5 - Image Sweeper V

## Description

The objective of this challenge is to search through the target's github to find a hidden message.

# Solution
**1. Review Github**

Reviewing the Github as well as what one has already used from it will point the user in the direction necesarry to solve challenge, reviewing the 
'Cool-Photos' repository. On this repository there is only one photo of a car.
 
**2. Using Stegnography Techniques**

The user should then try to use stenography techniques to determine if there is any hidden message within the image file.  In doing so the user should discover that there
is a hidden archive within the image file.  This can be achieve by trying to open the file as a directory with tools such as 7zip or winrar. In this archive will be a single
text file containing encoded text.

**3. Decoding the Text**

The user should then notice that the text is encoded in base64 and then decoded it.  This will yield the following message: flag{VROOMVROOM}.  The user can then submit this flag to complete the challenge.

# Recreating this challenge 

To recreate this challenge one can follow these steps:

1. Select an image to start with.
2. Create a flag and encode it base64.
3. Create a text file and insert the flag.
4. Zip the text file.
5. Use the following command on Windows command prompt: copy / b [name of image file]+[name of text file] [new name of second image file]
6. Then upload the new image file to the github repo of your target account. 

This completes the recreation of this CTF Challenge. 

