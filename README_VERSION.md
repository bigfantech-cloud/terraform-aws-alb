# v1.1.1

### Minor

#### what changed:

S3 log bucket Lifecycle expiration added. Expiration, and transition days are made as variables

#### reason for change:

To add lifecycle expiration

#### info:

`log_bucket_transition_days`: Days after which log bucket objects are transitioned to Glacier. Default = 365
`log_bucket_expiry_days`:     Days after which log bucket objects are deleted. Default = 730

# v1.1.0

### Feture

#### what changed:

S3 log bucket Lifecycle configuration added to transfer to `glacier` post 365 days.

#### reason for change:

S3 bucket Lifecycle configuration

# v1.0.0

### Major

Initial release.
