require "singleton"

class Sanitize
  TIDY_LOOKUP = [
    '/usr/local/lib/',
    '/opt/local/lib/',
    '/usr/lib/'
  ]
  
  TIDY_OPTIONS = {
    :output_xhtml => true, 
    :show_body_only => true,
    :char_encoding => "utf8",
    :indent => false,
    :wrap => 0,
    :anchor_as_name => false,
    :drop_empty_paras => true
  }
  
  include Singleton
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::SanitizeHelper
  
  def self.html(text, options={})
    text = tidy(text, TIDY_OPTIONS) if options[:tidy]
    
    html_options = {}
    html_options[:attributes] = options[:attributes] if options[:attributes]
    html_options[:tags] = options[:tags] if options[:tags]
    text = instance.sanitize(text, html_options)
    text = tidy(text, TIDY_OPTIONS) if options[:tidy]
    text
  end
  
  def self.tidy(text, options={})
    require "tidy"
    
    if const_defined?('TIDY_PATH')
      lib_path = TIDY_PATH
    else
      TIDY_LOOKUP.each do |dir|
        %w(tidy libtidy).each do |file|
          %w(dylib so).each do |ext|
            lib_path = File.join(dir, "#{file}.#{ext}")
            break if File.exists?(lib_path)
          end
        end
      end
    end
    
    Tidy.path = lib_path
    
    Tidy.open(TIDY_OPTIONS.merge(options)) do |tidy|
      tidy.clean(text)
    end.strip
  end
end