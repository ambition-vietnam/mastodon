# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::SuggestedAccountsController, type: :controller do
  let(:user) { Fabricate(:user) }

  describe '#index' do
    subject { get :index }

    context 'without token' do
      it { is_expected.to have_http_status :unauthorized }
    end

    context 'with token' do
      before do
        allow(controller).to receive(:doorkeeper_token) do
          Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'follow')
        end
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end
