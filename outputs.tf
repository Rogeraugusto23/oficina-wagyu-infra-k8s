output "instance_public_ip" {
  description = "IP público da instância EC2 rodando o K3s"
  value       = aws_instance.k3s_node.public_ip
}

output "ssh_command" {
  description = "Comando para acessar via SSH"
  value       = "ssh -i <sua-chave.pem> ubuntu@${aws_instance.k3s_node.public_ip}"
}

output "fetch_kubeconfig_command" {
  description = "Comando para buscar o kubeconfig do K3s e ajustar o endereço do servidor"
  value       = "scp -i <sua-chave.pem> ubuntu@${aws_instance.k3s_node.public_ip}:/etc/rancher/k3s/k3s.yaml ./kubeconfig && sed -i 's/127.0.0.1/${aws_instance.k3s_node.public_ip}/' ./kubeconfig"
}

output "api_url" {
  description = "URL de acesso à API da aplicação (após deploy do NodePort)"
  value       = "http://${aws_instance.k3s_node.public_ip}:30080"
}
