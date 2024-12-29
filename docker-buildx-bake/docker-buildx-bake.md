# Docker Bake 🐳

`Docker buildx bake` is a feature introduced in `Docker 24.0`. ***It helps us to build and push multiple images in parallel. It also helps in ease of use and maintainability for Build Configurations when running `docker buildx build` with multiple options.*** We can declare all the build configurations in a single declarative file and run `docker buildx bake` to build all the images in parallel without specifying all the build configurations in a single command.<br>

The bake file can be written in `YAML`, `JSON`, or `HCL` format. I'm going to use `HCL` syntax for this article.

### Prerequisites for Using Docker Build Checks

`Docker buildx bake` is a feature introduced in `Docker 24.0`. To run Docker Build Checks, you need to have `Buildx CLI` installed on your system. You can check the version of Docker Buildx installed on your system by running the following command:

```bash
docker buildx version
```

If you don't have Docker Buildx installed on your system, you can install it by running the following command:

- For Debian/Ubuntu-based systems:

```bash
apt install docker-buildx-plugin
docker buildx install
```

- For Fedora/CentOS-based systems:

```bash
yum install docker-buildx-plugin
docker buildx install
```

- If you have Docker Desktop installed on your system, just update Docker Desktop to the latest version.<br>

### Working with Docker Buildx Bake

Let's explore the power of Docker Buildx Bake with two real-world examples:

1. **Managing Multiple Build Configurations with Docker Buildx Bake**<br>

2. **Building and Pushing Multiple Images in Parallel with Docker Buildx Bake**<br>

### Managing Multiple Build Configurations with Docker Buildx Bake

Consider a `Dockerfile` for a simple Node.js application with multiple build configurations.

```Dockerfile
# Stage 1: Builder stage
FROM node:18-alpine AS builder

ARG NODE_ENV=production

ENV NODE_ENV=${NODE_ENV}

LABEL maintainer="YourName <your.email@example.com>"
LABEL description="Node.js application"

WORKDIR /app
COPY package*.json ./
RUN npm install --only=${NODE_ENV}

COPY . .

RUN npm run build

# Stage 2: Production-ready stage
FROM nginx:alpine

ARG NGINX_CONFIG=default.conf

COPY ${NGINX_CONFIG} /etc/nginx/conf.d/default.conf

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

In the above Dockerfile, we can see there are many build configurations that need to be set when building the images (we need to set the `NODE_ENV` and `NGINX_CONFIG` build arguments when running the `docker build` command).

#### Dockerfile Structure:

1. **Builder stage**: This stage builds the Node.js application using the `node:18-alpine` image. It accepts a build argument `NODE_ENV` to set the environment. It installs the dependencies, copies the source code, and builds the application.

2. **Production-ready stage**: This stage creates a production-ready image using the `nginx:alpine` image. It accepts a build argument `NGINX_CONFIG` to set the Nginx configuration. It copies the Nginx configuration and the built application from the builder stage.<br>

#### Building Images from the Dockerfile:

We can build the images using the following steps:<br>

Now, if we want to build the images from the above Dockerfile, we need to run the `docker build` command with all the build configuration values defined in the command line.

```bash
docker build \
  --build-arg NODE_ENV=production \
  --build-arg NGINX_CONFIG=my-custom-config.conf \
  --no-cache \
  --target builder \
  --tag my-app:latest \
```

This command will set the `NODE_ENV` and `NGINX_CONFIG` build arguments, disable the cache, target the builder stage, and tag the image as `my-app:latest`.

#### Using Docker Buildx Bake

Now every time we need to build the images from the above Dockerfile, we need to run the `docker build` command with all the required build configurations. This can be difficult to manage when we have multiple build configurations and multiple build arguments needed to be defined for the images.<br>

Let's say we have many images to build with multiple build configurations. Running commands with all the build configurations for each image can be difficult to manage.<br>

With Docker Buildx Bake, we can declare all the build configurations for all the images in a single file (declarative way) and run `docker buildx bake` to build all the images easily.<br>

**Let's create a `docker-bake.yaml` file with the following content:**

```hcl
group "default" {
  targets = ["builder", "production"]
}

target "builder" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    NODE_ENV = "production"
  }
  tags = ["my-app:builder"]
}

target "production" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    NGINX_CONFIG = "my-custom-config.conf"
  }
  tags = ["my-app:latest"]
  no-cache = true
}
```

**File Structure Explanation:**

- The `group` block is used to define the group of targets.
- The `target` block is used to define the build configuration for each target (image). We can also execute a single target using `docker buildx bake builder`.
- `context` is the path to the directory containing the Dockerfile.
- `dockerfile` is the name of the Dockerfile.
- `tags` is the list of tags for the image.
- `args` is the list of build arguments for the image.
- `no-cache` is used to disable the cache for the image.

Now, we can run the following command to build the images from the above `docker-bake.hcl` file:

```bash
docker buildx bake -f docker-bake.hcl
```

Now we don't need to provide the build arguments and other options in the command line. We can just run the `docker buildx bake` command to build all the images in parallel. This will help us when we have many images with multiple build configurations to build.

I'll show you the demo of the above example at the end of this article.

### Building and Pushing Multiple Images in Parallel with Docker Buildx Bake

Let's say we have an application with frontend and backend with the below directory structure:

```
.
├── frontend
│   ├── Dockerfile
│   ├── index.html
│   └── styles.css
└── backend
    ├── Dockerfile
    ├── app.js
    └── package.json
