module Sanitizer
  def sanitize(target)
    node_set =
      case target
      when Oga::XML::NodeSet
        target
      when Oga::XML::Document, Oga::XML::Element
        target.children
      when String
        Oga.parse_html(target).children
      else
        raise "Unexpected class for sanitize: #{target.class}"
      end

    node_set
      .map do
        if _1.is_a?(Oga::XML::Text)
          _1.text
        elsif _1.is_a?(Oga::XML::Comment) || %w[script style].include?(_1.name)
          nil
        else
          " #{sanitize(_1.children)} "
        end
      end.flatten.compact.join.strip.gsub(/ {2,}/, ' ')
  end
end
