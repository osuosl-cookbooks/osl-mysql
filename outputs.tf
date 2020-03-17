output "chef_zero" {
    value = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
}
output "master" {
    value = "${openstack_compute_instance_v2.master.network.0.fixed_ip_v4}"
}
output "slave" {
    value = "${openstack_compute_instance_v2.slave.network.0.fixed_ip_v4}"
}
