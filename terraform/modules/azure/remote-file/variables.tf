#################################################
# Input variables for remote script execution
#################################################
variable "remote_host" {
  type = string
}
variable "ssh_user" {
  type = string
}
variable "private_key" {
  type = string
}
variable "file_path" {
  type = string
}
variable "executor_role" {
  type = string
}
variable "file_args" {
  type    = string
  default = ""
}
variable "execute_file" {
  type    = bool
  default = false
}
variable "wait_handle" {
  type    = any
  default = null
}
