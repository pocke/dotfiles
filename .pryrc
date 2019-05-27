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

$__is_pry_rubyvm_ast_mode = false

def ast!
  $__is_pry_rubyvm_ast_mode = !$__is_pry_rubyvm_ast_mode
end

Pry.config.hooks.add_hook(:before_eval, :"ast<3") do |code, _pry|
  next if code == "ast!\n"
  next unless $__is_pry_rubyvm_ast_mode

  x = code.inspect
  code.clear
  code << "RubyVM::AbstractSyntaxTree.parse(#{x})"
end
