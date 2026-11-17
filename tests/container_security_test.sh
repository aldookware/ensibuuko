#!/bin/sh
set -eu

fail() { echo "FAIL: $*" >&2; exit 1; }

[ -f Dockerfile ] || fail "root multi-stage Dockerfile is missing"
[ ! -f app/Dockerfile ] || fail "legacy app/Dockerfile still exists"
[ ! -f frontend/Dockerfile ] || fail "legacy frontend/Dockerfile still exists"
! git ls-files --error-unmatch app/.env >/dev/null 2>&1 || fail "app/.env is tracked"
grep -q '^APP_ENV=production$' app/.env.example || fail "environment template is not production-safe"
grep -q '^APP_DEBUG=false$' app/.env.example || fail "environment template enables debug mode"

for pinned in \
  'php:8.5.12-fpm-alpine3.23@sha256:619ba0e2ca1c5debd940479226bd419e9db0931154d2b002fdc94e28fa341c55' \
  'composer:2.11.2@sha256:5bcb28b8d0edc4091125f8218f9d088f998bdfc843f8fbb9a4beb4dcd8625684' \
  'node:22.21.1-alpine3.22@sha256:b2358485e3e33bc3a33114d2b1bdb18cdbe4df01bd2b257198eb51beb1f026c5' \
  'nginx:1.28.0-alpine3.21@sha256:30f1c0d78e0ad60901648be663a710bdadf19e4c10ac6782c235200619158284'
do
  grep -Fq "$pinned" Dockerfile || fail "missing pinned image $pinned"
done

grep -Fq 'mysql:8.4.7@sha256:0426ec38c7a10aa45ba383887df7878f74ee70e2fd589c7b69207f3577901903' docker-compose.yml || fail "MySQL image is not pinned"
! grep -RqsE 'php:7\.2|artisan serve' Dockerfile docker-compose.yml app nginx || fail "vulnerable runtime or development server remains"
! grep -Eq 'docker-php-ext-install[^#\n]*opcache' Dockerfile || fail "PHP 8.5 already provides OPcache; rebuilding it breaks the image build"

API_BLOCK=$(awk '/^  api:/{on=1} /^  [a-zA-Z0-9_-]+:/{if(on && $1 != "api:") exit} on{print}' docker-compose.yml)
DB_BLOCK=$(awk '/^  db:/{on=1} /^  [a-zA-Z0-9_-]+:/{if(on && $1 != "db:") exit} on{print}' docker-compose.yml)
printf '%s' "$API_BLOCK" | grep -q 'ports:' && fail "API publishes a host port"
printf '%s' "$DB_BLOCK" | grep -q 'ports:' && fail "database publishes a host port"
grep -q '3030:' docker-compose.yml || fail "Nginx host port is missing"
! grep -q 'COMPOSE_PROJECT_NAME:-' scripts/smoke-test.sh || fail "smoke test may reuse and delete a caller-supplied Compose project"
grep -Fq -- '--password=\"$$MYSQL_ROOT_PASSWORD\"' docker-compose.yml || fail "MySQL healthcheck does not preserve spaces in the root password"
grep -Fq '"audit:prod": "npm audit --omit=dev --audit-level=high"' frontend/package.json || fail "production frontend audit gate is missing"

echo "container security configuration: PASS"
