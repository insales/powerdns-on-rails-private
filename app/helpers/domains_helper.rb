module DomainsHelper
  def select_record_type( form )
    types = if current_user
      RecordTemplate.record_types.map{ |t| [t,t] } - [["SOA", "SOA"]]
    else
      current_token.new_types
    end
    form.select( :type, types )
  end

  def domain_name_with_encoded(name)
    encoded = name.from_punicode
    encoded != name ? "#{encoded} (#{name})" : name
  end
end
