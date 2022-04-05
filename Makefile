current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: build
build: deps start

.PHONY: deps
deps: composer-install

composer-env-file:
	@if [ ! -f .env.local ]; then echo '' > .env.local; fi

.PHONY: composer-install
composer-install: CMD=install

.PHONY: composer-update
composer-update: CMD=update

.PHONY: composer-require
composer-require: CMD=require
composer-require: INTERACTIVE=-ti --interactive

.PHONY: composer-require-module
composer-require-module: CMD=require $(module)
composer-require-module: INTERACTIVE=-ti --interactive

.PHONY: composer
composer composer-install composer-update composer-require composer-require-module: composer-env-file
	@docker run --rm $(INTERACTIVE) --volume $(current-dir):/app --user $(id -u):$(id -g) \
		composer:2.2.6 $(CMD) \
			--ignore-platform-reqs \
			--no-ansi

# Docker Compose
.PHONY: start
start: CMD=up --build -d

.PHONY: stop
stop: CMD=stop

.PHONY: destroy
destroy: CMD=down

start stop destroy: composer-env-file
	@docker-compose $(CMD)

.PHONY: rebuild
rebuild: composer-env-file
	docker-compose build --pull --force-rm --no-cache
	make deps
	make start

.PHONY: phpcs
phpcs:
	@docker exec dvidz-php ./vendor/bin/phpcs -p

.PHONY: tests
tests: phpcs psalm phpunit behat

.PHONY: psalm
psalm:
	docker exec -it dvidz-php ./vendor/bin/psalm

.PHONY: phpunit
phpunit:
	docker exec -it dvidz-php ./vendor/bin/phpunit --testsuite Dvidz

.PHONY: behat
behat:
	docker exec -it dvidz-php ./vendor/bin/behat

.PHONY: ping-mysql
ping-mysql:
	@docker exec dvidz-mysql mysqladmin --user=root --password= --host "127.0.0.1" ping --silent

.PHONY: database-create
database-create:
	@docker exec dvidz-php bin/console doctrine:database:create -n
	@docker exec dvidz-php bin/console doctrine:migrations:migrate -n

.PHONY: database-drop
database-drop:
	@docker exec dvidz-php bin/console doctrine:database:drop --force
