# small is beautiful
FROM alpine:latest

# The container listens on port 80, map as needed
EXPOSE 80

# This is where the repositories will be stored, and
# should be mounted from the host (or a volume container)
VOLUME ["/git"]

# We need the following:
# - nginx, because it is our frontend
# - git-daemon, because that gets us the git-http-backend CGI script
# - fcgiwrap, because that is how nginx does CGI
# - spawn-fcgi, to launch fcgiwrap and to create the unix socket
RUN apk add --no-cache \
    nginx \
    git-daemon \
    fcgiwrap \
    spawn-fcgi

RUN touch /etc/nginx/htaccess

COPY nginx.conf /etc/nginx/
COPY git-http-backend.conf /etc/nginx/

# launch fcgiwrap via spawn-fcgi; launch nginx in the foreground
# so the container doesn't die on us; supposedly we should be
# using supervisord or something like that instead, but this
# will do
CMD spawn-fcgi -U nginx -s /run/fcgi.sock /usr/bin/fcgiwrap && \
    nginx

