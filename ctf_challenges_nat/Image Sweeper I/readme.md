

# Challenge 1 - Image Sweeper I

## Description

The objective of this challenge is to determine the owner's email from an image file that was reconstructed from a public WiFi. 

# Solution
**1. Review Metadata**

Reviewing the Metadata will reveal that the photographer's online alias is C0SM1CINFLUX.
 
**2. Conduct a Search**

After conducting a thorough search, the user should be able to find the target's github and subsequently the target's twitter page and blog.

**3. Locating the Email**

The user can then find the target's email visible in their Project-Recruiter repo readme.md file.

**4. Entering the Flag**

The user should then enter the following flag to submit the email: flag{C0SM1CINFLUX@gmail.com}

# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

To recreate this challenge one can follow these steps:

1. Select an image to start with.
2. Modify the copyright metadata string to be the name/alias of the target using `exiftool`.
3. Create a supporting github account `https://github.com/C0SM1CINFLUX`, twitter account `https://x.com/C0SM1CINFLUX`, and blog webpage `https://comets.pro/`.
4. Create a repo on the github account with an readme.md file that contains the target's email. 

This completes the recreation of this CTF Challenge. 

