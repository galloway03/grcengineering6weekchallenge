# Week 1 - Create compliant s3 bucket
This Terraform module enforces SC-28, AC-3, CM-6, and AU-3 on a cloud storage bucket and emits the proof as JSON.

These are the controls that are implemented in week 1: 
| Control | Title | Description |
|---|---|---| 
| **SC-28** | Protection of Information at Rest | The primary bucket must encrypt objects by default. The log bucket too. Server-side encryption with AES-256 is enough for this week. |
| **AC-3** | Access Enforcement | Public access must be blocked on all four vectors. AWS exposes four separate flags for this, and all four have to be true. Three is not enough. They are four independent doors.|
| **CM-6** | Configuration Settings | Versioning on the primary bucket, so prior object states are recoverable and auditable. Four required tags on every taggable resource: Project, Environment, ManagedBy, ComplianceScope. The clean way to do this is the provider `default_tags` block, so you cannot forget them on a new resource.
| **AU-3** and **AU-6** | Audit record content and review | he primary bucket logs access to the dedicated log bucket. The log bucket needs ownership controls set so it can accept a log-delivery ACL before logging will work. |

For this to be successful, I had to set up an AWS account that allowed me to create S3 buckets. Then I installed Terraform and VS Code on my laptop. From there, I used the Terraform Registry to find the relevant Terraform settings for AWS. 

From there, the controls are attached to the buckets and executed. 

Once set up, I verified the controls were applied and printed the results in a JSON file. This becomes the evidence an auditor needs. 

Eventually, we will automate continuous monitoring of these controls with alerts to notify the team when something changes. 

## Tools used
  + Terraform
  + AWS CLI
  + Terraform Registry website

## Files updated/created
  + main.tf - configuration file
  + outputs.tf - expected outputs from Terraform Plan
  + variables.tf - variables used in the main file
  + verify.sh - verifies the controls are set
  + plan.json and plan-broken.json - plans that will be used throughout the challenge. Created with terraform plan
