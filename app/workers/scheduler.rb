require_relative '../scheduler/scheduler'

class SchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    minutely
  end

  def perform
    Scheduler.new.run
  end
end
