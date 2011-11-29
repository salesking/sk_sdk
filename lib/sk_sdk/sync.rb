module SK::SDK

  # Provide methods for mapping and syncing the fields of a remote to local
  # object.
  # The class gets two objects(local/remote) and a field-map(Array) which
  # maps the field-names between those two. Of course your objects MUST respond
  # to the method names passed in the mapping.
  #
  # When syncing the corresponding fields, the names are simply #send to each
  # object.
  #
  # After an object was updated you can check the #log for changes
  # 
  # == Example
  #
  #  map =[
  #   [:name, :full_name, :'someClass.set_local_name', :'SomeClass.set_remote_name'],
  #   [:street, :address1]
  #  ]
  #   map = SK::SDK::Sync.new(@local_user, @remote_user, map)
  #   map.update(:r) #Does not save! only sets the field values on the remote object
  #
  # == Mapping Explanation
  # 
  # A mapping consist of the local and the remote field name. It can further
  # contain transition methods if the value needs to be changed when set from
  # one side to the other.
  #
  # Those methods will be called(eval'ed) and receive the value from the other
  # side as param:
  #
  # Mappings are passed as an array:
  # [
  #   [:local_field_name, :remote_field_name, "SomeClass.left_trans", "SomeClass.rigt_trans"]
  #   [:firstname, :first_name, :'SomeClass.set_local_name', :'SomeClass.set_remote_name']
  # ]
  class Sync

    # The local object
    attr_accessor :l_obj
    # The remote object
    attr_accessor :r_obj
    # <Hash{Symbol=>Symbol, Symbol=>{Hash} }>::the field mapping
    attr_reader :fields
    # the outdated fields
    attr_reader :outdated
    # <Array[String]>::log field changes
    attr_reader :log

    # Takes a local and remote object which should respond to function defined
    # in the mapping hash
    # === Parameter
    # l_obj<Object>::
    # r_obj<Object>::
    # field_map<Hash{Symbol=>Symbol, Symbol=>{Hash} }>::the field mapping
    def initialize(l_obj, r_obj, field_map)
      @l_obj = l_obj
      @r_obj = r_obj
      self.fields = field_map
      @log = []
    end

    # === Parameter
    # field_map<Array[Hash{}]>::
    def fields=(field_map)
      @fields = []
      field_map.each { |fld| @fields << Field.new(fld) }
      @fields
    end

    # Find a field by its local name
    # === Parameter
    # l_name<Symbol>:: local name
    # === Return
    # <Field>::
    def field(l_name)
      fields.find{|fld| fld.l_name == l_name}
    end

    # Check if the any of the fields are outdated
    # Populates self.outdated with outdated local field names
    # === Returns
    # <Boolean>:: false if not outdated
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
    # === Parameter
    # side<String|Symbol>:: the side to update l OR r
    # flds<Array[Field] | nil>:: fields to update, if nil all fields are updated
    def update(side, flds=nil)
      raise ArgumentError, 'The side to update must be :l or :r' unless [:l, :r].include?(side)
      target, source = (side==:l) ? [:l, :r] : [:r, :l]
      # use set field/s or update all
      flds ||= fields
      target_obj, source_obj = self.send("#{target}_obj"), self.send("#{source}_obj")
      flds.each do |fld|
        target_name, source_name = fld.send("#{target}_name"), fld.send("#{source}_name")
        # remember for log
        old_val = target_obj.send(target_name) rescue 'empty'
        # get new value through transfer method or direct
        new_val = if fld.transition? #call transfer function
                    cur_trans = fld.send("#{target}_trans")
                    eval "#{cur_trans} source_obj.send( source_name )"
                  else # lookup directly on other side object
                    source_obj.send( source_name )
                  end
        target_obj.send( "#{target_name}=" , new_val )

        log << "#{target_name} was: #{old_val} updated from: #{source_name} with value: #{new_val}"
      end
    end

    # A Sync::Field holds the local(left) and remote(right) field names and if
    # available the transfer methods.
    class Field
      attr_reader :l_name, :r_name, :l_trans, :r_trans

      # Create a new sync field. the local and remote name MUST be set.
      # Transition methods are optional.
      #
      # == Example

      # With options as array:
      # opts = [:local_name, :remote_name, "SomeClass.left_trans", "SomeClass.rigt_trans"]
      # fld = Field.new opts
      #
      # == Parameter
      # opts<Hash>::
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
    end # class Field


  end # Sync
end