data "openstack_networking_network_v2" "public" {
    name = "${var.network}"
}
