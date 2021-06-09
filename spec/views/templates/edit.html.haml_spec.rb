require 'spec_helper'

describe "templates/edit.html.haml" do

  context "and existing templates" do

    before(:each) do
      @zone_template = FactoryBot.create(:zone_template)
      assign(:zone_template, @zone_template)
    end

    it "should show the correct title" do
      render

      rendered.should have_css('h1.underline', :text => 'Update Zone Template')
    end
  end

end
