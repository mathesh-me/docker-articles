# Inconsistent casing
FROM node:16-alpine As base
WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

ARG BUILD_ENV
FROM node:16-alpine AS builder
WORKDIR /app
COPY . ./
RUN npm install
RUN npm run build

# Inconsistent casing and Using relative WORKDIR paths
FROM node:16-alpine as production
WORKDIR ./app

COPY --from=base /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

EXPOSE 3000

# JSONArgsRecommended
CMD node dist/index.js