resource "openstack_networking_network_v2" "mysql_network" {
    name            = "mysql_network"
    admin_state_up  = "true"
}

resource "openstack_networking_subnet_v2" "mysql_subnet" {
    network_id      = openstack_networking_network_v2.mysql_network.id
    cidr            = "10.1.0.0/24"
    enable_dhcp     = "false"
    no_gateway      = "true"
}

resource "openstack_networking_port_v2" "source_port" {
    network_id            = openstack_networking_network_v2.mysql_network.id
    admin_state_up        = "true"
    port_security_enabled = "false"
    fixed_ip {
        subnet_id  = openstack_networking_subnet_v2.mysql_subnet.id
        ip_address = "10.1.0.11"
    }
}

resource "openstack_networking_port_v2" "replica_port" {
    network_id            = openstack_networking_network_v2.mysql_network.id
    admin_state_up        = "true"
    port_security_enabled = "false"
    fixed_ip {
        subnet_id  = openstack_networking_subnet_v2.mysql_subnet.id
        ip_address = "10.1.0.12"
    }
}

resource "openstack_networking_port_v2" "chef_zero" {
    name            = "chef_zero"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.public.id
}

resource "openstack_compute_instance_v2" "chef_zero" {
    name            = "chef-zero"
    image_name      = var.docker_image
    flavor_name     = "m2.local.2c3m10d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.chef_zero.all_fixed_ips.0
    }
    network {
        port = openstack_networking_port_v2.chef_zero.id
    }
    provisioner "remote-exec" {
        inline = [
            "until [ -S /var/run/docker.sock ] ; do sleep 1 && echo 'docker not started...' ; done",
            "sudo docker run -d -p 8889:8889 --name chef-zero osuosl/chef-zero"
        ]
    }
    provisioner "local-exec" {
        command = "rake knife_upload"
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
}

resource "openstack_networking_port_v2" "source_server" {
    name            = "source_server"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.public.id
}

resource "openstack_blockstorage_volume_v3" "source_boot_volume" {
    size            = var.disk_size
    image_id        = data.openstack_images_image_v2.os_image.id
}

resource "openstack_compute_instance_v2" "source" {
    name            = "source"
    image_name      = var.os_image
    flavor_name     = "m2.4c4m50d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.source_server.all_fixed_ips.0
    }
    block_device {
        uuid                    = openstack_blockstorage_volume_v3.source_boot_volume.id
        source_type             = "volume"
        destination_type        = "volume"
        boot_index              = 0
        delete_on_termination   = true
    }
    network {
        port = openstack_networking_port_v2.source_server.id
    }
    network {
        port = openstack_networking_port_v2.source_port.id
    }
    provisioner "remote-exec" {
        inline = ["echo online"]
    }
}

resource "null_resource" "source" {
    provisioner "local-exec" {
        command = <<-EOF
            knife bootstrap -c test/chef-config/knife.rb \
                ${var.ssh_user_name}@${openstack_compute_instance_v2.source.network.0.fixed_ip_v4} \
                -y -N source --secret-file test/integration/encrypted_data_bag_secret \
                --sudo --bootstrap-version ${var.chef_version} \
                -r 'recipe[multi_node_test::source],role[mysql-vip]'
            EOF
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
    depends_on = [
        openstack_compute_instance_v2.source
    ]
}

resource "openstack_networking_port_v2" "replica_server" {
    name            = "replica_server"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.public.id
}

resource "openstack_blockstorage_volume_v3" "replica_boot_volume" {
    size            = var.disk_size
    image_id        = data.openstack_images_image_v2.os_image.id
}

resource "openstack_compute_instance_v2" "replica" {
    name            = "replica"
    image_name      = var.os_image
    flavor_name     = "m2.4c4m50d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    depends_on      = [openstack_compute_instance_v2.source]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.replica_server.all_fixed_ips.0
    }
    block_device {
        uuid                    = openstack_blockstorage_volume_v3.replica_boot_volume.id
        source_type             = "volume"
        destination_type        = "volume"
        boot_index              = 0
        delete_on_termination   = true
    }
    network {
        port = openstack_networking_port_v2.replica_server.id
    }
    network {
        port = openstack_networking_port_v2.replica_port.id
    }
    provisioner "remote-exec" {
        inline = ["echo online"]
    }
}

resource "null_resource" "replica" {
    provisioner "local-exec" {
        command = <<-EOF
            knife bootstrap -c test/chef-config/knife.rb \
                ${var.ssh_user_name}@${openstack_compute_instance_v2.replica.network.0.fixed_ip_v4} \
                -y -N replica --secret-file test/integration/encrypted_data_bag_secret \
                --sudo --bootstrap-version ${var.chef_version} \
                -r 'recipe[multi_node_test::replica],role[mysql-vip]'
            EOF
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
    depends_on = [
        null_resource.source,
        openstack_compute_instance_v2.replica
    ]
}
