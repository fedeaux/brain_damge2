require_relative '../templateable/class_templateable'

module BrainDamage
  class ModelGenerator < Templateable::ClassTemplateable
    def initialize(resource, options = {})
      @template_file = 'model.rb'
      super
    end

    def generate
      improve_belongs_to_lines
      add_lines_from_fields
      super
    end

    def attribute_white_list
      @resource.fields.values.map(&:attr_white_list).reject(&:nil?).join ', '
    end

    def improve_belongs_to_lines
      return unless @parser and @parser.leading_class_method_calls

      belongs_to_lines = @parser.leading_class_method_calls.each_with_index.map { |line, index|
        [index, line.print]
      }.select{ |pair|
        pair.second =~ /belongs_to :(\w+)\s*$/
      }.map { |pair|
        [pair.first, add_options_to_belongs_to_line(pair.second) ]
      }.each { |pair|
        @parser.leading_class_method_calls[pair.first].line = pair.second
      }
    end

    def add_lines_from_fields
      @parser.leading_class_method_calls += @resource.fields.values.map(&:model_lines).flatten.reject(&:nil?).reject(&:empty?).map { |line|
        RubySimpleParser::CodeLine.new line

      }
    end

    def add_options_to_belongs_to_line(line)
      related_field = line.scan(/:(\w+)/).first.first.to_sym
      options = @resource.columns[related_field].dup
      options.delete :type

      options = options.map { |key, value|
        "#{key}: '#{value}'"
      }

      if options.any?
        "#{line}, #{options.join(', ')}"
      else
        line
      end
    end

    private
    def dir
      __dir__
    end
  end
end
