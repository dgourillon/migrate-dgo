

#### VPC, subnet, router and cloud NAT config

module "vpc_hub" {
  source     = "./modules/net-vpc"
  project_id = module.project_network_hub.project_id
  name       = "hub-network"
  subnets = [
    {
      ip_cidr_range = "10.168.3.0/24"
      name          = "subnet-us-west2"
      region        = "us-west2"
      secondary_ip_range = {}
    }
  ]
  shared_vpc_host = true

}

module "nat_hub_us_west2" {
  source         = "./modules/net-cloudnat"
  project_id     = module.project_network_hub.project_id
  region         = "us-west2"
  name           = "nat-us-west2"
  router_network = module.vpc_hub.name
  router_create  = true
  router_asn     = 64513
}

module "vpc_spoke_prod" {
  source     = "./modules/net-vpc"
  project_id = module.project_network_spoke_prod.project_id
  name       = "spoke-prod-network"
  subnets = [
    {
      ip_cidr_range = "10.168.2.0/24"
      name          = "subnet-us-west2"
      region        = "us-west2"
      secondary_ip_range = {}
    }
  ]
  shared_vpc_host = true
  shared_vpc_service_projects = [
    module.project_app_prod.project_id
  ]
  
}

module "nat_spoke_prod_us_west2" {
  source         = "./modules/net-cloudnat"
  project_id     = module.project_network_spoke_prod.project_id
  region         = "us-west2"
  name           = "nat-us-west2"
  router_network = module.vpc_spoke_prod.name
  router_create  = true
  router_asn     = 64514
}

module "vpc_spoke_dev" {
  source     = "./modules/net-vpc"
  project_id = module.project_network_spoke_dev.project_id
  name       = "spoke-dev-network"
  subnets = [
    {
      ip_cidr_range = "10.168.4.0/24"
      name          = "subnet-us-west2"
      region        = "us-west2"
      secondary_ip_range = {}
    }
  ]
  shared_vpc_host = true
  shared_vpc_service_projects = [
    module.project_app_nonprod.project_id,
    module.project_app_dev.project_id

  ]
  
}

module "nat_spoke_dev_us_west2" {
  source         = "./modules/net-cloudnat"
  project_id     = module.project_network_spoke_dev.project_id
  region         = "us-west2"
  name           = "nat-us-west2"
  router_network = module.vpc_spoke_dev.name
  router_create  = true
  router_asn     = 64515
}

