output "assume_role_arn" {
  value       = aws_iam_role.terraform_user_role.arn
  description = "ARN of role to assume."
}