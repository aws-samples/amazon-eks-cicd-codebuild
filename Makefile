TAG_VER ?= 1.12.7-20190620
REPO ?= pahud/eks-kubectl-docker
EKS_ROLE_ARN ?= arn:aws:iam::903779448426:role/AmazonEKSAdminRole
REGION ?= us-west-2
CLUSTER_NAME ?= eksdemo2

ifdef EKS_ROLE_ARN
	EXTRA_DOCKER_ARGS = -e EKS_ROLE_ARN=$(EKS_ROLE_ARN)
endif


TAG	?= $(REPO):$(TAG_VER)

.PHONY: all build push build-latest push-latest get-nodes version
all: build

build:
	@docker build -t  $(TAG) .
	
push:
	@docker push $(TAG)
	
build-latest:
	@docker build -t  $(REPO):latest .
	
push-latest:
	@docker push $(REPO):latest
	
get-nodes:
	@docker run -v $(HOME)/.aws:/home/kubectl/.aws \
-e REGION=$(REGION) \
-e AWS_DEFAULT_REGION=$(REGION) \
-e AWS_REGION=$(REGION) \
-e CLUSTER_NAME=$(CLUSTER_NAME) \
$(EXTRA_DOCKER_ARGS) \
-ti pahud/eks-kubectl-docker:$(TAG_VER) \
kubectl get no


version:
	@docker run -v $(HOME)/.aws:/home/kubectl/.aws \
-e REGION=$(REGION) \
-e AWS_DEFAULT_REGION=$(REGION) \
-e AWS_REGION=$(REGION) \
-e CLUSTER_NAME=$(CLUSTER_NAME) \
$(EXTRA_DOCKER_ARGS) \
-ti pahud/eks-kubectl-docker:$(TAG_VER) \
kubectl version

