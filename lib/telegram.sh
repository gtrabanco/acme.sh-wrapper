#!/usr/bin/env sh

telegram_send_message() {
  if
    [ -z "$TG_API_KEY" ] ||
    [ -z "$TG_CHAT_ID" ]
  then
    echo "Non API KEY or CHAT ID" >&2
    return 1
  fi

  curl -sG --data-urlencode "chat_id=${TG_CHAT_ID}" --data-urlencode "text=${*}" "$(printf "https://api.telegram.org/bot%s/sendMessage" "$TG_API_KEY")"
}


