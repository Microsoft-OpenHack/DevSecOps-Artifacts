# DevSecOps OpenHack Light deployment script

This script deploys and configures all the resources your team will need in order to complete the challenges during the OpenHack. These resources:

* **Deployed to Opsgility Subscription**
  * Azure Key Vault
  * Azure Container Registry
  * App Service
  * App Service Plan
  * Virtual Machine running Aqua

* **Deployed to Microsoft Azure DevOps Organization (<https://dev.azure.com/DevSecOpsOH>)**
  * Azure DevOps Project

## How to deploy lab env

### High Level Overview

1. Az Login to Opsgility subscription

2. Provision Azure Resources in Opsgility subscription

3. Az Login using your Microsoft Account

4. Provision Azure DevOps resources

5. Save your work

### 1. Az Login to Opsgility Subscription

Using the one of the credentials provided by Opsgility, execute an AZ Login (For testing you can either your internal subscription or MSDN subscription)

```bash
#For OpsGility use
az login -u <username> -p '<password>'

#For Internal or MSDN use (Will take you to browser to complete sign-in)
az login
```

### 2. Provision the Azure Resources in Opsgility subscription

This assumes you are in the root of repo.

```bash
cd script
./provision_azure_resources.sh -l westus -t <teamNumber>
```

Once this script completes, two files will be present in the scripts directory. They are acr.json and subscription.json. These files contain information needed during the provisioning of DevOps resources in step 4. Do not delete them. Keeping a copy of these files after the provisioning has completed will save time during some of the challenges by making information quickly available to the team.

### 3. Az login to your MSFT Account

Once you have provisioned the infrastructure, you will need to do a second az login to login with your Microsoft Account.

``` Bash
az login #should open a browser where you can sign-in with your MSFT account.

#If you have multiple subscriptions, you need to set the correct subscription.
az account list
az account set -s <subscription id>

az account show
```

### 4. Prepare Personal Access Token (PAT) for Azure DevOps

Personal Access Token is required to configure Git repo for OpenHack challenges. To get PAT, please follow below steps:

1. Go to [https://dev.azure.com/DevSecOpsOH/_usersSettings/tokens](https://dev.azure.com/DevSecOpsOH/_usersSettings/tokens), and click **New Token**.

1. Fill out Name for your token (e.g. DevSecOps - code full), and select **Full** under **Code** section.

    ![PAT create](images/PatCreate.png)

1. Save your Token for later use in the next section (5. Deploy Azure DevOps project).

    ![PAT OK](images/PatCreateOk.png)

### 5. Deploy Azure DevOps project

Finally, provision the DevOps project by running the script below. You will pass the same team number, a **comma-separated list** of emails for users that should be provisioned into the project, and PAT created in previous section.

```bash
bash provision_devops.sh -u <Comma separated usernames> -t <teamNumber> -s '<personalAccessToken>'
```

Example: Provision the project for Volker Will and Richard Guthrie who are in team 1

```bash
bash provision_devops.sh -u teamMember1@microsoft.com,teamMember2@microsoft.com -t 1 -s 'lqqmlixfx5sgfsfguu7bhsv5uggsdhjfkuhkhlljlkh2yyfgklsa'
```

### 6. Save your work

Keep the `<teamName>_subscription.json` and `<teamName>_acr.json` files you will need them in Challenge 1.
