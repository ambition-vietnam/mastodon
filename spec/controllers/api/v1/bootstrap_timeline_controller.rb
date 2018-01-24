require 'rails_helper'

RSpec.describe Api::V1::BootstrapTimelineController, type: :controller do
  render_views

  describe 'POST #create' do
    let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

    it 'returns http success' do
      post :create, params: { id: user.account.id }
      @expected = {result: 'ok'}.to_json

      expect(response).to have_http_status(:success)
      expect(response.body).to eq(@expected)
    end

    it 'returns nil' do
      post :create, params: { id: nil }
      @expected = {}.to_json

      expect(response).to have_http_status(:success)
      expect(response.body).to eq(@expected)
    end
  end
end
