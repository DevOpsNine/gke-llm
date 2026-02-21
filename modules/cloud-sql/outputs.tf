output "instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.postgres.name
}

output "instance_connection_name" {
  description = "The connection name of the instance to be used in connection strings"
  value       = google_sql_database_instance.postgres.connection_name
}

output "private_ip_address" {
  description = "The private IP address assigned for the master instance"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "db_name" {
  description = "The name of the default database"
  value       = google_sql_database.database.name
}

output "db_user" {
  description = "The name of the default database user"
  value       = google_sql_user.users.name
}
