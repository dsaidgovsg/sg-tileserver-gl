ARG TILESERVER_GL_VERSION="v3.1.1"
FROM maptiler/tileserver-gl:${TILESERVER_GL_VERSION}

COPY ./app /app
WORKDIR /app
