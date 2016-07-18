Dir[File.dirname(__FILE__) + '/base/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/single_page_manager/*.rb'].each {|file| require file }

module BrainDamage
  module ViewSchemas
    class Base
      attr_reader :views

      def initialize(resource)
        find_views_names

        @views = {}
        @resource = resource
      end

      def find_views_names
        schema_class = self.class
        @views_names = []

        loop do
          path = File.join(dir, schema_class.name.demodulize.underscore, 'templates/')
          @views_names += Dir.glob(path + '**/*' ).select{ |name|
            name =~ /html.haml$/
          }.map{ |name|
            name.gsub('.html.haml', '').gsub(path, '')
          }

          break if schema_class == BrainDamage::ViewSchemas::Base
          schema_class = schema_class.superclass
        end

        @views_names.uniq!
      end

      def ensure_views_descriptions
        @views_names.each do |name|
          describe_view name unless @views.has_key? name
        end
      end

      def describe_view(name, options = {})
        # First it tries BrainDamage::View::[SpecificSchemaClass]::[SpecificViewClass]
        # Then it tries BrainDamage::View::[SpecificSchemaClass]::Base
        # If none exists, it will try both again with SpecificSchemaClass.parent, until eventually
        # landing on BrainDamage::View::Base::Base

        schema_class = self.class

        view_class_name = name.gsub('/', '::').camelize

        loop do
          specific_view_class_name = "BrainDamage::View::#{schema_class.name.demodulize}::#{view_class_name}"

          if Object.const_defined? specific_view_class_name
            @views[name] = eval(specific_view_class_name).new @resource, options
            break
          end

          base_view_class_name = "BrainDamage::View::#{schema_class.name.demodulize}::Base"
          if Object.const_defined? base_view_class_name
            klass = eval base_view_class_name

            if klass.has_template? name
              options[:file_name] = "#{name}.html.haml" unless options[:file_name]
              options[:template_name] = "#{name}.html.haml" unless options[:template_name]
              @views[name] = eval(base_view_class_name).new @resource, options
              break
            end
          end

          schema_class = schema_class.superclass

          if schema_class == Object
            puts "ERROR: Unable to find any class capable of rendering the view: #{name}"
            break
          end
        end
      end

      private
      def self.dir
        __dir__
      end

      def dir
        __dir__
      end
    end
  end
end
