variable "default" {
  type = "map"
  default = {
    "cpu"                       = 2,
    "memory"                    = 4096,
    "suffix"                    = "enwdco",
    "name_start_count"          = 1,
    "vm-initial_user"           = "silver",
    "vm-initial_password"       = "Charter1",
    "disk-type"                 = "thin",
    "add_disk_suffix"           = "disk01",
    "add_disk_type"             = "thin",
    "add_disk_controller_type"  = "scsi"
    "chef-attributes_json"      = "{}",
    "chef-client_version"       = "12.19.36",
    "chef-ssl_verify_mode"      = ":verify_none",
    "chef-skip_client_install"  = false
  }
}

variable "vms" {
  type = "list"
}

variable "depends_id" {
  type = "string"
  default = ""
}
