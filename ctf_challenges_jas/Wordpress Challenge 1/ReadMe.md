# Challenge 1: WordPress CTF

## Description
The objective of this challenge is for the participant to search through the posts on the WordPress site and locate the hidden flag within the comments.

---

## Solution
1. Open a web browser and visit the webpage at:  
   ```
   http://localhost:8081
   ```
2. Browse through the posts and take note of the URLs used in each post.
3. Use the terminal to make a GET request to find the hidden comment containing the flag:  
   ```bash
   curl GET http://localhost:8081/?p=4 | grep FLAG
   ```
4. Example hidden flag in HTML comment:  
   ```html
   <!-- FLAG{Wordpress-exploit-flag} -->
   ```

---

## Recreating This Challenge

Recreating this challenge is straightforward but involves several steps:

### 1. Deploy WordPress
- Use Docker to pull **WordPress version 4.7.0** and deploy it.

### 2. Configure WordPress
- Access the administration page using default credentials.
- Create multiple posts.
- In one of the posts, hide the flag using the HTML or code section.
- Add a comment containing the flag:
  ```html
  <!-- flag{Wordpress-exploit-flag} -->
  ```

### 3. Create Docker Image and Push to Docker Hub
- Create a Docker image of the WordPress instance and the MariaDB container.
- Push the image to your Docker Hub account.

### 4. Create Docker Compose File
- Write a `docker-compose.yml` file that pulls the same instance of the challenge.

---

## Example Docker Commands

### Pull WordPress 4.7.0
```bash
docker pull wordpress:4.7.0
```

### Run WordPress with MariaDB
```bash
docker run --name wordpressdb -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=wordpress -d mariadb:latest
docker run --name wordpress --link wordpressdb:mysql -p 8081:80 -d wordpress:4.7.0
```

### Build and Push to Docker Hub
```bash
docker build -t your-dockerhub-username/wordpress-ctf .
docker push your-dockerhub-username/wordpress-ctf
```

---

## Final Notes
This completes the recreation of the **WordPress CTF Challenge**. Once deployed, participants can interact with the WordPress site, search for the hidden flag, and practice their web exploitation skills.
