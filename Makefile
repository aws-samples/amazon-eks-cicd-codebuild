.PHONY: all build build-v1 push push-v1

TAG	?= pahud/eks-kubectl-docker:latest
V1	?= pahud/eks-kubectl-docker:1.0.0

all: build

build:
	@docker build -t  $(TAG) .
build-v1:
	@docker build -t $(V1) .
push:
	@docker push $(TAG)
push-v1:
	@docker push $(V1)


