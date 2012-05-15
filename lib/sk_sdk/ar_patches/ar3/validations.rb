module ActiveResource
  class Errors < ActiveModel::Errors
    # Patched cause we dont need no attribute name magic .. and its just simpler
    # orig version is looking up the humanized name of the attribute in the error
    # message, which we dont supply => only field name is used in returned error msg
    def from_array(messages, save_cache=false)
      clear unless save_cache
      messages.each do |message_hash|
        message_hash.each do |attr_name, attr_values|
          attr_values.each do |attr_value|
            add attr_name, attr_value
          end
        end
      end
    end
  end #Errors
end
