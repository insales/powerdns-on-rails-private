# See #SOA

# = Start of Authority Record
# Defined in RFC 1035. The SOA defines global parameters for the zone (domain).
# There is only one SOA record allowed in a zone file.
#
# Obtained from http://www.zytrax.com/books/dns/ch8/soa.html
#
class Record::SOA < Record
  validates_presence_of :primary_ns, :content, :serial, :refresh, :retry,
    :expire, :minimum

  validates_numericality_of :serial, :refresh, :retry, :expire,
    :allow_blank => true,
    :greater_than_or_equal_to => 0

  validates_numericality_of :minimum, # RFC2308
    :allow_blank => true,
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 10800

  # FIXME: why disabled?
  #validates_uniqueness_of :domain_id
  validates_format_of :contact,
    with: /\A[a-zA-Z0-9\-\.]+@[a-zA-Z0-9-]+\.[a-zA-Z.]{2,6}\z/,
    message: 'contact should be valid email address'
  validates :name, :presence => true, :hostname => true

  before_validation :set_content
  before_update :update_serial
  after_initialize :update_convenience_accessors

  # The portions of the +content+ column that make up our SOA fields
  SOA_FIELDS = %i[primary_ns contact serial refresh retry expire minimum].freeze

  attr_accessible *SOA_FIELDS
  attr_accessor :serial
  # This allows us to have these convenience attributes act like any other
  # column in terms of validations
  SOA_FIELDS.each do |soa_entry|
    define_method "#{soa_entry}_before_type_cast" do
      instance_variable_get("@#{soa_entry}")
    end
  end

  # Treat contact specially, replacing the first period with an @ if
  # no @'s are present
  def contact=( email )
    if !email.nil? && email.index('@').nil?
      email.sub!('.', '@')
    end

    @contact = email
  end

  # Hook into #reload
  def reload
    super.tap { update_convenience_accessors }
  end

  # Updates the serial number to the next logical one. Format of the generated
  # serial is YYYYMMDDNN, where NN is the number of the change for the day.
  # 01 for the first change, 02 the seconds, etc...
  #
  # If the serial number is 0, we opt for PowerDNS's automatic serial number
  # generation
  def update_serial
    unless Record.batch_soa_updates.nil?
      if Record.batch_soa_updates.include?( self.id )
        return
      end

      Record.batch_soa_updates << self.id
    end

    return if self.content_changed?

    date_serial = Time.now.strftime( "%Y%m%d00" ).to_i

    self.serial = if self.serial.nil? || date_serial > self.serial
        date_serial
    else
       self.serial + 1
    end
  end

  # Same as #update_serial and saves the record
  def update_serial!
    if respond_to?( :without_auditing )
      without_auditing do
        update_serial
        save
      end
    else
      update_serial
      save
    end
  end

  # Nicer representation of the domain as XML
  def to_xml(options = {}, &block)
    super(options.merge(:methods => SOA_FIELDS))
  end

  def set_content
    self.content = SOA_FIELDS.map { |f| instance_variable_get("@#{f}").to_s  }.join(' ')
  end

  private

  # Update our convenience accessors when the object has changed
  def update_convenience_accessors
    # Setup our convenience values
    @primary_ns, @contact, @serial, @refresh, @retry, @expire, @minimum =
      self[:content].split(/\s+/) unless self[:content].blank?
    %w{ serial refresh retry expire minimum }.each do |i|
      value = instance_variable_get("@#{i}")
      value = value.to_i unless value.nil?
      send("#{i}=", value )
    end

    update_serial if @serial.nil? || @serial.zero?
  end
end
