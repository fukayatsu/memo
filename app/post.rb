require 'commonmarker'
require 'front_matter_parser'
require 'oga'
require 'time'

require './app/sanitizer'
require './app/errors'

class Post
  include Sanitizer

  FILE_PATH_PATTERN = 'posts/**/*.md'

  class << self
    def all(limit: nil)
      paths = Dir.glob(FILE_PATH_PATTERN).sort.reverse
      paths = paths.take(limit) if limit
      paths.map { |file_path| Post.new(file_path) }
    end

    def find(path)
      if File.exist?(path)
        Post.new(path)
      else
        raise NotFound, "File Not Found: #{path}"
      end
    end
  end

  def initialize(file_path)
    @file_path = file_path
  end

  def path
    @path ||= "/" + @file_path.delete_suffix('.md')
  end

  def title_document
    @title_document ||= document.css('h1').first
  end

  def title_html
    @title_html ||= title_document.children.map(&:to_xml).join
  end

  def title_text
    @title_text ||= sanitize(title_document)
  end

  # 最初の見出しから次の見出しまでを抽出
  def description_document
    return @description_document if @description_document

    header_found = false
    children = []
    document.children.each do |elem|
      if elem.respond_to?(:name) && elem.name.match?(/\Ah\d\z/)
        break if header_found
        next header_found = true
      end
      children << elem if header_found
    end

    @description_document = Oga::XML::Document.new(children: children)
  end

  def description_html
    @description_html ||= description_document.to_xml
  end

  def description_text
    @description_text ||= sanitize(description_document)
  end

  def created_at
    return nil unless m = @file_path.match(%r!(?<date>\d{4}/\d{2}/\d{2})/(?<hour>\d{2})(?<minute>\d{2})!)
    Time.parse("#{m[:date]} #{m[:hour]}:#{m[:minute]}:00 +0900")
  end

  def html_without_header
    return @html_without_header if @html_without_header

    document.children[1..-1].map(&:to_xml).join.strip
  end

  def html
    return @html if @html
    parsed = FrontMatterParser::Parser.parse_file(@file_path, loader: unsafe_loader)
    # meta_data = parsed.front_matter.transform_keys(&:to_sym)
    @content = parsed.content

    doc = CommonMarker.render_doc(parsed.content, [
      # :DEFAULT,
      :FOOTNOTES,
      :STRIKETHROUGH_DOUBLE_TILDE,
      :VALIDATE_UTF8
    ], [
      :table,
      :strikethrough,
      :autolink
    ])
    @html = doc.to_html([
      # :DEFAULT,
      :HARDBREAKS,
      :UNSAFE,
      :SOURCEPOS,
      :TABLE_PREFER_STYLE_ATTRIBUTES
    ])
  end

  private

  def document
    @document ||= Oga.parse_html(html)
  end

  def unsafe_loader
    @unsafe_loader ||= -> (string) { YAML.load(string) }
  end
end
