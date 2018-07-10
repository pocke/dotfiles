def octokit_client
  @__octokit_client__ ||= begin
    require 'octokit'
    require 'yaml'
    conf = YAML.load_file(File.expand_path("~/.config/hub"))
    token = conf['github.com'].first['oauth_token']
    ::Octokit::Client.new(access_token: token).tap do |client|
      client.middleware = Faraday::RackBuilder.new do |builder|
        builder.use ::Octokit::Middleware::FollowRedirects
        builder.use ::Octokit::Response::RaiseError
        builder.use ::Octokit::Response::FeedParser
        builder.response :logger
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
