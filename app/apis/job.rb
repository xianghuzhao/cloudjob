require 'base64'

require_relative '../models/counter'
require_relative '../models/job'

class JobAPI < Grape::API
  format :json

  resource :jobs do
    get do
      result = []
      Job.asc(:job_id).each do |job|
        result.push job_id: job.job_id, name: job.name, exe_name: job.exe_name, status: job.status, created_at: job.created_at
      end
      result
    end

    get :count do
      Job.count
    end

    get :stat do
      stat = {}
      Job.distinct(:status).each do |status|
        stat[status] = Job.where(status: status).count
      end
      stat
    end

    post do
      puts params
      exe_name = params[:file][:filename]
      job_id = Counter.next_sequence('job')
      Job.create!(job_id: job_id, name: exe_name, status: 'INIT', exe_name: exe_name)

      job_dir = File.join(ROOT_PATH, 'tmp', job_id.to_s)
      Dir.mkdir job_dir
      File.open(File.join(job_dir, exe_name), 'wb') do |file|
        file.write(params[:file][:tempfile].read)
      end

      job_id
    end

    route_param :id, type: Integer do
      get do
        job = Job.find_by(job_id: params[:id])
        job_dir = File.join(ROOT_PATH, 'tmp', job.job_id.to_s)
        exe_file_base64 = Base64.encode64(File.open(File.join(job_dir, job.exe_name), 'rb').read)
        { job_id: job.job_id, name: job.name, exe_name: job.exe_name, status: job.status, created_at: job.created_at, exe_file: exe_file_base64 }
      end

      get :output do
        job_dir = File.join(ROOT_PATH, 'tmp', params[:id].to_s)
        stdout_base64 = Base64.encode64(File.open(File.join(job_dir, 'stdout'), 'rb').read)
        stderr_base64 = Base64.encode64(File.open(File.join(job_dir, 'stderr'), 'rb').read)
        { job_id: params[:id], stdout: stdout_base64, stderr: stderr_base64 }
      end

      put do
        job = Job.find_by(job_id: params[:id])
        job.update(status: params[:status]) if params.include?(:status)

        job_dir = File.join(ROOT_PATH, 'tmp', job.job_id.to_s)
        if params.include?(:stdout)
          File.open(File.join(job_dir, 'stdout'), 'w') do |file|
            file.write(Base64.decode64(params[:stdout]))
          end
        end
        if params.include?(:stderr)
          File.open(File.join(job_dir, 'stderr'), 'w') do |file|
            file.write(Base64.decode64(params[:stderr]))
          end
        end
      end
    end
  end
end
