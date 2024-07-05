variable "centos_atomic_image" {
    default = "CentOS Atomic 7.1902"
}
variable "os_image" {
    type = string
}
variable "ssh_key_name" {
    default = "bootstrap"
}
variable "ssh_user_name" {
    default = "almalinux"
}
variable "network" {
    default = "backend"
}
