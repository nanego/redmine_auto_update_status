require 'rails_helper'

RSpec.describe AutoUpdateRule, :type => :model do

  context "attributes" do

    it "has initial_status_ids" do
      expect(AutoUpdateRule.new(initial_status_ids: [3, 4])).to have_attributes(initial_status_ids: [3, 4])
    end

    it "has final_status_id" do
      expect(AutoUpdateRule.new(final_status_id: 5)).to have_attributes(final_status_id: 5)
    end

    it "has time_limit" do
      expect(AutoUpdateRule.new(time_limit: 30)).to have_attributes(time_limit: 30)
    end

    it "has note" do
      expect(AutoUpdateRule.new(note: 'TEST')).to have_attributes(note: 'TEST')
    end

    it "has author_id" do
      expect(AutoUpdateRule.new(author_id: 1)).to have_attributes(author_id: 1)
    end

  end


end
