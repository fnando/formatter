class Markup
  attr_accessor :markup
  
  def initialize(format, text)
    raise ArgumentError, "expected format to be :textile or :markup; received #{format.inspect}" unless [:textile, :markdown].include?(format)
    
    if format == :markdown
      require 'rdiscount'
      @markup = RDiscount.new(text)
    else
      require 'RedCloth'
      @markup = RedCloth.new(text)
    end
  end
  
  def to_html
    @markup.to_html
  end
end