#!/bin/sh
set -e
# check whether an env exists
check_sc_env_exist() {
    if [ -z "$CSE_REGISTRY_ADDR" ]; then
        /bin/echo "Please export CSE_REGISTRY_ADDR=http(s)://ip:port"
        exit 1
    fi
}

check_cc_env_exist() {
    if [ -z "$CSE_CONFIG_CENTER_ADDR" ]; then
        /bin/echo "WARNING: Please export CSE_CONFIG_CENTER_ADDR=http(s)://ip:port"
    fi
}

check_metric_env_exist() {
    if [ -z "CSE_MONITOR_SERVER_ADDR" ]; then
        /bin/echo "WARNING: Please export CSE_MONITOR_SERVER_ADDR=http(s)://ip:port"
    fi
}

check_AKSK_env_exist(){
    if [ -z "$ACCESS_KEY" ]; then
        /bin/echo "Please export ACCESS_KEY"
        exit 1
    fi
    if [ -z "$SECRET_KEY" ]; then
        /bin/echo "Please export SECRET_KEY"
        exit 1
    fi
}

check_SC_type(){
    local_SC="http://ServiceCenter:30100"
    if [ "$CSE_REGISTRY_ADDR" != "$local_SC" ]; then
        /bin/echo "Service center is not running locally: AKSK required"
        check_AKSK_env_exist
        cd /opt/mesher
        sed -i s/"accessKey:.*"/"accessKey: $ACCESS_KEY"/g conf/chassis.yaml
        sed -i s/"secretKey:.*"/"secretKey: $SECRET_KEY"/g conf/chassis.yaml
    else
        cd /opt/mesher
        ./wait_for_sc.sh
    fi
        
}

check_config_files(){
    # configs can be mounted, maybe config map
    if [ -f "/tmp/mesher.yaml" ]; then
        echo "mesher config exists"
        cp -f  /tmp/mesher.yaml /etc/mesher/conf/mesher.yaml
    fi
    copy_tmp2mesher chassis.yaml
    copy_tmp2mesher microservice.yaml
    copy_tmp2mesher circuit_breaker.yaml
    copy_tmp2mesher load_balancing.yaml
    copy_tmp2mesher monitoring.yaml
    copy_tmp2mesher lager.yaml
    copy_tmp2mesher rate_limiting.yaml
    copy_tmp2mesher tls.yaml
    copy_tmp2mesher auth.yaml
    copy_tmp2mesher tracing.yaml
}
copy_tmp2mesher(){
    tmp="/tmp"
    mesher_conf="/opt/mesher/conf"
    if [ -f $tmp/$1 ]; then
        echo "$1 exists"
        cp -f $tmp/$1 $mesher_conf/$1
    fi
}
# //////////////////////////////////////////////////////////////////////////// #
#                               go sdk                                         #
# //////////////////////////////////////////////////////////////////////////// #
check_sc_env_exist
check_SC_type
check_cc_env_exist
check_metric_env_exist

check_config_files

listen_addr=$(ifconfig eth0 | grep -E 'inet\W' | grep -o -E [0-9]+.[0-9]+.[0-9]+.[0-9]+ | head -n 1)
advertise_addr=$listen_addr

cd /opt/mesher
# replace ip addr
sed -i s/"listenAddress:\s\{1,\}[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}"/"listenAddress: $listen_addr"/g conf/chassis.yaml
sed -i s/"advertiseAddress:\s\{1,\}[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}"/"advertiseAddress: $advertise_addr"/g conf/chassis.yaml
mesher_outcome_handler="bizkeeper-consumer,loadbalance"
if [ "$SERVICE_NAME" = "mesher" ]; then
    if [ -z "$OUTCOME_HANDLER" ]; then
        sed -i s/"outcome:.*"/"outcome: $mesher_outcome_handler"/g conf/chassis.yaml
    else
        sed -i s/"outcome:.*"/"outcome: $OUTCOME_HANDLER"/g conf/chassis.yaml
    fi
else
    echo "Running as Side Car"
    if [ ! -z "$INCOME_HANDLER" ]; then
        sed -i s/"income:.*"/"income: $INCOME_HANDLER"/g conf/chassis.yaml
    fi
    if [ ! -z "$OUTCOME_HANDLER" ]; then
        sed -i s/"outcome:.*"/"outcome: $OUTCOME_HANDLER"/g conf/chassis.yaml
    fi
fi;

service_name=${SERVICE_NAME:-hellomesher}
service_version=${VERSION:-0.1}
application=${APP_ID:-default}

/bin/echo "service name/version/appid: $service_name/$service_version/$application"
if [[ -z "$SERVICE_NAME" && -z $VERSION && -z $APP_ID ]]; then
    /bin/echo "If you want to change service info, set env: SERVICE_NAME/VERSION/APP_ID"
fi

cat << EOF > /opt/mesher/conf/microservice.yaml
APPLICATION_ID: $application
service_description:
  name: $service_name
  version: $service_version
  properties:
    allowCrossApp: true
EOF

# ENABLE_PROXY_TLS decide whether mesher is https proxy or http proxy
if [[ $TLS_ENABLE && $TLS_ENABLE == true ]]; then
    sed -i '/ssl:/a \ \ mesher.provider.cipherPlugin: default \n \ mesher.provider.verifyPeer: false \n \ mesher.provider.cipherSuits: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 \n \ mesher.provider.protocol: TLSv1.2 \n \ mesher.provider.caFile: \n \ mesher.provider.certFile: /etc/ssl/meshercert/kubecfg.crt \n \ mesher.provider.keyFile: /etc/ssl/meshercert/kubecfg.key \n \ mesher.provider.certPwdFile: \n' conf/chassis.yaml
fi

./mesher --config /etc/mesher/conf/mesher.yaml
