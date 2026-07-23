# build bin
FROM golang:1.25 AS go-builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o hazard-service ./cmd/hazard

# run
FROM ubuntu:22.04

WORKDIR /app

COPY --from=go-builder /build/hazard-service .
COPY db/migrations ./db/migrations

EXPOSE 8084

CMD ["./hazard-service"]
