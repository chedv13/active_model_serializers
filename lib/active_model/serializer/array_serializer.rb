module ActiveModel
  class Serializer
    class ArraySerializer
      include Enumerable
      delegate :each, to: :@objects

      attr_reader :meta, :meta_key

      def initialize(objects, options = {})
        @resource = objects
        @objects = objects.map do |object|
          serializer_class = options.fetch(
              :serializer,
              ActiveModel::Serializer.serializer_for(object)
          )
          serializer_class.new(object, options.except(:serializer))
        end
        @meta = options[:meta]
        @meta_key = options[:meta_key]

        if options[:count]
          object, @count = objects.first, {}

          options[:count].split(',').each do |field|
            if object.respond_to?(field.to_sym)
              @count[field] = count(object.class, field)
            end
          end
        end
      end

      def count(klass, field)
        klass.select("COUNT(*) AS count, #{field}").where(user_id: 130353).group(field).as_json.map { |x| { x[field] => x.count } }
      end

      def json_key
        if @objects.first
          @objects.first.json_key.pluralize
        else
          @resource.name.downcase.pluralize if @resource.try(:name)
        end
      end

      def root=(root)
        @objects.first.root = root if @objects.first
      end
    end
  end
end
