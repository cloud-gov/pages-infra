resource "aws_sqs_queue" "queue" {
  kms_master_key_id = "alias/aws/sqs"

  tags = var.tags
}

data "aws_iam_policy_document" "queue-policy-document" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.queue.arn
    ]
  }
}

resource "aws_iam_policy" "queue-policy" {
  description = "SQS Queue Policy"
  policy      = data.aws_iam_policy_document.queue-policy-document.json
}

resource "aws_iam_user" "queue-user" {
  name = var.aws_user_name

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "queue-user-policy-attach" {
  user       = aws_iam_user.queue-user.name
  policy_arn = aws_iam_policy.queue-policy.arn
}

resource "aws_iam_access_key" "queue-user-access-key" {
  user = aws_iam_user.queue-user.name
}

resource "cloudfoundry_user_provided_service" "queue-credentials" {
  name  = var.service_name
  space = var.space
  credentials = {
     access_key = aws_iam_access_key.queue-user-access-key.id
     region     = var.aws_region
     secret_key = aws_iam_access_key.queue-user-access-key.secret
     sqs_url    = aws_sqs_queue.queue.id
  }
}