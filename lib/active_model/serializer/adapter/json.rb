module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = {})
          if serializer.respond_to?(:each)
            @result = serializer.map { |s| FlattenJson.new(s).serializable_hash }
          else
            @hash = {}

            @core = serializer.attributes(options)

            serializer.each_association do |name, association, opts|
              if association.respond_to?(:each)
                array_serializer = association
                @hash[name] = array_serializer.map do |item|
                  res = {}

                  res.merge!(item.attributes(opts))

                  item.each_association do |inner_name, inner_assoc, inner_opts|
                    res.merge!({ inner_name => inner_assoc.attributes(inner_opts) })
                  end

                  res
                end
              else
                if association && association.object
                  res = {}

                  res.merge!(association.attributes(options))

                  association.each_association do |inner_name, inner_assoc, inner_opts|
                    res.merge!({ inner_name => inner_assoc.attributes(inner_opts) })
                  end

                  @hash[name] = res
                elsif opts[:virtual_value]
                  @hash[name] = opts[:virtual_value]
                else
                  @hash[name] = nil
                end
              end
            end
            @result = @core.merge @hash
          end

          { root => @result }
        end
      end
    end
  end
end
