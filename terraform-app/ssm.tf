resource "aws_ssm_parameter" "mongo_uri" {
  name        = "/devops-sandbox/backend/MONGO_URI"
  description = "The connection string for the MongoDB database"

  type  = "SecureString"
  value = "mongodb://mongodb.devops.local:27017/dev-resource-tracker"
}
