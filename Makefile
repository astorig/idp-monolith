#!/usr/bin/make -f
# SHELL = /bin/sh

ENVFILE=.env
MAKEFILE_PATH=.

ifneq ("$(wildcard .env)","")
	# ENVFILE=.env
	APP_DIR=$(shell echo $$(cd . && pwd))
else
	# ENVFILE=../.env
	APP_DIR=$(shell echo $$(cd .. && pwd))
	MAKEFILE_PATH=$(shell basename $$(cd . && pwd))
endif

SHELL = /bin/sh
.DEFAULT_GOAL = help
.PHONY: help down up docker.clear update build first_install tests_run

DC=
COPY=cp
RM=rm -rf

help:
	@echo Usage:
	@echo "   make <command> [<command>, [<command>, ...]]"
	@echo -----
	@echo Available commands:
	@echo "   up             Up projects"
	@echo "   down           Down projects"
	@echo "   update         Update docker images"
	@echo "   build          Build docker images"
	@echo "   first_install  First installation of the project"
	@echo "   docker.clear   Clear docker system folder"
	@echo "   tests_run   	 Run tests"
	@echo Settings:
	@echo "   APP_DIR:              $(APP_DIR)"
	@echo -----
	@echo Example:
	@echo "   make up          "
	@echo "   make down up     "
	@echo "   make update up   "
	@echo -----

down:
	cd $(APP_DIR) && docker-compose down -v --remove-orphans

up:
	docker rm -f $$(docker ps -a | grep idp | awk '{print $$1}') || echo
	cd $(APP_DIR) && docker-compose up -d --remove-orphans --force-recreate
	cd $(APP_DIR) && $(DC) docker-compose exec -T php /bin/bash -c "COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-ansi --no-scripts --no-interaction --no-progress"
	@echo ---------------------------------------------
	@echo =============================================
	@echo == Done
	@echo =============================================

docker.clear:
	docker-compose down -v --remove-orphans
	docker container prune -f
	docker image prune -f
	docker volume prune -f
	docker network prune -f
	docker network create idpnetwork || echo Created
	@echo "======================="

update:
	cd $(APP_DIR) && docker-compose pull

build:
	cd $(APP_DIR) && docker-compose build

first_install:
	cp .env.example .env
	docker network create idpnetwork || echo Created
	$(MAKE) build
	$(MAKE) up

tests_run:
	$(MAKE) up
	cp .env.test.example .env.test
	cd $(APP_DIR) && $(DC) docker-compose exec -T php /bin/bash -c "COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-ansi --no-scripts --no-interaction --no-progress"
	#cd $(APP_DIR) && $(DC) docker-compose exec -T php php vendor/bin/phpunit

exec-bash:
	docker-compose exec -T php bash -c "$(cmd)"

migrate:
	@make exec-bash cmd="php artisan migrate --force"
