#! /bin/sh
apt update
apt -y  install apache2
sleep 5
cat <<EOF > /var/www/html/index.html
<html><body><h1>Teste metadata_startup_script https config</h1>
<p> Este foi um teste executado com sucesso</p>
</body></html>
EOF
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2
sleep 5
mkdir /etc/apache2/certificate
cd /etc/apache2/certificate
hostname2=$(curl http://metadata.google.internal/computeMetadata/v1/instance/hostname -H "Metadata-Flavor: Google")
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout apache.key -out apache-certificate.crt -subj "/C=BR/ST=PR/L=cwb/O=apache2/OU=server/CN='$hostname2'/emailAddress=devops@contabilizei.com.br"
sleep 10
sudo cat <<EOF >> /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        SSLEngine on
        SSLCertificateFile /etc/apache2/certificate/apache-certificate.crt
        SSLCertificateKeyFile /etc/apache2/certificate/apache.key
</VirtualHost>
EOF
sudo service apache2 restart
