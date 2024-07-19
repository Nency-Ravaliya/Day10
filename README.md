# Application Deployment with Kubernetes and Minikube

This guide provides a step-by-step walkthrough for deploying a web application using Docker, Minikube, and Kubernetes. It includes setting up SSL certificates, configuring ingress, and performing load testing.

## Prerequisites

- Docker installed
- Minikube installed
- kubectl installed

## 1. Build and Push Docker Image

Build the Docker image and push it to your Docker registry:

```bash
docker build -t nensiravaliya28/day10:v2 .
docker push nensiravaliya28/day10:v2

##2. Start Minikube

minikube start --addons=ingress
minikube status

##3Apply Kubernetes Configurations

kubectl apply -f frontend-deployment.yaml
kubectl apply -f ingress-resource.yaml
kubectl apply -f hpa-v2.yaml

## 4. Create and Configure SSL Certificates

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out self-signed-tls.crt -keyout self-signed-tls.key \
  -subj "/CN=my-self-signed-domain.com" \
  -reqexts SAN \
  -extensions SAN \
  -config <(cat /etc/ssl/openssl.cnf \
    <(printf "[SAN]\nsubjectAltName=DNS:my-self-signed-domain.com,DNS:*.my-self-signed-domain.com"))

kubectl create secret tls self-signed-tls --key=self-signed-tls.key --cert=self-signed-tls.crt
kubectl get secrets

##5. Verify Ingress Configuration

kubectl get deployment
kubectl get ingress
kubectl apply -f ingress-resource.yaml

###Verify HTTPS connection:

curl -v https://my-self-signed-domain.com -k

##6. Load Testing
Set up Horizontal Pod Autoscaler (HPA):

kubectl autoscale deployment static-web-app --cpu-percent=50 --min=1 --max=10
kubectl get hpa
kubectl get hpa static-web-app --watch


##7. Verify SSL HTTPS Connection

curl -I http://my-self-signed-domain.com/

##8. Update Local Hosts File
Edit the /etc/hosts file:

sudo nano /etc/hosts
Add the following line:
<minikube-ip> my-self-signed-domain.com

##9. Access the Application
Open your browser and go to:

https://my-self-signed-domain.com



