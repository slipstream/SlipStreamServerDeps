#!/bin/bash

NGINX_HOME=/etc/nginx/ssl
NGINX_CERT=${NGINX_HOME}/server.crt
NGINX_KEY=${NGINX_HOME}/server.key
NGINX_CSR=${NGINX_HOME}/server.csr
OPENSSL_CFG=${NGINX_HOME}/openssl.cfg

# If certificate exists, then do nothing.
if [ -f "${NGINX_CERT}" ]; then
  exit 0;
fi

# Ensure that the destination directory exists.
mkdir -p ${NGINX_HOME}

# File is needed for OpenSSL.
RANDFILE=${NGINX_HOME}/.rnd
touch ${RANDFILE}
export RANDFILE

echo "Creating SSL certificate for nginx proxy..."

# Get the a hostname of the machine.
FULL_HOSTNAME=`hostname -f || hostname -s || echo "selfsigned.hostcert.me"`

cat > ${OPENSSL_CFG} <<EOF
[ req ]
distinguished_name     = req_distinguished_name
x509_extensions        = v3_ca
prompt                 = no
input_password         = nginxcred
output_password        = nginxcred

dirstring_type = nobmp

[ req_distinguished_name ]
C = EU
CN = ${FULL_HOSTNAME}

[ v3_ca ]
basicConstraints = CA:false
nsCertType=server, client, email, objsign
keyUsage=critical, digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always

EOF

# Generate initial private key.
openssl genrsa -passout pass:nginxcred -des3 -out ${NGINX_KEY} 2048

# Create a certificate signing request.
openssl req -new -key ${NGINX_KEY} -out ${NGINX_CSR} -config ${OPENSSL_CFG}

# Create (self-)signed certificate. 
openssl x509 -req -days 365 -in ${NGINX_CSR} -signkey ${NGINX_KEY} \
             -out ${NGINX_CERT} -extfile ${OPENSSL_CFG} -extensions v3_ca \
             -passin pass:nginxcred

# Remove password on the key.
mv ${NGINX_KEY} ${NGINX_KEY}.orig
openssl rsa -in ${NGINX_KEY}.orig -out ${NGINX_KEY} -passin pass:nginxcred 

# Reduce priviledges on the certificate and key.
chmod 0400 ${NGINX_CERT}
chmod 0400 ${NGINX_KEY}

# Remove intermediate files.
rm -f ${OPENSSL_CFG} ${NGINX_CSR} ${NGINX_KEY}.orig ${RANDFILE}
