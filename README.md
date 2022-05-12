# Azure Functions custom handlers
This sample demonstrates how to use [Azure functions custom handlers](https://docs.microsoft.com/en-us/azure/azure-functions/functions-custom-handlers) to run a PHP script with a [custom container](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image?tabs=in-process%2Cbash%2Cazure-cli&pivots=programming-language-other) running on function.

![azure-functions-custom-handlers-overview](https://user-images.githubusercontent.com/94471999/168082793-74ab6685-b99c-49f4-9b8f-eeb448c41349.png)


# Timer Trigger Function

In this sample we use a timer trigger function to run on a schedule and execute a PHP script. This script will query a SQL database and read data from it. The output of the function will be a message created in a queue.
