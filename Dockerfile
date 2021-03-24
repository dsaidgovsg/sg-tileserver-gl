ARG TILESERVER_GL_VERSION="v3.1.1"
FROM maptiler/tileserver-gl:${TILESERVER_GL_VERSION}

# This must be run after generate-all.sh and set-up-mbtiles.sh have been run
COPY ./app /app
WORKDIR /app
