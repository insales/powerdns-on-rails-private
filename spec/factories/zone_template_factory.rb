FactoryGirl.define do
  sequence :zone_template_name do |i|
    "Zone template #{i}"
  end

  factory(:zone_template, :class => ZoneTemplate) do
    name { generate :zone_template_name }
    ttl 86400
  end

  factory :record_template do
    zone_template

    factory(:template_soa, :class => RecordTemplate) do
      ttl 86400
      record_type 'SOA'
      #content 'ns1.%ZONE% admin@%ZONE% 0 10800 7200 604800 3600'
      primary_ns 'ns1.%ZONE%'
      contact 'admin@example.com'
      refresh 10800
      self.retry 7200
      expire 604800
      minimum 3600
    end

    factory(:template_ns, :class => RecordTemplate) do
      ttl 86400
      record_type 'NS'
      content 'ns1.%ZONE%'
    end

    factory(:template_ns_a, :class => RecordTemplate) do
      ttl 86400
      record_type 'A'
      name 'ns1.%ZONE%'
      content '10.0.0.1'
    end

    factory(:template_cname, :class => RecordTemplate) do
      ttl 86400
      record_type 'CNAME'
      name '%ZONE%'
      content 'some.cname.org'
    end

    factory(:template_mx, :class => RecordTemplate) do
      ttl 86400
      record_type 'MX'
      content 'mail.%ZONE%'
      prio 10
    end
  end
end
