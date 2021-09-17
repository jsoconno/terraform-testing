variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(string)
}