

### VPN Hub -> Spoke prod

module "vpn_hub_to_prod" {
  source           = "./modules/net-vpn-ha"
  project_id       = module.project_network_hub.project_id
  region           = "us-west2"
  network          = module.vpc_hub.self_link
  router_create    = true
  name             = "vpn-hub-to-prod"
#  router_name      = module.nat_hub_us_west2.router_name
  router_asn       = 64515
  peer_gcp_gateway = module.vpn_prod_to_hub.self_link
  
  router_advertise_config = {
    groups = ["ALL_SUBNETS"]
    ip_ranges = {
      "172.16.10.0/24" = "onprem-range-1",
      "172.16.20.0/24" = "onprem-range-2",
      "10.0.10.0/24" = "onprem-range-3",
      "10.168.3.0/24" = "hub-range"
    }
    mode = "CUSTOM"
  }
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.1"
        asn     = 64516
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.1.2/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = ""
      vpn_gateway_interface           = 0
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.1"
        asn     = 64516
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.2.2/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = ""
      vpn_gateway_interface           = 1
    }
  }
}

module "vpn_prod_to_hub" {
  source           = "./modules/net-vpn-ha"
  project_id       = module.project_network_spoke_prod.project_id
  region           = "us-west2"
  network          = module.vpc_spoke_prod.self_link
  name             = "vpn-prod-to-hub"
  router_create    = true
  router_asn       = 64516
#  router_name      = module.nat_hub_us_west2.router_name
  peer_gcp_gateway = module.vpn_hub_to_prod.self_link
  router_advertise_config = {
    groups = ["ALL_SUBNETS"]
    ip_ranges = {
      "10.168.2.0/24" = "prod-range"
    }
    mode = "CUSTOM"
  }
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.2"
        asn     = 64515
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.1.1/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = module.vpn_hub_to_prod.random_secret
      vpn_gateway_interface           = 0
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.2"
        asn     = 64515
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.2.1/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = module.vpn_hub_to_prod.random_secret
      vpn_gateway_interface           = 1
    }
  }
}

## VPN Hub -> dev VPC


module "vpn_hub_to_dev" {
  source           = "./modules/net-vpn-ha"
  project_id       = module.project_network_hub.project_id
  region           = "us-west2"
  network          = module.vpc_hub.self_link
  router_create    = true
  name             = "vpn-hub-to-dev"
#  router_name      = module.nat_hub_us_west2.router_name
  router_asn       = 64519
  peer_gcp_gateway = module.vpn_dev_to_hub.self_link
  
  router_advertise_config = {
    groups = ["ALL_SUBNETS"]
    ip_ranges = {
      "172.16.10.0/24" = "onprem-range-1",
      "172.16.20.0/24" = "onprem-range-2",
      "10.0.10.0/24" = "onprem-range-3",
      "10.168.3.0/24" = "hub-range"
    }
    mode = "CUSTOM"
  }
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.5"
        asn     = 64518
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.1.4/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = ""
      vpn_gateway_interface           = 0
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.5"
        asn     = 64518
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.2.4/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = ""
      vpn_gateway_interface           = 1
    }
  }
}

module "vpn_dev_to_hub" {
  source           = "./modules/net-vpn-ha"
  project_id       = module.project_network_spoke_dev.project_id
  region           = "us-west2"
  network          = module.vpc_spoke_dev.self_link
  name             = "vpn-dev-to-hub"
  router_create    = true
  router_asn       = 64518
#  router_name      = module.nat_hub_us_west2.router_name
  peer_gcp_gateway = module.vpn_hub_to_dev.self_link
  router_advertise_config = {
    groups = ["ALL_SUBNETS"]
    ip_ranges = {
      "10.168.2.0/24" = "prod-range"
    }
    mode = "CUSTOM"
  }
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.6"
        asn     = 64519
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.1.4/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = module.vpn_hub_to_dev.random_secret
      vpn_gateway_interface           = 0
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.6"
        asn     = 64519
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.2.4/30"
      ike_version                     = 2
      peer_external_gateway_interface = null
      router                          = null
      shared_secret                   = module.vpn_hub_to_dev.random_secret
      vpn_gateway_interface           = 1
    }
  }
}