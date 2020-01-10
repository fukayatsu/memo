require 'json'
require 'base64'

require 'haml'
require 'sassc'

require './app/errors'
require './app/post'

class App
  class << self
    def paths
      file_paths =
        Dir.glob('posts/**/*.*') +
        Dir.glob('pages/**/*.*').map { _1.delete_prefix('pages/') }

      %w[
        /
        /posts
        /screen.css
      ] + file_paths.map { "/#{_1.delete_suffix('.md')}" }
    end
  end

  def render(file, locales = {})
    template = File.read("views/#{file}.haml")
    Haml::Engine.new(template).render(binding, locales)
  end

  def render_with_layout(file, locales = {})
    template = File.read("views/layout.haml")
    Haml::Engine.new(template).render(binding, locales) do
      render(file, locales)
    end
  end

  def call(env)
    # TODO: Use Rack::Request.new(env)
    path_info = env['PATH_INFO']

    body = nil
    headers = {}

    case path_info
    when '/'
      body = render_with_layout :home, posts: Post.all(limit: 5)
    when '/about'
      body = render_with_layout :post, post: Post.find('pages/about.md')
    when '/posts'
      body = render_with_layout :posts, posts: Post.all
    when %r{^/posts/.*}
      file_path = path_info.delete_prefix('/')
      if File.exist?(file_path)
        body = File.read(file_path)
        headers["Content-Type"] = Rack::Mime.mime_type(File.extname(file_path))
      else
        post = Post.find(file_path + '.md')
        body = render_with_layout(
          :post,
          post: post,
          title: post.title_text,
          description: post.description_text
        )
      end
    when '/screen.css'
      headers["Content-Type"] = "text/css"
      body = SassC::Engine.new(
        File.read("css/screen.sass"),
        style: :compressed,
        syntax: :sass
      ).render
    when %r{^/dev/.*}
      raise NotFound if ENV['RACK_ENV'] == 'production'

      if env['REQUEST_METHOD'] == 'POST'
        data = JSON.parse(env['rack.input'].read)
        md_path = data['pathname'].delete_prefix('/') + '.md'
        raise NotFound unless File.exist?(md_path)

        dir = File.dirname(md_path)
        content = Base64.decode64(data['result'].split(',').last)
        file_name = data['name'].gsub(' ', '_')
        file_path = "#{dir}/#{file_name}"
        File.write(file_path, content)
        File.open(md_path, 'a') { |f|
          f.puts "\n![#{data['name']}](#{file_name})\n"
        }
        return [204, {}, []]
      else
        file_path = path_info.delete_prefix('/')
        raise NotFound unless  File.exist?(file_path)

        body = File.read(file_path)
        headers["Content-Type"] = Rack::Mime.mime_type(File.extname(file_path))
      end
    else
      file_path = "public#{path_info}"
      raise NotFound unless File.exists?(file_path)

      body = File.read(file_path)
      headers["Content-Type"] = Rack::Mime.mime_type(File.extname(file_path))
    end

    headers["Content-Type"] ||= "text/html"
    headers["Content-Length"] = body.bytesize.to_s

    [200, headers, [body]]
  rescue NotFound
    return [404, {}, ['Not Found']]
  end
end
