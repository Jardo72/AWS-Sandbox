# AWS Organizations Sandbox

## Introduction
Collection of AWS Organizations Service Control Policies and test scenarios demonstrating how access can be restricted for AWS Organizations member accounts.

## Service Control Policies
The following table describes the custom SCPs used during the experiments.
| SCP               | Description                           |
| ----------------- | ------------------------------------- |
| [AllowAllS3Operationsn](./AllowAllS3Operations.json)  | Allows all S3 operations for any resource |
| [DenyAllS3Operationsn](./DenyAllS3Operations.json)    | Denies all S3 operations for any resource |
| [DenyAllIAMOperations](./DenyAllIAMOperations.json)   | Denies all IAM operations for any resource |

## Scenarios
TODO:
- all operations tested with an IAM user having AdministratorAccess (arn:aws:iam::aws:policy/AdministratorAccess) within the tested AWS account

### Scenario #1: FullAWSAccess Everywhere Down the Hierarchy
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU                  | Applied SCP(s)        | Parent OU         |
| ------------------- | --------------------- | ----------------- |
| Root                | FullAWSAccess         |                   |
| SANDBOX-LEVEL1-OU   | FullAWSAccess         | Root              |
| SANDBOX-LEVEL2-OU   | FullAWSAccess         | SANDBOX-LEVEL1-OU |

The following table summarizes 
| Operation          | Access Decision |
| ------------------ | --------------- |
|                    |                 |

### Scenario #2: FullAWSAccess Inherited from Root
The following table summarizes the hierarchy of organizational units (OUs) and the SCPs applied to particular OUs.
| OU                  | Applied SCP(s)        | Parent OU         |
| ------------------- | --------------------- | ----------------- |
| Root                | FullAWSAccess         |                   |
| SANDBOX-LEVEL1-OU   |                       | Root              |
| SANDBOX-LEVEL2-OU   |                       | SANDBOX-LEVEL1-OU |

### Scenario #3: 
