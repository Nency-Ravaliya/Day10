# Application Deployment with Kubernetes and Minikube

This guide provides a step-by-step walkthrough for deploying a web application using Docker and Minikube. It includes setting up SSL certificates, configuring ingress, and performing load testing.

## Prerequisites

- Docker installed
- Minikube installed
- kubectl installed

## 1. Build and Push Docker Image

Build the Docker image and push it to your Docker registry:

```bash
docker build -t nensiravaliya28/day10:v2 .  ##build your own docker image for your static website
docker push nensiravaliya28/day10:v2        ##push that image to docker hub
```

## 2. Start Minikube

```
minikube start --addons=ingress
minikube status
```

## 3. Apply Kubernetes Configurations

```
kubectl apply -f frontend-deployment.yaml
kubectl apply -f ingress-resource.yaml
kubectl apply -f hpa-v2.yaml
```

## 4. Update Local Hosts File
Edit the /etc/hosts file:
```
sudo nano /etc/hosts
```
Add the following line:
```
<minikube-ip> my-self-signed-domain.com  # Add your domain name here
```

## 5. Create and Configure SSL Certificates
### It is a self-signed certificate. You can generate certificates for free.

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out self-signed-tls.crt -keyout self-signed-tls.key \
  -subj "/CN=my-self-signed-domain.com" \
  -reqexts SAN \
  -extensions SAN \
  -config <(cat /etc/ssl/openssl.cnf \
    <(printf "[SAN]\nsubjectAltName=DNS:my-self-signed-domain.com,DNS:*.my-self-signed-domain.com"))

kubectl create secret tls self-signed-tls --key=self-signed-tls.key --cert=self-signed-tls.crt
kubectl get secrets
```
## 6. Verify Ingress Configuration
```
kubectl get deployment
kubectl get ingress
kubectl apply -f ingress-resource.yaml
```
### Verify HTTPS connection:
```
curl -v https://my-self-signed-domain.com -k
curl http://host1example.com/app1
curl http://host1example.com/app2
curl http://host2example.com/app1

```
![image](https://github.com/user-attachments/assets/0b2a38dc-4f57-42b9-b06c-39fff8af451b)
![image](https://github.com/user-attachments/assets/91e62d71-5cda-4d0d-b51d-e93bf6afb6da)
![image](https://github.com/user-attachments/assets/42c043c6-0c35-4348-ad10-000a3847cd01)

## 7. Load Testing
Set up Horizontal Pod Autoscaler (HPA):

You can also generate you hpa.yaml file:
```
kubectl get hpa static-web-app -o yaml > hpa-v2.yaml #generate the hpa-v2.yaml file in your current directory.
```
Add the autoscalling and test it:
```
kubectl autoscale deployment static-web-app --cpu-percent=50 --min=1 --max=10 
kubectl get hpa
kubectl get hpa static-web-app --watch
```

![image](https://github.com/user-attachments/assets/31031a94-2b36-45df-83aa-45b51cf773cd)

## 8. Verify SSL HTTPS Connection
```
 curl my-self-signed-domain.com -L -k

```
![image](https://github.com/user-attachments/assets/4bf1b0e4-0040-4e84-b38b-c257d0ab9dc0)


## 9. Open your browser and go to:

```
https://my-self-signed-domain.com
```
![image](https://github.com/user-attachments/assets/ed279e89-d648-4f44-9980-81ba1656ee71)






