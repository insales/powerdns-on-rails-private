# frozen_string_literal: true

# steps_for :macro_definition do ??
module MacroDefinitionSteps
  extend Turnip::DSL

  placeholder :type do
    match(%r{"([A-Z]+)"}) { |type| type }
  end

  step "I have a domain" do
    @domain = FactoryBot.create(:domain)
  end

  step "I have a domain named :domain" do |name|
    @domain = FactoryBot.create(:domain, :name => name)
  end

  step "I have a macro" do
    @macro = FactoryBot.create(:macro)
  end

  step "I apply the macro" do
    @macro.apply_to( @domain )
    @domain.reload
  end

  step "the macro :action (a/an) :type record for :name with :content" do |action, type, name, content|
    # clean up the action by singularizing the components
    action = action.gsub(/s$/,'').gsub('s_', '_')

    MacroStep.create!(:macro => @macro, :action => action, :record_type => type, :name => name, :content => content)
  end

  step 'the macro :action an :type record for :name' do |action, type, name|
    # clean up the action by singularizing the components
    action = action.gsub(/s$/,'').gsub(/s_/, '')

    MacroStep.create!(:macro => @macro, :action => action, :record_type => type, :name => name)
  end

  step "the macro :action an :type record with :content with priority :priority" do |action, type, content, prio|
    # clean up the action by singularizing the components
    action = action.gsub(/s$/,'').gsub(/s_/, '')

    MacroStep.create!(:macro => @macro, :action => action, :record_type => type, :content => content, :prio => prio)
  end

  step "the domain has (a/an) :type record for :name with :content" do |type, name, content|
    type.constantize.create!( :domain => @domain, :name => name, :content => content )
  end

  step "the domain should have (a/an) :type record for :name with :content" do |type, name, content|
    records = @domain.send("#{type.downcase}_records", true)

    records.should_not be_empty

    records.detect { |r| r.name =~ /^#{name}\./ && r.content == content }.should_not be_nil
  end

  step "the domain should have (a/an) :type record with priority :priority" do |type, prio|
    records = @domain.send("#{type.downcase}_records", true)

    records.should_not be_empty

    records.detect { |r| r.prio == prio.to_i }.should_not be_nil
  end

  step "the domain should not have (an) :type record for :name with :content" do |type, name, content|
    records = @domain.send("#{type.downcase}_records", true)

    records.detect { |r| r.name =~ /^#{name}\./ && r.content == content }.should be_nil
  end

  step "the domain should not have an :type record for :name" do |type, name|
    records = @domain.send("#{type.downcase}_records", true)

    records.detect { |r| r.name =~ /^#{name}\./ }.should be_nil
  end
end
