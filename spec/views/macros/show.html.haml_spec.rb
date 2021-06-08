require 'spec_helper'

describe "macros/show.html.haml" do
  before(:each) do
    @macro = FactoryGirl.create(:macro)
    FactoryGirl.create(:macro_step_create, :macro => @macro)

    assign(:macro, @macro)

    render
  end

  it "should have the name of the macro" do
    rendered.should have_css('h1', :text => @macro.name)
  end

  it "should have an overview table" do
    rendered.should have_css('table.grid td', :text => "Name")
    rendered.should have_css('table.grid td', :text => "Description")
    rendered.should have_css('table.grid td', :text => "Active")
  end

  it "should have a list of steps" do
    rendered.should have_css('h1', :text => 'Macro Steps')
    rendered.should have_css('table#steps-table td', :text => "1")
  end

end
