# Task 4 — CI Least-Privilege Policy

The custom policy grants the `ci` principal only the stated pipeline capabilities:
push images to one ECR repository, register task definitions, update and inspect
one ECS service, pass only the application's task roles to ECS tasks, and read
objects from one build-artifacts bucket.

## Deliberately excluded

- ECR repository creation/deletion, repository policy changes, and access to
  other repositories. The pipeline is expected to push to an already-created
  repository.
- ECS cluster/service creation or deletion, task execution, stopping tasks,
  changing other services, and broad ECS administration. The pipeline deploys
  by registering a task definition and updating the existing service.
- IAM user, group, role, policy, and access-key administration. The pipeline
  must not grant itself permissions or change its own identity.
- `iam:PassRole` for arbitrary roles. Passing a task role can give the deployed
  workload that role's permissions, so this is limited to the app's specific
  task role and execution role and constrained to `ecs-tasks.amazonaws.com`.
- S3 uploads, object modification, deletion, bucket configuration changes,
  and access to other buckets. The build-artifacts bucket is read-only.
- CloudWatch, load balancer, autoscaling, and console permissions. They are
  not required for the stated deployment operations. If the pipeline later
  needs additional deployment features, grant only the exact actions and
  resources needed for those features.

`ecs:RegisterTaskDefinition` requires `"Resource": "*"` because ECS does not
support resource-level permissions for task-definition registration. This is
an AWS authorization limitation, not a grant of ECS-wide permissions for all
other actions. The service update and describe permissions remain scoped to
the specified service.

The ECR authorization token action also requires `"Resource": "*"`. ECR image
push actions are scoped to the named repository.

The S3 `ListBucket` permission lets the pipeline discover artifact keys. If it
already knows every required key and does not need to list the bucket, remove
that action. `GetBucketLocation` can also be omitted if the pipeline does not
query the bucket's region.

Replace the example ARNs and bucket name before attaching the policy. Verify
the resulting policy with IAM Access Analyzer and test the pipeline using the
actual deployment workflow.

An ECS deployment that changes task-definition roles may need iam:PassRole; this is intentionally restricted because passing a role lets the service use that role’s permissions.

