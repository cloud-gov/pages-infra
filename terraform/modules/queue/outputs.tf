output "arn" {
  value       = aws_sqs_queue.queue.arn
  description = "The ARN of the created SQS queue"
}

output "name" {
  value       = aws_sqs_queue.queue.name
  description = "The name of the created SQS queue"
}

output "url" {
  value       = aws_sqs_queue.queue.id
  description = "The URL of the created SQS queue"
}

output "service_id" {
  value       = cloudfoundry_user_provided_service.queue_credentials.id
  description = "The guid of the created Cloud Foundry service with the IAM credentials for the created queue"
}