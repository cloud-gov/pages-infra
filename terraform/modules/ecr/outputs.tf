output "read_key" {
  value       = aws_iam_access_key.federalist_ecr_read_access_key.id
  description = "The aws access key for the IAM user with read-only access to the ECR instance"
}

output "read_secret" {
  value       = aws_iam_access_key.federalist_ecr_read_access_key.secret
  description = "The aws secret key for the IAM user with read-only access to the ECR instance"
}

output "write_key" {
  value       = aws_iam_access_key.federalist_ecr_write_access_key.id
  description = "The aws access key for the IAM user with write-only access to the ECR instance"
}

output "write_secret" {
  value       = aws_iam_access_key.federalist_ecr_write_access_key.secret
  description = "The aws secret key for the IAM user with write-only access to the ECR instance"
}

output "account_url" {
  value       = replace(aws_ecr_repository.federalist_ecr.repository_url, "/${local.repo_name}", "")
  description = "The url of the ECR account"
}

output "repo" {
  value       = local.repo_name
  description = "The repository name of the ECR instance"
}