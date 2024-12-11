

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_ec2_snapshot_manager"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# IAM Policy for EC2 Full Access
resource "aws_iam_policy" "ec2_full_access" {
  name        = "EC2FullAccess"
  description = "Provides full access to EC2 resources"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
    ]
  })
}

# IAM Policy for Snapshot Full Access
resource "aws_iam_policy" "snapshot_full_access" {
  name        = "SnapshotFullAccess"
  description = "Provides full access to EBS snapshots"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
    ]
  })
}

# Attach Policies to Role
resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  policy_arn = aws_iam_policy.ec2_full_access.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "attach_snapshot_policy" {
  policy_arn = aws_iam_policy.snapshot_full_access.arn
  role       = aws_iam_role.lambda_role.name
}
resource "aws_s3_bucket" "firsbu" {
  bucket = "terraform-tf-bucket"
}

resource "aws_lambda_function" "snapshot_manager" {
  function_name    = "SnapshotManagerFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  
  s3_bucket        = "terraform-tf-bucket" 
  s3_key           = "path/to/lambda_function.zip" 
}

# Output the Lambda Function ARN
output "lambda_function_arn" {
  value = aws_lambda_function.snapshot_manager.arn
}
