output "arn" {
  value       = aws_sns_topic.topic.arn
  description = "The ARN of the created SNS topic"
}