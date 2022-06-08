FROM node

RUN useradd -ms /bin/bash user
USER user

WORKDIR /home/user

COPY package.json .
RUN npm install

COPY --chown=user:user . .
RUN npm run build

CMD npm start
