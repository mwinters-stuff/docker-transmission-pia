# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM ubuntu:latest

# COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

RUN apt-get -qq update && \
    apt-get upgrade -y && \
      apt-get install -y \
      bash \
      ca-certificates \
      curl \
      python3 \
      python3-pkg-resources \
      python3-pip \
      traceroute 


RUN pip install https://github.com/mwinters-stuff/mnamer/archive/refs/heads/master.zip 
RUN apt-get remove -y python3-pip && apt-get auto-remove -y
RUN echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/tmp/* \
    && apt-get clean

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]

