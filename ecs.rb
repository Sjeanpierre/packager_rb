require 'aws-sdk'


class ECSCaller
  def initialize(tar_url)
    @tar_url = tar_url
  end

  def perform
    client = Aws::ECS::Client.new(:region => 'us-west-2')
    params = {
        :task_definition => 'builder:7',
        :overrides => {
            :container_overrides => [
                {
                    :name => 'builder',
                    :environment => [
                        {
                            :name => 'TAR_URL',
                            :value => @tar_url,
                        },
                    ],
                },
            ],
        },
        :count => 1,
    }
    resp = client.run_task(params)
    if resp.failures.count != 0
      raise('Could not create new build')
    end
  end
end