# See #Record

# = Record
#
# The parent class for all our DNS RR's. Used to apply global rules and logic
# that can easily be applied to any DNS RR's
#
class Record < ActiveRecord::Base
  audited :associated_with => :domain, :allow_mass_assignment => true
  self.non_audited_columns.delete( self.inheritance_column ) # Audit the 'type' column

  def self.attributes_protected_by_default
    []
  end

  def self.find_sti_class(type_name)
    super("Record::#{type_name}")
  end

  def self.sti_name
    self.name.sub(/^.*:/, "")
  end

  def haml_object_ref
    self.class.sti_name.downcase
  end

  belongs_to :domain

  scope :ordered, ->{ order(Arel.sql("record_type='SOA' DESC, name ASC, id ASC")) }

  validates_presence_of :domain_id
  validates_presence_of :name
  validates_numericality_of :ttl,
    :greater_than_or_equal_to => 0,
    :only_integer => true

  class_attribute :batch_soa_updates

  attr_accessible :content, :name, :ttl, :prio
  attr_accessible :domain # хакофикс тестов, но вообще надо просто record создавать через domain

  # This is needed here for generic form support, actual functionality
  # implemented in #SOA
  attr_accessor :primary_ns, :contact, :refresh, :retry, :expire, :minimum

  before_validation :inherit_attributes_from_domain
  before_save :update_change_date
  after_save  :update_soa_serial

  # Known record types

  class_attribute :record_types
  self.record_types = ['A', 'AAAA', 'CNAME', 'LOC', 'MX', 'NS', 'PTR', 'SOA', 'SPF', 'SRV','SSHFP', 'TXT']

  validates_inclusion_of :type, in: self.record_types

  class << self
    # Restrict the SOA serial number updates to just one during the execution
    # of the block. Useful for batch updates to a zone
    def batch
      raise ArgumentError, "Block expected" unless block_given?

      # FIXME: такое надо складывать в Thread.current
      self.batch_soa_updates = []
      yield
      self.batch_soa_updates = nil
    end

    def record_class(type)
      "Record::#{type}".constantize
    end

    # Make some ammendments to the acts_as_audited assumptions
    def configure_audits
      record_types.each do |type|
        klass = record_class(type)
        defaults = [klass.non_audited_columns ].flatten
        defaults.delete( klass.inheritance_column )
        defaults.push( :change_date )
        klass.write_inheritable_attribute :non_audited_columns, defaults.flatten.map(&:to_s)
      end
    end
  end

  def shortname
    self[:name].gsub( /\.?#{self.domain.name}$/, '' )
  end

  def shortname=( value )
    self[:name] = value
  end

  # Nicer representation of the domain as XML
  def to_xml(options = {}, &block)
    # no difference?
    super(options, &block)
  end

  # Pull in the name & TTL from the domain if missing
  def inherit_attributes_from_domain #:nodoc:
    return unless self.domain
    append_domain_name!
    self.ttl ||= self.domain.ttl
  end

  # Update the change date for automatic serial number generation
  def update_change_date
    self.change_date = Time.now.to_i
  end

  def update_soa_serial #:nodoc:
    unless self.type == 'SOA' || @serial_updated || self.domain.slave?
      self.domain.soa_record.update_serial!
      @serial_updated = true
    end
  end

  # By default records don't support priorities. Those who do can overwrite
  # this in their own classes.
  def supports_prio?
    false
  end

  private

  # Append the domain name to the +name+ field if missing
  def append_domain_name!
    self[:name] = self.domain.name if self[:name].blank?
    self[:name] += ".#{self.domain.name}" unless self[:name].index( self.domain.name )
  end
end
