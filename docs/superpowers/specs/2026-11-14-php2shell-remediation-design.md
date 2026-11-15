# PHP2Shell Remediation Design

## Intent
Eliminate CVE-2026-109618 and CVE-2026-109619 from the runnable Ensibuuko stack while preserving the existing browser experience and the JSON contract of GET /api/reports/transactions. The repository must build reproducibly from supported components without embedding environment secrets.

## Goals
- Replace PHP 7.2 and Laravel 5.8 with supported PHP 8.5.12 and Laravel 13.
- Preserve the reports endpoint rows and totals: rows, total_withdrawals, total_deposits, total_saccos, and total_netgains.
- Serve the frontend unchanged at / and the backend at /api through one Nginx port.
- Run PHP-FPM only on the internal Compose network and MySQL 8.4 internally.
- Add database-backed feature coverage, container configuration checks, and smoke coverage.
- Leave production Composer dependencies free of known advisories.

## Non-goals
- Redesigning Vue components, styling, or report semantics.
- Retaining Laravel 5.8 compatibility or providing an unsupported PHP backport.
- Adding authentication or changing the source SQL dataset.

## Constraints
- PHP image: php:8.5.12-fpm-alpine3.23@sha256:619ba0e2ca1c5debd940479226bd419e9db0931154d2b002fdc94e28fa341c55 or newer officially patched PHP 8.5.
- Composer image: composer:2.11.2@sha256:5bcb28b8d0edc4091125f8218f9d088f998bdfc843f8fbb9a4beb4dcd8625684.
- Frontend builder: node:22.21.1-alpine3.22@sha256:b2358485e3e33bc3a33114d2b1bdb18cdbe4df01bd2b257198eb51beb1f026c5.
- Nginx image: nginx:1.28.0-alpine3.21@sha256:30f1c0d78e0ad60901648be663a710bdadf19e4c10ac6782c235200619158284.
- Database image: mysql:8.4.7@sha256:0426ec38c7a10aa45ba383887df7878f74ee70e2fd589c7b69207f3577901903.
- No .env file may be tracked or copied into an image. Runtime secrets come from environment variables.

## Approaches considered
1. In-place multi-major Laravel upgrade: rejected because the locked Laravel 5.8 graph rejects PHP 8.2+, Composer 2 bootstrap fails, and the graph has 28 production advisories.
2. Vendor-patched PHP 7.4 bridge: rejected as the durable fix because Laravel 5.8 remains unsupported and vulnerable.
3. Fresh current backend preserving only application behavior: selected. The custom backend is one report controller and one route, so a fresh Laravel 13 scaffold is safer and smaller than carrying legacy framework state.

## Architecture
A root multi-stage Dockerfile builds the Vue 2 frontend with supported Node, installs Laravel production dependencies with pinned Composer, creates a PHP-FPM application image, and creates an Nginx image containing the frontend assets. Nginx serves the SPA and passes /api requests to the internal api:9000 FastCGI service. Compose publishes only Nginx on host port 3030; PHP-FPM and MySQL use expose-only networking.

The backend uses an invokable report controller with the existing aggregate query and response keys. A feature test creates the three relevant tables in an isolated SQLite database, inserts representative deposits and withdrawals for multiple countries, calls the real HTTP route, and asserts row and total values. A MySQL container smoke test additionally proves the historical SQL dump imports and the endpoint responds through Nginx.

## Safety and operations
The committed app/.env is removed and app/.env.example contains non-secret placeholders with production-safe defaults (debug off). Composer install uses composer.lock, --no-dev, and optimized autoloading. Image tags are exact and digests are pinned. Health checks gate database and API startup. Existing credentials in history remain compromised and must not be reused.
