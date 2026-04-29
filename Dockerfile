FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY next.config.* ./
COPY tsconfig.json ./
COPY public ./public
COPY app ./app

RUN npm run build

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000

CMD ["npm", "start"]