ARG TILESERVER_GL_VERSION="v3.1.1"
FROM maptiler/tileserver-gl:${TILESERVER_GL_VERSION}

# This must be run after setup.sh
# /data should already be the WORKDIR in the base image
COPY ./data /data
