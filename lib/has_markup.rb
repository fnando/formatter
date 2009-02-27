%w(markup sanitize).each {|f| require File.dirname(__FILE__) + "/#{f}" }

module SimplesIdeias
  module HasMarkup
    def self.included(base)
      base.extend ClassMethods
      
      class << base
        attr_accessor :has_markup_options
      end
    end
    
    module ClassMethods
      def has_markup(attribute, options={})
        include SimplesIdeias::HasMarkup::InstanceMethods
        
        self.has_markup_options ||= {}
        self.has_markup_options[attribute] = {:sanitize => true}.merge(options)
        
        before_save :sanitize_markup_attributes
      end
    end
    
    module InstanceMethods
      private
        def sanitize_markup_attributes
          self.class.has_markup_options.each do |attr_name, options|
            sanitize_markup(attr_name, options)
          end
        end
        
        def sanitize_markup(attr_name, options)
          if send("#{attr_name}_changed?") || send("formatted_#{attr_name}").blank?
            text = send(attr_name).to_s
            text = Markup.new(options[:format], text).to_html unless options[:format] == :html
            text = Sanitize.html(text, options) if options[:sanitize]
            write_attribute("formatted_#{attr_name}", text)
          end
        end
    end
  end
end