FROM node:5
MAINTAINER Ando Roots <ando@sqroot.eu>

WORKDIR /usr/src

COPY src app
COPY node_modules node_modules

CMD ["node", "app/stream.js"]
