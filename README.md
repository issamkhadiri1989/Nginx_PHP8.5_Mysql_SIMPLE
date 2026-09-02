# Local PHP Development Stack

A Dockerized local development environment for PHP applications using Nginx, PHP-FPM, MySQL, and phpMyAdmin.

## Stack

- PHP 8.5-FPM
- Nginx (Alpine)
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

- `nginx` – serves the application through HTTP on port `80` and HTTPS on port `443`
- `fpm` – PHP runtime via PHP-FPM, internally exposed on ports `9000` (FPM) and `9003` (Xdebug) within the Docker network
- `database` – MySQL 8.4 database, published on host port `33060` (container `3306`)
- `phpmyadmin` – database administration interface on port `9002`

All services communicate over the `internal_network` Docker bridge network.

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

## Project configuration

The environment is defined in `compose.yaml` and uses the following mounted directories and files:

- Application source: `./src` → `/var/www/html`
- Nginx config: `./infra/nginx/conf.d` → `/etc/nginx/conf.d`
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
docker compose logs -f nginx
docker compose logs -f fpm
docker compose logs -f database
```

### Restart services

```bash
docker compose restart
```

### Restart a specific service

```bash
docker compose restart nginx
docker compose restart fpm
docker compose restart database
```

### Access a running container shell

```bash
docker compose exec fpm bash
docker compose exec nginx sh
docker compose exec database mysql -u root -p
```

### Recreate containers without cache

```bash
docker compose up -d --force-recreate
```

## Composer & application commands

Composer is installed inside the `fpm` container. Run commands from the container shell or directly:

```bash
# Install dependencies
docker compose exec fpm composer install

# Require a new package
docker compose exec fpm composer require <vendor/package>

# Update dependencies
docker compose exec fpm composer update
```

If the application is a Symfony project, the console is available at `bin/console`:

```bash
docker compose exec fpm php bin/console cache:clear
docker compose exec fpm php bin/console doctrine:migrations:migrate
```

## Access URLs

- Application: `http://localhost`
- HTTPS: `https://localhost`
- phpMyAdmin: `http://localhost:9002`
- MySQL: `localhost:33060`

## Notes

- Nginx uses a self-signed certificate generated during the image build.
- The project is designed for local development and debugging workflows.
- Xdebug is enabled for PHP debugging support.
