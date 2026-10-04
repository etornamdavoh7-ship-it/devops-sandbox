# 1. THE FOUNDATION: Go buy a lightweight Linux computer that has Node.js 20 pre-installed.
FROM node:20-alpine

# 2. THE WORKSPACE: Create a folder called /app and do all future work inside it.
WORKDIR /app

# 3. THE SHOPPING LIST: Copy ONLY the package.json files first. 
# (We do this separately to take advantage of Docker Layer Caching).
COPY package*.json ./

RUN npm install -g npm@latest

# 4. THE INSTALL: Read the package.json and download the required software.
RUN npm ci --omit=dev

# 5. THE CODE: Copy our actual written code from our laptop into the container.
# (The .dockerignore file ensures we don't accidentally copy our laptop's node_modules).
COPY . .

# 6. THE MAILBOX: A sticky-note documentation for other developers letting them know this app uses Port 5000.
EXPOSE 5000

# 7. THE POWER BUTTON: When this container is turned on, run this command to start the engine.
CMD ["node", "server.js"]