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
- Make sure that terraform currently uses you cso.joonix.net credentals
  - Run the following command line to set the credentials  
<pre>  gcloud auth application-default login </pre> 
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

## Step 2 : Scripts to run from the GCP console on your migrate-xx project (to_run_on_gcp_pso_lab folder)  

### Prerequisites  
- Have a 'Migrate Tool with vCenter - 7 Day Lease' environment provisioned from the [PSO lab portal](https://vra-02.cso.joonix.net/vcac/)  
- Perform the steps 1 and 2 from the [Migrate test bed setup doc](https://www.google.com/url?q=https://docs.google.com/document/d/1TA7bKs9JXpo4dP9TvX9lgzD85OJ77bsNkM_dA-tdEvE/edit?usp%3Dsharing&sa=D&source=editors&ust=1634745752792000&usg=AOvVaw3bzyE4XFZYTixnXhwmHVLu)  
- Make sure that terraform currently uses you cso.joonix.net credentals
  - Run the following command line to set the credentials  
<pre>  gcloud auth application-default login </pre> 
- Run the following command lines  
  - terraform init  
  - terraform plan  
  - terraform apply  
### Execution 
- Fill a terraform.tfvars with the following values  
<pre>
migrate_gcp_project_id="migrate-xx-yy"      # The GCP project ID you are currently using  
mtb_number = "xx"                           # The MTB number  
cso_lab_subnet = "migrate-aa-bb"            # The name of the subnet that matches with your MTB number / Pick from migrate-00-24 , migrate-25-49, migrate-50-74, migrate-75-99  

my_network_project = "net-hub-project-nnnn"  # The name of the network hub project provisioned in the step 1 above
my_network = "hub-network"                   # The name of the network provisioned in the step 1 above - hub-network  
</pre> 

- Run the following command lines  
  - terraform init  
  - terraform plan  
  - terraform apply  
  
The terraform script will create a network , peered with the network created in step 1 and a vpngw GCE VM that will act as a network gateway with the on premise pso lab network 

## Step 3 : Finalize the peering connection from your org (to_run_on_your_org folder)  
### Execution 
- Add the variables *mtb_project* and *mtb_network* to the tvfars file you used in your own org  
<pre>
parent_type = "folders"  
parent_id = "00000000000000"  
billing_acccount = "XXXXXX-YYYYYY-ZZZZZZ"  
mtb_project = "migrate-xx-yyyy"            # the ID of the GCP project used in the step 2
mtb_network = "migrate-network"     # the name of the network provisionned above - it should be migrate-network
</pre> 
- Make sure that terraform currently uses you cso.joonix.net credentals
  - Run the following command line to set the credentials  
<pre>  gcloud auth application-default login </pre> 
- Run the following command lines  
  - terraform init  
  - terraform plan  
  - terraform apply  