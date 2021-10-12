
resource "random_string" "random" {
  length           = 4
  special          = false
  upper          = false
}

module "project_migrate" {
  source              = "./modules/project"
  billing_account     = var.billing_acccount
  name                = "migrate-project-${random_string.random.result}"
  auto_create_network = false
  parent              = module.folder_1.ids_list[0]
  services            = [
    "compute.googleapis.com",
    "stackdriver.googleapis.com",
    "vmmigration.googleapis.com",
    "servicemanagement.googleapis.com", 
    "servicecontrol.googleapis.com" ,
    "iam.googleapis.com" ,
    "cloudresourcemanager.googleapis.com" 
  ]

}

module "project_app_dev" {
  source              = "./modules/project"
  billing_account     = var.billing_acccount
  name                = "app-dev-project-${random_string.random.result}"
  auto_create_network = false
  parent              = module.folder_apps.ids_list[2]
  services            = [
    "compute.googleapis.com",
    "stackdriver.googleapis.com"
  ]

}

module "project_app_nonprod" {
  source              = "./modules/project"
  billing_account     = var.billing_acccount
  name                = "app-nonprod-project-${random_string.random.result}"
  auto_create_network = false
  parent              = module.folder_apps.ids_list[1]
  services            = [
    "compute.googleapis.com",
    "stackdriver.googleapis.com"
  ]

}

module "project_app_prod" {
  source              = "./modules/project"
  billing_account     = var.billing_acccount
  name                = "app-prod-project-${random_string.random.result}"
  auto_create_network = false
  parent              = module.folder_apps.ids_list[0]
  services            = [
    "compute.googleapis.com",
    "stackdriver.googleapis.com"
  ]

}

module "project_network_hub" {
  source              = "./modules/project"
  billing_account     = var.billing_acccount
  name                = "net-hub-project-${random_string.random.result}"
  auto_create_network = false
  parent              = module.folder_1.ids_list[1]
  services            = [
    "compute.googleapis.com",
    "stackdriver.googleapis.com"
  ]

}

module "project_network_spoke_prod" {
  source              = "./modules/project"
  billing_account     = var.billing_acccount
  name                = "net-prod-project-${random_string.random.result}"
  auto_create_network = false
  parent              = module.folder_1.ids_list[1]
  services            = [
    "compute.googleapis.com",
    "stackdriver.googleapis.com"
  ]

}

module "project_network_spoke_dev" {
  source              = "./modules/project"
  billing_account     = var.billing_acccount
  name                = "net-nonprod-project-${random_string.random.result}"
  auto_create_network = false
  parent              = module.folder_1.ids_list[1]
  services            = [
    "compute.googleapis.com",
    "stackdriver.googleapis.com"
  ]

}