# METADATA
# title: CM-6 - Configuration Settings (AWS required tags)
# description: Taggable resources must carry the four required compliance tags.
# custom:
#   control_id: CM-6
#   framework: nist-800-53
#   severity: medium
#   remediation: Add the missing tags or rely on provider default_tags.

package compliance.cm6_aws

import rego.v1

required := {"Project", "Environment", "ManagedBy", "ComplianceScope"}
provided_labels(resource) := set() if { not resource.values.labels }

deny contains msg if {
    bucket := input.planned_values.root_module.resources[_]
    bucket.type == "aws_s3_bucket"
	
	  bucket_address := sprintf("%s.%s", [bucket.type, bucket])

	  provided := object.keys(bucket.values.tags_all)
	  missing := required - provided

	  count(missing) > 0
    
	  msg := sprintf("[CM-6] S3 bucket '%s' is missing one or more required tags. Remediation: Add missing tags to resources.", [bucket_address])
}
