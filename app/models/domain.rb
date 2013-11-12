require 'scoped_finders'

# = Domain
#
# A #Domain is a unique domain name entry, and contains various #Record entries to
# represent its data.
#
# The zone is used for the following purposes:
# * It is the $ORIGIN off all its records
# * It specifies a default $TTL
#
class Domain < ActiveRecord::Base
  audited :allow_mass_assignment => true
  has_associated_audits

  belongs_to :user

  has_many :records, :dependent => :destroy

  has_one  :soa_record,    :class_name => 'SOA'
  has_many :ns_records,    :class_name => 'NS'
  has_many :mx_records,    :class_name => 'MX'
  has_many :a_records,     :class_name => 'A'
  has_many :txt_records,   :class_name => 'TXT'
  has_many :cname_records, :class_name => 'CNAME'
  has_one  :loc_record,    :class_name => 'LOC'
  has_many :aaaa_records,  :class_name => 'AAAA'
  has_many :spf_records,   :class_name => 'SPF'
  has_many :srv_records,   :class_name => 'SRV'
  has_many :sshfp_records, :class_name => 'SSHFP'
  has_many :ptr_records,   :class_name => 'PTR'

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :type, :in => %w(NATIVE MASTER SLAVE), :message => "must be one of NATIVE, MASTER, or SLAVE"

  validates_presence_of :master, :if => :slave?
  validates_format_of :master, :if => :slave?,
    :allow_blank => true,
    :with => /\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z/

  # Disable single table inheritence (STI)
  self.inheritance_column = 'not_used_here'

  attr_accessor :zone_template_id, :zone_template_name
  attr_accessible :type, :ttl, :name, :master, :zone_template_id, :zone_template_name

  # Virtual attributes that ease new zone creation. If present, they'll be
  # used to create an SOA for the domain
  attr_accessor *SOA::SOA_FIELDS
  attr_accessible *SOA::SOA_FIELDS

  SOA::SOA_FIELDS.each do |f|
    next if :serial == f # serial is generated in soa
    validates_presence_of f, :on => :create, :unless => :slave?
  end

  # Scopes
  scope :user, lambda { |user| user.admin? ? nil : where(:user_id => user.id) }
  default_scope order('name')

  class << self
    def search( string, page, user = nil )
      query = self.scoped
      query = query.user( user ) unless user.nil?
      query.where('name LIKE ?', "%#{string.to_punicode}%").paginate( :page => page )
    end
  end

  def initialize(params = {})
    params_sym = params.symbolize_keys
    super self.class.const_defined?(:DOMAIN_DEFAULTS) ?
      DOMAIN_DEFAULTS.merge(params_sym) : params_sym
    build_soa_record
  end

  def name=(val)
    super val.try(:to_punicode)
  end

  # arguably should have as_json includes here too FIX
  def to_xml(options={})
    super(options.merge(:include => :records))
  end

  # Are we a slave domain
  def slave?
    self.type == 'SLAVE'
  end

  # return the records, excluding the SOA record
  def records_without_soa
    records.includes(:domain).all.select { |r| !r.is_a?( SOA ) }.sort_by {|r| [r.shortname, r.type]}
  end

  # Setup an SOA if we have the requirements
  def build_soa_record #:nodoc:
    return if self.slave?

    soa_args = Hash[SOA::SOA_FIELDS.map { |f| [f, send(f)] }]
    self.records << soa = SOA.new(soa_args)
    self.soa_record = soa
    soa.domain = self
  end

  def attach_errors(e)
    e.message.split(":")[1].split(",").uniq.each do |m|
      self.errors.add(m , '')
    end
  end
end
