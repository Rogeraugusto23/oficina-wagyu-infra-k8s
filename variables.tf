variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo da instância EC2. O AWS Academy Learner Lab costuma restringir os tipos permitidos (geralmente t2.*/t3.micro/small/medium) — confira a lista de tipos permitidos na página do laboratório antes de mudar."
  type        = string
  default     = "t2.medium"
}

variable "key_pair_name" {
  description = "Nome do par de chaves EC2 já existente na conta, para acesso SSH"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorizado a acessar via SSH (restrinja para o seu IP em produção)"
  type        = string
  default     = "0.0.0.0/0"
}
