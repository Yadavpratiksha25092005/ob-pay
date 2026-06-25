FROM golang:latest AS builder
ENV GOTOOLCHAIN=auto
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
WORKDIR /app
COPY . .
RUN go mod tidy
RUN go build -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8000
CMD ["./main"]
