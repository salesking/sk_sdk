module ActiveResource
  # Overridden methods to suit SalesKing's nested json format
  # only valid for AR 4+
  # In the future might add a custom format class, see base.format
  class Base

    # override ARes method to parse only the client part
    def load_attributes_from_response(response)
      if (response['Transfer-Encoding'] == 'chunked' || (!response['Content-Length'].blank? && response['Content-Length'] != "0")) && !response.body.nil? && response.body.strip.size > 0
        load( self.class.format.decode(response.body)[self.class.element_name] )
        #fix double nested items .. active resource SUCKS soooo bad
        if self.respond_to?(:items)
          new_items = []
          self.items.each { |item| new_items << item.attributes.first[1] }
          self.items = new_items
        end
        @persisted = true
      end
    end
private
    # Overridden to grab the data(= clients-collection) from json:
    # { 'collection'=> will_paginate infos,
    #   'links' => prev/next links
    #   'clients'=> [data],             << what we need
    # }
    def self.instantiate_collection(collection, original_params = {}, prefix_options = {})
      elements_name = self.element_name.pluralize if collection.is_a?(Hash)
      collection_parser.new(collection, elements_name).tap do |parser|
        parser.resource_class  = self
        parser.original_params = original_params
      end.collect! { |record| instantiate_record(record, prefix_options) }
    end
  end
end
