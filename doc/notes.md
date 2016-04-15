# Reg DMS set up notes

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

## Graphite access

Lower case password