```

Normally, for building the images from the above Dockerfiles, we need to run the `docker build` command for each Dockerfile.<br>

1. Build the frontend image:
```bash
docker build -t frontend:1.0 ./frontend
```

2. Build the backend image:
```bash
docker build -t backend:1.0 --build-arg NODE_ENV=production ./backend
```

We can also combine the above two commands into a single command using the `docker buildx build` command.

```bash
docker buildx build -t frontend:1.0 -t backend:1.0 --build-arg NODE_ENV=production ./frontend ./backend
```

But in this case too, we need to specify all the locations of the Dockerfiles and build configurations of Dockerfiles in a single command. This can be difficult to manage when we have many `Dockerfiles` with multiple build configurations.<br>

With Docker Buildx Bake, we can declare all the build configurations in a single file and run `docker buildx bake` to build all the images in parallel.

Let's create a `docker-bake.hcl` file with the following content:

```
.
├── docker-bake.hcl
├── frontend
│   ├── Dockerfile
│   ├── index.html
│   └── styles.css
└── backend
    ├── Dockerfile
    ├── app.js
    └── package.json
```

**Create a `docker-bake.hcl` file with the following content:**

```hcl
variable "tag_version" {
  default = "1.0"
}

variable "build_env" {
  default = "production"
}

group "default" {
  targets = ["frontend", "backend"]
}

target "frontend" {
  context = "frontend"
  dockerfile = "Dockerfile"
  tags = ["frontend:${tag_version}"]
}

target "backend" {
  context = "backend"
  dockerfile = "Dockerfile"
  tags = ["backend:${tag_version}"]
  args = {
    NODE_ENV = "${build_env}"
  }
}
```

**File Structure Explanation:**

- The `variable` block is used to define the variables that can be used in the build configurations.
- The `group` block is used to define the group of targets.
- The `target` block is used to define the build configuration for each target (image). We can also execute a single target using `docker buildx bake frontend`.
- `context` is the path to the directory containing the Dockerfile.
- `dockerfile` is the name of the Dockerfile.
- `tags` is the list of tags for the image.
- `args` is the list of build arguments for the image.

Now, we can run the following command to build the images from the above Dockerfiles:

```bash
docker buildx bake -f docker-bake.hcl
```

Now we don't need to provide the location of the Dockerfiles, build arguments, and other options in the command line. We can just run the `docker buildx bake` command to build all the images in parallel.

I'll show you the demo of the above example at the end of this article.

### Important Points to Remember when using Docker Buildx Bake:

1. You don't need to specify the `Bake` file name when running the `docker buildx bake` command. By default, it looks for the `docker-bake.hcl` file in the current directory. If you have a different file name, you can specify it using the `-f` flag.

2. You can also run a single target using the `docker buildx bake <target-name>` command.

3. There are many options available for the `docker buildx bake` command. You can check the available options by running the `docker buildx bake --help` command.

4. There is a specific lookup order for the Bake file. It looks for the Bake file in the following order:
   - The file specified using the `-f` flag.
   - `compose.yaml`
   - `compose.yml`
   - `docker-compose.yml`
   - `docker-compose.yaml`
   - `docker-bake.json`
   - `docker-bake.override.json`
   - `docker-bake.hcl`
   - `docker-bake.override.hcl`

### Demo of Docker Buildx Bake:

Let's see the demo of the above examples using Docker Buildx Bake.

I'm going to use the directory structure as I mentioned above for the second use case (Build Multiple Images in Parallel).

```
.
├── docker-bake.hcl
├── frontend
│   ├── Dockerfile
│   ├── index.html
│   └── styles.css
└── backend
    ├── Dockerfile
    ├── app.js
    └── package.json
```

You can find all the files I used in this folder.

1. `docker-bake.hcl` File:

![Screenshot 2024-12-29 121204](https://github.com/user-attachments/assets/e48cffa7-286a-41d5-8d4d-01246f60a527)

2. `Dockerfile` for Frontend:

![Screenshot 2024-12-29 121352](https://github.com/user-attachments/assets/e427035c-bfe3-41a7-b6e2-19b7638117e0)

3. `Dockerfile` for Backend:

![Screenshot 2024-12-29 121406](https://github.com/user-attachments/assets/fbd6069c-0051-47a5-be05-3510af8082b5)

Now I'm going to run the `docker buildx bake` command to build the `frontend` and `backend` images.

![Screenshot 2024-12-29 121443](https://github.com/user-attachments/assets/2c95d574-f614-4cef-b3a0-893e720fb770)

![Screenshot 2024-12-29 121459](https://github.com/user-attachments/assets/e4e5f8b3-b54e-4345-b993-1bba574a372d)

Let's run the container from the images,

![Screenshot 2024-12-29 121825](https://github.com/user-attachments/assets/940e0759-1739-4c06-9ee6-4f2ff665f0a0)

![Screenshot 2024-12-29 122129](https://github.com/user-attachments/assets/53807367-f8e5-48e9-afed-fdd8c93e4ead)

Accessing the `Frontend` and `Backend`:

![Screenshot 2024-12-29 121902](https://github.com/user-attachments/assets/e8da526f-f115-4f64-bfb0-0815dcf7b04b)

![Screenshot 2024-12-29 122404](https://github.com/user-attachments/assets/07bba3b5-1909-4f2e-a9ee-8dc037f6a73a)

### Conclusion:

This article is just an introduction to the `Docker Buildx Bake` feature. We have seen how to manage multiple build configurations and build multiple images in parallel using Docker Buildx Bake. Docker Buildx Bake is a powerful feature that helps in ease of use and maintainability for Build Configurations when running `docker buildx build` with multiple options. It also helps in building and pushing multiple images in parallel. We can declare all the build configurations in a single declarative file and run `docker buildx bake` to build all the images in parallel without specifying all the build configurations in a single command.

Refer to the official Docker documentation for more information on Docker Buildx Bake.

Docker Buildx Bake: https://docs.docker.com/build/bake/