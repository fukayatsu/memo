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
    when %r{^/posts/[^\.]+\.[^\.]{3,}$}
      path = path_info.delete_prefix('/')
      raise NotFound unless File.exist?(path)
      body = File.read(path)
      headers["Content-Type"] = Rack::Mime.mime_type(File.extname(path))
    when %r{^/posts/.*}
      file_path = path_info.delete_prefix('/') + '.md'
      body = render_with_layout :post, post: Post.find(file_path)
    when '/screen.css'
      headers["Content-Type"] = "text/css"
      body = SassC::Engine.new(
        File.read("css/screen.sass"),
        style: :compressed,
        syntax: :sass
      ).render
    else
      raise NotFound
    end

    headers["Content-Type"] ||= "text/html"
    headers["Content-Length"] = body.bytesize.to_s

    [200, headers, [body]]
  rescue NotFound
    return [404, {}, ['Not Found']]
  end
end
