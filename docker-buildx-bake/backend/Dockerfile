# Use a Node.js base image
FROM node:16-alpine

# Build argument for environment
ARG NODE_ENV

# Set environment variable
ENV NODE_ENV=$NODE_ENV

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy the application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the Node.js app
CMD ["npm", "start"]
