# v1.1.1

### Fix

#### what changed:

- Fix: S3 log bucket Lifecycle status attribute moved inside rule
- Fix: `listener_rules` var default value keys name correction
- Fix: target_group `name_prefix` change -> `name`

#### reason for change:

- Fix: S3 log bucket Lifecycle status attribute was in wrong place
- Fix: `listener_rules` var default value keys name incorrect
- Fix: target_group `name_prefix` character limts to 6

#### info:


# v1.1.0

### Feature

#### what changed:

S3 log bucket Lifecycle transition, and expiration added

#### reason for change:

To add lifecycle transition, and expiration

#### info:

`log_bucket_transition_days`: Days after which log bucket objects are transitioned to Glacier. Default = 180

`log_bucket_expiry_days`:     Days after which log bucket objects are deleted. Default = 365

# v1.0.0

### Major

Initial release.
