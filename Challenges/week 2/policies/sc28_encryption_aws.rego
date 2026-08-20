# METADATA
# title: SC-28 - Encryption at Rest (AWS S3)
# description: Every aws_s3_bucket must have a matching server-side encryption configuration.
# custom:
#   control_id: SC-28
#   framework: nist-800-53
#   severity: high
#   remediation: Add aws_s3_bucket_server_side_encryption_configuration referencing the bucket.

package compliance.sc28_aws

import rego.v1

deny contains msg if {
    resource := input.configuration.root_module.resources[_]
    resource.type == "aws_s3_bucket"
	resource_address := sprintf("%s.%s", [resource.type, resource.name])

    not has_matching_encryption_config(resource_address)

    msg := sprintf("S3 resource '%s' has no matching server-side encryption configuration. Remediation: Add encryption", [resource_address])
}

has_matching_encryption_config(resource_address) if {
    resource := input.configuration.root_module.resources[_]
    resource.type == "aws_s3_bucket_server_side_encryption_configuration"

    some ref in resource.expressions.bucket.references
    ref == resource_address
}
