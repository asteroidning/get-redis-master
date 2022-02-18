#! /bin/bash

# 获取redis master
set -x
MASTER="${MASTER:-"test"}"
NAMESPACE="${NAMESPACE:-"default"}"
RELEASE="${RELEASE:-"cache-redis"}"
REDIS_SVC="${REDIS_SVC:-""}"
MASTER_GROUP_NAME="${MASTER_GROUP_NAME:-""}"
SLEEP_TIME="${SLEEP_TIME:-"10"}"

#每次重新启动都会清除当前带有role=master的redis pod的label
INIT_MASTER_LABEL_NAME=$(/usr/bin/kubectl get pod -n ${NAMESPACE} --show-labels -o wide | grep 'role=master' | grep "release=${RELEASE}" | awk '{print $1}')
/usr/bin/kubectl label pods $INIT_MASTER_LABEL_NAME -n ${NAMESPACE} role- >/dev/null 2>&1

#创建只转发redis master的svc
kubectl get svc -n ${NAMESPACE} ${RELEASE}-master
if [ "$?" -ne 0 ]; then
    /usr/bin/kubectl create service clusterip ${RELEASE}-master --tcp=6379:6379 -n ${NAMESPACE}
    kubectl patch svc -n ${NAMESPACE} ${RELEASE}-master --type='json' -p '[{"op":"replace","path":"/spec/selector","value":{"role":"master","release":'${RELEASE}'}}]'
fi

while [ "1" = "1" ]; do
    REDIS_MASTER_SVC_IP=$(redis-cli -h ${REDIS_SVC} -p 26379 sentinel get-master-addr-by-name ${MASTER_GROUP_NAME} | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
    REDIS_MASTER_SVC_NAME=$(/usr/bin/kubectl get svc -n ${NAMESPACE} | grep $REDIS_MASTER_SVC_IP | awk '{print $1}')
    REDIS_MASTER_POD_NAME=$(/usr/bin/kubectl get svc -n ${NAMESPACE} -o yaml $REDIS_MASTER_SVC_NAME | grep 'statefulset.kubernetes.io/pod-name' | awk '{print $2}' | tail -1)
    if [ "$MASTER" != "$REDIS_MASTER_POD_NAME" ]; then
        /usr/bin/kubectl label pods ${MASTER} -n ${NAMESPACE} role- >/dev/null 2>&1
    fi
    MASTER=${REDIS_MASTER_POD_NAME}
    #给master pod添加一个label
    /usr/bin/kubectl label pod ${MASTER} -n ${NAMESPACE} role=master >/dev/null 2>&1
    sleep ${SLEEP_TIME}
done
