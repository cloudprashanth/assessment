Create the lock table before running terraform init:

aws dynamodb create-table \
  --table-name terraform-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

The table must have a partition key named LockID of type String.


What happens today with local state
With the default local backend, Terraform writes terraform.tfstate on each engineer’s machine. If two people run terraform apply at the same time, each process can read and write its own local state independently. Terraform cannot reliably coordinate those operations, so one person’s changes can overwrite the other’s, producing stale state, infrastructure drift, or conflicting resource changes. Local backends have limited locking semantics.

How S3 + DynamoDB prevents this
After terraform init, both engineers use the same state file in the shared S3 bucket. Before an operation that can modify state, Terraform attempts to acquire a lock in the DynamoDB table. If the first user holds the lock, the second user’s terraform apply waits or fails with a state-lock error rather than modifying the same state concurrently. This prevents simultaneous writes and reduces the risk of state corruption or infrastructure inconsistency.

Migration note
Run this once from the directory containing the existing local state:


terraform init
Terraform should detect the backend change and ask whether to migrate the existing local state to S3. Confirm the migration, then verify with:


terraform state list
Note: DynamoDB locking is deprecated in newer Terraform versions in favor of native S3 locking (use_lockfile = true, Terraform 1.10+). Since this task explicitly requires DynamoDB locking, the configuration above uses dynamodb_table; for a new long-term setup, consider S3 native locking instead.

