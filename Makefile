BOLD=$(shell tput -T xterm bold)
YELLOW=$(shell tput -T xterm setaf 3)
RESET=$(shell tput -T xterm sgr0)

__tf_init:
	@printf "\n${BOLD}${YELLOW}Initializing Terraform...${RESET}\n"
	cd infrastructure && \
	terraform init

__ui_install:
	@printf "\n${BOLD}${YELLOW}Installing UI dependencies...${RESET}\n"
	cd ui && \
	pnpm install

__functions_build:
	@printf "\n${BOLD}${YELLOW}Building functions...${RESET}\n"
	cd functions && \
	zip -r functions.zip . && \
	mv functions.zip ../infrastructure

__ui_build:
	@printf "\n${BOLD}${YELLOW}Building UI...${RESET}\n"
	cd ui && \
	pnpm build

__ui_push:
	@printf "\n${BOLD}${YELLOW}Pushing UI to S3...${RESET}\n"
	cd ui && \
	aws s3 cp dist s3://$(shell cd infrastructure && terraform output -raw bucket_name) --recursive --region eu-west-1

__infrastructure_deploy:
	@printf "\n${BOLD}${YELLOW}Deploying infrastructure...${RESET}\n"
	cd infrastructure && \
	terraform apply \
		-input=false \
		-auto-approve=true \

install: __ui_install __tf_init
build: __functions_build __ui_build
deploy: build __infrastructure_deploy __ui_push

destroy:
	@printf "\n${BOLD}${YELLOW}Destroying infrastructure...${RESET}\n"
	cd infrastructure && \
	terraform destroy \
		-input=false \
		-auto-approve=true \

.PHONY: install build deploy destroy