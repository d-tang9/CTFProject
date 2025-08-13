

# Challenge 9 - Billy Jean I

## Description

This challenge is the first challenge in two a part challenge wherein the user is provided a multi-volume file. You will need to download both of the files and put them in the same directory or else you will not be able to process the disk image. The disk image used in this challenge can be found here https://digitalcorpora.org/corpora/scenarios/m57-jean/. The disk image given is from an employee named Jean who works at M57.biz. A few weeks into the creation of the company, a confidential spreadsheet that contains the names and salaries of the company’s key employees was found posted to the comment section of one of the firm’s competitors.

With this in mind, the goal of this challenge is to determine the online identity of the adversary (email address) which leaked this information.

# Solution


Reviewing Jean's emails will reveal an email from ‘Alison’ was received urging Jean for the sensitive document that was leaked. Upon further inspection of the same email it is clear that the return path of the email is not Alison's email or even M57.biz related.  An even closer look will reveal that the email was actually sent by a ‘tuckgeorge@gmail.com’, which confirms that the sensitive information was released via a spear phishing attack wherein the attacker posed as Alison.  Therefore the flag in this challenge would be `flag{tuckgeorge@gmail.com}`.
 

# Recreating this challenge 

To recreate this challenge one can simply download the multi-volume files listed below from the following source: https://digitalcorpora.org/corpora/scenarios/m57-jean/

1. nps-2008-jean.E01
2. nps-2008-jean.E02 
