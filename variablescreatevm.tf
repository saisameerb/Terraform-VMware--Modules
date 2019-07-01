# vsphere configuration
variable "datacenter" { type = "string" }
variable "cluster" { type = "string" }

# name of "project" - to be used for folder and resource pool.
# must exist.
variable "project" { 
  description = "name of 'project' - to be used for folder and resource pool."
  type = "string" 
}

# VM Configuration
variable "vm-names" {
  description = "map of names of VMs"
  type = "map"
}
variable "vm-vcpu" { default = 2 }
variable "vm-mem" { default = 4096 }
variable "vm-initial_password" { type = "string" }
variable "vm-initial_user" { type = "string" default = "root" }

# DNS configuration
variable "domain" { type = "string" }
variable "dns_servers" { type = "list" } 
variable "dns_suffixes" { 
  type = "list" 
  default = [
    "enwd.co.sc.charterlab.com",
    "enwd.co.ss.charterlab.com",
    "charterlab.com"
  ]
}

# Disk/Machine information
variable "datastore" { type = "string" }
variable "disk-type" { type = "string" default = "thin" }
variable "template" { type = "string" }

# Network configuration
variable "net_label" { type = "string" }
variable "gateway" { type = "string" }
variable "net_prefix" { type = "string" }

## This assumes you are creating 3 VMs, adjust count accordingly
variable "ips" { type = "map" }

# Chef Configuration
variable "chef-environment" { type = "string" }
variable "chef-run_list" { type = "list" }
variable "chef-attributes_json" { type = "string" default = "{}" }
variable "chef-server_url" { type = "string" }
variable "chef-user_name" { type = "string" }
# need to find a workaround for this.
#variable "chef-user_key_path" { default = "~/.chef/${var.chef-validation_client_name}.pem" }
variable "chef-client_version" { type = "string" default = "12.19.36" }
variable "chef-ssl_verify_mode" { default = ":verify_none" }

