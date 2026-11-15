# PHP2Shell Remediation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the vulnerable legacy backend and deployment stack while preserving the reports API and frontend behavior.

**Architecture:** Generate a clean Laravel 13 backend, port the single report endpoint under tests, then package it with pinned multi-stage PHP-FPM, Node, Nginx, and MySQL images. Nginx is the only published service.

**Tech Stack:** PHP 8.5.12, Laravel 13, PHPUnit/Pest-compatible Laravel tests, Vue 2, Node 22, Nginx 1.28, MySQL 8.4, Docker Compose.

**Spec:** docs/superpowers/specs/2026-11-14-php2shell-remediation-design.md

## Global Constraints
- Preserve GET /api/reports/transactions response keys and aggregate behavior.
- Keep frontend source behavior unchanged.
- Pin all container bases to the exact versions and digests in the spec.
- Never copy or track app/.env; APP_DEBUG defaults false.
- Publish only Nginx; PHP-FPM and MySQL remain internal.
- Use composer install from composer.lock, never composer update in image builds.

## Review Focus
- Countries missing either deposits or withdrawals retain the legacy inner-intersection behavior.
- Numeric JSON values remain compatible with the frontend totals and table rendering.
- Requests to /api reach Laravel while SPA routes still fall back to index.html.
- MySQL initialization is ready before the API is considered healthy.
- Fresh clones can build without a local app/.env or vendor directory.

---

### Task 1: Fresh Laravel backend and report contract

**Files:** replace legacy app scaffold; create app/app/Http/Controllers/TransactionReportController.php; create app/routes/api.php; create app/tests/Feature/TransactionReportTest.php.

**Interfaces:** Produces GET /api/reports/transactions with the legacy five response keys.

- [ ] Generate Laravel 13 into a temporary directory and replace legacy framework files while retaining the report behavior target.
- [ ] Write the database-backed feature test first, including two countries and an unmatched country; run it and verify RED because the route/controller is absent.
- [ ] Implement the API route and minimal controller query; run the focused test GREEN.
- [ ] Run the complete backend suite and composer audit --locked --no-dev.
- [ ] Commit backend replacement and tests.

### Task 2: Reproducible secure container stack

**Files:** create Dockerfile; modify docker-compose.yml; replace nginx/default.conf; remove app/Dockerfile and frontend/Dockerfile; update ignore and environment example files.

**Interfaces:** Consumes the Laravel public/index.php and frontend dist; produces api and web image targets and internal api:9000 routing.

- [ ] Add a configuration test that asserts vulnerable tags, artisan serve, published API/DB/frontend ports, and tracked app/.env are absent; run RED.
- [ ] Implement pinned multi-stage images, internal-only services, health checks, Nginx FastCGI API routing, and environment templates; run the configuration test GREEN.
- [ ] Validate Compose with explicit non-secret test variables and build every target.
- [ ] Commit container modernization.

### Task 3: Runtime integration and documentation

**Files:** create scripts/smoke-test.sh; update README.md.

**Interfaces:** Starts the Compose stack, waits on http://localhost:3030/api/reports/transactions, validates response shape, and tears down cleanly.

- [ ] Write the smoke script response assertion before the stack is available and verify RED.
- [ ] Complete stack startup/readiness behavior and run the smoke test GREEN against MySQL 8.4 and Nginx.
- [ ] Document setup, required environment variables, testing, architecture, and credential-history warning.
- [ ] Run backend tests, frontend unit/lint/build, Composer audit, Compose validation/build/smoke, and git diff --check.
- [ ] Commit runtime proof and documentation.
