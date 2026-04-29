FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY next.config.ts ./
COPY tsconfig.json ./
COPY public ./public
COPY app ./app

RUN npm run build && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

CMD ["npm", "start"]