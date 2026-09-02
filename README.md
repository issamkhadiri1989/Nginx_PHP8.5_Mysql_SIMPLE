# Local PHP Development Stack

A Dockerized local development environment for PHP / Symfony applications using the Symfony CLI local web server, PHP-FPM runtime, MySQL, and phpMyAdmin.

## Stack

- PHP 8.5-FPM
- Symfony CLI (local web server)
- MySQL 8.4
- phpMyAdmin 5
- Docker Compose
- Composer
- Xdebug
- APCu
- AMQP
- Redis
- MongoDB
- GD
- BCMath
- XSL
- LDAP

## Included services

- `fpm` – PHP 8.5 runtime that runs the Symfony CLI local web server (`symfony server:start`). It is published on host port `80` (mapped to the container's port `8000`) and internally exposes ports `9000` (FPM) and `9003` (Xdebug) within the Docker network.
- `database` – MySQL 8.4 database, published on host port `33060` (container `3306`).
- `phpmyadmin` – database administration interface on port `9002`.

All services communicate over the `internal_network` Docker bridge network. The application is served directly by the Symfony CLI web server started inside the `fpm` container.

## Enabled PHP extensions

The PHP container enables the following extensions:

- `amqp`
- `pdo_mysql`
- `sockets`
- `intl`
- `zip`
- `apcu`
- `xdebug`
- `redis`
- `mongodb`
- `gd`
- `bcmath`
- `xsl`
- `ldap`

The `fpm` image also bundles the **Symfony CLI**, **Composer**, and common developer tooling (git, unzip, nano, fish, supervisor, cron).

## How the web server starts

The `fpm` service is configured with:

```yaml
command: symfony server:start --port=8000 --allow-all-ip --no-tls
```

- `--allow-all-ip` makes the server listen on `0.0.0.0` so it is reachable from the host.
- `--port=8000` matches the `80:8000` port mapping, exposing the app on `http://localhost`.
- `--no-tls` disables local HTTPS.
- The server runs in the foreground, which keeps the container alive.

The Symfony project must exist in `./src` (with a `public/` directory) for the server to find a document root.

## Project configuration

The environment is defined in `compose.yaml` and uses the following mounted directories and files:

- Application source: `./src` → `/var/www/html`
- PHP-FPM config: `./infra/php/php-fpm.d/www.conf` → `/usr/local/etc/php-fpm.d/www.conf`
- PHP ini: `./infra/php/config/php.ini` → `/usr/local/etc/php/php.ini`
- Xdebug ini: `./infra/php/xdebug/xdebug.ini` → `/usr/local/etc/php/conf.d/xdebug.ini`

## Environment variables

Create or update the `.env` file with the database configuration:

```env
DATABASE_ROOT_PASSWORD="root"
DATABASE_NAME="example_db"
```

The following variables are optional and fall back to sensible defaults when omitted:

```env
# MySQL native async I/O (1 = enabled, default)
INNODB_USE_NATIVE_AIO=1
# MySQL SQL mode
SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
```

## Docker Compose commands

From the project root:

### Start the stack

```bash
docker compose up -d
```

### Rebuild containers after changes

```bash
docker compose up -d --build
```

### Stop the stack

```bash
docker compose down
```

### Stop and remove volumes

```bash
docker compose down -v
```

### View running containers

```bash
docker compose ps
```

### View logs

```bash
docker compose logs -f
```

### View logs for a specific service

```bash
docker compose logs -f fpm
docker compose logs -f database
```

### Restart services

```bash
docker compose restart
```

### Restart a specific service

```bash
docker compose restart fpm
docker compose restart database
```

### Access a running container shell

```bash
docker compose exec fpm bash
docker compose exec database mysql -u root -p
```

### Recreate containers without cache

```bash
docker compose up -d --force-recreate
```

## Composer & application commands

Composer and the Symfony CLI are installed inside the `fpm` container. Run commands from the container shell or directly:

```bash
# Install dependencies
docker compose exec fpm composer install

# Require a new package
docker compose exec fpm composer require <vendor/package>

# Update dependencies
docker compose exec fpm composer update
```

Symfony console and CLI commands:

```bash
docker compose exec fpm php bin/console cache:clear
docker compose exec fpm php bin/console doctrine:migrations:migrate

# Symfony CLI server management
docker compose exec fpm symfony server:status
docker compose exec fpm symfony server:log
```

## Access URLs

- Application: `http://localhost`
- phpMyAdmin: `http://localhost:9002`
- MySQL: `localhost:33060`

## Notes

- The application is served by the Symfony CLI local web server.
- The project is designed for local development and debugging workflows.
- Xdebug is enabled for PHP debugging support (Xdebug port `9003`).
