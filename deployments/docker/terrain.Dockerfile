# multi-stage docker file for S2

# building terrain binary
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04 AS cuda-builder

RUN apt-get update && apt-get install -y gcc-12 g++-12 make && rm -rf /var/lib/apt/lists/*

ENV CUDAHOSTCXX=/usr/bin/g++-12

WORKDIR /build
COPY cuda/terrain/ ./cuda/terrain/

RUN make -C cuda/terrain


# build go
FROM golang:1.25 AS go-builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o terrain-service ./cmd/terrain


# put both builds together
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

WORKDIR /app

COPY --from=cuda-builder /build/cuda/terrain/terrain ./bin/terrain

COPY --from=go-builder /build/terrain-service .

COPY db/migrations ./db/migrations

EXPOSE 8082

CMD ["./terrain-service"]
