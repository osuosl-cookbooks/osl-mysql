data "openstack_networking_network_v2" "public" {
    name = "${var.network}"
}

data "openstack_images_image_v2" "os_image" {
    name        = var.os_image
    most_recent = true
}
