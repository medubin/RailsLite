require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/static'
require_relative '../lib/router'


app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use Static
  run app
end.to_app

Rack::Server.start(
  app: app,
  Port: 3000
)
