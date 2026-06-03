FROM node:20-bookworm-slim

WORKDIR /app

COPY package.json ./
RUN npm install --omit=dev

COPY index.js ./

ENV NODE_ENV=production

CMD ["node", "index.js"]
