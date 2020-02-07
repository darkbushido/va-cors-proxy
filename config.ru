require 'bundler/inline'

gemfile do
  source "https://rubygems.org"
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem 'awesome_print'
  gem 'rack'
  gem 'thin'
  gem 'pry'
  gem 'rest-client'
end

use Rack::ContentLength
use Rack::Reloader, 100

app = -> (env) do
  req = Rack::Request.new(env)
  uri = URI('https://staging-api.va.gov')
  uri.path = req.path
  ap req.params
  begin
    res = RestClient.get uri.to_s, {params: req.params}
    [
      res.code,
      {
        'Content-Type' => 'application/json',
        'Access-Control-Allow-Origin' => 'http://localhost:3001',
        'Access-Control-Allow-Methods' => "GET, PUT, POST, DELETE, HEAD, OPTIONS",
        'Access-Control-Allow-Credentials' => true
      },
      [ res.body ]
    ]
  rescue RestClient::NotFound => e
    puts "#{req.path} #{e.message}"
    [404, { 'Content-Type' => 'text/plain' }, ["#{req.path} #{e.message}"] ]
  end
end

run app
