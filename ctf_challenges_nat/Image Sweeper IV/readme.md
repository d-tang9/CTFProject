﻿

# Challenge 4 - Image Sweeper IV

## Description

The objective of this challenge is to determine the target's web admin's password. 

# Solution
**1. Review Target Github**

Reviewing github will reveal that the target has a blog post webpage. 
 
**2. Review Webpage Elements**

Reviewing the elemnents and html code of the web page will reveal a hidden piece of text that blends in with the back ground of the webpage.  The text is as follows: "VG9wU2VjcmV0ISEwMQ==" 

**3. Decoding the Text**

Upon further inspection, the text is an encoded string using base64.  Once decoded the text reads: "TopSecret!!01"

**4. Submitting the Flag**

One can the submit this flag in the following format: flag{TopSecret!!01}.

# Recreating this challenge 

To recreate this challenge one can follow these steps:

1. Create and host a simple HTML webpage.
2. Create and encode the flag using base64.
3. Insert the flag on the webpage and hide it matching the bacground colour site with the encoded text.

This completes the recreation of this CTF Challenge. 

