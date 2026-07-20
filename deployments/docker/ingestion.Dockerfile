# build bin
FROM golang:1.25 AS go-builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o ingestion-service ./cmd/ingestion

# run
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y gdal-bin && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=go-builder /build/ingestion-service .
COPY db/migrations ./db/migrations

EXPOSE 8081

CMD ["./ingestion-service"]
