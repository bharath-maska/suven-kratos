# Use Debian as the base image
FROM debian:bookworm-slim AS builder

# Install dependencies
RUN apt update && apt install -y curl git gcc

# Install Go 1.21 manually
RUN curl -fsSL https://go.dev/dl/go1.21.13.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy Go module files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod tidy && go mod verify

# Copy the source code
COPY . .

# Build Kratos
RUN go build -tags netgo -ldflags '-s -w' -o /kratos ./cmd/kratos

# Final minimal image
FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /kratos /kratos
COPY kratos.yml .

EXPOSE 4433 4434
CMD ["/kratos", "serve", "-c", "kratos.yml"]
