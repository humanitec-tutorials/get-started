# Create a project
resource "platform-orchestrator_project" "get_started" {
  id = "get-started"
}

# Create an environment type
resource "platform-orchestrator_environment_type" "get_started_development" {
  id = "get-started-development"
}

# Create an environment "development" in the project "get-started"
resource "platform-orchestrator_environment" "development" {
  id          = "development"
  project_id  = platform-orchestrator_project.get_started.id
  env_type_id = platform-orchestrator_environment_type.get_started_development.id
}