# challenge1

A 3 tier environment is a common setup

below image shows one of the approach for the 3 tier architecture diagram
![image](https://user-images.githubusercontent.com/10312519/201530910-1031ea64-b667-40f9-8c06-05d93aaa29b0.png)

build using teraform modules is the best approarch and reuseable of the modules.

org
utilizes gcp-org module
creates and configures:
 |--top-level folders
 |--org level iam bindings
 |--log sinks
 |--org policy definitions
 |--common org projects
 |--Security council center notification
 |--service accounts
    |--user managed key
vpcsc
utilizes vpcsc module
creates and configures VPCSC perimeter:
 perimeter spec:
 |--Perimeter Name
 |--Protected API list
 |--Access levels
 |--Egress/Ingress policies

Project Setup:
|-- projects
|  |-- your-project-name
|  |  |-- dev (Any number of environments.)
|  |      |-- terraform.tfvars
|  |  |-- prod
|  |      |-- terraform.tfvars

app-terraform
    │   main.tf
    │   outputs.tf
    │   variables.tf
    │
    ├───envs
    │   ├───dev
    │   │       backend.tf (Storage used for storing the terraform state)
    │   │       description.md
    │   │       main_dev.tf
    │   │       outputs.tf
    │   │       README.md
    │   │
    │   └───sandbox
    │           backend.tf (Storage used for storing the terraform state)
    │           main_sandbox.tf
    │           outputs.tf
    │           README.md
    │
    └───Prod
            main_Prod_dev.tf
            backend.tf (Storage used for storing the terraform state)
            outputs.tf
            README.md





