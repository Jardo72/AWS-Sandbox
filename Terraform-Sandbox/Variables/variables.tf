variable "dummy_string" {
  description = "Dummy variable of type string"
  type = string
}

variable "dummy_number" {
  description = "Dummy variable of type number"
  type = number
}

variable "dummy_bool" {
  description = "Dummy variable of type bool"
  type = bool
}

variable "dummy_string_list" {
  description = "Dummy variable of type list of string(s)"
  type = list(string)
}

variable "dummy_number_list" {
  description = "Dummy variable of type list of number(s)"
  type = list(number)
}

variable "dummy_object" {
  description = "Dummy variable of type object"
  type = object({
    cidr = string
    az_index = number
  })
}
