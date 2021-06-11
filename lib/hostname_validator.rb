class HostnameValidator < ActiveModel::EachValidator
  include RecordPatterns

  def validate_each( record, attribute, value )
    record.errors.add(attribute, I18n.t(:message_attribute_must_be_hostname)) unless hostname?( value ) && !ip?( value )
  end

end
