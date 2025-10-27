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
```

## Here is a visual representation of the working app:

### Login page:

<img width="1580" height="926" alt="image" src="https://github.com/user-attachments/assets/b9918f93-d702-448e-ba6d-6fce3d459a89" />

### When logged in:

<img width="1570" height="925" alt="image" src="https://github.com/user-attachments/assets/b3f72eb3-da15-4d04-b1dc-60c12b1ee9e3" />

### When a website has a failed response example:

<img width="1568" height="924" alt="image" src="https://github.com/user-attachments/assets/42136f3d-dc32-49af-93e3-0c2581dac8d8" />

### On website show page to see failed response example:

<img width="1569" height="924" alt="image" src="https://github.com/user-attachments/assets/24853d46-add0-4bc4-aad1-09e581e3f780" />

### Failure email example:

<img width="626" height="354" alt="image" src="https://github.com/user-attachments/assets/8abaf975-b355-47ce-a986-c3d76c7d5fb2" />





