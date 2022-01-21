## What about this repository

This repository has a script `./bin/acme.sh` that is able to install [acme.sh][1] in a server and also auto load configuration depending on specified domain or dns validation. It also provide sample .env files to deploy any cert to udm, udm-pro, udr or udmse. If you will use this for any ubiquiti product, please make a backup of the original certificates first.

This script was thought to run in a machine different than the unifi router (udm, udr, udmpro, udmse). If you decide to run acme.sh on synology nas you will need to use synology deploy hook anyway.

If you want to run acme.sh on the UDM/Pro check this project:
- https://github.com/alxwolf/ubios-cert

If you want to deploy to cloud key there is a [ubiquiti][2] deploy hook on [acme.sh][1] for that

If you do not matter to use acme.sh or any other and you have a UDM/SE:
- https://github.com/kchristensen/udm-le (You will need on_boot.d from boostchiken-dev repository)
- https://github.com/boostchicken-dev/udm-utilities

## UDM-PRO-SE & UDR Custom certificated

To deploy certs for UDM-PRO-SE & UDR you have to replace `/data/unifi-core/config/unifi-core.crt` and `/data/unifi-core/config/unifi-core.key`.

Finally reset unifi-core service:

```bash
systemctl restart unifi-core
```

Import the certificates using java or keystore seems not necessary but keep doing it because maybe there is any non used option by me which needs that step.

If you want to import certificates for wifiman and do all stuff in one step you need to put the file [udmse-full-cert-deploy](bin/udmse-full-cert-deploy) in the udmse or udr `/root/bin/udmse-full-cert-deploy` and give to it `chmod u+x /root/bin/udmse-full-cert-deploy` permissions.

## Autoload env files

This script will autoload any env file by the value of:
- `--notify-hook`
- `--domain` or `-d`
- `--dns`
- `--deploy-hook`

It will also load `{dns}-{domain}.env` and `{deploy_hook}-{domain}.env` files.

When there is a `.env.private` file, this will be preferred over `.env` file.

## Autoload configuration variables

If you define without value `--home` it will use env var `ACME_HOME`. If you define a value it will replace script variable `ACME_HOME`.

Same functionality for:
- `--cert-home`, will use `ACME_CERT_HOME`.
- `--config-home`, will use `ACME_CONF_HOME`.

## Setup Notifications

It will autoload --notify-hook vale as `.env` file:

```bash
./bin/acme.sh --set-notify --notify-level 2 --notify-mode 0 --notify-hook pushover
# Will autoload pushover.env in current path, envconfigs dir, $HOME, ${HOME}/.env or ${HOME}/.secrets directories
# only one in that order.
./bin/acme.sh --set-notify --notify-level 2 --notify-mode 0 --notify-hook telegram
# Same for telegram.env
```

You can add any other files by using `--env` argument.

```bash
./bin/acme.sh --env customnotify --set-notify ...
```

## Issue a new cert sample

```bash
# Will load if exists:
#   dns_namecheap.env, example.com.env, *.example.com.env, dns_namecheap-example.com.env
./bin/acme.sh --home --cert-home --config-home --server --issue --dns dns_namecheap --domain example.com --domain *.example.com
```

## Deploy

### Synology sample

```bash
./bin/acme.sh --env synology --home --cert-home --config-home --insecure --deploy --deploy-hook synology_dsm --domain example.com --domain *.example.com
```

## UDM/Pro

```bash
./bin/acme.sh --env udm --home --cert-home --config-home --insecure --deploy --deploy-hook ssh --domain example.com --domain *.example.com
```

## UDR/UDMSE

```bash
./bin/acme.sh --env udmse --home --cert-home --config-home --insecure --deploy --deploy-hook ssh --domain example.com --domain *.example.com
```

[1]: https://acme.sh "acme.sh web site"
[2]: https://github.com/acmesh-official/acme.sh/wiki/deployhooks#23-deploy-the-cert-on-a-unifi-controller-or-cloud-key "Unifi Controller Deploy Hook"
