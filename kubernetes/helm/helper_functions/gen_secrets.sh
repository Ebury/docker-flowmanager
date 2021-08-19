#!/bin/bash
# set -x
set -euo pipefail

function gen_certs_selfsigned {
./../scripts/generate_certs.sh

mkdir -p certs


cp ./custom-ca/governance/cacert.p12 ./certs/governanceca.p12
cp ./custom-ca/governance/governanceca.pem ./certs/governanceca.pem
cp ./custom-ca/governance/uicert.p12 ./certs/uicert.p12
cp ./custom-ca/business/cacert.p12  ./certs/businessca.p12
cp ./custom-ca/st-fm-plugin/st-fm-plugin-ca.pem   ./certs/st-fm-plugin-ca.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem ./certs/st-fm-plugin-cert-key.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-cert.pem ./certs/st-fm-plugin-cert.pem
cp ./custom-ca/st-fm-plugin/private-key ./certs/private-key
cp ./custom-ca/st-fm-plugin/public-key ./certs/public-key
chmod 755 -R ./certs/
rm -rf ./custom-ca/


if [ -f ./license.xml ]; then
    kubectl create secret generic license --from-file=./license.xml -n ${NAMESPACE}
else
    msg_info 'License not found.'
	msg_info 'You can manually run: kubectl create secret generic flowmanager-license --from-file=license.xml -n namespace'
fi

if [ -f ./certs/uicert.p12 ]; then
    kubectl create secret generic uicert --from-file=./certs/uicert.p12 -n ${NAMESPACE}
else
    msg_info "uicert.p12 was not found in ./certs/."
fi

if [ -f ./certs/governanceca.p12 ]; then
    kubectl create secret generic governanceca --from-file=./certs/governanceca.p12 -n ${NAMESPACE}
else
    msg_info "governanceca.p12 was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-ca.pem ]; then
    kubectl create secret generic st-fm-plugin-ca --from-file=./certs/st-fm-plugin-ca.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-ca.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-cert-key.pem ]; then
    kubectl create secret generic st-fm-plugin-cert-key --from-file=./certs/st-fm-plugin-cert-key.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-cert-key.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-cert.pem ]; then
    kubectl create secret generic st-fm-plugin-cert --from-file=./certs/st-fm-plugin-cert.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-cert.pem was not found in ./certs/."
fi

if [ -f ./certs/private-key ]; then
    kubectl create secret generic private-key-st --from-file=./certs/private-key -n ${NAMESPACE}
else
    msg_info "private-key was not found in ./certs/."
fi

if [ -f ./certs/public-key ]; then
    kubectl create secret generic public-key-st --from-file=./certs/public-key -n ${NAMESPACE}
else
    msg_info "public-key was not found in ./certs/."
fi

if [ -f ./certs/governanceca.pem ]; then
    kubectl create secret generic governanceca-st --from-file=./certs/governanceca.pem -n ${NAMESPACE}
else
    msg_info "public-key was not found in ./certs/."
fi

}
