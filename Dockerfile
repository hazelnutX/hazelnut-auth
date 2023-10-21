# syntax=docker/dockerfile:1

# Build the application from source
FROM golang:1.21.3 AS build-stage

RUN apt-get update && apt-get install -y ca-certificates openssl

ARG cert_location=/usr/local/share/ca-certificates

# Get certificate from "github.com"
RUN openssl s_client -showcerts -connect github.com:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > ${cert_location}/github.crt
# Get certificate from "proxy.golang.org"
RUN openssl s_client -showcerts -connect proxy.golang.org:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >  ${cert_location}/proxy.golang.crt
# Get certificate from "proxy.golang.org"
RUN openssl s_client -showcerts -connect storage.googleapis.com:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >  ${cert_location}/proxy.golang.crt
# Update certificates
RUN update-ca-certificates
# FIX PROBLEM
# 0.693 go: github.com/golang/protobuf@v1.5.3: Get "https://proxy.golang.org/github.com/golang/protobuf/@v/v1.5.3.mod": tls: failed to verify certificate: x509: certificate signed by unknown authority
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./ ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-auth-service ./cmd/grpc_server/

# Run the tests in the container
# FROM build-stage AS run-test-stage
# RUN go test -v ./...

# Deploy the application binary into a lean image
FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /docker-auth-service /docker-auth-service

EXPOSE 5001

USER nonroot:nonroot

ENTRYPOINT ["/docker-auth-service"]