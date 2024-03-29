# AWS Organizations Sandbox

## Introduction
Collection of AWS Organizations Service Control Policies and test scenarios demonstrating how access can be restricted for AWS Organizations member accounts.

## Service Control Policies
The following table describes the custom SCPs used during the experiments.
| SCP                                                  | Description                                                                |
| ---------------------------------------------------- | -------------------------------------------------------------------------- |
| [AllowAllS3Operations](./AllowAllS3Operations.json)  | Allows all S3 operations for any resource                                  |
| [DenyAllS3Operations](./DenyAllS3Operations.json)    | Denies all S3 operations for any resource                                  |
| [DenyAllIAMOperations](./DenyAllIAMOperations.json)  | Denies all IAM operations for any resource                                 |
| [RestrictEC2ToT2Micro](./RestrictEC2ToT2Micro.json)  | Allows all EC2 operations, but only t2.micro instance type can be launched |

Besides the custom SCPs listed above, the AWS managed FullAWSAccess SCP is used as well.

## Scenarios
For all scenarios documented below, all operations were tested with an IAM user having AdministratorAccess (arn:aws:iam::aws:policy/AdministratorAccess) within the tested AWS account.

### Scenario #1: FullAWSAccess Everywhere Down the Hierarchy
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs and the test account.
| OU/AWS Account      | Applied SCP(s) | Parent OU         |
| ------------------- | -------------- | ----------------- |
| Root                | FullAWSAccess  |                   |
| SANDBOX-LEVEL1-OU   | FullAWSAccess  | Root              |
| SANDBOX-LEVEL2-OU   | FullAWSAccess  | SANDBOX-LEVEL1-OU |
| AWS account         | FullAWSAccess  | SANDBOX-LEVEL2-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               | Allowed         |
| Create a new S3 bucket               | Allowed         |
| Launch a new EC2 instance (t2.micro) | Allowed         |
| Launch a new EC2 instance (t2.nano)  | Allowed         |
| Display all IAM users                | Allowed         |
| Create a new IAM user                | Allowed         |

### Scenario #2: Reduced Access SCP Attached to Direct Parent OU, FullAWSAccess Attached to AWS Account
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs and the test account.
| OU/AWS Account      | Applied SCP(s)                             | Parent OU         |
| ------------------- | ------------------------------------------ | ----------------- |
| Root                | FullAWSAccess                              |                   |
| SANDBOX-LEVEL1-OU   | FullAWSAccess                              | Root              |
| SANDBOX-LEVEL2-OU   | AllowAllS3Operations, RestrictEC2ToT2Micro | SANDBOX-LEVEL1-OU |
| AWS account         | FullAWSAccess                              | SANDBOX-LEVEL2-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               | Allowed         |
| Create a new S3 bucket               | Allowed         |
| Launch a new EC2 instance (t2.micro) | Allowed         |
| Launch a new EC2 instance (t2.nano)  | Denied          |
| Display all IAM users                | Denied          |
| Create a new IAM user                | Denied          |

### Scenario #3: Reduced Access SCP Attached to Indirect Parent OU, FullAWSAccess Attached to AWS Account
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU/AWS Account      | Applied SCP(s)       | Parent OU         |
| ------------------- | -------------------- | ----------------- |
| Root                | FullAWSAccess        |                   |
| SANDBOX-LEVEL1-OU   | RestrictEC2ToT2Micro | Root              |
| SANDBOX-LEVEL2-OU   | FullAWSAccess        | SANDBOX-LEVEL1-OU |
| AWS account         | FullAWSAccess        | SANDBOX-LEVEL2-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               | Denied          |
| Create a new S3 bucket               | Denied          |
| Launch a new EC2 instance (t2.micro) | Allowed         |
| Launch a new EC2 instance (t2.nano)  | Denied          |
| Display all IAM users                | Denied          |
| Create a new IAM user                | Denied          |

### Scenario #4: Explicit Deny of Certain Service in Direct Parent OU
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU/AWS Account      | Applied SCP(s)       | Parent OU         |
| ------------------- | -------------------- | ----------------- |
| Root                | FullAWSAccess        |                   |
| SANDBOX-LEVEL1-OU   | FullAWSAccess        | Root              |
| SANDBOX-LEVEL2-OU   | DenyAllIAMOperations | SANDBOX-LEVEL1-OU |
| AWS account         | FullAWSAccess        | SANDBOX-LEVEL2-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               | Denied          |
| Create a new S3 bucket               | Denied          |
| Launch a new EC2 instance (t2.micro) | Denied          |
| Launch a new EC2 instance (t2.nano)  | Denied          |
| Display all IAM users                | Denied          |
| Create a new IAM user                | Denied          |

### Scenario #5: FullAWSAccess Everywhere Down the Hierarchy Combined with Explicit Deny of Certain Service in Direct Parent OU
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU/AWS Account      | Applied SCP(s)                      | Parent OU         |
| ------------------- | ----------------------------------- | ----------------- |
| Root                | FullAWSAccess                       |                   |
| SANDBOX-LEVEL1-OU   | FullAWSAccess                       | Root              |
| SANDBOX-LEVEL2-OU   | FullAWSAccess, DenyAllIAMOperations | SANDBOX-LEVEL1-OU |
| AWS account         | FullAWSAccess                       | SANDBOX-LEVEL2-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               | Allowed         |
| Create a new S3 bucket               | Allowed         |
| Launch a new EC2 instance (t2.micro) | Allowed         |
| Launch a new EC2 instance (t2.nano)  | Allowed         |
| Display all IAM users                | Denied          |
| Create a new IAM user                | Denied          |

### Scenario #6: Excplicit Deny in Indirect Parent OU "Overwritten" by Allow in Direct Parent OU
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU/AWS Account      | Applied SCP(s)       | Parent OU         |
| ------------------- | -------------------- | ----------------- |
| Root                | FullAWSAccess        |                   |
| SANDBOX-LEVEL1-OU   | DenyAllS3Operations  | Root              |
| SANDBOX-LEVEL2-OU   | AllowAllS3Operations | SANDBOX-LEVEL1-OU |
| AWS account         | FullAWSAccess        | SANDBOX-LEVEL2-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               | Denied          |
| Create a new S3 bucket               | Denied          |
| Launch a new EC2 instance (t2.micro) | Denied          |
| Launch a new EC2 instance (t2.nano)  | Denied          |
| Display all IAM users                | Denied          |
| Create a new IAM user                | Denied          |
