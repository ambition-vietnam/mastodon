require 'rails_helper'

RSpec.describe Settings::OutgoingWebhooksController, type: :controller do
  render_views

  let!(:user) { Fabricate(:user) }
  let!(:outgoing_webhook) { Fabricate(:outgoing_webhook, account_id: user.account_id) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    let!(:other_outgoing_webhook) { Fabricate(:outgoing_webhook) }

    it 'shows outgoing_webhooks' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:outgoing_webhooks)).to include(outgoing_webhook)
      expect(assigns(:outgoing_webhooks)).to_not include(other_outgoing_webhook)
    end
  end

  describe 'GET #new' do
    it 'works' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'success' do
      def call_create
        post :create, params: {
          outgoing_webhook: {
            name: Faker::Name.name,
            url: Faker::Internet.url,
            trigger_word: Faker::Lorem.word,
            account_id: user.account_id,
          }
        }
        response
      end

      it 'creates an entry in the database' do
        expect{ call_create }.to change(OutgoingWebhook, :count).by(1)
      end

      it 'redirects back to outgoing webhooks page' do
        expect(call_create).to redirect_to(settings_outgoing_webhooks_path)
      end
    end

    context 'failure' do
      before do
        post :create, params: {
          outgoing_webhook: {
            account_id: user.account_id,
          }
        }
      end

      it 'renders form again' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'success' do
      let(:opts) {
        {
          name: 'new_name',
          url: 'new_url',
          trigger_word: 'new_trigger',
        }
      }

      before do
        patch :update, params: {
          id: outgoing_webhook.id,
          outgoing_webhook: opts,
        }
      end

      it 'updates existing outgoing webhook' do
        outgoing_webhook.reload
        opts.each do |name, value|
          expect(value).to eq(outgoing_webhook[name])
        end
      end

      it 'redirects back to outgoing webhooks page' do
        expect(response).to redirect_to(settings_outgoing_webhooks_path)
      end
    end

    context 'failure' do
      before do
        patch :update, params: {
          id: outgoing_webhook.id,
          outgoing_webhook: {
            name: nil
          }
        }
      end

      it 'renders form again' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'POST #destroy' do
    before do
      post :destroy, params: { id: outgoing_webhook.id }
    end

    it 'redirects back to outgoing webhooks page' do
      expect(response).to redirect_to(settings_outgoing_webhooks_path)
    end

    it 'removes the outgoing webhook' do
      expect(OutgoingWebhook.find_by(id: outgoing_webhook.id)).to be_nil
    end
  end

  describe 'POST #generate' do
    before do
      post :generate, params: { id: outgoing_webhook.id }
    end

    it 'redirects back to outgoing webhooks page' do
      expect(response).to redirect_to(settings_outgoing_webhooks_path)
    end

    it 'removes the outgoing webhook' do
      old_token = outgoing_webhook.token
      new_token = outgoing_webhook.reload.token
      expect(new_token).to_not eql(old_token)
    end
  end
end
