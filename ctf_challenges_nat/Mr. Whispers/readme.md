﻿

# Challenge 8 - Mr. Whispers

## Description

The objective of this challenge is to extract the hidden message which has been spread accross one or more of the 9 images of cats found in the provided folder. 

# Solution
**1. Using Stegnography Techniques**

The user should then try to use stenography techniques to determine if there is any hidden messages within the image files.  In doing so the user should discover that there
is a hidden archive within two of image files, specifically image2 and image7. Each image contains a text file with one half of an encoded message. 

**2. Decoding the Text**

The user should then notice that the text is encoded in base64 and then decoded it for each text file. This should produce the following results:

1. Image2 --> `You exist to open cans and scratch`
2. Image7 --> ` behind my ears. Don’t forget that`

When piecing these two messages together it will yield the following message:

`You exist to open cans and scratch behind my ears. Don’t forget that`

Therefore, the flag will be: `flag{You exist to open cans and scratch behind my ears. Don’t forget that}`

# Recreating this challenge 

To recreate this challenge one can follow these steps:

1. Select 9 images to start with.
2. Create a message to be the flag.
3. Divide it in half and encode each half in base64
4. Create a text file for each cipher text and zip them.
5. Then for each zip select 2 files to hide them in by using the following command on Windows command prompt: copy / b [name of image file]+[name of text file] [new name of second image file]

This completes the recreation of this CTF Challenge. 

