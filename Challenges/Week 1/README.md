# Week 1 - Create compliant s3 bucket
This Terraform module enforces SC-28, AC-3, CM-6, and AU-3 on a cloud storage bucket and emits the proof as JSON.

These are the controls that are implemented in week 1: 
| Control | Title | Description |
|---|---|---| 
| **SC-28** | Protection of Information at Rest | The primary bucket must encrypt objects by default. The log bucket too. Server-side encryption with AES-256 is enough for this week. |
| **AC-3** | Access Enforcement | Public access must be blocked on all four vectors. AWS exposes four separate flags for this, and all four have to be true. Three is not enough. They are four independent doors.|
| **CM-6** | Configuration Settings | Enable versioning on the primary bucket so prior object states are recoverable and auditable. Four required tags on every taggable resource: Project, Environment, ManagedBy, ComplianceScope. The clean way to do this is the provider `default_tags` block, so you cannot forget them on a new resource.
| **AU-3** and **AU-6** | Audit record content and review | he primary bucket logs access to the dedicated log bucket. The log bucket needs ownership controls set so it can accept a log-delivery ACL before logging will work. |

For this to be successful, I had to set up an AWS account that allowed me to create S3 buckets. Then I installed Terraform and VS Code on my laptop. From there, I used the Terraform Registry to find the relevant Terraform settings for AWS. 

From there, the controls are attached to the buckets and executed. 

Once set up, I verified the controls were applied and printed the results in a JSON file. This becomes the evidence an auditor needs. 

Eventually, we will automate continuous monitoring of these controls with alerts to notify the team when something changes. 

## Tools used
  + Terraform
  + AWS CLI
  + VS Code
  + Terraform Registry website

## Files updated/created
  + main.tf - configuration file
  + outputs.tf - expected outputs from Terraform Plan
  + variables.tf - variables used in the main file
  + verify.sh - verifies the controls are set
  + plan.json and plan-broken.json - plans that will be used throughout the challenge. Created with terraform plan

# Troubleshooting issues
### Destroying buckets
Once complete, if you need to destroy these, empty the buckets first, then remove them. Here are the steps I took for this process. I decided to use AWS commands and manually type the bucket_name instead of using Terraform. Typing the name didn't work correctly.  
1. Confirm the AWS profile in use.
   ```
   aws configure list-profiles
   ```
2. List the s3 buckets currently in the system.
   ```
   aws s3 ls
   ```
3. Once you find the bucket name of interest, delete the bucket. This will only remove recent versions of the bucket. If you still get an error removing the bucket, continue to the next step.
   ```
   aws s3 rm "s3://ACTUAL-BUCKET-NAME-HERE" --recursive
   ```
4. Checked the version status, and it came up "Suspended". This is why I was unable to delete all the versions of the buckets. The bucket name comes from Step 2. 
   ```
   aws s3api get-bucket-versioning --bucket ACTUAL-BUCKET-NAME-HERE
   ```
5. Once versions are checked, delete them and the markers using the commands below.
   ```
   aws s3api delete-objects --bucket ACTUAL-BUCKET-NAME-HERE --delete "$(aws s3api list-object-versions --bucket ACTUAL-BUCKET-NAME-HERE --output json --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
   aws s3api delete-objects --bucket ACTUAL-BUCKET-NAME-HERE --delete "$(aws s3api list-object-versions --bucket ACTUAL-BUCKET-NAME-HERE --output json --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
   ```
6. Verify the bucket is empty.
   ```
   aws s3api list-object-versions --bucket ACTUAL-BUCKET-NAME-HERE
   ```
7. Once empty, remove the bucket. rb = remove bucket
   ```
   aws s3 rb "s3://ACTUAL-BUCKET-NAME-HERE"
   ```

### Using Terraform to delete

1. Confirm the AWS profile in use
   ```
   aws configure list-profiles
   ```
2. Check resources; if the output comes back empty, use show to see if anything exists in the bucket
   ```
   terraform output or terraform show
   ```
3. Destroy the buckets
   ```
   terraform destroy
   ```
