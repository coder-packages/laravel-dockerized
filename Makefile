COMPOSE=docker-compose -f ./docker/docker-compose.yml --project-directory ./docker
DOCKER=docker
PARAMS=$(filter-out $@, $(MAKECMDGOALS))
EXEC=@$(COMPOSE) exec --user=laradock workspace
EXEC_ROOT=@$(COMPOSE) exec --user=root workspace
PROJECT_PATH=www/code
PROJECT_NAME=
CONTAINERS=workspace nginx php-fpm postgres

.PHONY: artisan tinker composer php yarn npm

# init project
init:
	./init

# docker-compose up -d
up:
	@$(COMPOSE) up -d --build ${CONTAINERS}

# docker-compose down
down:
	@$(COMPOSE) down -v

# docker-compose start
start:
	@if [ $(shell $(DOCKER) ps --filter name=^/${PROJECT_NAME}_ | grep ${PROJECT_NAME}_ > /dev/null; echo $$?) -eq 0 ]; then \
		echo "Already started"; \
	elif [ $(shell $(DOCKER) ps -a --filter name=^/${PROJECT_NAME}_ | grep ${PROJECT_NAME}_ > /dev/null; echo $$?) -eq 0 ]; then \
		$(COMPOSE) start; \
	else \
		make up; \
	fi

# docker-compose stop
stop:
	@$(COMPOSE) stop

# docker-compose ps
ps:
	@$(COMPOSE) ps

# docker-compose top
top:
	@$(COMPOSE) top

# docker-compose logs
logs:
	@$(COMPOSE) logs -f $(PARAMS)

# open shell in php container
bash:
	$(EXEC) bash

bash/root:
	$(EXEC_ROOT) bash

# Execute command in a running container. E.g. make exec npm run dev
exec:
	$(EXEC) $(PARAMS)

# laravel artisan
artisan:
	$(EXEC) php artisan $(PARAMS)

# laravel tinker
tinker:
	$(EXEC) php artisan tinker $(PARAMS)

# composer command in container
composer:
	$(EXEC) composer $(PARAMS)

# yarn
yarn:
	$(EXEC) yarn $(PARAMS)

# yarn watch
watch:
	$(EXEC) yarn watch $(PARAMS)

# npm
npm:
	$(EXEC) npm $(PARAMS)

# check laravel version
laravel/version:
	$(EXEC) php artisan --version

seed:
	$(EXEC) php artisan migrate:fresh
	$(EXEC) php artisan db:seed

sync:
	$(EXEC) composer dump-autoload
	$(EXEC) composer install
	$(EXEC) php artisan migrate

test:
	$(EXEC) $(PROJECT_PATH)/vendor/phpunit/phpunit/phpunit $(PARAMS)

laravel/log:
	tail -f $(PROJECT_PATH)/storage/logs/laravel.log

# MAGIC - This just accepts all targets and silences, need this for the exec command
%:
	@:
