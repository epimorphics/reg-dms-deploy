# Reg DMS set up notes

Notes below are obsoleted. Now switched off letsencrypt due to errors doing the renewal.

Just installed our standard wildcard certificate manually.

## TLS

Installed letsencrypt-auto client and a (3 month) certificate

    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    ./letsencrypt-auto --help

To get certificate:

    ./letsencrypt-auto certonly --apache

To install the certificate compatiblity with default DMS https set up:

    sudo cp /etc/letsencrypt/live/reg-controller.epimorphics.net/privkey.pem /etc/ssl/private/reg-controller.epimorphics.net.key
    sudo cp /etc/letsencrypt/live/reg-controller.epimorphics.net/chain.pem   /etc/ssl/certs/IntermediateCA.crt
    sudo cp /etc/letsencrypt/live/reg-controller.epimorphics.net/cert.pem    /etc/ssl/certs/ssl_certificate.crt

Backup:

   cd
   sudo tar czvf letsencrypt-backup.tgz /etc/letsencrypt/

Then copy the backup to a safe location.

Replaced with epi_base tooling.

## Graphite access

Lower case password

## SSL for dev server

    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    ./letsencrypt-auto --help

To get certificate:

    ./letsencrypt-auto certonly --manual

environment-registry.epimorphics.net location-registry.epimorphics.net    

To install:

    sudo cp /etc/letsencrypt/live/environment-registry.epimorphics.net/chain.pem /etc/ssl/certs/environment-registry_trusted.pem
    sudo cp /etc/letsencrypt/live/environment-registry.epimorphics.net/fullchain.pem /etc/ssl/certs/environment-registry.pem
    sudo cp /etc/letsencrypt/live/environment-registry.epimorphics.net/privkey.pem /etc/ssl/private/privkey.pem
