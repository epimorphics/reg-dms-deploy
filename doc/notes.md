# Reg DMS set up notes

## TLS

Installed letsencrypt-auto client and a (3 month) certificate

To install (will script this):

    sudo cp /etc/letsencrypt/live/reg-controller.epimorphics.net/privkey.pem /etc/ssl/private/reg-controller.epimorphics.net.key
    sudo cp /etc/letsencrypt/live/reg-controller.epimorphics.net/chain.pem   /etc/ssl/certs/IntermediateCA.crt
    sudo cp /etc/letsencrypt/live/reg-controller.epimorphics.net/cert.pem    /etc/ssl/certs/ssl_certificate.crt

Backup by:

   cd
   sudo tar czvf letsencrypt-backup.tgz /etc/letsencrypt/

Then copy the backup to a safe location.

## Graphite access

Lower case password
