GRC Engineering Club Projects

# 6-week GRC Challenge with the GRC Engineering Club
This challenge helps GRC professionals move from checkbox compliance to engineered and continuous monitoring of compliance with actual evidence and not just screenshots. This is code anyone can read, pseudocode, "that takes a piece of cloud infrastructure from it works to it is audit-defensible."

One build a week, six weeks, each one harder than the last. You start with a single compliant cloud resource, and you end with a pipeline that writes its own evidence. Every week produces an artifact that goes straight onto your portfolio, so when you finish you are not just done, you have six new things to show."

### Week 1: Create a compliant resource - AWS s3 buckets
Creating a compliant resource using Terraform to enforce:
+ encryption
+ public access blocks
+ version control
+ required tags

### Week 2: Execute Rules from a Terraform plan
Create three Rego rules that check compliance and provide output as evidence an auditor can pull at any time. Shows passing and failing compliance rules with recommendations for remediation. Controls checked: 
+ SC-28 deny if no encryption enabled at rest
+ AC-3 deny if all 4 public access rules aren't present and enabled
+ CM-6 deny if at least one required tag is missing

### Week 3: Building the gate
### Week 4: Evidence you can trust
### Week 5: Turn on the camera
### Week 6: Speak the auditor language using OSCAL

Follow the challenge on LinkedIn using the hashtag:
**#grcengineering6weekchallenge**
