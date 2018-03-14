require 'rails_helper'

RSpec.describe SuggestionTag, type: :model do
  describe 'validations' do
    let(:tag) { Fabricate(:tag) }

    it 'is invalid without tag_id' do
      suggestion_tag = Fabricate.build(:suggestion_tag)
      suggestion_tag.valid?
      expect(suggestion_tag).to model_have_error_on_field(:tag)
    end

    it 'is invalid without order' do
      suggestion_tag = Fabricate.build(:suggestion_tag, tag: tag, order: nil)
      suggestion_tag.valid?
      expect(suggestion_tag).to model_have_error_on_field(:order)
    end

    it 'is invalid without description' do
      suggestion_tag = Fabricate.build(:suggestion_tag, tag: tag, description: nil)
      suggestion_tag.valid?
      expect(suggestion_tag).to model_have_error_on_field(:description)
    end

    it 'is invalid with duplicate tag_id' do
      suggestion_tag = Fabricate(:suggestion_tag, tag: tag)
      duplicate_suggestion_tag = Fabricate.build(:suggestion_tag, tag: tag)
      duplicate_suggestion_tag.valid?
      expect(duplicate_suggestion_tag).to model_have_error_on_field(:tag_id)
    end

    it 'is valid with tag_id' do
      suggestion_tag = Fabricate.build(:suggestion_tag, tag: tag)
      suggestion_tag.valid?
      expect(suggestion_tag).to be_valid
    end
  end
end
