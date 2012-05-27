module SK::SDK

  # Provide methods for mapping and syncing the fields of a remote to local
  # object.
  # Sync needs a local(left), a remote(right) object and a field-map(Array) to
  # map the field-names between those two. Optionally you can add transition
  # methods to convert the values from on side to the other.
  #
  # When syncing the corresponding fields, the names are simply #send to each
  # object.
  #
  # After an object was updated you can check the #log for changes. Sync does
  # not save anything, it only sets the field values on the other object.
  #
  #
  # == Example
  #
  #  map =[
  #   [:name, :full_name, :'someClass.set_local_name', :'MyClass.set_remote_name'],
  #   [:street, :address1]
  #  ]
  #  map = SK::SDK::Sync.new(@local_user, @remote_user, map)
  #  map.update(:r)
  #
  # == Mapping Explained
  #
  # Mappings are passed as an array:
  #   [
  #    [:local_field_name, :remote_field_name, "MyClass.local_trans", "MyClass.remote_trans"]
  #    [:firstname, :first_name, :'MyClass.set_local_name', :'MyClass.set_remote_name']
  #   ]
  # A mapping consist of a local and the remote field(method) name. And might
  # contain transition methods, if the value needs to be changed when set from
  # one side to the other. Those methods will be called with the value from
  # the other side.
  #   local_obj.field = MyClass.local_trans(remote_obj.field)
  #
  class Sync

    # @return [Object] The local object
    attr_accessor :l_obj
    # @return [Object] The remote object
    attr_accessor :r_obj
    # @return [Array<Field>] mapped fields
    attr_reader :fields
    # @return [Array<Field>] outdated fields
    attr_reader :outdated
    # @return [Array<String>] log of field changes
    attr_reader :log

    # @param [Object] local_object
    # @param [Object] remote_object
    # @param [Array<String,Symbol>] field_map assign local to remote field names
    def initialize(local_object, remote_object, field_map)
      @l_obj = local_object
      @r_obj = remote_object
      self.fields = field_map
      @log = []
    end

    # Create field for given mapping arrays and resets all existing ones
    # @param [Array<Array>] field_maps
    def fields=(field_maps)
      @fields = []
      field_maps.each { |fld| @fields << Field.new(fld) }
      @fields
    end

    # Find a field by its local name
    #
    # @param [Symbol] l_name local name
    # @return [Field]
    def field(l_name)
      fields.find{|fld| fld.l_name == l_name}
    end

    # Check if the any of the fields are outdated
    # Populates #outdated with local field names
    #
    # @return [Boolean] false if not outdated
    def outdated?
      @outdated = []
      fields.each do |fld|
        if fld.transition?
          # call r_trans method with local val to compare local with remote val
          # SomeTrans.remote_transfer_method( l_obj.field )
          virtual_l_val = eval "#{fld.r_trans} l_obj.send( fld.l_name )"
          @outdated << fld if virtual_l_val != r_obj.send( fld.r_name )
        else
          # no transfer method, directly compare values
          @outdated << fld if r_obj.send( fld.r_name ) != l_obj.send( fld.l_name )
        end
      end
      !@outdated.empty?
    end

    # update all local outdated fields with values from remote object
    def update_local_outdated
      update(:l, @outdated) if outdated?
    end
    # update all remote outdated fields with values from local object
    def update_remote_outdated
      update( :r, @outdated) if outdated?
    end

    # Update a side with the values from the other side.
    # Populates the log with updated fields and values.
    #
    # @param [String|Symbol] side to update l OR r
    # @param [Array<Field>, nil] flds fields to update, default nil update all fields
    def update(side, flds=nil)
      raise ArgumentError, 'The side to update must be :l or :r' unless [:l, :r].include?(side)
      target, source = (side==:l) ? [:l, :r] : [:r, :l]
      # use set field/s or update all
      flds ||= fields
      target_obj = self.send("#{target}_obj")
      source_obj = self.send("#{source}_obj")
      flds.each do |fld|
        target_name = fld.send("#{target}_name")
        source_name = fld.send("#{source}_name")
        # remember for log
        old_val = target_obj.send(target_name) rescue 'empty'
        # get new value through transfer method or direct
        new_val = if fld.transition?
                    cur_trans = fld.send("#{target}_trans")
                    eval "#{cur_trans} source_obj.send( source_name )"
                  else
                    source_obj.send( source_name )
                  end
        target_obj.send( "#{target_name}=" , new_val )

        log << "#{target_name} was: #{old_val} updated from: #{source_name} with value: #{new_val}"
      end
    end

    # A Sync::Field holds the local(left) and remote(right) field name and if
    # available the transfer methods.
    class Field
      attr_reader :l_name, :r_name, :l_trans, :r_trans

      # Create a new sync field. The local and remote name MUST be set.
      # Transition methods are optional.
      #
      # @example no transition methods:
      #   opts = [:local_name, :remote_name]
      #   fld = Field.new opts
      # @example with transition method:
      #   opts = [:local_name, :remote_name, "AClass.local_transition", "AClass.remote_transition"]
      #   fld = Field.new opts
      #
      # @param [Array<String, Symbol>] opts
      def initialize(opts)
        if opts.is_a? Array
          @l_trans, @r_trans = opts[2], opts[3] if opts.length == 4
          @l_name = opts[0]
          @r_name = opts[1]
        end
      end

      def transition?
        @l_trans && @r_trans
      end
    end

  end # Sync
end