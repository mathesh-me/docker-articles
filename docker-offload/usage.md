## Docker Offload

### Introduction

Docker Offload is a feature that lets you build and run containers on cloud infrastructure, reducing the load on your local machine and improving performance for resource-intensive applications. It also supports GPU-accelerated instances, which is great for machine learning, data processing, and other high-compute workloads.

### Features

- **Cloud-based Containerization**: Run Docker containers on cloud platforms to leverage scalable resources.
- **GPU Support**: Use NVIDIA L4 GPU-backed environments for high-performance computing needs.
- **Resource Optimization**: Offload heavy tasks to the cloud, freeing up your local resources.
- **Ephemeral Cloud Runners**: Automatically provision and tear down cloud environments for each container session.
- **Seamless Integration**: Works smoothly with your existing Docker workflows and tools.
- **Shared Cache**: Speed up builds and reduce redundant downloads of images and dependencies across machines and teammates.

### How it Works

<img width="8110" height="3089" alt="image" src="https://github.com/user-attachments/assets/1f87fdde-7f12-4faf-bc0f-08827f720722" />


- Docker Desktop connects to the cloud and triggers container builds and runs on cloud infrastructure.
- `docker offload`  pulls images and starts containers in the cloud, using your specified GPU, CPU, and memory configurations.
- The connection stays open while the container is running, so you can interact with it in real time.
- The cloud environment is ephemeral—created for the duration of your session and destroyed afterward, so there are no leftover resources.

> Docker Offload provisions a temporary cloud environment for each session. The environment stays active while you’re using Docker Desktop or running containers. If there’s no activity for about 5 minutes, the session shuts down automatically. This deletes any containers, images, or volumes in that environment.

### Getting Started

#### Prerequisites

Make sure you have Docker Desktop version 4.43 or later installed.

### How to Use Docker Offload

#### Sign Up for Docker Offload

1. Docker Offload is currently in beta, so you’ll need to sign up for the beta program.
2. Go to the [Docker Offload Beta Sign Up](https://www.docker.com/products/docker-offload/) page and fill out the form.
3. After signing up, you’ll get an email with instructions on how to enable Docker Offload in Docker Desktop. (For me, the email arrived about a week after signing up.)

> Once you receive the email, you can enable Docker Offload in Docker Desktop.

#### Enable Docker Offload in Docker Desktop

You can enable Docker Offload in two ways:

- **Via Docker Desktop Settings**:
    - Open Docker Desktop.
    - Toggle the switch to enable Docker Offload (you’ll find this option at the bottom left corner of the Docker Desktop window).
      
      <img width="1919" height="1015" alt="Screenshot 2025-07-19 191135" src="https://github.com/user-attachments/assets/0036b946-2dd7-46cb-a633-ed9d781a7f74" />

- **Via Command Line**:
    - Open a terminal and run:
        ```bash
        docker offload start
        ```
    - This command will prompt you to choose the account you want to use for Docker Offload and whether you want to enable GPU support.

      <img width="1919" height="270" alt="Screenshot 2025-07-19 191233" src="https://github.com/user-attachments/assets/6a8d6149-d528-4753-b5e0-5cce9441b4d0" />
      <img width="1919" height="294" alt="Screenshot 2025-07-19 191243" src="https://github.com/user-attachments/assets/1ef1f18a-ce44-4101-bc92-56299436bac4" />


To verify Docker Offload is running, use:
```bash
docker offload status
```

You can also check the current context to make sure Docker Offload is active:
```bash
docker context ls
```
You should see `docker-cloud` as the current context.

<img width="1919" height="606" alt="Screenshot 2025-07-19 191330" src="https://github.com/user-attachments/assets/e0f54e01-5442-41ab-a148-42f1570d52fb" />


#### Using Docker Offload

1. Once Docker Offload is enabled, you can use your usual Docker commands to build and run containers.
2. To test Docker Offload with GPU support, try running a simple hello-world container:
     ```bash
     docker run --rm --gpus all hello-world
     ```
     
     <img width="1919" height="715" alt="Screenshot 2025-07-19 191447" src="https://github.com/user-attachments/assets/c94f809e-6b0b-41f5-9626-efb17a600f96" />


3. To run an Nginx container and access it from your browser:
     ```bash
     docker run --name offload-nginx -d -p 8081:80 nginx
     ```
     <img width="1919" height="577" alt="Screenshot 2025-07-19 191614" src="https://github.com/user-attachments/assets/9e2ccbdf-2c32-4790-92e0-2a2facf853a9" />

     
4. Open your browser and go to `http://localhost:8081`. You should see the Nginx welcome page, showing the container is running in the cloud.

<img width="1919" height="1020" alt="Screenshot 2025-07-19 191650" src="https://github.com/user-attachments/assets/a40342b2-212c-4745-8c5d-1ee04d1af516" />

5. To see which containers and images are running in the cloud, use the Docker Desktop Offload dashboard or run:
     ```bash
     docker offload ps
     docker offload images
     ```
<img width="1919" height="1008" alt="Screenshot 2025-07-19 191629" src="https://github.com/user-attachments/assets/85ce23b1-3504-4365-99c6-0a5c93c4a753" />


#### Stopping Docker Offload

You can stop Docker Offload in two ways:

- **Via Docker Desktop Settings**:
    - Open Docker Desktop.
    - Toggle the switch to disable Docker Offload.
- **Via Command Line**:
    - Open a terminal and run:
        ```bash
        docker offload stop
        ```
    - You’ll be prompted to confirm, and once confirmed, Docker Offload will stop.
    
    <img width="1919" height="290" alt="Screenshot 2025-07-19 192932" src="https://github.com/user-attachments/assets/b51f6d3e-a350-43b5-949c-126daedbc845" />


    <img width="1919" height="298" alt="Screenshot 2025-07-19 192101" src="https://github.com/user-attachments/assets/516371fb-6c88-4ec4-a7ad-86341e53131a" />


Even though the prompt says it will destroy containers, images, and volumes, I noticed that I could still see them in the Docker Desktop Offload dashboard after restarting Offload. This might be a bug or a feature that needs clarification. I checked both in the dashboard and via:

Dashboard Results:

<img width="1919" height="1016" alt="Screenshot 2025-07-19 223342" src="https://github.com/user-attachments/assets/4f243339-1646-4b39-9730-460f94258f3b" />

CLI Results:
```bash
docker ps
docker images
```
<img width="1919" height="859" alt="Screenshot 2025-07-19 223450" src="https://github.com/user-attachments/assets/0c4d0726-fabe-454a-940c-640634bc52d4" />


If you want to remove all images and containers from the cloud, run:
```bash
docker stop <container_id>
docker rm <container_id>
docker rmi <image_id>
```

### Other Useful Docker Offload Configurations

- **Disk Allocation**: Configure how much disk space to allocate for Shared Cache in the Docker Offload settings.
- **Private Resource Access**: Allow cloud builders to pull images and packages from private resources—useful for corporate environments with private registries.
- **Authentication**: Docker Offload supports authentication for private registries, so you can pull images securely.
- **Firewall Rules**: Configure firewall rules to control access from the cloud builder to egress IP addresses, ensuring secure communication between your local machine and the cloud environment.
