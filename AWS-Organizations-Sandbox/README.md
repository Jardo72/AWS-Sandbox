# AWS Organizations Sandbox

## Introduction
Collection of AWS Organizations Service Control Policies and test scenarios demonstrating how access can be restricted for AWS Organizations member accounts.

## Service Control Policies
The following table describes the custom SCPs used during the experiments.
| SCP               | Description                           |
| ----------------- | ------------------------------------- |
|                   | [](./)                                |
|                   | [](./)                                |
|                   | [](./)                                |

## Scenarios

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
