class RecordTemplate < ActiveRecord::Base

  belongs_to :zone_template

  # General validations
  validates_presence_of :zone_template_id
  validates_associated :zone_template
  validates_presence_of :record_type

  before_save :update_soa_content
  before_validation :inherit_ttl
  after_initialize :update_convenience_accessors
  validate :validate_record_template

  attr_accessible :record_type, :name, :ttl, :prio, :content
  attr_accessible :zone_template # для тестов

  # We need to cope with the SOA convenience
  attr_accessor *Record::SOA::SOA_FIELDS
  attr_accessible *Record::SOA::SOA_FIELDS

  class << self
    def record_types
      Record.record_types
    end
  end

  # Hook into #reload
  def reload
    super.tap { update_convenience_accessors }
  end

  # Convert this template record into a instance +record_type+ with the
  # attributes of the template copied over to the instance
  def build( domain_name = nil )
    # get the class of the record_type
    record_class = Record.record_class(self.record_type)
    white_list = record_class.accessible_attributes

    # duplicate our own attributes, strip out the ones the destination doesn't
    # have (and the id as well)
    attrs = attributes.dup.with_indifferent_access
    attrs.delete_if { |k,_|
      !record_class.columns.map(&:name).include?(k) || white_list.deny?(k)
    }
    attrs.delete( :id )

    # parse each attribute, looking for %ZONE%
    unless domain_name.nil?
      attrs.keys.each do |k|
        attrs[k] = attrs[k].gsub( '%ZONE%', domain_name ) if attrs[k].is_a?( String )
      end
      # на 2.4 можно так:
      # attrs.transform_values!{ |val| val.is_a?(String) ? val.gsub('%ZONE%', domain_name) : val }
    end

    # Handle SOA convenience fields if needed
    if soa?
      Record::SOA::SOA_FIELDS.each do |soa_field|
        attrs[soa_field] = instance_variable_get("@#{soa_field}")
      end
      attrs[:serial] = 0
    end

    # instantiate a new destination with our duplicated attributes & validate
    record_class.new attrs
  end

  def soa?
    self.record_type == 'SOA'
  end

  def content
    soa? ? Record::SOA::SOA_FIELDS.map{ |f| instance_variable_get("@#{f}") || 0 }.join(' ') : self[:content]
  end

  # Manage TTL inheritance here
  def inherit_ttl
    unless self.zone_template_id.nil?
      self.ttl ||= self.zone_template.ttl
    end
  end

  # Manage SOA content
  def update_soa_content #:nodoc:
    self[:content] = content
  end

  # Here we perform some magic to inherit the validations from the "destination"
  # model without any duplication of rules. This allows us to simply extend the
  # appropriate record and gain those validations in the templates
  def validate_record_template #:nodoc:
    return # this magic fails!
    unless self.record_type.blank?
      record = build
      record.errors.each do |k,v|
        # skip associations we don't have, validations we don't care about
        next if %i[domain_id domain name].include?(k)

        self.errors.add( k, v )
      end unless record.valid?
    end
  end

  private

  # Update our convenience accessors when the object has changed
  def update_convenience_accessors
    return unless self.record_type == 'SOA'

    # Setup our convenience values
    @primary_ns, @contact, @serial, @refresh, @retry, @expire, @minimum =
      self[:content].split(/\s+/) unless self[:content].blank?
    %w{ serial refresh retry expire minimum }.each do |i|
      value = instance_variable_get("@#{i}")
      value = value.to_i unless value.nil?
      send("#{i}=", value )
    end
  end
end
