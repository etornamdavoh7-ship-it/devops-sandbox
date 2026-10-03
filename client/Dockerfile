# ==========================================
# STAGE 1: The Builder (Node.js)
# ==========================================
# 1. Get a heavy Node.js computer and name it "builder"
FROM node:20-alpine AS builder

ARG VITE_API_URL

ENV VITE_API_URL=$VITE_API_URL

# 2. Set the workspace
WORKDIR /app

# 3. Copy package lists for layer caching
COPY package*.json ./

# 4. Download all the heavy React development tools
RUN npm install

# 5. Copy the actual React source code
COPY . .

# 6. Compile the React code into static HTML/CSS/JS files (Output goes to /app/dist)
RUN npm run build 


# ==========================================
# STAGE 2: The Production Server (Nginx)
# ==========================================
# 7. Start a brand new, tiny Nginx computer. (The Node.js computer will be thrown away).
FROM nginx:alpine

# 8. TELEPORT: Copy ONLY the finished static files from the "builder" stage into Nginx's public folder.
COPY --from=builder /app/dist /usr/share/nginx/html

# 9. Document that Nginx serves traffic on Port 80.
EXPOSE 80
