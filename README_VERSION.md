# v1.1.0

### Minor

#### what changed:

S3 log bucket Lifecycle transition, and expiration added.

#### reason for change:

To add lifecycle transition, and expiration

#### info:

`log_bucket_transition_days`: Days after which log bucket objects are transitioned to Glacier. Default = 180

`log_bucket_expiry_days`:     Days after which log bucket objects are deleted. Default = 365

# v1.0.0

### Major

Initial release.
