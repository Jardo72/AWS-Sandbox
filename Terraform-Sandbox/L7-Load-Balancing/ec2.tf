resource "aws_iam_role" "ec2_iam_role" {
  name = "SSMParameterReaderRole"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowEC2Assume",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })

  /* TODO: remove or adapt to what is really needed
  inline_policy {
    name = "SSMParameterValueReadAccess"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Sid : "AllowGetParameter",
          Action : ["ssm:GetParameter"]
          Effect : "Allow"
          Resource : format("arn:aws:ssm:%s:%s:parameter%s", local.aws_region, data.aws_caller_identity.current_account.account_id, local.ssm_parameter_name)
        }
      ]
    })
  } */

  # needed in order to be able to connect to the instance via the Session Manager
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  ]

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "ssm_parameter_reader_profile" {
  name = "SSMParameterReaderProfile"
  role = aws_iam_role.ec2_iam_role.name
  tags = local.common_tags
}
