#!/usr/bin/env bash

echo "💻 Installing Service Mesh Operator"
oc apply -f service-mesh/namespace.yaml
oc apply -f service-mesh/operators.yaml
sleep 60
oc wait --for=condition=ready pod -l name=istio-operator -n openshift-operators --timeout=300s
oc apply -f service-mesh/smcp.yaml
oc apply -f service-mesh/smmr.yaml
sleep 10
oc wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=300s
oc wait --for=condition=ready pod -l app=istio-ingressgateway -n istio-system --timeout=300s


echo "💻 Installing Serverless Operator"
oc apply -f serverless/operator.yaml
sleep 60
oc wait --for=condition=ready pod -l name=knative-openshift -n openshift-serverless --timeout=300s
oc wait --for=condition=ready pod -l name=knative-openshift-ingress -n openshift-serverless --timeout=300s
oc wait --for=condition=ready pod -l name=knative-operator -n openshift-serverless --timeout=300s

echo "💻 Creating gateway resources"
oc apply -f service-mesh/knative-gateways.yaml

echo "💻 Creating an Knative Serving instance"
oc apply -f serverless/knativeserving-istio.yaml
oc apply -f serverless/network-policy.yaml
sleep 60
oc wait --for=condition=ready pod -l app=controller -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=autoscaler-hpa -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=domain-mapping -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=webhook -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=activator -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=autoscaler -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=net-istio-webhook -n knative-serving --timeout=300s
oc wait --for=condition=ready pod -l app=net-istio-controller -n knative-serving --timeout=300s

echo "💻 Installing cert-manager operator"
oc apply -f cert-manager/operator.yaml
sleep 60
oc wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=300s
oc wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=300s
oc wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s

echo "💻 All DONE. You can now use OpenShift Serverless!"
