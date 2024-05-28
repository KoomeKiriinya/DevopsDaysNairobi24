ecr_repositories = {
  example-app = {
    read_only_account_access = [
      "arn:aws:iam:{example-dev-account-id}:root",
    ]
  }
}

public_ecr_repositories = {
  alpine-mysql = {

  }
}