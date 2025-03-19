# Use the official Go image as a base
FROM golang:1.21 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Kratos source code into the container
COPY . .

# Download dependencies
RUN go mod tidy

# Build the Kratos binary
RUN go build -tags netgo -ldflags '-s -w' -o /kratos ./cmd/kratos

# Use a minimal base image to reduce size
FROM alpine:latest

# Install dependencies
RUN apk --no-cache add ca-certificates curl

# Set the working directory inside the container
WORKDIR /root/

# Copy the compiled binary from the builder stage
COPY --from=builder /kratos .

# Copy the configuration file (Make sure kratos.yml exists in your repo)
COPY ./kratos.yml /root/kratos.yml

# Expose the necessary ports
EXPOSE 4433 4434 4435

# Start Kratos
CMD ["./kratos", "serve", "-c", "/root/kratos.yml"]
