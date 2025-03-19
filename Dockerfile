# Use the official Go image for building Kratos
FROM golang:1.21 AS builder

# Set the working directory
WORKDIR /app

# Copy go.mod and go.sum before the full source code (to use Docker caching)
COPY go.mod go.sum ./

# Download dependencies
RUN go mod tidy && go mod verify

# Copy the rest of the source code
COPY . .

# Build the Kratos binary
# RUN go build -tags netgo -ldflags '-s -w' -o /kratos ./cmd/kratos
RUN go build -mod=vendor -tags netgo -ldflags '-s -w' -o /kratos ./cmd/kratos

# Create a minimal runtime image
FROM alpine:latest

# Install required packages
RUN apk --no-cache add ca-certificates curl

# Set working directory
WORKDIR /root/

# Copy the compiled Kratos binary from the builder stage
COPY --from=builder /kratos .

# Copy the Kratos config file
COPY ./kratos.yml /root/kratos.yml

# Expose necessary ports
EXPOSE 4433 4434 4435

# Run Kratos
CMD ["./kratos", "serve", "-c", "/root/kratos.yml"]
