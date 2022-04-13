#!/usr/bin/env bash

ACME_HOME="${ACME_HOME:-${HOME}/.acme.sh}"
SRC_PATH="${SRC_PATH:-$(dirname "$(dirname "${BASH_SOURCE[0]}")")}"
LIB_PATH="${SRC_PATH}/lib"
ENV_PATH="${SRC_PATH}/envconfigs"

#shellcheck disable=SC1091
. "${LIB_PATH}/loadenvfile.sh" || exit 1

[ -n "$(get_env "default")" ] &&
  load_env "default"
[ -n "$(get_env "acme")" ] &&
  load_env "acme"
[ -n "$(get_env "acme.sh")" ] &&
  load_env "acme.sh"
[ -n "$(get_env "secrets")" ] &&
  load_env "secrets"

# Check if acme.sh is installed
if ! command -v acme.sh >/dev/null 2>&1; then
  if [ ! -d "$ACME_HOME" ]; then
    echo "acme.sh not found"
    echo -n "Do you want to install it? [y/N]: "
    read -r answer
    answer="${answer:-n}"
    if [[ "$answer" =~ ^[yY] ]]; then
      while [[ -z "${USER_EMAIL:-}" ]]; do
        echo -n "Enter your email: "
        read -r USER_EMAIL
      done

      echo "Installing acme.sh"
      if command -v curl >/dev/null 2>&1; then
        curl https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh | sh -s -- --install-online -m "$USER_EMAIL" --home "$ACME_HOME"
      else
        wget -O - https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh | sh -s -- --install-online -m "$USER_EMAIL" -- --home "$ACME_HOME"
      fi

      if [[ ! -d "$ACME_HOME" ]]; then
        echo "acme.sh could not be installed"
        exit 1
      fi

      "${BASH_SOURCE[0]}" "$@"
      exit "$?"
    fi
  else
    #shellcheck disable=SC1091
    . "${ACME_HOME}/acme.sh.env"
  fi
fi

ACME_BIN="${ACME_BIN:-${ACME_HOME}/acme.sh}"
ACME_CONF_HOME="${ACME_CONF_HOME:-${ACME_HOME}/data}"
ACME_CERT_HOME="${ACME_CERT_HOME:-${ACME_HOME}/certs}"
ACME_SERVER="${ACME_SERVER:-letsencrypt}"
DNS_RESOLVERS="${DNS_RESOLVERS:-1.1.1.1}"

if [ ! -x "$ACME_BIN" ]; then
  echo "acme.sh executable not found"
  exit 1
fi

# Main functionality
ACME_ARGUMENTS=()
DOMAINS_CMD=()

while [ $# -gt 0 ]; do
  case "$1" in
  --env)
    load_env "${ENV_PATH}/$2"
    shift 2
    ;;
  --home)
    shift
    if [ -d "${1:-}" ]; then
      ACME_HOME="$1"
      shift
    fi
    ACME_ARGUMENTS+=("--home" "$ACME_HOME")
    ;;
  --cert-home)
    shift
    if [ -d "${1:-}" ]; then
      ACME_CERT_HOME="$1"
      shift
    fi
    ACME_ARGUMENTS+=("--home" "$ACME_CERT_HOME")
    ;;
  --config-home)
    shift
    if [ -d "${1:-}" ]; then
      ACME_CONF_HOME="$1"
      shift
    fi
    ACME_ARGUMENTS+=("--home" "$ACME_CONF_HOME")
    ;;
  --dns)
    shift
    DNS_PROVIDER="${1:-}"
    if [ -n "$(get_env "${ENV_PATH}/${1:-}")" ]; then
      load_env "${ENV_PATH}/${1:-}"
    fi
    ACME_ARGUMENTS+=(--dns "$1")
    shift
    ;;
  --deploy-hook)
    shift
    DEPLOY_HOOK="${1:-}"
    if [ -n "$(get_env "${ENV_PATH}/${1:-}")" ]; then
      load_env "${ENV_PATH}/${1:-}"
    fi
    ACME_ARGUMENTS+=(--deploy-hook "$1")
    shift
    ;;
  -d | --domain)
    shift
    #shellcheck disable=SC2125
    DOMAINS_CMD+=("$1")
    if [ -n "$(get_env "${ENV_PATH}/${1:-}")" ]; then
      load_env "${ENV_PATH}/${1:-}"
    fi
    ACME_ARGUMENTS+=(--domain "$1")
    shift
    ;;
  --server)
    shift
    if [[ "$1" =~ ^-- ]]; then
      ACME_ARGUMENTS+=(--server "$ACME_SERVER")
    else
      ACME_ARGUMENTS+=(--server "${1:-}")
      shift
    fi
    ;;
  *)
    ACME_ARGUMENTS+=("$1")
    shift
    ;;
  esac
done

for domain in "${DOMAINS_CMD[@]}"; do
  all_possible_envfiles=(
    "${DNS_PROVIDER}"
    "${ENV_PATH}/${DNS_PROVIDER}"
    "${DNS_PROVIDER}-${domain}"
    "${ENV_PATH}/${DNS_PROVIDER}-${domain}"
    "${DEPLOY_HOOK}"
    "${ENV_PATH}/${DEPLOY_HOOK}"
    "${DEPLOY_HOOK}-${domain}"
    "${ENV_PATH}/${DEPLOY_HOOK}-${domain}"
  )

  for envfile in "${all_possible_envfiles[@]}"; do
    if [ -n "$(get_env "${envfile}")" ]; then
      load_env "${envfile}"
    fi
  done
done

"$ACME_BIN" "${ACME_ARGUMENTS[@]}"
