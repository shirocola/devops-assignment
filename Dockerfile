# Stage 1: Build GO App
FROM golang:1.22-alpine3.19 AS builder

# Set working dir inside container
WORKDIR /app

# Copy go.mod
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build App
RUN go build -o hello-api

# Stage 2: Create runtime image
FROM alpine:latest

# Install curl for heath checks
RUN apk add --no-cache curl

# Add a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working dir inside container
WORKDIR /app

# Copy from the builder stage
COPY --from=builder /app/hello-api .

# Expose port
EXPOSE 8080

# Change ownership of the app files
RUN chown appuser:appgroup /app/hello-api

# Health check route (assuming your application has a /health endpoint)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD curl -f http://localhost:8080/health || exit 1

# Run the application
CMD [ "./hello-api" ]
