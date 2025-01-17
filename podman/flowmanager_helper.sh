#!/bin/bash
set -euo pipefail

# Setup and run the app.
# Example: ./flowmanager_helper.sh [setup/start/restart/stop/help...]

PROJECT_NAME="flowmanager"

# Generate and copy generated certificates in the right configs path
function gen_config() {
    # Generate certifications
    cd ../scripts/
    ./generate_certs.sh
    cd -
	
    cp ../scripts/custom-ca/governance/governanceca.pem ./files/$PROJECT_NAME/configs/
    cp ../scripts/custom-ca/business/cacert.p12 ./files/$PROJECT_NAME/configs/businessca.p12
    cp ../scripts/custom-ca/governance/uicert.pem ./files/$PROJECT_NAME/configs/
    cp ../scripts/custom-ca/governance/cacert.pem ./files/st-fm-plugin/governanceca.pem
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-ca.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/*key ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-shared-secret ./files/st-fm-plugin/
    chmod -R 755 ./files/st-fm-plugin

    # List config files
    if [ $? -eq 0 ]; then
        echo "INFO: Certificates generated and copied to the configs space"
    else
        echo "ERROR: Some issues in generating and copy certs to the configs space"
        exit 1
    fi
}

# Start the container(s)
function start_container() {
    podman network create flowmanager_pod-network
    podman play kube ./flowmanager.yml --network=flowmanager_pod-network
    echo "FlowManager was installed."
}

# Restart the container(s)
function update_container() {
    podman pod rm -f flowmanager_pod
    podman play kube ./flowmanager.yml --network=flowmanager_pod-network
    echo "Pod 'flowmanager_pod' was updated"
}

# Check the container(s)
function status_container() {
    podman pod stats flowmanager_pod
}

# Stop the container(s)
function stop_container() {
    podman pod stop flowmanager_pod
    echo "Pod 'flowmanager_pod' was stopped"
}

# Delete the container(s)
function delete_container() {
    podman pod rm -f flowmanager_pod
    rm -rf ./mongodb_data_container/*
    podman network rm flowmanager_pod-network
    echo "Pod 'flowmanager_pod' was deleted"
}

# Inspect the container(s)
function inspect() {
    podman pod inspect flowmanager_pod
}

# How to use the script
function usage() {
    echo "--------"
    echo " HELP"
    echo "--------"
    echo "Usage: ./${PROJECT_NAME}_helper.sh [option]"
    echo "  options:"
    echo "    setup    : Generate certificates"
    echo "    start    : Create the pod network, $PROJECT_NAME, mongodb and securetransport plugin containers and start them"
    echo "    update   : Update $PROJECT_NAME, mongodb and securetransport plugin containers with new configuration; can also be used to restart the containers"
    echo "    stop     : Stop $PROJECT_NAME, mongodb and securetransport plugin containers"
    echo "    stats    : Show the status of $PROJECT_NAME, mongodb and securetransport plugin containers"
    echo "    delete   : Delete $PROJECT_NAME, mongodb and securetransport containers and other parts related to the containers, like storage and pod network"
    echo "    inspect  : Get the details about your flowmanager pod"
    echo "    help     : Show the usage of the script file"
    echo ""
    exit
}

[[ $# -eq 0 ]] && usage

# Menu
if [[ $@ ]]; then
    while (( $# ))
    do
        case "$1" in
            setup)
                gen_config
                shift
                ;;
            start)
                if [ -z "${2-}" ]; then
                    start_container
                else
                    start_container $2
                fi
                shift
                ;;
            stop)
                stop_container
                shift
                ;;
            update)
                if [ -z "${2-}" ]; then
                    update_container
                else
                    update_container $2
                fi
                shift
                ;;
            stats)
                status_container
                shift
                ;;
            delete)
                delete_container
                shift
                ;;
            inspect)
                if [ -z "${2-}" ]; then
                    inspect
                else
                    inspect $2
                fi
                shift
                ;;
            help)
                usage
                exit 0
                ;;
            *)
                error_message "ERROR: Invalid option $1. Type help option for more information"
                exit 0
                ;;
        esac
    done
else
    usage
    exit 0
fi
