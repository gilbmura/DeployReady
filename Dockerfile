FROM node:20-alpine

WORKDIR /app

# Install dependencies first (better layer caching)
COPY app/package*.json ./
RUN npm ci --omit=dev

# Copy application source
COPY app/ .

# Create a non-root user and switch to it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000

CMD ["node", "index.js"]
