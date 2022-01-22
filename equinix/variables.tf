variable "auth_token" {
  type = string
}

variable "project_id" {
  type = string
}

variable "hostname" {
  type = string
}

variable "plan" {
  type    = string
  default = "c3.small.x86"
}

variable "facilities" {
  type    = list(string)
  default = ["ams1"]
}

variable "operating_system" {
  type    = string
  default = "ubuntu_20_04"
}
