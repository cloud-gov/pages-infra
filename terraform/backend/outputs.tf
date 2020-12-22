output "backend_user_access_key" {
  value = aws_iam_access_key.terraform_backend_user_access_key.id
}

output "backend_user_secret" {
  value = aws_iam_access_key.terraform_backend_user_access_key.secret
}