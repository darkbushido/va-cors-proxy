require 'bundler/inline'

gemfile do
  source "https://rubygems.org"
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem "rack"
  gem "thin"
  gem "pry"
  gem "rest-client"
end

use Rack::ContentLength
use Rack::Reloader, 100

app = -> (env) do
  req = Rack::Request.new(env)
  uri = URI('https://staging-api.va.gov')
  uri.path = req.path
  res = RestClient.get uri.to_s, {params: req.params}
  # binding.pry
  [
    res.code,
    { "Content-Type" => "application/json" },
    [ res.body ]
  ]
end

run app
