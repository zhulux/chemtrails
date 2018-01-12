require 'json'
require 'excon'

module Chemtrails
  class BasicAuthConfigurationFetcher
    def fetch_configuration(url, application, environment, branch, username, password)
      configuration_properties_url = build_url(url: url, application: application, environment: environment, branch: branch)

      response = Excon.get(configuration_properties_url, headers: {
        'Authorization' => "Basic #{encode_credentials(username, password)}"
      })

      if success?(response)
        json = JSON.parse(response.body)
        {}.tap do |props|
          sources = json['propertySources']
          sources.each { |source| props.reverse_merge!(source['source']) }
        end
      else
        raise RuntimeError.new("Error fetching configuration from: #{url}")
      end
    end

    private

    def success?(response)
      response.status >= 200 && response.status < 400
    end

    def encode_credentials(username, password)
      Base64.encode64("#{username}:#{password}").chomp
    end

    def build_url(url:, application:, environment:, branch:)
      if branch.present?
        "#{url}/#{application}/#{environment}/#{branch}"
      else
        "#{url}/#{application}/#{environment}"
      end
    end
  end
end