require 'open3'

require_relative '../models/counter'
require_relative '../models/host'

class HostManager
  def run
    HostPool.all.each do |host_pool|
      if host_pool.operation == 'CREATE'
        create_host
      elsif host_pool.operation == 'DESTROY'
        destroy_host host_pool.host_id
      end

      host_pool.destroy
    end
  end

  def create_host
    puts 'Really creating host...'

    new_host_id = Counter.next_sequence('host')
    context_template = File.expand_path('../context.sh', __FILE__)
    context_file = Tempfile.new('context')
    File.open(context_template) do |file|
      context_file.write(file.read.sub('HOSTID', new_host_id.to_s))
    end

    cmd = "occi --endpoint https://vmdirac03.ihep.ac.cn:11443 \
--action create --resource compute --mixin os_tpl#uuid_cloudjob_60 --attribute occi.core.title='job_host_#{new_host_id}' \
--auth basic --username jobtest --password jobtest --skip-ca-check \
--output-format json --context user_data='file://#{context_file.path}'"
    puts cmd

    context_file.close

    id_in_region = ''
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      occi_stdout = stdout.read
      occi_stderr = stderr.read
      puts 'STDOUT: ', occi_stdout
      puts 'STDERR: ', occi_stderr
      id_in_region = occi_stdout.strip
    end

    Host.create!(host_id: new_host_id, status: 'INIT', id_in_region: id_in_region)
  end

  def destroy_host(host_id)
    puts "Really destroying host #{host_id}..."

    host = Host.find_by(host_id: host_id)
    instance_id = host.id_in_region

    cmd = "occi --endpoint https://vmdirac03.ihep.ac.cn:11443 \
--action delete --resource #{instance_id} \
--auth basic --username jobtest --password jobtest --skip-ca-check \
--output-format json"
    puts cmd

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      puts 'STDOUT: ', stdout.read
      puts 'STDERR: ', stderr.read
    end

    host.update(status: 'DESTROYED')
  end
end
