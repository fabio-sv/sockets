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

install: 
	@printf "\n${BOLD}${YELLOW}Installing dependencies...${RESET}\n"
	__ui_install __tf_init

build:
	@printf "\n${BOLD}${YELLOW}Building UI...${RESET}\n"
	cd functions && \
	zip -r functions.zip . && \
	mv functions.zip ../infrastructure

deploy:
	@printf "\n${BOLD}${YELLOW}Deploying infrastructure...${RESET}\n"
	cd infrastructure && \
	terraform apply \
		-input=false \
		-auto-approve=true \

destroy:
	@printf "\n${BOLD}${YELLOW}Destroying infrastructure...${RESET}\n"
	cd infrastructure && \
	terraform destroy \
		-input=false \
		-auto-approve=true \
