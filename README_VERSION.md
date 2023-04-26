# v1.1.0

### fix

Log bucket ACL

#### what changed:

Log bucket ACL removed to support default ObjectOwnership. Log bucket has BucketPolicy allowing LB to PutLog.

#### info & what to do:

AWS changed default ACL, and ObjectOwnership setting. Ref: https://aws.amazon.com/blogs/aws/heads-up-amazon-s3-security-changes-are-coming-in-april-of-2023/

# v1.0.0

### Major

First Standard version.
