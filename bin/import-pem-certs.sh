#!/usr/bin/env bash
# This script copies the default cacerts to $TRUSTSTORE_PATH 
# and imports all the certs contained in the $IDM_PEM_TRUSTSTORE if it exists

#
# Copyright 2019-2021 ForgeRock AS. All Rights Reserved
#

set -e 
set -o pipefail

IDM_DEFAULT_TRUSTSTORE=${IDM_DEFAULT_TRUSTSTORE:-$JAVA_HOME/lib/security/cacerts}
# If a $IDM_PEM_TRUSTSTORE is provided, import it into the truststore. Otherwise, do nothing
if [ -f "$IDM_DEFAULT_TRUSTSTORE" ] && [ -f "$IDM_PEM_TRUSTSTORE" ]; then
    TRUSTSTORE_PATH="${TRUSTSTORE_PATH:-/opt/openidm/idmtruststore}"
    TRUSTSTORE_PASSWORD="${TRUSTSTORE_PASSWORD:-changeit}"
    echo "Copying ${IDM_DEFAULT_TRUSTSTORE} to ${TRUSTSTORE_PATH}"
    cp ${IDM_DEFAULT_TRUSTSTORE} ${TRUSTSTORE_PATH}
    # Calculate the number of certs in the PEM file
    CERTS=$(grep 'END CERTIFICATE' $IDM_PEM_TRUSTSTORE| wc -l)
    echo "Found (${CERTS}) certificates in $IDM_PEM_TRUSTSTORE"
    echo "Importing (${CERTS}) certificates into ${TRUSTSTORE_PATH}"
    # For every cert in the PEM file, extract it and import into the JKS truststore
    for N in $(seq 0 $(($CERTS - 1))); do
        ALIAS="imported-certs-$N"
        cat $IDM_PEM_TRUSTSTORE |
            awk "n==$N { print }; /END CERTIFICATE/ { n++ }" |
            keytool -noprompt -importcert -trustcacerts -storetype JKS \
                    -alias "${ALIAS}" -keystore "${TRUSTSTORE_PATH}" \
                    -storepass "${TRUSTSTORE_PASSWORD}"
    done
    echo "Import complete!"
else
    echo "Nothing was imported to the truststore. Check ENVs IDM_DEFAULT_TRUSTSTORE and IDM_PEM_TRUSTSTORE"
    exit -1
fi
