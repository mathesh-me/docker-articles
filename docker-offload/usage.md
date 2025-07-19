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
- **Via Command Line**:
    - Open a terminal and run:
        ```bash
        docker offload start
        ```
    - This command will prompt you to choose the account you want to use for Docker Offload and whether you want to enable GPU support.

To verify Docker Offload is running, use:
```bash
docker offload status
```

You can also check the current context to make sure Docker Offload is active:
```bash
docker context ls
```
You should see `docker-offload` as the current context.

#### Using Docker Offload

1. Once Docker Offload is enabled, you can use your usual Docker commands to build and run containers.
2. To test Docker Offload with GPU support, try running a simple hello-world container:
     ```bash
     docker run --rm --gpus all hello-world
     ```
3. To run an Nginx container and access it from your browser:
     ```bash
     docker run --name offload-nginx -d -p 8081:80 nginx
     ```
4. Open your browser and go to `http://localhost:8081`. You should see the Nginx welcome page, showing the container is running in the cloud.
5. To see which containers and images are running in the cloud, use the Docker Desktop Offload dashboard or run:
     ```bash
     docker offload ps
     docker offload images
     ```

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

Even though the prompt says it will destroy containers, images, and volumes, I noticed that I could still see them in the Docker Desktop Offload dashboard after restarting Offload. This might be a bug or a feature that needs clarification. I checked both in the dashboard and via:
```bash
docker offload ps
docker offload images
```

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