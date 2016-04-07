require_relative 'params'
require_relative '../models/region'

class Scheduler
  def run
    sp = SchedulingParams.new('config/cloudjob.yml')

    params = sp.params

    jobs = params[:job][:jobs_waiting] - params[:job][:jobs_pending]
    puts 'All jobs to be scheduled: ', jobs
    puts 'hosts ready: ', params[:job][:hosts_cpu]
    hosts_scheduled = {}
    params[:job][:hosts_cpu].each do |host_id, host_property|
      next unless host_property.include?('cpu_core')

      cpu_core = host_property['cpu_core']
      pending_jobs = host_property['pending_jobs'] || 0
      running_jobs = host_property['running_jobs'] || 0
      available_core = cpu_core - running_jobs - pending_jobs

      available_core.times do
        break if jobs.empty?
        job_id = jobs.shift
        puts "Scheduling job #{job_id} to host #{host_id}"
        JobPool.create!(job_id: job_id, host_id: host_id, operation: 'START')

        hosts_scheduled[host_id] ||= 0
        hosts_scheduled[host_id] += 1
      end
      break if jobs.empty?
    end


    jobs_all = params[:job][:jobs_waiting].size + params[:job][:jobs_running].size
    hosts_all = params[:host][:hosts_ready].size + params[:host][:hosts_pending].size
    hosts_shortage = jobs_all - hosts_all
    hosts_to_create = [params[:host][:restriction]['max_running'] - hosts_all, hosts_shortage].min
    puts "#{hosts_to_create} hosts will be created"
    puts "hosts_shortage: #{hosts_shortage}"
    puts "jobs_all: #{jobs_all}"
    puts "hosts_all: #{hosts_all}"
    hosts_to_create.times do
      puts "Creating new host"
      HostPool.create!(region_id: 0, operation: 'CREATE')
    end

    params[:job][:hosts_cpu].each do |host_id, host_property|
      pending_jobs = host_property['pending_jobs'] || 0
      running_jobs = host_property['running_jobs'] || 0
      scheduled_jobs = hosts_scheduled[host_id] || 0

      next unless (pending_jobs + running_jobs + scheduled_jobs) == 0

      puts "Destroy host #{host_id}"
      HostPool.create!(host_id: host_id, operation: 'DESTROY')
    end
  end
end
