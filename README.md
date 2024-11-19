# Steps to Setup and Deploy

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
    - Add the following roles:
        - Kubernetes Engine Admin
        - Viewer
        - Service Account User
        - Secret Manager Secret Accessor
        - Compute Admin
    - Click **Continue** and then **Done**.

6. **Authentication Using Workload Identity Federation**
    - Follow these steps:

      1. **Set Up Workload Identity Pool**
          - Navigate to **IAM & Admin > Workload Identity Federation**.
          - Click **Create Pool**.
          - Name your pool (e.g., `github-actions-pool`) and add a description.
          - Click **Continue**.

      2. **Create an OIDC Provider in the Pool**
          - Select the newly created Workload Identity Pool and click **Add Provider**.
          - Choose **OIDC** as the identity provider type.
          - Use the following values:
            - **Issuer URI**: `https://token.actions.githubusercontent.com`
            - **Attribute Mapping**:
              ```
              google.subject: "assertion.sub"
              ```
          - Optionally, restrict access by adding a condition:
            ```
            assertion.repository == "<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>"
            ```

      3. **Link the Service Account**
          - In **IAM & Admin > Service Accounts**, select your service account.
          - Assign the `roles/iam.workloadIdentityUser` role for the Workload Identity Pool.

      4. **Configure GitHub Actions**
          - Use the following GitHub Actions step to authenticate with GCP:
            ```yaml
            - name: Authenticate to Google Cloud
              uses: google-github-actions/auth@v1
              with:
                workload_identity_provider: "projects/${{ secrets.GCP_PROJECT_NUMBER }}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
                service_account: "github-actions-sa@${{ secrets.GCP_PROJECT_ID }}.iam.gserviceaccount.com"
            ```

7. **Deploy Using Terraform**
    ```bash
    terraform init
    terraform apply
    ```

## Step 2: Set Up ArgoCD

1. **Install ArgoCD**
    ```bash
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    kubectl create namespace argocd
    helm install argocd argo/argo-cd -n argocd
    ```

2. **Access ArgoCD UI**
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

3. **Login to ArgoCD**
    ```bash
    kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
    ```

## Set GitHub Actions Secrets

- **`ARGOCD_INSTALLED`**: `true` or `false`
- **`DOCKERHUB_TOKEN`**: Your Docker Hub token
- **`DOCKERHUB_USERNAME`**: Your Docker Hub username
- **`KUBECONFIG`**: Encoded Kubernetes config:
    ```bash
    cat ~/.kube/config | base64
    ```

## Destroy Resources

```bash
terraform destroy
