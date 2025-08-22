FROM postgres:16-alpine
RUN apk add --no-cache tzdata
COPY init/ /docker-entrypoint-initdb.d/
