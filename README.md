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

6. **Authentication Using Workload Identity Federation**

   1. **Set Up Workload Identity Pool**
      - In the **Google Cloud Console**, navigate to **IAM & Admin > Workload Identity Federation**.
      - Click on **Create Pool**.
      - Name your pool (e.g., `github-actions-pool`), and add a description.
      - Click **Continue**.

   2. **Create an OIDC Provider in the Pool**
      - Select the newly created Workload Identity Pool and click **Add Provider**.
      - Choose **OIDC** as the identity provider type.
      - For **Provider ID**, enter a unique name (e.g., `github-provider`).
      - Under **Issuer URI**, use the GitHub Actions OIDC URI:
        ```
        https://token.actions.githubusercontent.com
        ```
      - In the **Attribute Mapping** section, set `google.subject` to map to the GitHub claim `assertion.sub`:
        ```
        google.subject: "assertion.sub"
        ```
      - Optionally, add a condition to restrict which GitHub repositories can authenticate. For example, to restrict access to a specific repository:
        ```
        assertion.repository == "<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>"
        ```
      - Click **Save**.

   3. **Link the Service Account to the Workload Identity Pool**
      - In the **Google Cloud Console**, navigate to **IAM & Admin > Service Accounts**.
      - Select the service account you created for GitHub Actions (e.g., `github-actions-sa`).
      - Under **IAM & Admin > IAM**, add the following role to the service account if not already assigned:
        - `roles/iam.workloadIdentityUser` on the Workload Identity Pool. The member should be in the format:
        ```
        serviceAccount:<YOUR_PROJECT_ID>.svc.id.goog[gcp-project-id/service-account-id]
        ```
      - Verify the service account has the necessary permissions for your GCP resources.

   4. **Configure GitHub Actions**
      - Update your GitHub Actions workflow to use the workload identity provider instead of a JSON key file.
      - Use the following configuration in your workflow:

      ```yaml
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          workload_identity_provider: "projects/${{ secrets.GCP_PROJECT_NUMBER }}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
          service_account: "github-actions-sa@${{ secrets.GCP_PROJECT_ID }}.iam.gserviceaccount.com"
      ```

   5. **Set Up GitHub Secrets**
      - In your GitHub repository, go to **Settings > Secrets and variables > Actions**.
      - Add secrets for `GCP_PROJECT_ID` and `GCP_PROJECT_NUMBER` if they are not already present.


    1. ***Set Up Workload Identity Pool**
    - In the **Google Cloud Console**, navigate to **IAM & Admin > Workload Identity Federation**.
    - Click on **Create Pool**.
    - Name your pool (e.g., `github-actions-pool`), and add a description.
    - Click **Continue**.

    2. ***Create an OIDC Provider in the Pool**
    - Select the newly created Workload Identity Pool and click **Add Provider**.
    - Choose **OIDC** as the identity provider type.
    - For **Provider ID**, enter a unique name (e.g., `github-provider`).
    - Under **Issuer URI**, use the GitHub Actions OIDC URI:
        ```
        https://token.actions.githubusercontent.com
        ```
    - In the **Attribute Mapping** section, set `google.subject` to map to the GitHub claim `assertion.sub`:
        ```
        google.subject: "assertion.sub"
        ```
    - Optionally, add a condition to restrict which GitHub repositories can authenticate. For example, to restrict access to a specific repository:
        ```
        assertion.repository == "<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>"
        ```
    - Click **Save**.

    3. ***Link the Service Account to the Workload Identity Pool**
    - In the **Google Cloud Console**, navigate to **IAM & Admin > Service Accounts**.
    - Select the service account you created for GitHub Actions (e.g., `github-actions-sa`).
    - Under **IAM & Admin > IAM**, add the following role to the service account if not already assigned:
        - `roles/iam.workloadIdentityUser` on the Workload Identity Pool. The member should be in the format:
        ```
        serviceAccount:<YOUR_PROJECT_ID>.svc.id.goog[gcp-project-id/service-account-id]
        ```
    - Verify the service account has the necessary permissions for your GCP resources.

    4. ***Configure GitHub Actions**
    - Update your GitHub Actions workflow to use the workload identity provider instead of a JSON key file.
    - Use the following configuration in your workflow:

    ```yaml
    - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
        workload_identity_provider: "projects/${{ secrets.GCP_PROJECT_NUMBER }}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
        service_account: "github-actions-sa@${{ secrets.GCP_PROJECT_ID }}.iam.gserviceaccount.com"
    
    5. ***Set Up GitHub Secrets
        In your GitHub repository, go to Settings > Secrets and variables > Actions.
        Add secrets for GCP_PROJECT_ID and GCP_PROJECT_NUMBER if they are not already present.

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

