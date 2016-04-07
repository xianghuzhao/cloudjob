require_relative '../scheduler/host_manager'

class HostManagerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    minutely
  end

  def perform
    HostManager.new.run
  end
end
