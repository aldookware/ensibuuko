# Ensibuuko Transaction Reports

Ensibuuko serves the existing Vue 2 reports interface and the Laravel reports API through one Nginx endpoint.

## Architecture

- **Nginx 1.28** is the only service published to the host, at <http://localhost:3030>.
- **PHP 8.5 / Laravel 13 PHP-FPM** runs only on the internal Compose network. Nginx forwards `/api` requests to it over FastCGI.
- **MySQL 8.4** runs only on the internal network and imports `db/transactions_report_test.sql` into a fresh data volume.
- The Vue application is built with Node 22 and copied into the Nginx image.
- All base images are pinned to supported versions and immutable digests in `Dockerfile` and `docker-compose.yml`.

## Run locally

Docker Engine, Docker Compose, and `curl` are required.

Set runtime-only values in the shell. Do not commit them or place them in an image:

```sh
export APP_KEY="base64:$(openssl rand -base64 32)"
export DB_USERNAME=ensibuuko
export DB_PASSWORD='choose-a-local-password'
export DB_ROOT_PASSWORD='choose-a-different-root-password'
# Optional: export DB_DATABASE=ensibuuko
# Optional: export APP_URL=http://localhost:3030
```

Build and start the stack:

```sh
docker compose up --build --detach
```

Use `docker-compose` in place of `docker compose` on installations that provide the standalone Compose command. Open <http://localhost:3030>, or request the API directly:

```sh
curl http://localhost:3030/api/reports/transactions
```

The response keeps the legacy contract:

```json
{
  "rows": [
    {
      "Country": "Kenya",
      "Saccos": 1,
      "Deposit": 200,
      "Withdrawal": 50,
      "Net": 150
    }
  ],
  "total_withdrawals": 50,
  "total_deposits": 200,
  "total_saccos": 1,
  "total_netgains": 150
}
```

Stop the stack with `docker compose down`. Add `--volumes` only when you also want to delete the local MySQL data.

## Verification

Run the configuration checks and full container smoke test from the repository root:

```sh
sh tests/container_security_test.sh
./scripts/smoke-test.sh
```

The smoke test creates an isolated Compose project, builds both application targets, waits for MySQL and PHP-FPM health checks, verifies the API response shape through Nginx, verifies the Vue shell, and removes its containers and volume.

Backend tests and the production dependency audit:

```sh
cd app
composer install
composer test
composer audit --locked --no-dev
```

Frontend tests, lint, and build (Node 22):

```sh
cd frontend
npm ci --legacy-peer-deps
npm run test:unit -- --runInBand
npm run lint
npm run build
npm run audit:prod
```

## Security notes

- `APP_DEBUG` defaults to `false`; do not enable it in production.
- PHP-FPM and MySQL have no published host ports. Only Nginx publishes port 3030.
- Production Composer dependencies are installed reproducibly from `app/composer.lock` with `composer install --no-dev`; image builds never run `composer update`.
- No `.env` file is tracked or copied into an image. Supply credentials as runtime environment variables or through your deployment platform's secret manager.
- Credentials previously committed in repository history must be treated as compromised. Do not reuse them; rotate any values that were ever deployed.

## Contributor

Aldo Okware
