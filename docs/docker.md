# How to use shellspec with Docker

## Official docker images

There are official images on the [Docker Hub](https://hub.docker.com/r/shellspec/shellspec).

| Name                            | Linux  | Included                  |  Size |
| ------------------------------- | ------ | ------------------------- | ----: |
| shellspec/shellspec             | Alpine | busybox (ash)             |  3 MB |
| shellspec/shellspec:kcov        | Alpine | busybox (ash), bash, kcov | 14 MB |
| shellspec/shellspec-debian      | Debian | dash, bash                | 48 MB |
| shellspec/shellspec-debian:kcov | Debian | dash, bash, kcov          | 68 MB |
| shellspec/shellspec-scratch     | None   | none (shellspec only)     | 40 KB |

- shellspec/shellspec:kcov is **beta** (currently using alpine:edge not stable)
- Version specified images are also available (VERSION: 0.21.0 and above)
  - `shellspec/shellspec[-VARIANT]:<VERSION | master>[-kcov]`

## Using shellspec docker image

### 1. Run shellspec and your specfiles within container

```sh
# Run docker command on the project root
$ docker run -it --rm -v "$PWD:/src" shellspec/shellspec

# Display help
$ docker run -it --rm -v "$PWD:/src" shellspec/shellspec --help

# Run with kcov (requires kcov supported image)
$ docker run -it --rm -u $(id -u):$(id -g) \
    -v "$PWD:/src" shellspec/shellspec:kcov --kcov

# For users using Docker Desktop for Windows within WSL 1
$ docker run -it --rm -v "$(wslpath -wa .):/src" shellspec/shellspec
```

### 2. Run simple with helper script and extra hooks

Use [contrib/shellspec-docker](../contrib/shellspec-docker) helper script.

```sh
# Specify the Docker image to use (default: shellspec/shellspec)
$ export SHELLSPEC_DOCKER=shellspec/shellspec

# Run helper script on the project root
$ shellspec-docker

# Display help
$ shellspec-docker --help

# Run with kcov (requires kcov supported image)
$ shellspec-docker --kcov

# Enter the Docker container
$ shellspec-docker -

# Execute command with in the Docker container
$ shellspec-docker - hostname
```

If you want to run manually.

```sh
$ docker run -it --rm --entrypoint=/shellspec-docker \
    -u $(id -u):$(id -g) -v "$PWD:/src" shellspec/shellspec

# For users using Docker Desktop for Windows within WSL 1
$ docker run -it --rm --entrypoint=/shellspec-docker \
    -u $(id -u):$(id -g) -v "$(wslpath -wa .):/src" shellspec/shellspec
```

#### Hooks

##### .shellspec-docker/initrc

This file should be a shell script. You can override [docker_run()](../contrib/shellspec-docker) to
changes options, pass environment variables, etc.

##### .shellspec-docker/pre-test

Invoked before execute shellspec inside of the docker container.

##### .shellspec-docker/post-test

Invoked after executed shellspec inside of the docker container.

### 3. Using shellspec image as parent image

Example

```Dockerfile
# Dockerfile
FROM shellspec/shellspec
RUN apk add --no-cache add-your-required-packages
COPY ./ /src
```

```sh
# Build and run at your project root
$ docker build -t your-project-name .
$ docker run -it your-project-name
```

### 4. Include shellspec into another image

Example

```Dockerfile
# Dockerfile
FROM buildpack-deps
RUN apt-get update && apt-get install -y add-your-required-packages
COPY --from=shellspec/shellspec-scratch /opt/shellspec /opt/shellspec
ENV PATH /opt/shellspec/:$PATH
WORKDIR /src
ENTRYPOINT [ "shellspec" ]
COPY ./ /src
```

```sh
# Build and run at your project root
$ docker build -t your-project-name .
$ docker run -it your-project-name
```

## Appendix

### How to build official shellspec docker image yourself

Example

```sh
contrib/build.sh .dockerhub/Dockerfile         shellspec
contrib/build.sh .dockerhub/Dockerfile         shellspec kcov
contrib/build.sh .dockerhub/Dockerfile.debian  shellspec-debian
contrib/build.sh .dockerhub/Dockerfile.debian  shellspec-debian kcov
contrib/build.sh .dockerhub/Dockerfile.scratch shellspec-scratch
```
