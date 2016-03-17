require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    session
    @params = params

  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'Already rendered/redirected' if already_built_response?
    @session.store_session(@res)
    flash.store_flash(@res)
    @already_built_response = true
    @res['location'] = url #@res.header
    @res.status = 302
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Already rendered/redirected' if already_built_response?
    @session.store_session(@res)
    @already_built_response = true
    @res['Content-Type'] = content_type
    @res.write(content)
    @res.status = 200


  end

  def flash
    @flash ||= Flash.new(req)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    class_name = self.class.to_s.underscore
    erb_file = File.read("views/#{class_name}/#{template_name}.html.erb")
    erb_file = ERB.new(erb_file).result(binding)
    render_content(erb_file, 'text/html')

  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
