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
