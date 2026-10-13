# Task 3 Notes

## Would I give `engine` and `ci` IAM users with access keys in production?

No, not as the default design.

- `engine` represents a human engineer. In production, I would use AWS IAM
  Identity Center or federated login through the corporate identity provider.
  The engineer would receive short-lived role credentials through SSO rather
  than a permanent IAM-user access key.
- `ci` represents automation. I would run the pipeline with an OIDC federation
  integration where possible, such as GitHub Actions OIDC assuming a narrowly
  scoped deployment role. If the CI system cannot use OIDC, I would use a
  dedicated EC2 instance profile, ECS task role, or Lambda execution role with
  temporary credentials.

IAM users with long-lived access keys create operational and security risk:
keys can be copied into repositories, CI variables, developer laptops, or
support tickets; they do not expire automatically; and they require rotation,
inventor, and revocation processes. AWS explicitly recommends temporary
credentials and roles for human users and workloads wherever possible.

For this exercise, `engine` and `ci` are IAM users with access keys because the
task requires group-based programmatic access. In production, I would treat
this as an exception requiring approval, least-privilege policies, key rotation,
CloudTrail monitoring, and automated removal when no longer needed.

## Why trust `roleB` specifically rather than Account A root?

`roleC`'s trust policy should trust only:

```text
arn:aws:iam::000000000000:role/roleB
```

Trusting the Account A root principal does **not** mean trusting only Account
A's root user. In an IAM trust policy, the account root principal delegates
trust to the account, meaning identities in that account may be allowed to
assume the role if their identity policies grant `sts:AssumeRole`.

That would make the trust boundary much broader: any IAM user, group-based
identity, or role in Account A that receives an allow for
`sts:AssumeRole` on `roleC` could potentially assume it. That includes
`engine`, `ci`, `alice`, `bob`, and any future identities created in Account A.

By trusting only `roleB`'s exact ARN, Account B limits the cross-account entry
point to one narrowly scoped role. `roleB` itself has only one permission:
assuming `roleC`. This creates a clear, auditable chain:

```text
Allowed principal in Account A -> roleB -> roleC -> named S3 bucket
```

It also reduces confused-deputy and privilege-escalation risk. If someone later
adds broad `sts:AssumeRole` permissions in Account A, they still cannot assume
`roleC` unless they can first assume `roleB`.