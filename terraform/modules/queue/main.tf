terraform {
  required_version = "~> 0.13.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.5.0"
    }

    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }
  }
}

resource "aws_sqs_queue" "queue" {
  name              = "${var.name_prefix}-sqs"
  kms_master_key_id = "alias/aws/sqs"

  tags = var.tags
}

data "aws_iam_policy_document" "queue_policy_document" {
  statement {
    sid = "AllowReadingAndWritingMessages"

    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]

    effect = "Allow"

    resources = [aws_sqs_queue.queue.arn]
  }
}

resource "aws_iam_policy" "queue_policy" {
  description = "SQS Queue Policy"
  policy      = data.aws_iam_policy_document.queue_policy_document.json
}

resource "aws_iam_user" "queue_user" {
  name = "${var.name_prefix}-sqs-user"

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "queue_user_policy_attach" {
  user       = aws_iam_user.queue_user.name
  policy_arn = aws_iam_policy.queue_policy.arn
}

resource "aws_iam_access_key" "queue_user_access_key" {
  user = aws_iam_user.queue_user.name
}

resource "cloudfoundry_user_provided_service" "queue_credentials" {
  name  = "${var.name_prefix}-sqs-creds"
  space = var.space
  credentials = {
    access_key = aws_iam_access_key.queue_user_access_key.id
    region     = var.aws_region
    secret_key = aws_iam_access_key.queue_user_access_key.secret
    sqs_url    = aws_sqs_queue.queue.id
  }
}

resource "aws_cloudwatch_metric_alarm" "queue_alarm" {
  alarm_name          = "${var.name_prefix}-queue-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "900"
  statistic           = "Average"
  threshold           = "60"
  treat_missing_data  = "ignore"

  alarm_description = "This metric monitors sqs message delays"
  alarm_actions     = [var.sns_topic]
  ok_actions        = [var.sns_topic]

  tags = var.tags
}

resource "aws_sns_topic_policy" "queue_alarm_sns_topic_policy" {
  arn = var.sns_topic

  policy = data.aws_iam_policy_document.queue_alarm_sns_topic_policy_document.json
}

data "aws_iam_policy_document" "queue_alarm_sns_topic_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "AllowCloudwatchEvents"

    actions = ["SNS:Publish"]

    effect = "Allow"

    resources = [var.sns_topic]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}