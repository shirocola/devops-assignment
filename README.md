**Candidate Assignment Instructions:**

The sample application is developed using Go. Our development team would like to deliver this application to Production. As a DevOps engineer, you are responsible to complete the tasks by following these key areas: High Availability, Scalability, Security.

**Task:**

1. Create a Dockerfile for a given application

**Expected Output:** Dockerfile

2. Build the image using the Dockerfile and push to Docker Hub

**Expected Output:** Build and push command and Docker Hub url

3. Create a Kustomize manifest to deploy the image from the previous step. The Kustomize should have flexibility to allow Developer to adjust values without having to rebuild the Kustomize frequently

**Expected Output:** Kustomize manifest file to deploy the application

4. Setup GKE cluster with the related resources to run GKE like VPC, Subnets, etc. by following GKE Best Practices using any IaC tools (Terraform, OpenTufo, Pulumi) (Bonus point: use Terraform/Terragrunt)

**Expected Output:** IaC code

* Condition: Avoid injecting the generated GCP access keys to the application directly. **Expected Output:** Kustomize manifest, IaC code or anything to complete this task.

6. Use ArgoCD to deploy this application. To follow GitOps practices, we prefer to have an ArgoCD application defined declaratively in a YAML file if possible.

**Expected output:** Yaml files and instruction how to deploy the application or command line

7. Create CICD workflow using GitOps pipeline to build and deploy application **Expected output:** GitOps pipeline (Github, Gitlab, Bitbucket, Jenkins) workflow or diagram


_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

# Step To Setup And Deploy

## Step 1: Configure GCP

1. **Create a GCP Project**
    - Navigate to the [Google Cloud Console](https://console.cloud.google.com/).
    - **Create a New Project**:
        - Click on the project drop-down in the top navigation bar and select **New Project**.
        - Fill in the project name and organization (if applicable), then click **Create**.

2. **Enable Required APIs**
    - In the Google Cloud Console, navigate to **APIs & Services > Library**.
    - Enable the following APIs:
        - Kubernetes Engine API
        - Cloud Build API (if applicable for CI/CD)
        - Container Registry API (if using Google Container Registry)
        - Secret Manager API
        - Cloud Resource Manager API
    - Search for each API and click **Enable**.

3. **Set Up Billing**
    - Ensure that billing is enabled for your project. You can set this up in the **Billing** section of the Google Cloud Console.

4. **Create a Service Account**
    - Navigate to **IAM & Admin > Service Accounts**.
    - Click **Create Service Account**.
        - **Service Account Name**: Enter a name (e.g., GKE Admin).
        - **Service Account ID**: This will auto-generate; you can leave it as is.
        - Click **Create and Continue**.

5. **Assign Roles to Service Account**
    - Select Roles:
        - Add the following roles:
            - Kubernetes Engine Admin
            - Viewer (or more specific roles as needed)
            - Service Account User
            - Secret Manager Secret Accessor
            - Compute Admin
    - Click **Continue** and then **Done**.

6. **Generate and Download the Service Account Key**
    - Find your newly created service account in the list and click on it.
    - Navigate to the **Keys** tab and click **Add Key > Create New Key**.
    - Choose **JSON** as the key type and click **Create**.
    - Download the JSON key file. This file will be used for authentication.

7. **Go to repository cd to terraform and and run:**
    ```bash
    terraform init
    terraform apply
    ```

## Step 2: Set Up ArgoCD

1. **Install ArgoCD**
    - Fetching Kube context
        ```bash
        gcloud container clusters get-credentials <CLUSTER_NAME> --zone <CLUSTER_ZONE> --project <PROJECT_ID>
        ```
    - Use Helm (Recommended Method):
        If you have Helm installed, you can add the ArgoCD Helm repository and install it:
        ```bash
        helm repo add argo https://argoproj.github.io/argo-helm
        helm repo update
        kubectl create namespace argocd
        helm install argocd argo/argo-cd -n argocd
        ```

2. **Access ArgoCD UI**
    - To access the ArgoCD UI, you need to port-forward the service:
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

3. **Login to ArgoCD**
    - The default username is `admin`.
    - To get the initial password, run:
    ```bash
    kubectl get pods -n argocd
    ```
    - Find the ArgoCD Server pod and get the password:
    ```bash
    kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
    ```
    - Use this password to log in.

## Set Secret and Variable in GitHub Actions

- **ARGOCD_INSTALLED** - true or false
- **DOCKERHUB_TOKEN** - your Docker Hub token
- **DOCKERHUB_USERNAME** - your Docker Hub username
- **GOOGLE_APPLICATION_CREDENTIALS_JSON** - your key JSON (same as Terraform)
- **KUBECONFIG** - You can get it by going to your Cloud Shell, `cd` to `.kube`, and run:
    ```bash
    cat config | base64
    ```

## Check Web Deploy

1. Go to Cloud Shell and run:
    ```bash
    kubectl get svc -n hello-api-namespace
    ```

2. Test your service with curl:
    ```bash
    curl "http://EXTERNAL.IP/:8080?name=YourName"
    ```

## Destroy Resources

1. Go to Cloud Shell and run:
    ```bash
    gcloud compute firewall-rules delete your-firewall-rule-name --project=your-project-id
    ```

2. In the terminal, run:
    ```bash
    terraform destroy
    ```

