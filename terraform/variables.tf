variable "name" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "filename" {
  type = string
  default = "app.zip"
}

variable "description" {
  type    = string
  default = null
}

variable "handler" {
  type    = string
  default = "app.handler"
}

variable "runtime" {
  type    = string
  default = "nodejs18.x"
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "timeout" {
  default = 5
  type    = number
}

variable "tags" {
  default = {}
  type    = map(any)
}

variable "retention_in_days" {
  default = 7
  type    = number
}