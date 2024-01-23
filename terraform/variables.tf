variable "pingfederate_username" {
  type        = string
  description = "The username for the PingFederate admin API"
  default     = "administrator"
}

variable "pingfederate_password" {
  type        = string
  description = "The password for the PingFederate admin API"
  default     = "2FederateM0re"
}

variable "pingfederate_https_host" {
  type        = string
  description = "The PingFederate admin API host"
  default     = "https://localhost:9999"
}

variable "pingfederate_insecure_trust_all_tls" {
  type        = bool
  description = "Whether to trust all TLS certificates"
  default     = true
}

variable "pingfederate_x_bypass_external_validation_header" {
  type        = bool
  description = "Whether to bypass external validation"
  default     = true
}
