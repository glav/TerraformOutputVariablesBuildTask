# Terraform Output variables build task for Azure DevOps

This task is a very crude and simple task to take the 'outputs' of a terraform apply operation, and make these into environment variables that can be used within Azure DevOps Pipelines.

Note: This task assumes (and relies on) the fact that a previous marketplace task has already been run to install and execute a set of Terraform templates. This task has only been tested with [this](https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Release-Terraform#overview) Terraform task. 

### Operation
The above noted terraform task has an option to install the Terraform tooling which it typically does in: 
```c#
c:\terraform-download\
```
This task first checks for that location and if exists, runs the Terraform tool from there, othewise it just runs terraform without any path assuming it will be on the searchable paths.

Apart from that, the only important item to ensure is correct is the path. This path should be the one that the templates reside in as terraform will be run in that directory, and the outputs extracted from there.

### Using the variables
When executing the terraform command (which is what this task does):
```
c:\> terraform output
```
you will receive output similar to the following, based on what outputs you have defined within your terraform templates:
```
app_id = 12345678-1234-4321-1cba-4321abcd1234
some_access_key = WPD+s1234987HJ+bvx==
```
This task will take those outputs and creates environment variables of the same name but with a prefix of 'TF_'. So with the examples given above, they would be converted into the following environment variables:
```
TF_APP_ID = 12345678-1234-4321-1cba-4321abcd1234
TF_SOME_ACCESS_KEY = WPD+s1234987HJ+bvx==
````
These can then be used in Azure DevOps pipelines build/deployment tasks using syntax like:
```
$(TF_APP_ID)
$(TF_SOME_ACCESS_KEY)
```
