 resource "aws_ecr_repository" "repos" {
  for_each             = var.ecr_repositories
  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "repos" {
  depends_on = [aws_ecr_repository.repos]

  for_each   = var.ecr_repositories
  repository = aws_ecr_repository.repos[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Effect = "Allow"
        Sid    = "ReadWOnlyECRAccess"
        Principal = {
          AWS = var.ecr_repositories[each.key].read_only_account_access
        }
      }
    ]
  })
}

resource "aws_ecrpublic_repository" "repos" {
  for_each             = var.public_ecr_repositories
  provider = aws.us_east_1

  repository_name = each.key
  catalog_data {
    about_text        = try(each.value.catalog_data.about_text, "")
    architectures     = try(each.value.catalog_data.architectures, [])
    description       = try(each.value.catalog_data.description, "")
    #logo_image_blob   = filebase64(image.png)
    operating_systems = try(each.value.catalog_data.operating_systems, [])
    #usage_text        = "Usage Text"
  }
}