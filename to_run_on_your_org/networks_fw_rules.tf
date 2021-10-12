
# Firewall rules for the hub VPC 

module "firewall_hub" {
  source       = "./modules/net-vpc-firewall"
  project_id   =  module.project_network_hub.project_id
  network      =  module.vpc_hub.name
  admin_ranges_enabled = true
  admin_ranges = ["10.0.0.0/8","172.0.0.0/8","169.254.0.0/16"]
  custom_rules = {
    allow-iap = {
      description          = "ranges allowed for IAP"
      direction            = "INGRESS"
      action               = "allow"
      sources              = []
      ranges               = ["35.235.240.0/20"]
      targets              = []
      use_service_accounts = false
      rules                = [{ protocol = "tcp", ports = [22,3389,80,443] }]
      extra_attributes     = {}
    }
  }
}

resource "google_compute_firewall" "allow_egress_hub" {
  name      = "allow-all-egress"
  network   = module.vpc_hub.name
  project   =  module.project_network_hub.project_id
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
}

# Firewall rules for the prod spoke VPC 
module "firewall_spoke_prod" {
  source       = "./modules/net-vpc-firewall"
  project_id   =  module.project_network_spoke_prod.project_id
  network      =  module.vpc_spoke_prod.name
  admin_ranges_enabled = true
  admin_ranges = ["10.0.0.0/8","172.0.0.0/8","169.254.0.0/16"]
  custom_rules = {}
}

resource "google_compute_firewall" "allow_egress_spoke_prod" {
  name      = "allow-all-egress"
  network   = module.vpc_spoke_prod.name
  project   =  module.project_network_spoke_prod.project_id
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
}

# Firewall rules for the dev spoke VPC 
module "firewall_spoke_dev" {
  source       = "./modules/net-vpc-firewall"
  project_id   =  module.project_network_spoke_dev.project_id
  network      =  module.vpc_spoke_dev.name
  admin_ranges_enabled = true
  admin_ranges = ["10.0.0.0/8","172.0.0.0/8","169.254.0.0/16"]
}

resource "google_compute_firewall" "allow_egress_spoke_dev" {
  name      = "allow-all-egress"
  network   =  module.vpc_spoke_dev.name
  project   =  module.project_network_spoke_dev.project_id
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
}
