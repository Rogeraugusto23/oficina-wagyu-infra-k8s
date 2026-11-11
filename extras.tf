resource "aws_security_group_rule" "microservices" {
  type              = "ingress"
  from_port         = 30081
  to_port           = 30083
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s.id
  description       = "NodePorts dos microsservicos (OS, Billing, Execucao)"
}
