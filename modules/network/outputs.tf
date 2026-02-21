output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "pods_range_name" {
  description = "Name of the secondary IP range for pods"
  value       = var.pods_range_name
}

output "services_range_name" {
  description = "Name of the secondary IP range for services"
  value       = var.services_range_name
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value       = google_compute_router_nat.nat.name
}

output "private_vpc_connection_id" {
  description = "The ID of the VPC peering connection"
  value       = google_service_networking_connection.private_vpc_connection.id
}
