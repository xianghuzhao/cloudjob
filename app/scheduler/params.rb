require_relative '../models/job'
require_relative '../models/host'
require_relative '../models/job_pool'
require_relative '../models/job_execution'
require_relative '../models/host_pool'

class SchedulingParams
  def initialize(param_file)
    @params = YAML.load_file(param_file)
  end

  def params
    {
      job: {
        restriction: jobs_restriction,
        jobs_waiting: jobs_waiting,
        jobs_running: jobs_running,
        jobs_pending: jobs_pending,
        hosts_cpu: hosts_cpu,
      },
      host: {
        restriction: hosts_restriction,
        hosts_ready: hosts_ready,
        hosts_pending: hosts_pending,
      },
    }
  end

  def jobs_restriction
    @params['job']
  end

  def hosts_restriction
    @params['host']
  end

  def jobs_waiting
    Job.in(status: ['WAITING']).asc(:created_at).map(:job_id)
  end

  def jobs_running
    Job.in(status: ['RUNNING']).map(:job_id)
  end

  def jobs_pending
    JobPool.in(operation: 'START').map(:job_id)
  end

  def hosts_ready
    Host.in(status: ['INIT', 'READY']).map(:host_id)
  end

  def hosts_pending
    HostPool.in(operation: 'CREATE').map(:host_id)
  end

  def hosts_cpu
    ready = {}

    Host.in(status: ['READY']).each do |host|
      ready[host.host_id] ||= {}
      ready[host.host_id]['status'] = host.status
      ready[host.host_id]['cpu_core'] = host.cpu_core
    end

    JobPool.each do |job_pool|
      ready[job_pool.host_id] ||= {}
      ready[job_pool.host_id]['pending_jobs'] ||= 0
      ready[job_pool.host_id]['pending_jobs'] += 1
    end

    JobExecution.in(status: ['RUNNING']).each do |job_execution|
      ready[job_execution.host.host_id]['running_jobs'] ||= 0
      ready[job_execution.host.host_id]['running_jobs'] += 1
    end

    ready
  end
end
