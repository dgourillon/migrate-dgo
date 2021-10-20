# Connect a pso lab to your organization

This repository contains terraform an shell scripts to connect a pso lab with your org, using peering from your migrate-xx project as a gateway .  

Please follow the following steps to do so  

## Step 1 : Scripts to run under your organization (to_run_on_your_org folder)  

### Prerequisites  
- Create an empty folder in your organization  
- Please make sure your cso.joonix.net credentials has the folder editor rights there  
### Execution 
- Fill a terraform.tfvars with the following values  
<pre>
parent_type = "folders"  
parent_id = "00000000000000"  # ID of the folder you created above  
billing_acccount = "XXXXXX-YYYYYY-ZZZZZZ"  # Billing account of your org  
</pre> 
- Run the following command lines  
  - terraform init  
  - terraform plan  
  - terraform apply  
The terraform script will create the following resources, and a set of network with no IP overlap with the ranges used on premise.  
<pre>
         psolab-target (top folder) 
         ├── apps  
         │   ├── dev  
         │   │   └── GCP project for migrated dev applications  
         │   ├── nonprod  
         │   │   └── GCP project for migrated for nonprod applications  
         │   └── prod  
         │       └── GCP project for migrated for prod applications  
         ├── network  
         │   ├── GCP project for the Hub network  
         │   ├── GCP project for the Dev/Nonprod network  (linked to the hub through vpn)  
         │   └── GCP project for the prod network  (linked to the hub through vpn)  
         └── migrate  
             └──  GCP project for the M4CE resources  
</pre> 