


resource "google_compute_network_peering" "peering_to_mtb" {
  name         = "mtb-myorg-peering"
  network      = module.vpc_hub.self_link
  peer_network = "projects/${var.mtb_project}/global/networks/${var.mtb_network}"
  export_custom_routes = true
  import_custom_routes = true
  export_subnet_routes_with_public_ip = false
  
}