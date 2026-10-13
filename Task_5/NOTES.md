# Task 5 — Bug Fix Notes

The trust policy named the wrong kind of principal. It used
`arn:aws:iam::000000000000:user/roleB`, which identifies an IAM user named
`roleB` in Account A. But `roleB` is an IAM role, so its ARN must use
`role/roleB`, not `user/roleB`. Since the trust policy did not identify the
role that was supposed to call `sts:AssumeRole`, roleB could not assume roleC.

I corrected the trusted principal to
`arn:aws:iam::000000000000:role/roleB`. The caller in Account A must also have
an identity policy allowing `sts:AssumeRole` on roleC's ARN; cross-account
assumption requires both the target role's trust and the caller's permission.

I changed the inline policy's `role` reference from
`aws_iam_role.roleC.id` to `aws_iam_role.roleC.name`. The
`aws_iam_role_policy` resource expects the IAM role name in its `role`
argument.

The original S3 permission is also broader than least privilege:
`s3:*` on `*` allows access to all S3 resources permitted by that policy.
It is retained in the corrected snippet only to isolate the broken
cross-account role configuration. In a real deployment, replace it with
the specific bucket ARN and bucket-object ARN, and only the S3 actions
the role actually requires.