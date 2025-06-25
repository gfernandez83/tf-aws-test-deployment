data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "ecs:ExecuteCommand",
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:ecs:*:*:cluster/*",
      "arn:aws:ecs:*:*:task/*/*",
    ]
  }
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "iam:PassRole",  
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs-task-policy" {
  name        = "ecs-task-policy"
  description = "ECS Task Policy"
  policy      = data.aws_iam_policy_document.ecs_task_policy.json
}

data "aws_iam_policy_document" "ecs-task-trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = aws_iam_policy.ecs-task-policy.arn
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-trust.json
}
