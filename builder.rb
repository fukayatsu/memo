require './app'

class Builder
  OUTPUT_DIR = 'build'

  def build
    FileUtils.rm_rf('build')

    App.paths.each do |path|
      response = App.new.call('PATH_INFO' => path)
      raise "Error on path: #{path}" unless response[0] == 200

      dist = file_path(path, response)
      content = response.dig(2, 0)
      write_content(dist, content)
    end

    copy_static_files
  end

  private

  def copy_static_files
    FileUtils.copy(Dir.glob('public/*'), "#{OUTPUT_DIR}/")
  end

  def write_content(dist, content)
    FileUtils.mkdir_p(File.dirname(dist))
    File.write(dist, content)
  end

  def file_path(request_path, response)
    if request_path == '/'
      "#{OUTPUT_DIR}/index.html"
    elsif response.dig(1, "Content-Type") == 'text/html'
      "#{OUTPUT_DIR}#{request_path}.html"
    else
      "#{OUTPUT_DIR}#{request_path}"
    end
  end
end
