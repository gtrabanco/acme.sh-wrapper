#!/usr/bin/env sh

get_url_cert() {
  [ $# -gt 0 ] || return 1
  tmp_dir=$(mktemp -d)
  url="$1"

  hostname="$(echo "$url" | cut -d'/' -f3)"
  [ -n "$hostname" ] || return 1

  cert_file="${tmp_dir}/${hostname}.crt"
  [ -r "$cert_file" ] || printf "" | openssl s_client -servername "$hostname" -connect "${hostname}:443" 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "${tmp_dir}/${hostname}.crt"

  [ -r "$cert_file" ] && echo "$cert_file"
}

get_cert_expiration_days() {
  [ $# -gt 0 ] || return 1
  cert_file="$1"
  [ -r "$cert_file" ] || return 1
  ! command -v openssl >/dev/null 2>&1 && return 1

  cert_date=$(openssl x509 -in "$cert_file" -enddate -noout | sed "s/.*=\(.*\)/\1/" | awk -F " " '{print $1,$2,$3,$4}')
  cert_ts=$(date -d "$cert_date" +%s)

  now_ts=$(date -d now +%s)

  echo $(( (cert_ts - now_ts) / 86400 ))
}
