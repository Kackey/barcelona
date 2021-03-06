require 'rails_helper'

module Barcelona
  module Plugins
    describe DatadogPlugin do
      context "without proxy plugin" do
        let!(:district) do
          create :district, plugins_attributes: [
            {
              name: 'datadog',
              plugin_attributes: {
                "api_key" => "abcdef"
              }
            }
          ]
        end

        it "gets hooked with container_instance_user_data trigger" do
          ci = ContainerInstance.new(district)
          user_data = YAML.load(Base64.decode64(ci.user_data.build))
          expect(user_data["runcmd"].last).to eq "docker run -d --name dd-agent -h `hostname` -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=abcdef -e TAGS=\"barcelona,barcelona-dd-agent,district:#{district.name}\" datadog/docker-dd-agent:latest"
        end
      end
    end
  end
end
