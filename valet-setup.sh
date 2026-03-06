#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Laravel Valet Local Dev Setup
# Sets up MariaDB database, Mailpit, and Xdebug, then prints .env variables.
# Usage: ./valet-setup.sh [database_name]
# =============================================================================

DB_NAME="${1:-laravel}"
DB_USER="$(whoami)"
DB_HOST="127.0.0.1"
DB_PORT="3306"

MAIL_HOST="127.0.0.1"
MAIL_SMTP_PORT="1025"
MAIL_UI_PORT="8025"

XDEBUG_MODE="debug"
XDEBUG_PORT="9003"

PHP_VERSION="$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;' 2>/dev/null || echo "unknown")"
PHP_INI_DIR="/opt/homebrew/etc/php/${PHP_VERSION}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

info()  { printf "${CYAN}▸${RESET} %s\n" "$1"; }
ok()    { printf "${GREEN}✔${RESET} %s\n" "$1"; }
warn()  { printf "${YELLOW}!${RESET} %s\n" "$1"; }
fail()  { printf "${RED}✘${RESET} %s\n" "$1"; exit 1; }

# ── MariaDB ──────────────────────────────────────────────────────────────────

info "Checking MariaDB..."

if ! command -v mariadb &>/dev/null; then
    info "Installing MariaDB via Homebrew..."
    brew install mariadb
fi

if ! brew services list | grep -q "mariadb.*started"; then
    info "Starting MariaDB..."
    brew services start mariadb
    sleep 2
fi

DB_VERSION="$(mariadb -e "SELECT @@version;" -sN 2>/dev/null || echo "unknown")"
ok "MariaDB ${DB_VERSION} is running"

if mariadb -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${DB_NAME}';" -sN 2>/dev/null | grep -q "${DB_NAME}"; then
    warn "Database '${DB_NAME}' already exists — skipping creation"
else
    mariadb -e "CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
    ok "Created database '${DB_NAME}'"
fi

if mariadb -e "SELECT User FROM mysql.user WHERE User = '${DB_USER}';" -sN 2>/dev/null | grep -q "${DB_USER}"; then
    warn "User '${DB_USER}' already exists — skipping creation"
else
    mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '';" 2>/dev/null
    ok "Created user '${DB_USER}'"
fi

mariadb -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';" 2>/dev/null
mariadb -e "FLUSH PRIVILEGES;" 2>/dev/null
ok "Granted privileges on '${DB_NAME}' to '${DB_USER}'"

if mariadb -u "${DB_USER}" -h "${DB_HOST}" -P "${DB_PORT}" -e "SELECT 1;" "${DB_NAME}" &>/dev/null; then
    ok "Database connection verified"
else
    fail "Could not connect to '${DB_NAME}' as '${DB_USER}'"
fi

# ── Mailpit ──────────────────────────────────────────────────────────────────

info "Checking Mailpit..."

if ! command -v mailpit &>/dev/null; then
    info "Installing Mailpit via Homebrew..."
    brew install mailpit
fi

if ! brew services list | grep -q "mailpit.*started"; then
    info "Starting Mailpit..."
    brew services start mailpit
    sleep 1
fi

ok "Mailpit is running (UI: http://${MAIL_HOST}:${MAIL_UI_PORT})"

# ── Xdebug ───────────────────────────────────────────────────────────────────

info "Checking Xdebug for PHP ${PHP_VERSION}..."

if ! php -m 2>/dev/null | grep -qi xdebug; then
    info "Installing Xdebug via PECL..."
    pecl install xdebug
fi

XDEBUG_CONFIGURED=true
if ! grep -q "zend_extension=xdebug" "${PHP_INI_DIR}/php.ini" 2>/dev/null && \
   ! grep -q "zend_extension=xdebug" "${PHP_INI_DIR}/conf.d/"* 2>/dev/null; then
    XDEBUG_CONFIGURED=false
    cat >> "${PHP_INI_DIR}/conf.d/ext-xdebug.ini" <<XDEBUG
[xdebug]
zend_extension=xdebug
xdebug.mode=${XDEBUG_MODE}
xdebug.start_with_request=yes
xdebug.client_host=${DB_HOST}
xdebug.client_port=${XDEBUG_PORT}
XDEBUG
    ok "Wrote Xdebug config to ${PHP_INI_DIR}/conf.d/ext-xdebug.ini"
fi

CURRENT_MODE="$(php -r "echo ini_get('xdebug.mode');" 2>/dev/null || echo "${XDEBUG_MODE}")"
ok "Xdebug is loaded (mode: ${CURRENT_MODE})"

# ── Output ───────────────────────────────────────────────────────────────────

printf "\n"
printf "${BOLD}${GREEN}┌─────────────────────────────────────────────┐${RESET}\n"
printf "${BOLD}${GREEN}│  ✔  All services configured                 │${RESET}\n"
printf "${BOLD}${GREEN}└─────────────────────────────────────────────┘${RESET}\n"
printf "\n"
printf "${BOLD}Paste into your .env:${RESET}\n"
printf "${DIM}─────────────────────────────────────────────${RESET}\n"

cat <<ENV
DB_CONNECTION=mariadb
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=

MAIL_MAILER=smtp
MAIL_HOST=${MAIL_HOST}
MAIL_PORT=${MAIL_SMTP_PORT}
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="dev@${DB_NAME}.test"
MAIL_FROM_NAME="\${APP_NAME}"
ENV

printf "${DIM}─────────────────────────────────────────────${RESET}\n"
printf "\n"
printf "${DIM}Mailpit UI:  http://${MAIL_HOST}:${MAIL_UI_PORT}${RESET}\n"
printf "${DIM}Xdebug:      mode=${CURRENT_MODE}, port=${XDEBUG_PORT}${RESET}\n"
printf "${DIM}Site:        https://${DB_NAME}.test${RESET}\n"
