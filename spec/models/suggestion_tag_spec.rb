require 'rails_helper'

RSpec.describe SuggestionTag, type: :model do
  describe 'validations' do
    it 'is valid' do
      suggestion_tag = Fabricate.build(:suggestion_tag)
      suggestion_tag.valid?
      expect(suggestion_tag).to be_valid
    end

    it 'is invalid without tag' do
      suggestion_tag = Fabricate.build(:suggestion_tag, tag: nil)
      suggestion_tag.valid?
      expect(suggestion_tag).to model_have_error_on_field(:tag)
    end

    it 'is invalid without order' do
      suggestion_tag = Fabricate.build(:suggestion_tag, order: nil)
      suggestion_tag.valid?
      expect(suggestion_tag).to model_have_error_on_field(:order)
    end

    it 'is invalid without description' do
      suggestion_tag = Fabricate.build(:suggestion_tag, description: nil)
      suggestion_tag.valid?
      expect(suggestion_tag).to model_have_error_on_field(:description)
    end

    it 'is invalid with duplicate tag' do
      suggestion_tag = Fabricate(:suggestion_tag)
      duplicate_suggestion_tag = Fabricate.build(:suggestion_tag, tag: suggestion_tag.tag)
      duplicate_suggestion_tag.valid?
      expect(duplicate_suggestion_tag).to model_have_error_on_field(:tag_id)
    end
  end
end
