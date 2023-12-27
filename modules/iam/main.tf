resource "aws_iam_role" "ecs_task_execution_role" {
  name = lower("${var.application}-ecs-task-execution-role")
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "s3_rw_policy" {
  name        = "ecs-task-s3-rw-policy"
  description = "IAM policy for ECS tasks to access S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetBucketPolicyStatus",
          "s3:GetBucketTagging",
          "s3:ListAccessPoints",
          "s3:ListBucketVersions",
          "s3:GetBucketLogging",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketNotification",
          "s3:GetBucketPolicy",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListAllMyBuckets",
          "s3:GetBucketCORS",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${var.s3_bucket_prefix}-*/*",
        "arn:aws:s3:::${var.s3_bucket_prefix}-*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.s3_rw_policy.arn
}
