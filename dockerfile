FROM node:24-alpine

RUN mkdir /appx

WORKDIR /appx

COPY app/ .

RUN npm install

CMD ["node", "server.js"]
