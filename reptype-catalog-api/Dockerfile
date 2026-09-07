# syntax=docker/dockerfile:1
# check=error=true

# Build with:
# docker build -t reptype-catalog-api .
# docker run -d -p 8080:8080 -e DB_HOST=<host> -e DB_USER=<user> -e DB_PASSWORD=<password> -e DB_NAME=<name> --name reptype-catalog-api reptype-catalog-api

# Make sure GO_VERSION matches (or satisfies) the go directive in go.mod
ARG GO_VERSION=1.25

FROM golang:${GO_VERSION}-alpine AS build

WORKDIR /src

# Install dependencies first so they are cached separately from source changes
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# CGO disabled so the binaries run standalone on a minimal base image
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/server . && \
    CGO_ENABLED=0 GOOS=linux go build -o /out/seed ./cmd/seed

# Final stage for the runtime image
FROM alpine:3.20

RUN apk add --no-cache ca-certificates && \
    addgroup -g 1000 catalog && \
    adduser -D -u 1000 -G catalog catalog

WORKDIR /app

COPY --from=build /out/server /app/server
COPY --from=build /out/seed /app/seed

# Run and own only the runtime files as a non-root user for security
USER 1000:1000

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/healthz || exit 1

CMD ["/app/server"]
