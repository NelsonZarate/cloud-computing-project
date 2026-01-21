variable "client_name" {
  description = "Nome do Cliente (ex: nike, airbnb)"
  type        = string
}

variable "environments" {
  description = "Lista de ambientes para criar neste cluster"
  type        = list(string)
  # Exemplo: ["dev", "prod"]
}