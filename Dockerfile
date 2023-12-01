FROM node:21.2-alpine3.18
RUN mkdir /var/node
WORKDIR /var/node
ADD . /var/node
RUN npm install
EXPOSE 3000
CMD npm start
