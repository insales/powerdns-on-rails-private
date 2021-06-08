require 'spec_helper'

describe "macros/edit.html.haml" do
  let(:user) { FactoryBot.create :admin }
  before do
    allow(view).to receive(:current_user).and_return(user)
  end

  context "for new macros" do
    before(:each) do
      assign(:macro, Macro.new)
      render
    end

    it "should behave accordingly" do
      rendered.should have_css('h1', :text => 'New Macro')
    end

  end

  context "for existing records" do
    before(:each) do
      @macro = FactoryBot.create(:macro)
      assign(:macro, @macro)
      render
    end

    it "should behave accordingly" do
      rendered.should have_css('h1', :text => 'Update Macro')
    end
  end

  describe "for records with errors" do
    before(:each) do
      m = Macro.new
      m.valid?
      assign(:macro, m)
      render
    end

    it "should display the errors" do
      rendered.should have_css('div.errorExplanation')
    end
  end

end
