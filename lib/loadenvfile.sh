#!/usr/bin/env bash

get_env() {
  if [ -d "${ENV_PATH}" ]; then
    local -r paths=(
      "./"
      "${ENV_PATH}"
      "${HOME}/.secrets"
      "${HOME}/.env"
      "${HOME}"
    )
  else
    local -r paths=(
      "./"
      "${HOME}/.secrets"
      "${HOME}/.env"
      "${HOME}"
    )
  fi

  for file in "$@"; do
    for p in "${paths[@]}"; do
      if [ -f "${p}/${file}.private" ]; then
        printf "%s/%s.private" "$p" "$file"
        break
      elif [ -f "${p}/${file}.env.private" ]; then
        printf "%s/%s.env.private" "$p" "$file"
        break
      elif [ -f "${p}/${file}.secret" ]; then
        printf "%s/%s.private" "$p" "$file"
        break
      elif [ -f "${p}/${file}.env.secret" ]; then
        printf "%s/%s.env.private" "$p" "$file"
        break
      elif [ -f "${p}/${file}" ]; then
        #shellcheck disable=SC1090
        printf "%s/%s" "$p" "$file"
        break
      elif [ -f "${p}/${file}.env" ]; then
        printf "%s/%s.env" "$p" "$file"
        break
      fi
    done
  done
}

load_env() {
  local file_path
  local return_code=1

  for file in "$@"; do
    file_path="$(get_env "$file")"

    #shellcheck disable=SC1090
    [ -n "$file_path" ] &&
      return_code=0 &&
      . "$file_path"

    unset file_path
  done

  return "$return_code"
}
