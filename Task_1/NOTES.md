# Notes

## Protected instance

The `prod-db` instance has `prevent_destroy` enabled. This is the
stateful production database host, so an accidental Terraform destroy
or replacement should be blocked until the protection is deliberately
reviewed.

Terraform will reject a plan that destroys this resource while it remains
in the configuration. To intentionally destroy it, first remove or change
the lifecycle protection, review the resulting plan, and apply that change
before proceeding. Removing the resource from configuration also removes
the protection, so configuration changes should be reviewed carefully.

## Key pairs

`key_name` refers to an EC2 key pair that must already exist in the
target AWS region. This module does not create or manage key pairs.

## Root volume performance

The `analytics-1` and `prod-db` entries use `io1` and `io2` respectively.
For production use, confirm that the chosen instance types and volume sizes
meet the account's EBS performance and capacity requirements.