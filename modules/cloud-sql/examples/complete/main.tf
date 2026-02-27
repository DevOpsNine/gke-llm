module "cloud_sql" {
  source = "../../"

  project_id    = "example-project-id"
  region        = "us-central1"
  network_id    = "projects/example-project-id/global/networks/example-vpc"
  instance_name = "example-postgres-db"

  database_version = "POSTGRES_15"
  tier             = "db-f1-micro"

  db_name = "app_db"
  db_user = "app_user"
  # In a real environment, you should use a secret manager
  db_password = "super-secret-password-123!"

  labels = {
    environment = "dev"
    team        = "database"
  }
}
