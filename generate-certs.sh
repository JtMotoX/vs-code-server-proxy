#!/bin/sh

set -e
cd "$(dirname "$0")"

CERT_DIR="./cert"
. ./.env

mkdir -p "${CERT_DIR}"
if [ -f "${CERT_DIR}/server.crt" ]; then
    BACKUP_DIR="${CERT_DIR}/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "${BACKUP_DIR}"
    cp "${CERT_DIR}"/*.crt "${CERT_DIR}"/*.pem "${CERT_DIR}"/*.key "${BACKUP_DIR}/" 2>/dev/null || true
fi
cd "${CERT_DIR}"

# Generate CA
openssl genrsa -out ca.key 4096 2>/dev/null
openssl req -new -x509 -days ${CERT_VALIDITY_DAYS} -key ca.key -out ca.pem -subj "/C=${CERT_COUNTRY}/ST=${CERT_STATE}/L=${CERT_CITY}/O=${CERT_ORGANIZATION}/OU=${CERT_ORG_UNIT}/CN=${CERT_CA_CN}" 2>/dev/null

# Generate server certificate
openssl genrsa -out server.key 4096 2>/dev/null
openssl req -new -key server.key -out server.csr -subj "/C=${CERT_COUNTRY}/ST=${CERT_STATE}/L=${CERT_CITY}/O=${CERT_ORGANIZATION}/OU=${CERT_ORG_UNIT}/CN=${CERT_SERVER_CN}" 2>/dev/null

# Create SAN config
printf "subjectAltName = @alt_names\nextendedKeyUsage = serverAuth\n\n[alt_names]\n" > server-ext.cnf
i=1; IFS=','; for dns in ${CERT_DNS_NAMES}; do echo "DNS.$i = $dns" >> server-ext.cnf; i=$((i+1)); done
i=1; IFS=','; for ip in ${CERT_IP_ADDRESSES}; do echo "IP.$i = $ip" >> server-ext.cnf; i=$((i+1)); done

# Sign and convert
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out server.crt -days ${CERT_VALIDITY_DAYS} -extfile server-ext.cnf 2>/dev/null
openssl x509 -in ca.pem -outform DER -out windows-trusted-ca.crt
rm -f server.csr server-ext.cnf ca.key ca.srl

printf "\n✓ Certificates generated (valid until %s)\n" "$(openssl x509 -in server.crt -noout -enddate | cut -d= -f2)"
openssl x509 -in server.crt -noout -text | grep -A1 "Subject Alternative Name"
