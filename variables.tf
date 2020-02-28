variable "chef_version" {
    default = "14.14.29"
}
variable "centos_atomic_image" {
    default = "CentOS Atomic 7.1902"
}
variable "centos_image" {
    default = "CentOS 7.6"
}
variable "ssh_key_name" {
    default = "bootstrap"
}
variable "ssh_user_name" {
    default = "centos"
}
variable "network" {
    default = "vlan42"
}