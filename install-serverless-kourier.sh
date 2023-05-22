#!/usr/bin/env bash

export KUBECONFIG=/Users/rlehmann/code/retocode/devcluster/dev/auth/kubeconfig

echo "💻 Installing Serverless Operator"
oc apply -f serverless/operator.yaml
sleep 60
oc wait --for=condition=ready pod -l name=knative-openshift -n openshift-serverless --timeout=300s
oc wait --for=condition=ready pod -l name=knative-openshift-ingress -n openshift-serverless --timeout=300s
oc wait --for=condition=ready pod -l name=knative-operator -n openshift-serverless --timeout=300s

echo "💻 Creating an Knative instance"
oc apply -f serverless/knativeserving-kourier.yaml
sleep 60
oc wait --for=condition=ready pod -l app=controller -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=autoscaler-hpa -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=domain-mapping -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=webhook -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=activator -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=autoscaler -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=net-kourier-controller -n knative-serving-ingress --timeout=300s
oc wait --for=condition=ready pod -l app=3scale-kourier-gateway -n knative-serving-ingress --timeout=300s

echo "💻 Installing cert-manager operator"
oc apply -f cert-manager/operator.yaml
sleep 60
oc wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=300s
oc wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=300s
oc wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s

echo "💻 All DONE. You can now use OpenShift Serverless!"