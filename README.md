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

<img width="626" height="354" alt="image" src="https://github.com/user-attachments/assets/8abaf975-b355-47ce-a986-c3d76c7d5fb2" />





