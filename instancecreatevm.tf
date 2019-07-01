resource "vsphere_virtual_machine" "simple" {
  # Number of VMs to create
  count           = "${length(var.vm-names)}"
  # pulls name from a map
  name            = "${lookup(var.vm-names, count.index)}"
  # number of VCPUs
  vcpu            = "${var.vm-vcpu}"
  # Ram to assign in MB
  memory          = "${var.vm-mem}"

  # VM Location configuration, must exist
  folder          = "${var.project}"
  datacenter      = "${var.datacenter}"
  cluster         = "${var.cluster}"
  resource_pool   = "${var.cluster}/Resources/${var.project}"

  # DNS configuration for VM
  domain          = "${var.domain}"
  dns_suffixes    = "${var.dns_suffixes}"
  dns_servers     = "${var.dns_servers}"
  
  # Network configuration
  network_interface {
    label               = "${var.net_label}"
    # Perform lookup of IP address based on "ips" hash
    ipv4_address        = "${lookup(var.ips, count.index)}"
    ipv4_prefix_length  = "${var.net_prefix}"
    ipv4_gateway        = "${var.gateway}"
  }

  # VM Disk Configuration
  disk {
    datastore           = "${var.datastore}"
    # Assumes your template is located in the "Templates" folder, adjust as appropriate.
    template            = "Templates/${var.template}"
    type                = "${var.disk-type}"
  }

  # Chef configuration
  provisioner "chef" {
    environment         = "${var.chef-environment}"
    run_list            = "${var.chef-run_list}"
    server_url          = "${var.chef-server_url}"
    attributes_json     = "${var.chef-attributes_json}"
    recreate_client     = true
    # Node name should be FQDN in Chef
    node_name           = "${lookup(var.vm-names, count.index)}.${var.domain}"

    user_name           = "${var.chef-user_name}"
    # Assumes your chef private key is in ~/.chef/ directory
    user_key            = "${file("~/.chef/${var.chef-user_name}.pem")}"
    # Disable SSL verification since we're using self signed certs on the Chef server.
    ssl_verify_mode     = "${var.chef-ssl_verify_mode}"
    # Chef client version
    version             = "${var.chef-client_version}"
    # Connection to VM information, 
    connection {
      user              = "${var.vm-initial_user}"
      password          = "${var.vm-initial_password}"
    }
  }
}
