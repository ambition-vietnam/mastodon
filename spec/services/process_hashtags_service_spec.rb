require 'rails_helper'

RSpec.describe ProcessHashtagsService do
  let(:owner) { Fabricate(:account, username: 'alice', account_type: 1) }
  let(:tenant) { Fabricate(:account, username: 'bob', account_type: 2) }
  let(:status) { Fabricate(:status, account: owner, text: "#600usd #1bedroom #district1") }
  let(:tenant_status) { Fabricate(:status, account: tenant, text: "#650usd #1bedroom") }

  describe 'Register post with hashtag' do
    subject { ProcessHashtagsService.new }

    before do
      subject.call(status)
    end

    context 'public post' do
      it 'The number of registered tags is 3' do
        expect(status.tags.count).to eq 3
      end

      it 'Registered tag names are 600usd 1bedroom, and district1' do
        tags = { '600usd' => true, '1bedroom' => true, 'district1' => true }
        status.tags.each do |tag|
          expect(tags[tag.name]).to eq true
        end
      end
    end

    context 'get recommend' do
      before do
        stub_request(:post, 'cb6e6126.ngrok.io/api/v1/statuses').to_return(body: Oj.dump({ "status": "ok" }))
        subject.call(tenant_status)
      end

      it 'The number of registered status is 2' do
        expect(tenant_status.tags.count).to eq 2
      end
    end

    context 'Unlisted post' do
      pending 'Unlisted test is TBD'
    end
  end

  describe 'Invalid tags' do
    subject { ProcessHashtagsService.new }

    context "Only numerics isn't registered as hash tag" do
      let(:status) { Fabricate(:status, account: owner, text: "#1000") }

      before do
        subject.call(status)
      end

      it "hashtag's count is 0" do
        expect(status.tags.count).to eq 0
      end

      it "text is registered" do
        expect(status.text).to eq '#1000'
      end
    end

    context "hyphen(-) isn't included in hash tag" do
      let(:status) { Fabricate(:status, account: owner, text: "#district-1") }

      before do
        subject.call(status)
      end

      it "hashtag's count is 1" do
        expect(status.tags.count).to eq 1
      end

      it "hatshtag is district" do
        status.tags.each do |tag|
          expect(tag.name).to eq 'district'
        end
      end
    end
  end
end
