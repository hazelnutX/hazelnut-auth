LOCAL_BIN:=$(CURDIR)/bin

install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
	GOBIN=$(LOCAL_BIN) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

get-deps:
	go mod tidy

generate:
	protoc \
 	--plugin=protoc-gen-go-grpc=./bin/protoc-gen-go-grpc \
 	--plugin=protoc-gen-go=./bin/protoc-gen-go \
 	--go_out=./ \
 	--go-grpc_out=./ \
 	./api/public/auth/v1/* ./api/private/auth/v1/*
