# vmware_vm_simple

Create a VM in VMware.  Assumes permssions to create VM.

# Usage

## Usage Example

    data "terraform_remote_state" "terraform_test" {
      backend = "consul"
      config {
        path  = "terraform_state/jenkins_packer"
        address = "consul01enwdco:8500"
      }
    }
    
    variable "vsphere_user" { type = "string" }
    variable "vsphere_password" { type = "string" }
    variable "vsphere_server" { type = "string" }
    variable "vm-initial_password" { type = "string" }
    
    provider "vsphere" {
      user                  = "${var.vsphere_user}"
      password              = "${var.vsphere_password}"
      vsphere_server        = "${var.vsphere_server}"
      allow_unverified_ssl  = "true"
    }
    
    module "vmware_simple_vm" "cluster1" {
      source = "git::http://stash.dev-charter.net/stash/scm/chef/terraform_modules.git//vmware_simple_vm"
    
      project = "Jenkins"
      vm-names = {
        "0" = "jenkins01enwdco",
      }
      vm-initial_password = "${var.vm-initial_password}"
      datacenter = "ENWDCO"
      cluster = "11_ENWDCO_PACKER_BUILD_SINGLE"
    
      datastore = "vm_nfs_delivery_vol01_aggr01"
      template = "CENTOS-7.2-x86_64"
    
      # Network Config
      dns_servers = ["172.27.2.4"]
      domain = "enwd.co.sc.charterlab.com"
    
      net_label = "VLAN201_Packer_Build"
      gateway = "172.30.126.1"
      net_prefix = "24"
      ips = {
        "0" = "172.30.126.77"
      }
    
      chef-environment = "zone-sc-dev"
      chef-run_list = ["recipe[chtr_audit_only::default]"]
      chef-server_url = "https://chef-server01enwdco.enwd.co.sc.charterlab.com/organizations/charter-lab"
      chef-user_name = "jaykroyd"
    }    




## Attributes

## TODO:

* set name using array instead of map?
