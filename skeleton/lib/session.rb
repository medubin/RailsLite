require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @req = req
    @session = req.cookies['_rails_lite_app'] || {}
    @session = JSON.parse(@session) unless @session.is_a?(Hash)

  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
      res.set_cookie('_rails_lite_app', {path: '/', value: @session.to_json} )
  end
end
