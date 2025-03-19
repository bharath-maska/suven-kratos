# Use the official Golang image as the build stage
FROM golang:1.21 AS builder

# Set working directory inside the container
WORKDIR /app

# Copy Go module files
COPY go.mod go.sum ./

# Download dependencies and verify them
RUN go mod tidy && go mod verify

# Copy the entire source code
COPY . .

# Build the Kratos binary
RUN go build -tags netgo -ldflags '-s -w' -o /kratos ./cmd/kratos

# Use a minimal base image for the final container
FROM debian:bookworm-slim

# Set working directory
WORKDIR /app

# Copy the Kratos binary from the builder stage
COPY --from=builder /kratos /kratos

# Copy necessary config files
COPY kratos.yml .

# Expose necessary ports (adjust if needed)
EXPOSE 4433 4434

# Start Kratos
CMD ["/kratos", "serve", "-c", "kratos.yml"]
