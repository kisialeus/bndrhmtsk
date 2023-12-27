resource "aws_ecr_repository" "ecr_repository" {
  for_each = toset(var.ecr_repositories)
  name = lower("${var.application}-${each.key}")
}
