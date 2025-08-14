Each folder contains their own individual readme files.


# CTF Project Group 9
## Contact Information
The following are the members of Group 9 for SPR888. 
Dickson Tang - dtang9@myseneca.ca
Ajay Modgil - amodgil1@myseneca.ca
Jaskaran Sohal - jsohal6@myseneca.ca
Nathaniel Zapras - nzapras@myseneca.ca

## Introduction
This repo contains all of the source code for this CTF Projects. 

The following folders contain each group members developed CTF challenges with a `readme.md` each containing the challenges example solution and recreation steps:
- ctf_challenges_ajay
- ctf_challenges_dtang
- ctf_challenges_jas
- ctf_challenges_na

The `Participants Challenges` folder contains a set of challenges using Docker with a helpful script `ctf-helper.sh` designed for participants to easily launch each challenge. This folder should be provided to students at the beginning of the CTF event. 
 
Finally, the `CTFd` folder contains a configured CTFd instance with all the challenges pre-loaded and all configuration made. 

# CTFd - CTF Platfrom 
The CTFd repository is found in the `spr888-ctfd-main` folder and it contains an already configured CTFd instances with all the challenges and configurations pre-loaded for anyone to host this CTF project. This project is based on the popular CTF platform, CTFd:
- https://ctfd.io/
- https://github.com/CTFd/CTFd 

## Instructions for running the pre-configured CTFd platform
**Prerequisites** 
To host this CTF project, Docker engine and Docker Compose are required. Follow the following instructions on how to install `docker` and `docker compose` as they are required to run the CTF server. 
  - https://docs.docker.com/engine/install/ 
  - https://docs.docker.com/compose/install/linux/#install-using-the-repository

To host a CTF for about 20 participants the following are the bare minimum recommended specs for such a virtual machine:
-   **vCPU**: 2 cores
-   **RAM**: 4 GB
-   **Storage**: 60 GB SSD Minimum  
-   **Network**: 1 Gbps shared (IP address should be accessible to all participants)
-   **OS**: Latest Ubuntu LTS or Debian LTS 

Ensure the network is configured to allow multiple systems to reliably access the virtual machine simultaneously via it's IP address. 

**Step 1. Configure a virtual machine**
The first step to launch the configured CTFd instance is to copy the `spr888-ctfd-main` directory to a virtual machine intended to host this CTF web platform. 

Ensure that no other web applications or services are operating on port `8000` on this virtual machine. 

**Step 2. Launch CTFd**
Within the `ctfdfinal` directory, execute the following command to launch this pre-configured CTFd docker instance.

    $ docker compose pull 
    $ docker compose up -d
 Depending on how you have installed Docker, you may need to run these commands with`sudo`

**Step 3. Access CTFd Web application**

After the above steps are complete CTFd should be accessible through your local IP address. In a browser visit the following site:

    https://<vm-ip-address>:8000

At the login page use the following credentials to access the admin account:
``Username: PentestCourseAdmin ``
``Password: Thisisasecurepassword``

The following is the credentials for the test user account:
``Username: participant1``
``Password: P@ssw0rd``

Follow the following CTFd documentations on creating additional user accounts for each participant or they can create their own accounts:
https://docs.ctfd.io/tutorials/users/adding-new-users/ 

**Step 4. Provide participants with Access**
The last step is providing students with the URL of the CTFd instance for them to be able to access and participate. Student's can either access the platform with pre-configured accounts or may be allowed to register their own accounts as is up to the event host. 





