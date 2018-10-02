.PHONY: all build push

TAG	?= pahud/eks-kubectl-docker:latest

all: build

build:
	@docker build -t  $(TAG) .
push:
	@docker push $(TAG)



