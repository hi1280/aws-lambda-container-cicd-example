resource "aws_iam_role" "iam_for_codebuild" {
  name               = "iam_for_codebuild"
  path               = "/service-role/"
  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOS
}

resource "aws_iam_policy" "iam_for_codebuild" {
  name   = "iam_for_codebuild"
  path   = "/service-role/"
  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "sts:GetCallerIdentity",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode"
      ]
    }
  ]
}
EOS
}

resource "aws_iam_role_policy_attachment" "iam_for_codebuild" {
  role       = aws_iam_role.iam_for_codebuild.name
  policy_arn = aws_iam_policy.iam_for_codebuild.arn
}

resource "aws_codebuild_project" "aws_lambda_container_cicd_example" {
  name         = local.function_name
  service_role = aws_iam_role.iam_for_codebuild.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE",
    ]
    type = "LOCAL"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "https://github.com/hi1280/${local.function_name}"
    report_build_status = false
    type                = "GITHUB"
    git_submodules_config {
      fetch_submodules = false
    }
  }
}

resource "aws_codebuild_webhook" "aws_lambda_container_cicd_example" {
  project_name = aws_codebuild_project.aws_lambda_container_cicd_example.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH, PULL_REQUEST_MERGED"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "refs/heads/master"
    }
  }
}