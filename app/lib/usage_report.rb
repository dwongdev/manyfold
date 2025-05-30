module UsageReport
  def self.endpoint
    ENV.fetch("USAGE_TRACKING_URL", "https://tracking.manyfold.app")
  end

  def self.generate
    Jbuilder.encode do |report|
      report.id SiteSettings.anonymous_usage_id
      report.version do |version|
        version.app Rails.application.config.app_version.gsub(/^v/, "")
        version.sha Rails.application.config.git_sha
        version.image ENV.fetch("DOCKER_TAG", nil)&.split(":")&.first
        version.arch RUBY_PLATFORM
      end
    end
  end

  def self.set_schedule!
    SiteSettings.clear_cache
    jobname = "usage"
    if SiteSettings.anonymous_usage_id.present?
      Sidekiq::Cron::Job.create(
        name: jobname,
        cron: "every day",
        class: "UsageReportingJob"
      )
    else
      Sidekiq::Cron::Job.destroy(jobname)
    end
  end

  def self.enable!
    SiteSettings.anonymous_usage_id ||= SecureRandom.uuid
    set_schedule!
  end

  def self.disable!
    SiteSettings.anonymous_usage_id = nil
    set_schedule!
  end
end
