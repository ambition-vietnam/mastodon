require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
    it 'invalid with #' do
      expect(Tag.new(name: '#hello_world')).to_not be_valid
    end

    it 'invalid with .' do
      expect(Tag.new(name: '.abcdef123')).to_not be_valid
    end

    it 'invalid with spaces' do
      expect(Tag.new(name: 'hello world')).to_not be_valid
    end

    it 'valid with ａｅｓｔｈｅｔｉｃ' do
      expect(Tag.new(name: 'ａｅｓｔｈｅｔｉｃ')).to be_valid
    end
  end

  describe 'HASHTAG_RE' do
    subject { Tag::HASHTAG_RE }

    it 'does not match URLs with anchors with non-hashtag characters' do
      expect(subject.match('Check this out https://medium.com/@alice/some-article#.abcdef123')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors' do
      expect(subject.match('https://en.wikipedia.org/wiki/Ghostbusters_(song)#Lawsuit')).to be_nil
    end

    it 'matches ﻿#ａｅｓｔｈｅｔｉｃ' do
      expect(subject.match('﻿this is #ａｅｓｔｈｅｔｉｃ')).to_not be_nil
    end
  end

  describe '#to_param' do
    it 'returns name' do
      tag = Fabricate(:tag, name: 'foo')
      expect(tag.to_param).to eq 'foo'
    end
  end

  describe '.search_for' do
    let!(:account)  { Fabricate(:account) }

    it 'finds tag records with matching names' do
      match = 'match'

      PostStatusService.new.call(account, "This is ##{match} hashtag.")
      tag     = Tag.where(name: match).first
      results = Tag.search_for(match)

      expect(results).to eq [tag]
    end

    it 'finds tag records in case insensitive' do
      match = 'MATCH'

      PostStatusService.new.call(account, "This is ##{match} hashtag.")
      tag     = Tag.where('lower(name) = ?', match.downcase).first
      results = Tag.search_for(match)

      expect(results).to eq [tag]
    end

    it 'finds the exact matching tag as the first item' do
      match      = 'match'
      matchlater = 'matchlater'

      PostStatusService.new.call(account, "This is ##{match} hashtag.")
      PostStatusService.new.call(account, "This is ##{matchlater} hashtag.")
      tag         = Tag.where(name: match).first
      similar_tag = Tag.where(name: matchlater).first
      results     = Tag.search_for(match)

      expect(results).to eq [tag, similar_tag]
    end
  end
end
