#pin the provider version
provider "vsphere" { version = "1.3.0" }

#source data module
module "data" {
  source        = "data"
  default       = "${var.default}"
  vms           = "${var.vms}"
}

resource "vsphere_virtual_machine" "addtl_disk" {
  # Number of VMs to create
  count           = "${length(var.vms)}"

  # pulls name from a map
  name            = "${lookup(var.vms[count.index], "name", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%02d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}"

  # number of VCPUs
  num_cpus        = "${lookup(var.vms[count.index], "cpu", var.default["cpu"])}"

  # Ram to assign in MB
  memory          = "${lookup(var.vms[count.index], "memory", var.default["memory"])}"
  guest_id        = "${module.data.template_guest_id}"

  # VM Location configuration, must exist
  folder            = "${lookup(var.vms[count.index], "project",  var.default["project"])}"
  datastore_id      = "${module.data.datastore_id}"
  resource_pool_id  = "${module.data.resource_pool}"

  # VM Location configuration, must exist
  folder            = "${lookup(var.vms[count.index], "project",  var.default["project"])}"
  datastore_id      = "${module.data.datastore_id}"
  resource_pool_id  = "${module.data.resource_pool}"

  # Network configuration
  network_interface {
    network_id = "${module.data.network_id}"
  }

  # VM Disk Configuration
  disk {
    datastore_id        = "${module.data.datastore_id}"
    size                = "${module.data.template_size}"
    label		= "disk0"
    unit_number		= 0
  }

  disk {
    datastore_id        = "${module.data.datastore_id}"
    size                = "${lookup(var.vms[count.index], "add_disk_size", var.default["add_disk_size"])}"
    label	        = "${lookup(var.vms[count.index], "name", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%02d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}_${lookup(var.vms[count.index], "add_disk_suffix", var.default["add_disk_suffix"])}.vmdk"
    unit_number		= 1
  }

  clone {

    template_uuid       = "${module.data.template_id}"

    customize {

      linux_options {
        host_name = "${lookup(var.vms[count.index], "host_name", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}"
        domain    = "${lookup(var.vms[count.index], "domain",  var.default["domain"])}"
      }

      dns_suffix_list     = "${split(";;", lookup(var.vms[count.index], "dns_suffix_list",  var.default["dns_suffix_list"]))}"
      dns_server_list     = "${split(";;", lookup(var.vms[count.index], "dns_server_list",  var.default["dns_server_list"]))}"

      network_interface {
        ipv4_address = "${lookup(var.vms[count.index], "ip")}"
        ipv4_netmask = "${lookup(var.vms[count.index], "net_prefix",  var.default["net_prefix"])}"
      }

      ipv4_gateway        = "${lookup(var.vms[count.index], "gateway",  var.default["gateway"])}"
    }
  }

  # Chef configuration
  provisioner "chef" {
    environment         = "${lookup(var.vms[count.index], "chef-environment",  var.default["chef-environment"])}"
    run_list            = "${split(";;", lookup(var.vms[count.index], "chef-run_list",  var.default["chef-run_list"]))}"
    server_url          = "${lookup(var.vms[count.index], "chef-server_url",  var.default["chef-server_url"])}"
    attributes_json     = "${lookup(var.vms[count.index], "chef-attributes_json",  var.default["chef-attributes_json"])}"
    recreate_client     = true
    skip_install        = "${lookup(var.vms[count.index], "chef-skip_client_install", lookup(var.default, "chef-skip_client_install", false))}"
    # Node name should be FQDN in Chef
    node_name           = "${lookup(var.vms[count.index], "name", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%02d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}.${lookup(var.vms[count.index], "domain",  var.default["domain"])}"
    # Username of user with bootstrap permissions
    user_name           = "${lookup(var.vms[count.index], "chef-user_name",  var.default["chef-user_name"])}"
    # Assumes your chef private key is in ~/.chef/ directory
    user_key            = "${file("~/.chef/${lookup(var.vms[count.index], "chef-user_name",  var.default["chef-user_name"])}.pem")}"
    # Disable SSL verification since we're using self signed certs on the Chef server.
    ssl_verify_mode     = "${lookup(var.vms[count.index], "chef-ssl_verify_mode",  var.default["chef-ssl_verify_mode"])}"
    # Chef client version
    version             = "${lookup(var.vms[count.index], "chef-client_version",  var.default["chef-client_version"])}"
    # Connection to VM information,
    connection {
      user              = "${lookup(var.vms[count.index], "vm-initial_user",  var.default["vm-initial_user"])}"
      password          = "${lookup(var.vms[count.index], "vm-initial_password",  var.default["vm-initial_password"])}"
    }
  }

  # NOPASSWD sudoers cleanup
  provisioner "remote-exec" {
    # You may choose to create this file on your template to grant temporary sudo access to a provisioning user
    inline = [
      "sudo rm -f /etc/sudoers.d/silver"
    ]
    # Connection to VM information, as above
    connection {
      user              = "${lookup(var.vms[count.index], "vm-initial_user",  var.default["vm-initial_user"])}"
      password          = "${lookup(var.vms[count.index], "vm-initial_password",  var.default["vm-initial_password"])}"
      # Evade the noexec on /tmp, as tf will cache a script to execute
      script_path = "/home/silver/provision.sh"
    }
  }
}
