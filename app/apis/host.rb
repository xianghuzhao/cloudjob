require_relative '../models/counter'
require_relative '../models/host'

class HostAPI < Grape::API
  format :json

  resource :hosts do
    get do
      result = []
      Host.asc(:host_id).each do |host|
        result.push host_id: host.host_id, cpu_core: host.cpu_core, status: host.status, id_in_region: host.id_in_region, created_at: host.created_at
      end
      result
    end

    get :count do
      Host.count
    end

#    post do
#      puts params
#      exe_name = params[:file][:filename]
#      job_id = Counter.next_sequence('job')
#      Job.create!(job_id: job_id, name: exe_name, status: 'INIT', exe_name: exe_name)
#
#      job_dir = File.join(ROOT_PATH, 'tmp', job_id.to_s)
#      Dir.mkdir job_dir
#      File.open(File.join(job_dir, exe_name), 'wb') do |file|
#        file.write(params[:file][:tempfile].read)
#      end
#
#      job_id
#    end

    route_param :id, type: Integer do
      get do
        host = Host.find_by(host_id: params[:id])
        {host_id: host.host_id, status: host.status}
      end

      put do
        host = Host.find_by(host_id: params[:id])
        host.update(status: params[:status])
      end

      delete do
        host = Host.find_by(host_id: params[:id])
        host.destroy
      end
    end
  end
end
