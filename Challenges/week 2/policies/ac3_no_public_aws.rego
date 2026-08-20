# METADATA
# title: AC-3 - Access Enforcement (AWS S3 public access block)
# description: Every aws_s3_bucket must have a public access block with all four flags true.
# custom:
#   control_id: AC-3
#   framework: nist-800-53
#   severity: critical
#   remediation: Add aws_s3_bucket_public_access_block referencing the bucket, all four flags true.

package compliance.ac3_aws

import rego.v1

deny contains msg if {
    pab := input.configuration.root_module.resources[_]
    pab.type == "aws_s3_bucket"
	
	pab_address := sprintf("%s.%s", [pab.type, pab.name])
    not has_matching_public_access_block(pab_address)

    msg := sprintf("S3 bucket '%s' has no matching public access blocks with all settings enabled. Remediation: Enable public access blocks.", [pab_address])
}

has_matching_public_access_block(pab_address) if {
	# Step 1: find the access block config entry linked to this bucket 
    pab := input.configuration.root_module.resources[_]
    pab.type == "aws_s3_bucket_public_access_block"
  	pab_own_address := sprintf("%s.%s", [pab.type, pab.name])

    some ref in pab.expressions.bucket.references
    startswith(ref, pab_address)

	# Step 2: find that same access block's resolved values, check all 4 flags
    pab_values := input.planned_values.root_module.resources[_]
    pab_values.address == pab_own_address
	pab_values.values.block_public_acls == true
  	pab_values.values.block_public_policy == true
  	pab_values.values.ignore_public_acls == true
	pab_values.values.restrict_public_buckets == true
}
