#!/bin/sh
set -eu

if docker compose version >/dev/null 2>&1; then
  COMPOSE='docker compose'
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE='docker-compose'
else
  echo 'FAIL: Docker Compose is required' >&2
  exit 1
fi

export COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-ensibuuko_smoke_$$}
export APP_KEY=${APP_KEY:-base64:MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=}
export DB_DATABASE=${DB_DATABASE:-ensibuuko}
export DB_USERNAME=${DB_USERNAME:-ensibuuko_test}
export DB_PASSWORD=${DB_PASSWORD:-local-test-password}
export DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-local-root-password}

ENDPOINT=${SMOKE_URL:-http://localhost:3030/api/reports/transactions}
ROOT_URL=${SMOKE_ROOT_URL:-http://localhost:3030/}
RESPONSE=$(mktemp)
INDEX=$(mktemp)

cleanup() {
  status=$?
  if [ $status -ne 0 ]; then
    $COMPOSE ps >&2 || true
    $COMPOSE logs --no-color >&2 || true
  fi
  $COMPOSE down --volumes --remove-orphans >/dev/null 2>&1 || true
  rm -f "$RESPONSE" "$INDEX"
  exit $status
}
trap cleanup EXIT HUP INT TERM

$COMPOSE up --build --detach

attempt=0
until curl --fail --silent --show-error "$ENDPOINT" > "$RESPONSE" 2>/dev/null; do
  attempt=$((attempt + 1))
  if [ $attempt -ge 120 ]; then
    echo "FAIL: API did not become ready at $ENDPOINT" >&2
    exit 1
  fi
  sleep 2
done

$COMPOSE exec -T api php -r '
$data = json_decode(stream_get_contents(STDIN), true, 512, JSON_THROW_ON_ERROR);
$required = ["rows", "total_withdrawals", "total_deposits", "total_saccos", "total_netgains"];
if (!is_array($data) || array_diff($required, array_keys($data))) {
    fwrite(STDERR, "FAIL: API response does not contain the required report keys\n");
    exit(1);
}
if (!is_array($data["rows"]) || count($data["rows"]) === 0) {
    fwrite(STDERR, "FAIL: API response rows are missing or empty\n");
    exit(1);
}
echo "smoke response contract: PASS\n";
' < "$RESPONSE"

curl --fail --silent --show-error "$ROOT_URL" > "$INDEX"
grep -q 'id=app' "$INDEX" || grep -q 'id="app"' "$INDEX" || {
  echo 'FAIL: Nginx did not serve the Vue application shell' >&2
  exit 1
}

echo 'smoke Vue shell: PASS'
