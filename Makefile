# AWS Account and Region
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION := $(shell aws configure get region)

# ECR Repository
# CDK creates a repository with a predictable name format. We derive it here.
BOOTSTRAP_QUALIFIER := $(shell aws cloudformation describe-stacks --stack-name cdk-bootstrap-hnb659fds-ap-northeast-1 --query "Stacks[0].Outputs[?OutputKey=='BootstrapQualifier'].OutputValue" --output text 2>/dev/null || echo "hnb659fds")
ECR_REPOSITORY_NAME := cdk-$(BOOTSTRAP_QUALIFIER)-container-assets-$(AWS_ACCOUNT_ID)-$(AWS_REGION)
ECR_REPOSITORY_URI := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPOSITORY_NAME)

# Image Tag
IMAGE_TAG ?= latest

all: deploy

setup: install-python install-node

install-python: venv/touchfile
venv/touchfile: requirements.txt
	@echo "Creating virtual environment..."
	python3 -m venv venv
	@echo "Activating venv..."
	. venv/bin/activate
	@echo "Installing Python requirements..."
	pip install -r requirements.txt
	touch venv/touchfile

install-node: node_modules
node_modules: package.json package-lock.json
	@echo "Installing Node.js requirements..."
	npm install

login-ecr:
	@echo "Logging in to Amazon ECR..."
	@aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

build-and-push: login-ecr
	@echo "Building Docker image with tag: $(IMAGE_TAG)..."
	@docker build -t $(ECR_REPOSITORY_NAME):$(IMAGE_TAG) ./comfyui_aws_stack/docker
	@echo "Tagging image for ECR..."
	@docker tag $(ECR_REPOSITORY_NAME):$(IMAGE_TAG) $(ECR_REPOSITORY_URI):$(IMAGE_TAG)
	@echo "Pushing image to ECR..."
	@docker push $(ECR_REPOSITORY_URI):$(IMAGE_TAG)
	@echo "Image pushed successfully: $(ECR_REPOSITORY_URI):$(IMAGE_TAG)"

deploy: setup
	@echo "Running cdk bootstrap..."
	npx cdk bootstrap
	@echo "Running cdk deploy with image tag: $(IMAGE_TAG)..."
	npx cdk deploy --require-approval never -c comfyui_image_tag=$(IMAGE_TAG)

test: install-python
	pytest -vv

test-update: install-python
	pytest --snapshot-update

clean:
	@echo "Removing virtual environment and node modules..."
	rm -rf venv node_modules

.PHONY: all setup install-python install-node login-ecr build-and-push deploy test test-update clean