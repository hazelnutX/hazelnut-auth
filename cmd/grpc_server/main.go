package main

import (
	"context"
	"fmt"
	"github.com/hazemax/hazelnut-auth/pkg/api/public/v1/auth"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"log"
	"net"
)

const port = 5001

type server struct {
	auth.UnimplementedUserApiServer
}

func (*server) Create(ctx context.Context, req *auth.CreateRequest) (*auth.CreateResponse, error) {
	return &auth.CreateResponse{
		Id: int64(len(req.Name)),
	}, nil
}

func main() {
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	s := grpc.NewServer()
	reflection.Register(s)
	auth.RegisterUserApiServer(s, &server{})

	log.Printf("Server listening port %v", lis.Addr())

	if err = s.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}
