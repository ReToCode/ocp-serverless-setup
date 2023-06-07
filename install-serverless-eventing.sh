#!/usr/bin/env bash

export KUBECONFIG=/Users/rlehmann/code/retocode/devcluster/dev/auth/kubeconfig

echo "💻 Installing Strimzi Operator"
oc apply -n kafka --selector strimzi.io/crd-install=true -f kafka/strimzi-cluster-operator.yaml
oc wait crd --timeout=-1s kafkas.kafka.strimzi.io --for=condition=Established
oc apply -n kafka -f kafka/strimzi-cluster-operator.yaml

echo "💻 Installing Strimzi Cluster"
oc apply -f kafka/strimzi-cluster.yaml
oc wait kafka --all --timeout=-1s --for=condition=Ready -n kafka
oc wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka

echo "💻 Creating an Knative Eventing and Eventing Kafka instance"
oc apply -f serverless/knativeeventing.yaml
sleep 60
oc wait knativeeventing --all --timeout=-1s --for=condition=Ready -n knative-eventing

echo "💻 All DONE. You can now use OpenShift Serverless!"
