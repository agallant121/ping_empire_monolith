# Ping Empire Monolith

Ping Empire is a Ruby on Rails 8.0.2 application that monitors the uptime and response status of user-submitted websites.  
It pings each site periodically via Sidekiq background jobs and displays the current status, response time, and failure alerts.  

This monolithic version combines the web frontend, background job processing, and scheduler into one unified Rails app.

---

## Requirements

| Dependency | Version / Notes |
|-------------|-----------------|
| **Ruby** | 3.4.2 |
| **Rails** | 8.0.2 |
| **PostgreSQL** | Required for database |
| **Redis** | Required for Sidekiq |
| **Sidekiq** | Background job processing |
| **Sidekiq Scheduler** | Handles recurring cron jobs |
| **MailHog** | For local email testing (development) |

---

## Setup Instructions

Follow these exact steps to run Ping Empire locally from scratch.  

Clone the repository and navigate into it, then install all Ruby dependencies, set up the database, install and start MailHog, start Redis (before running the app), and finally launch the application using the following commands:

```bash
# Clone the repository and enter the directory
git clone git@github.com:agallant121/ping_empire_monolith.git
cd ping_empire_monolith

# Install Ruby dependencies
bundle install

# Set up the database
bin/rails db:create db:migrate

# Install MailHog (macOS)
brew install mailhog

# Start MailHog in a separate terminal window
MailHog

# Start Redis in another terminal window (must be running before bin/dev)
redis-server

# Start the Rails and Sidekiq processes together
bin/dev

# Visit
http://localhost:3000/

# Open Mailhog in separate browser tab
http://localhost:8025/

# login using:
email: user@example.com
password: asdfasdf123!

You will see multiple sign-in options (facebook & twitter) but only google oauth or the username/password above are functional
```

## Here is a visual representation of the working app:

### Login page:

<img width="1574" height="922" alt="image" src="https://github.com/user-attachments/assets/9b1aa190-b4a9-4431-955d-e4984a619e59" />

### When a user is logged in:

<img width="1133" height="915" alt="image" src="https://github.com/user-attachments/assets/a021ddf9-14d3-4ed8-bc7d-d09863688ccf" />

### When a website has a failed response - example:

<img width="615" height="400" alt="image" src="https://github.com/user-attachments/assets/3659ed14-7ddd-432a-82d1-f651ff672631" />

### On website show page to see failed response - example:

<img width="713" height="462" alt="image" src="https://github.com/user-attachments/assets/85a04e92-c032-4e6a-8906-7467dab92cd0" />

### Failure alert email - example:

<img width="660" height="526" alt="image" src="https://github.com/user-attachments/assets/e6b86d2c-7603-42b1-8ee5-dd259a279909" />


## Archiving daily responses

The `ArchiveDayOldPingsJob` background job exports every response that is more than a day old to a CSV file inside `./archive`.
The CSV contains the response id, website id, HTTP status code, response time, and timestamp so administrators can retain a full audit trail. The job never uploads or deletes these CSVs — they remain on disk until an administrator reviews them in the UI and decides to send a copy to S3.

If you still prefer to configure AWS credentials via environment variables, the `ArchiveDayOldPingsJob.build_s3_uploader` helper honors the following keys as a fallback:

| Variable | Description |
| --- | --- |
| `AWS_S3_ARCHIVE_BUCKET` | Destination S3 bucket name. |
| `AWS_REGION` | AWS region of the bucket (for example `us-east-1`). |
| `AWS_ACCESS_KEY_ID` | IAM access key id that has permission to upload to the bucket. |
| `AWS_SECRET_ACCESS_KEY` | IAM secret for the key above. |
| `AWS_SESSION_TOKEN` | *(Optional)* session token for temporary credentials. |
| `AWS_S3_ARCHIVE_PREFIX` | *(Optional)* folder/prefix (e.g. `responses/daily`). The basename of the CSV is appended automatically. |

However, the recommended approach is to store the credentials via the AWS settings page described below so that administrators can rotate keys or switch buckets without a deploy.


### Manually exporting via the admin UI

1. Sign in with an administrator account (you can flip an existing user to the admin role in the Rails console with `user.update!(role: 1)`).
2. Click the **Archives** link in the navigation bar (or visit `http://localhost:3000/admin/archives`).
3. The dashboard shows whether AWS credentials are configured, lists every CSV that lives under `./archive`, and provides an **Archive Responses Now** button to run the exporter immediately. That button always generates a new CSV and deletes the day-old responses. If AWS credentials are configured, the controller automatically uploads that freshly created file to S3 and removes the local copy, otherwise it keeps the CSV on disk and flashes a download link so you can inspect it before taking any further action.
4. Each row in the table includes **Download** and **Upload to S3** actions. The upload button becomes active once credentials are configured and, when clicked, streams the selected CSV to the configured bucket using the `S3ArchiveUploader`. This is useful for older CSVs that were generated before AWS credentials existed or when an automatic upload failed and left the file on disk for manual retry.
5. As soon as the CSV has been created the responses that were archived are deleted from the database, so only run an export when you’re ready for those day-old records to live either in the downloaded CSV or inside your S3 bucket once the automatic/manual upload completes.

### Connecting AWS via the UI

Administrators can enter their AWS credentials directly in the app:

1. Visit **Admin → AWS Settings**.
2. Provide the access key id, secret, region, destination bucket, and optional session token/prefix.
3. Submit the form to save the credentials in the database. The archives dashboard immediately reflects the connection, enabling the **Upload to S3** buttons.

This screen makes it easy to verify the workflow manually in development (generate a few responses, set one to be more than a day old via the Rails console, and run an export) as well as the primary workflow an admin would use in production when they need a copy of the day’s responses immediately.



