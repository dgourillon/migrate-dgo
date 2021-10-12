

module  "top_folder" {
  source = "./modules/terraform-google-folders"

  parent            = "${var.parent_type}/${var.parent_id}"
  names             = ["psolab-target"]
  set_roles         = false
}

module  "folder_1" {
  source = "./modules/terraform-google-folders"

  parent            = module.top_folder.ids_list[0]
  names             = ["migrate","network","apps"]
  set_roles         = false
}

module  "folder_apps" {
  source = "./modules/terraform-google-folders"

  parent            = module.folder_1.ids_list[2]
  names             = ["prod","nonprod","dev"]
  set_roles         = false
}

