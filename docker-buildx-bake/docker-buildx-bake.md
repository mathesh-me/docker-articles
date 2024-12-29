# Docker Bake 🐳

`Docker buildx bake` is a feature that introduced in `Docker 24.0` . ***It helps us to build and push multiple images in parallel. It also helps in ease of use and maintainability for Build Configurations when running `docker buildx build` with multiple options.*** We can declare all the build configurations in a single declarative file and run `docker buildx bake` to build all the images in parallel and without specifying all the build configurations in a single command.<br>

Bake file can be written in `YAML`, `JSON`, or `HCL` format.

### Prerequisites for Using Docker Build Checks

`Docker buildx bake` is a feature introduced in `Docker 24.0`. To run Docker Build Checks, you need to have `Buildx CLI` installed on your system. You can check the version of Docker Buildx installed on your system by running the following command:

```bash
docker buildx version
```

If you don't have Docker Buildx installed on your system, you can install it by running the following command:

- For Debian/Ubuntu based systems:

```bash
apt install docker-buildx-plugin
docker buildx install
```

- For Fedora/CentOS based systems:

```bash
yum install docker-buildx-plugin
docker buildx install
```

- If you have Docker Desktop installed on your system, Just update Docker Desktop to the latest version.<br>

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

In the above Dockerfile, we can see there are many build configurations that need to be set when building the images(We need to set the `NODE_ENV` and `NGINX_CONFIG` build arguments when running `docker build` Command).

#### Dockerfile Structure:

1. **Builder stage**: This stage builds the Node.js application using the `node:18-alpine` image. It accepts a build argument `NODE_ENV` to set the environment. It installs the dependencies, copies the source code, and builds the application.

2. **Production-ready stage**: This stage creates a production-ready image using the `nginx:alpine` image. It accepts a build argument `NGINX_CONFIG` to set the Nginx configuration. It copies the Nginx configuration and the built application from the builder stage.<br>

#### Building Images from the Dockerfile:

We can build the images using the following steps:<br>

Now, If we want to build the images from the above Dockerfile, we need to run the `docker build` command with all the build configurations values defined in the command line.

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

Now everytime we need to build the images from the above Dockerfile, we need to run the `docker build` command with all the required build configurations. This can be difficult to manage when we have multiple build configurations and multiple build arguments needed to be defined for the images.<br>

Let's say we have many images to build with multiple build configurations. And running commands with all the build configurations for each image can be difficult to manage.<br>

With Docker Buildx Bake, we can declare all the build configurations for all the images in a single file(Declarative way) and run `docker buildx bake` to build all the images easily.<br>

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

- `group` block is used to define the group of targets that
- `target` block is used to define the build configuration for each target(image). We can also execute single target using `docker buildx bake builder`.
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

Let's say we have a application with frontend and backend with the below directory structure:

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

Normally for building the images from the above Dockerfiles, we need to run the `docker build` command for each Dockerfile.<br>

1. Build the frontend image:
```bash
docker build -t frontend:1.0 ./frontend
```

2. Build the backend image:
```bash
docker build -t backend:1.0 --build-arg NODE_ENV=production ./backend
```

We can also combine the above two commands into a single command using `docker buildx build` command.

```bash
docker buildx build -t frontend:1.0 -t backend:1.0 --build-arg NODE_ENV=production ./frontend ./backend
```

But in this case too, we need to specify all the locations of the Dockerfiles and build configurations of a Dockerfiles in a single command. This can be difficult to manage when we have many `Dockerfiles` with multiple build configurations.<br>

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

- `variable` block is used to define the variables that can be used in the build configurations.
- `group` block is used to define the group of targets that
- `target` block is used to define the build configuration for each target(image). We can also execute single target using `docker buildx bake frontend`.
- `context` is the path to the directory containing the Dockerfile.
- `dockerfile` is the name of the Dockerfile.
- `tags` is the list of tags for the image.
- `args` is the list of build arguments for the image.


Now, we can run the following command to build the images from the above Dockerfiles:

```bash
docker buildx bake -f docker-bake.hcl
```

Now we don't need to provide the location of the Dockerfiles, build arguments and other options in the command line. We can just run the `docker buildx bake` command to build all the images in parallel.

I'll show you the demo of the above example at the end of this article.

### Important Points to Remember when using Docker Buildx Bake:

1. You don't need to specify the `Bake` file name when running the `docker buildx bake` command. By default, it looks for the `docker-bake.hcl` file in the current directory. If you have a different file name, you can specify it using the `-f` flag.

2. You can also run a single target using the `docker buildx bake <target-name>` command.

3. There are many options available for the `docker buildx bake` command. You can check the available options by running the `docker buildx bake --help` command.

4. There is a Specific look up order for the Bake file. It looks for the Bake file in the following order:
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

//Will add the demo steps here

### Conclusion:

This article is just a introduction to the `Docker Buildx Bake` feature. We have seen how to manage multiple build configurations and build multiple images in parallel using Docker Buildx Bake. Docker Buildx Bake is a powerful feature that helps in ease of use and maintainability for Build Configurations when running `docker buildx build` with multiple options. It also helps in building and pushing multiple images in parallel. We can declare all the build configurations in a single declarative file and run `docker buildx bake` to build all the images in parallel and without specifying all the build configurations in a single command.

Refer to the official Docker documentation for more information on Docker Buildx Bake.

Docker Buildx Bake: https://docs.docker.com/buildx/working-with-buildx/#buildx-bake