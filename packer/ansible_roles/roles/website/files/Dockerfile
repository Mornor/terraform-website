FROM node:8.9.1
MAINTAINER Celien Nanson<cesliens@gmail.com>

WORKDIR /usr/src/app

# Install app dependencies
COPY package.json .
RUN npm install

COPY . .

EXPOSE 8080

CMD ["npm", "start"]
