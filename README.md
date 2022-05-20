# Azure Functions custom handlers
This sample demonstrates how to use [Azure functions custom handlers](https://docs.microsoft.com/en-us/azure/azure-functions/functions-custom-handlers) to run a PHP script with a [custom container](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image?tabs=in-process%2Cbash%2Cazure-cli&pivots=programming-language-other) running on function.

![azure-functions-custom-handlers-overview](https://user-images.githubusercontent.com/94471999/168082793-74ab6685-b99c-49f4-9b8f-eeb448c41349.png)


# Timer Trigger Function

In this sample we use a timer trigger function to run on a schedule and execute a PHP script. This script will query a SQL database and read data from it. The output of the function will be a message that will be sent to a queue.

# To use this repository  

Clone this repository locally.

### 1. Create a service principal

You'll need to create a service principal and then assign a role on your subscription to your application so that your workflow has access to your subscription.
Create a new service principal in the Azure portal for your app. The service principal must be assigned the Contributor role. 
Run the below command in Azure CLI.

      az ad sp create-for-rbac --name "githubActions" --role contributor \
            --scopes /subscriptions/{subscription-id} \
            --sdk-auth
            
Copy the JSON object for your service principal.

     {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>",
        (...)
     }
Open your GitHub repository and go to **Settings**.
Select **Secrets** and then **New Secret** with the name `AZURE_CREDENTIALS`. Save by selecting **Add secret**.

### 2. Create SQL Server secrets

You'll need to create the following secrets for your SQL Server for the next steps.
`SQL_SERVERNAME`,`SQL_DATABASE`,`SQL_USERNAME`,`SQL_PASSWORD`.

### 3. Run GitHub Actions

Go to **Actions** tab in your repository and run **Create Azure Resources** workflow to create your resource group and all your resources in it.
Note that you can change the `DEPLOYMENT_NAME`, `RESOURCE_GROUP_NAME`, `LOCATION` in this workflow to reflect your location and naming convention.

After your resources are created, you can get the name of `AZURE_STORAGEACCOUNT_NAME` for your function, `AZURE_APPSERVICEPLAN_NAME`, `AZURE_ACR_NAME` and replace them in the deploy.yaml file in .github/workflows folder. You can run the next workflow, which is called **Deploy function with custom image** to create your function.

### 4. Update Application Settings 

You'll need to add your SQL Server information in the **Application Settings** tab of your new function in the Azure portal after it's created.
![image](https://user-images.githubusercontent.com/94471999/169546831-598e35c8-2739-4523-96c9-541658535081.png)

Add the following **Application Settings** and click **Save**.
![image](https://user-images.githubusercontent.com/94471999/169547104-47423577-a0a9-4d05-96b0-04ad0e10ab11.png)


          
