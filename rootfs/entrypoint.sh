#!/bin/sh

CONFIG_ORIGINAL=/app/example-dnscrypt-proxy.toml
CONFIG_FILE=/data/dnscrypt-proxy.toml

# change_config <var_name> <var>
change_config (){
    # check variable was set
    if [ -n "$2" ]; then VAR="" && counter=0

        # string formatting
        for i in $(echo $2 | sed "s/,/ /g"); do
            VAR="$VAR '$i'," && counter=$((counter+1))
        done

        # change line from file
        if [[ $counter -eq 1 ]]; then
            # key = value
            sed -i -r "s/^[# ]*${1} ?= ?[^[]*$/${1} = ${2}/" $CONFIG_FILE

            # key = [value]
            sed -i -r "s/^[# ]*${1} ?= ?\[.*$/${1} = \['${2}'\]/" $CONFIG_FILE
        else
            # key = [value1, value2, ...]
            sed -i -r "s/^[# ]*${1} ?=.*$/${1} = [${VAR%?}]/" $CONFIG_FILE
        fi

    fi
}

# check example-config file exist
if [ -e $CONFIG_ORIGINAL ]; then

    # config file not exist or auto regeneration not off
    if [ $ENABLE_AUTO_CONFIG == 'true' ] || [ ! -e $CONFIG_FILE ]; then

        echo "Create config file (${CONFIG_FILE})."

        echo "# Dynamic config file for dnscrypt-proxy generated by entrypoint" \
        "\n# DO NOT EDIT THIS FILE BY HAND IF 'ENABLE_AUTO_CONFIG' IS TURE --" \
        "\n# YOUR CHANGES WILL BE OVERWRITTEN\n" > $CONFIG_FILE

        cat $CONFIG_ORIGINAL >> $CONFIG_FILE

        change_config 'server_names' "${SERVER_NAMES}"

        change_config 'dnscrypt_servers' "${PROTO_DNSCRYPT}"

        change_config 'doh_servers' "${PROTO_DOH}"

        change_config 'require_dnssec' "${REQUIRE_DNSSEC}"

        change_config 'require_nolog' "${REQUIRE_NOLOG}"

        change_config 'require_nofilter' "${REQUIRE_NOFILTER}"

        change_config 'fallback_resolver' "'${FALLBACK_RESOLVER}'"

        change_config 'listen_addresses' "${LISTEN_ADDRESSES}"

    else
        echo "Config auto regeneration on boot disabled."
    fi
else
    echo "File not exist!! <${CONFIG_ORIGINAL}>"
fi

exec /app/dnscrypt-proxy -config ${CONFIG_FILE}