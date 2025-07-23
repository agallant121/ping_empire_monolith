Sidekiq.configure_server do |config|
  schedule_file = "config/sidekiq_scheduler.yml"

  if File.exist?(schedule_file)
    Sidekiq::Scheduler.dynamic = true
    config.on(:startup) do
      Sidekiq.schedule = YAML.load_file(schedule_file)[:schedule]
      Sidekiq::Scheduler.reload_schedule!
    end
  end
end