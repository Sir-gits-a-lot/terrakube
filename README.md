# infra-asssignment
Kubernetes manifests for running two different applications in a minikube cluster exposing them using an ingress controller and Terraform manifests to automate the provioning and management of the same infra setup.

# Steps to reproduce in local minikube based environment

1. Create a minikube cluster 
minikube start

2. Navigate to kube_manifests directory and apply all the manifests
cd kube_manifests

kubectl apply -f .

3. Check the status of the pods, you should see 2 blue-app and 3 green-app pods running respectively.  

kubectl get pods -A

4. In another terminal, run this command minikube tunnel. In cloud provider environment external LB will be provisioned but in local minikube environment, it's a handy utility. Otherwise, Terraform will keep on trying to create the helm chart as the provider is written in a way to check for External IP.

minikube tunnel

5. For infrastructure automation Stretch Goal, navigate to iac dirrectory and run the following commands and let terraform do it's magic

terraform init
terraform plan -out=tfplan
terraform apply tfplan


6. Access the services by making curl requests

curl -H "Host: www.example.io"  http://<EXTERNAL_IP>

6. After the verification of all the resources, remember to destroy them

terraform destroy
