# Ping Empire Monolith

Ping Empire is a Ruby on Rails 8.0.2 application that monitors the uptime and response status of user-submitted websites.  
It pings each site periodically via Sidekiq background jobs and displays the current status, response time, and failure alerts.

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

## ⚙️ Setup Instructions

### 1. Clone the repository
```bash
git clone <repository_url>
cd ping_empire_monolith
