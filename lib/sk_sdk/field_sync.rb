module SK::SDK
  # Provide methods for mapping and syncing the fields of a remote to local
  # object.
  # The class holds a remote and a local object. It works with a hash which
  # maps the fields between those two.
  # If you use such a mapping both of your objects MUST respond to the method
  # names passed in the mapping-table(hash)
  #
  # When an object is updated you can check the #log for changes
  # 
  # ==== Example
  #
  #  contact_map = {
  #     :l => :name,
  #     :r => :firstname,
  #     :trans => {
  #       :obj => 'ContactMapping',
  #       :l =>:set_local_name,
  #       :r => :set_remote_name
  #     }
  #   }
  #   map = SK::SDK::FieldSync.new(@local_user, @remote_user, contact_map)
  #   map.update_remote #Does not save! only sets the field values on the remote object
  #
  # ==== Mapping Hash Explanation
  #
  #  {
  #    :l => :name,               => Local fieldname
  #    :r => :firstname,          => remote fieldname
  #    :obj => 'ATransitionClass',      => The class which hold the following Transition methods as Class.methods
  #    :l =>:set_local_name,     =>  Method called when local field is updated
  #    :r => :set_remote_name    =>  Method called when remote field is update
  #  }
  class FieldSync

    # The local object
    attr_accessor :l_obj
    # The remote object
    attr_accessor :r_obj
    # <Hash{Symbol=>Symbol, Symbol=>{Hash} }>::the field mapping
    attr_accessor :fields
    # the outdated fields
    attr_reader :outdated
    # <Array[String]>::log field changes
    attr_reader :log

    # Takes a local and remote object which should respond to function defined
    # in the mapping hash
    # === Parameter
    # l_obj<Object>::
    # r_obj<Object>::
    # fields<Hash{Symbol=>Symbol, Symbol=>{Hash} }>::the field mapping
    def initialize(l_obj, r_obj, fields)
      @l_obj = l_obj
      @r_obj = r_obj
      @fields = fields
      @log = []
    end

    # check if the any of the fields are outdated
    # populates self.outdated array with outdated fields
    # ==== Returns
    # <Boolean>:: false if not outdated
    def outdated?
      @outdated = []
      fields.each do |fld|
        if fld[:trans]
          # SomeTransferObject.remote_tranfer_function(r_obj_data)
          virtual_local_val  = fld[:trans][:obj].constantize.send( fld[:trans][:r], l_obj.send( fld[:l] ) )
          @outdated << fld if virtual_local_val != r_obj.send( fld[:r] )
        else
          @outdated << fld if r_obj.send( fld[:r] ) != l_obj.send( fld[:l] )
        end
      end
      !@outdated.empty?
    end

    # update all local outdated fields with values from remote object
    def update_local_outdated
      update_local(@outdated) if outdated?
    end
    # update all remote outdated fields with values from local object
    def update_remote_outdated
      update_remote(@outdated) if outdated?
    end

    # update all local fields with values from remote
    def update_local(field=nil)
      update(:l, field)
    end

    # Update all or given remote fields with the value of the local fields
    #
    def update_remote(field=nil)
      update(:r, field)
    end

    # == Parameter
    # side<String|Symbol>:: the side to update l OR r
    # fields<Hash>::
    def update(side, field)
#      raise unless side in l or r
      # use single field/s or update all
      flds = field ? ( field.is_a?(Array) ? field : [field] ) : fields
      if side == :l
        current_obj, other_obj = l_obj, r_obj
        other_side = :r
      else
        current_obj, other_obj = r_obj, l_obj
        other_side = :l
      end
      
      flds.each do |fld|
#        transition = fld.delete :trans
#        fld.each{|k,v| l_name = k, r_name = v}
        # remember for log
        old_val = current_obj.send(fld[side]) rescue 'empty'
        # get new value through transfer method or direct
        new_val = if fld[:trans] #call transfer function
                    #TransObj.trans_method(remote obj key)
                    fld[:trans][:obj].constantize.send( fld[:trans][side], other_obj.send( fld[other_side] ) )
                  else # lookup directly on other side object
                    other_obj.send( fld[other_side] )
                  end
        current_obj.send( "#{fld[side]}=" , new_val )

        log << "#{fld[side]} was: #{old_val} updated from: #{fld[other_side]} with value: #{new_val}"
      end
    end

  end # FieldSync
end