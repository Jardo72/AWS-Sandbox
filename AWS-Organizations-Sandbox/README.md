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

## Scenarios
For all scenarios documented below, all operations were tested with an IAM user having AdministratorAccess (arn:aws:iam::aws:policy/AdministratorAccess) within the tested AWS account.

### Scenario #1: FullAWSAccess Everywhere Down the Hierarchy (TODO)
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU                  | Applied SCP(s) | Parent OU         |
| ------------------- | -------------- | ----------------- |
| Root                | FullAWSAccess  |                   |
| SANDBOX-LEVEL1-OU   | FullAWSAccess  | Root              |
| SANDBOX-LEVEL2-OU   | FullAWSAccess  | SANDBOX-LEVEL1-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               | Allowed         |
| Create a new S3 bucket               | Allowed         |
| Launch a new EC2 instance (t2.micro) | Allowed         |
| Launch a new EC2 instance (t2.nano)  | Allowed         |
| Display all IAM users                | Allowed         |
| Create a new IAM user                | Allowed         |

### Scenario #2: FullAWSAccess Only Inherited from Root (TODO)
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU                  | Applied SCP(s) | Parent OU         |
| ------------------- | -------------- | ----------------- |
| Root                | FullAWSAccess  |                   |
| SANDBOX-LEVEL1-OU   |                | Root              |
| SANDBOX-LEVEL2-OU   |                | SANDBOX-LEVEL1-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               |                 |
| Create a new S3 bucket               |                 |
| Launch a new EC2 instance (t2.micro) |                 |
| Launch a new EC2 instance (t2.nano)  |                 |
| Display all IAM users                |                 |
| Create a new IAM user                |                 |

### Scenario #3: FullAWSAccess Assigned Only Directly (TODO)
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU                  | Applied SCP(s)        | Parent OU         |
| ------------------- | --------------------- | ----------------- |
| Root                |                       |                   |
| SANDBOX-LEVEL1-OU   |                       | Root              |
| SANDBOX-LEVEL2-OU   | FullAWSAccess         | SANDBOX-LEVEL1-OU |

The following table summarizes the outcome of experimental testing of access.
| Operation                            | Access          |
| ------------------------------------ | --------------- |
| Display all S3 buckets               |                 |
| Create a new S3 bucket               |                 |
| Launch a new EC2 instance (t2.micro) |                 |
| Launch a new EC2 instance (t2.nano)  |                 |
| Display all IAM users                |                 |
| Create a new IAM user                |                 |

### Scenario #4: 
