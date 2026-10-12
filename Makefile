start:
	docker compose up -d --no-recreate --remove-orphans

stop:
	docker compose stop

build:
	docker compose build --force-rm

down:
	docker compose down -v

enter:
	docker compose exec fpm bash
