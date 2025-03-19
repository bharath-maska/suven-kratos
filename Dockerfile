# Use an official Golang image as the build stage
FROM golang:1.21 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy Go module files
COPY go.mod go.sum ./

# Download dependencies and create a vendor folder
RUN go mod tidy && go mod vendor

# Copy the rest of the source code
COPY . .

# Build the Kratos binary using the vendor folder
RUN go build -mod=vendor -tags netgo -ldflags '-s -w' -o /kratos ./cmd/kratos

# Use a minimal base image for the final stage
FROM debian:bookworm-slim

# Set working directory
WORKDIR /app

# Copy the Kratos binary from the builder stage
COPY --from=builder /kratos /kratos

# Copy necessary config files
COPY kratos.yml .

# Expose necessary ports (adjust if needed)
EXPOSE 4433 4434

# Run Kratos
CMD ["/kratos", "serve", "-c", "kratos.yml"]
