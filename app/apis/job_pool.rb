require_relative '../models/counter'
require_relative '../models/job_pool'

class JobPoolAPI < Grape::API
  format :json

  resource :job_pools do
    get do
      result = []
      if params.includes?(:host_id)
        JobPool.where(host_id: params[:host_id]).each do |job_pool|
          result.push id: job_pool._id.to_s, job_id: job_pool.job_id, host_id: job_pool.host_id, operation: job_pool.operation
        end
      else
        JobPool.each do |job_pool|
          result.push id: job_pool._id.to_s, job_id: job_pool.job_id, host_id: job_pool.host_id, operation: job_pool.operation
        end
      end
      result
    end

    route_param :id, type: String do
      delete do
        job_pool = JobPool.find(params[:id])
        job_pool.destroy
      end
    end
  end
end
