class ZoneTemplate < ActiveRecord::Base

  belongs_to :user
  has_many :record_templates

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :ttl

  attr_accessible :name, :content, :ttl, :prio

  # Scopes
  scope :user, lambda { |user| user.admin? ? nil : where(:user_id => user.id) }
  scope :with_soa, -> { joins(:record_templates).where('record_templates.record_type = ?', 'SOA') }
  default_scope { order('name') }

  class << self

    # Custom find that takes one additional parameter, :require_soa (bool), for
    # restricting the returned resultset to only instances that #has_soa?
    def find_with_validations( *args )
      options = args.extract_options!
      valid_soa = options.delete( :require_soa ) || false

      # find as per usual
      records = find_without_validations( *args << options )

      if valid_soa
        records.delete_if { |z| !z.has_soa? }
      end

      records # give back
    end
    alias_method_chain :find, :validations
  end

  # Build a new zone using +self+ as a template. +domain+ should be valid domain
  # name. Pass the optional +user+ object along to have the new one owned by the
  # user, otherwise it's for admins only.
  #
  # This method will throw exceptions as it encounters errors, and will use a
  # transaction to complete/rollback the operation.
  def build( domain_name, user = nil )
    soa_template = record_templates.detect { |r| r.record_type == 'SOA' }
    soa_args = soa_template && Hash[SOA::SOA_FIELDS.map { |f| [f, soa_template.send(f)] }] || {}
    # TODO: более аккуратно разложить, например сделать record_template#build_attributes
    soa_args.each_pair { |k,v| soa_args[k] = v.gsub('%ZONE%', domain_name) if v.is_a?(String) }

    domain = Domain.new soa_args.merge(name: domain_name, ttl: ttl)
    domain.user = user if user.is_a?( User )

    self.class.transaction do
      # save the zone or die
      domain.save!

      # get the templates
      templates = record_templates.dup

      Record.batch do
        # now build the remaining records according to the templates
        templates.delete( soa_template )
        templates.each do |template|
          record = template.build( domain_name )
          record.domain = domain
          record.save!
        end
      end
    end

    domain
  end

  # If the template has an SOA record, it can be used for building zones
  def has_soa?
    record_templates.count( :conditions => "record_type LIKE 'SOA'" ) == 1
  end

end
