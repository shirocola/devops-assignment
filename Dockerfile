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

# Set working dir inside container
WORKDIR /app

# Copy from the builder stage
COPY --from=builder /app/hello-api .

# Expose port
EXPOSE 8080

# Run the application
CMD [ "./hello-api" ]
