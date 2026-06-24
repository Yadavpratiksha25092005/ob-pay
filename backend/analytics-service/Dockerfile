FROM golang:latest AS builder
ENV GOTOOLCHAIN=auto
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
WORKDIR /app
<<<<<<< HEAD
COPY . .
=======
COPY backend/analytics-service/ .
>>>>>>> fafe03b9f5505580bc9fc1d2f929c32f7ef1606b
RUN go mod tidy
RUN go build -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8013
CMD ["./main"]
