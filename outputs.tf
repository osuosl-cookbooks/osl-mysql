output "chef_zero" {
    value = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
}
output "source" {
    value = "${openstack_compute_instance_v2.source.network.0.fixed_ip_v4}"
}
output "replica" {
    value = "${openstack_compute_instance_v2.replica.network.0.fixed_ip_v4}"
}
