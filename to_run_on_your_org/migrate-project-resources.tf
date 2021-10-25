provider "google" {
  user_project_override = true
  region  = "us-west2"
  project = var.migrate_gcp_project_id
}


resource "google_compute_network" "migrate-network" { 
name = "migrate-network" 
auto_create_subnetworks = false
routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "us-west2-subnet" {
  name          = "us-west2-subnet"
  ip_cidr_range = "10.168.0.0/24"
  region        = "us-west2"
  network       = google_compute_network.migrate-network.id
  private_ip_google_access = true
}

data "template_file" "vpngw_startup_script" {
  template = "${file("./vpngw_startup.tpl")}"
  vars = {
    mtb_number = var.mtb_number
  }
}

resource "google_compute_instance" "vpngw" {
  name         = "vpngw"
  machine_type = "n1-standard-1"
  zone         = "us-west2-a"
  can_ip_forward = true
  tags = ["allow-ssh-public"]
  boot_disk {
    initialize_params {
      image = "cso-lab-environments/vpngw"
    }
  }
  network_interface {
    subnetwork   = "projects/cso-lab-environments/regions/us-west2/subnetworks/${var.cso_lab_subnet}"
  }
  network_interface {
    subnetwork   = google_compute_subnetwork.us-west2-subnet.id
  }
  metadata_startup_script = data.template_file.vpngw_startup_script.rendered
}

resource "google_compute_route" "route-to-onprem-1" {
  name        = "route-to-onprem-1"
  dest_range  = "10.0.10.0/24"
  network     = google_compute_network.migrate-network.name
  next_hop_instance = google_compute_instance.vpngw.self_link
  next_hop_instance_zone = "us-west2-a"
}

resource "google_compute_route" "route-to-onprem-2" {
  name        = "route-to-onprem-2"
  dest_range  = "172.16.0.0/16"
  network     = google_compute_network.migrate-network.name
  next_hop_instance = google_compute_instance.vpngw.self_link
  next_hop_instance_zone = "us-west2-a"
}

resource "google_compute_route" "route-to-onprem-3" {
  name        = "route-to-onprem-3"
  dest_range  = "169.254.2.0/30"
  network     = google_compute_network.migrate-network.name
  next_hop_instance = google_compute_instance.vpngw.self_link
  next_hop_instance_zone = "us-west2-a"
}

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = google_compute_network.migrate-network.name
  allow {
    protocol = "all"
  }
  source_ranges = ["10.0.0.0/8","172.0.0.0/8","169.254.2.0/30"]
}

resource "google_compute_firewall" "allow-iap" {
  name    = "allow-iap"
  network = google_compute_network.migrate-network.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow-egress" {
  name    = "allow-egress-all"
  network = google_compute_network.migrate-network.name
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_router" "default-router" {
  name    = "default-nat-router"
  network = google_compute_network.migrate-network.name
  region = "us-west2"
  bgp {
    asn               = 4200000001
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "default-router-nat"
  router                             = google_compute_router.default-router.name
  region                             = google_compute_router.default-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_project_metadata" "default" {
  metadata = {
    serial-port-enable  = "TRUE"
    apply-alias-ip-ranges = "true"
    
  }
}

