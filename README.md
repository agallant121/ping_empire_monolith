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

# If on Linux:
# go install github.com/mailhog/MailHog@latest
# If on Windows, download from: https://github.com/mailhog/MailHog/releases

# Start MailHog in a separate terminal window
MailHog

# Start Redis in another terminal window (must be running before bin/dev)
redis-server

# Start the Rails and Sidekiq processes together
bin/dev
