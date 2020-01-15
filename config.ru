require './app'
if ENV['RACK_ENV'] != 'production'
  require 'rack/dev-mark'
  use Rack::DevMark::Middleware, [:title, Rack::DevMark::Theme::GithubForkRibbon.new(position: 'right')]
end
run App.new
