# this file is based on https://earthly.dev/blog/dos-gaming-in-docker/

FROM node:16-alpine

WORKDIR site

# js-dos
ADD https://js-dos.com/6.22/current/js-dos.js .
ADD https://js-dos.com/6.22/current/wdosbox.js .
ADD https://js-dos.com/6.22/current/wdosbox.wasm.js .

# the game itself
ADD https://github.com/mlesniew/kosmici/releases/download/1.0/kosmita.zip kosmita.zip

# add the index
COPY index.html .

# entrypoint
ENTRYPOINT npx serve -l tcp://0.0.0.0:8000
