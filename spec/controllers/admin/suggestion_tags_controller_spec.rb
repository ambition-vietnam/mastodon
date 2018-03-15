require 'rails_helper'

RSpec.describe Admin::SuggestionTagsController, type: :controller do
  render_views

  let!(:suggestion_tag) { Fabricate(:suggestion_tag) }

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    it 'shows suggestion_tags' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:suggestion_tags)).to include(suggestion_tag)
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
        tag = Fabricate(:tag)
        post :create, params: {
          suggestion_tag: {
            tag_attributes: { name: tag.name },
            description: Faker::Lorem.word,
          }
        }
        response
      end

      it 'creates an entry in the database' do
        expect{ call_create }.to change(SuggestionTag, :count).by(1)
      end

      it 'redirects back to suggestion tags page' do
        expect(call_create).to redirect_to(admin_suggestion_tags_path)
      end
    end

    context 'failure' do
      before do
        post :create, params: {
          suggestion_tag: {
            suggestion_type: :normal,
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
          order: 10,
          description: 'new_description',
          suggestion_type: 'comiket',
        }
      }

      before do
        patch :update, params: {
          id: suggestion_tag.id,
          suggestion_tag: opts,
        }
      end

      it 'updates existing suggestion tag' do
        suggestion_tag.reload
        opts.each do |name, value|
          expect(value).to eq(suggestion_tag[name])
        end
      end

      it 'redirects back to suggestion tags page' do
        expect(response).to redirect_to(admin_suggestion_tags_path)
      end
    end

    context 'failure' do
      before do
        patch :update, params: {
          id: suggestion_tag.id,
          suggestion_tag: {
            description: nil,
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
      post :destroy, params: { id: suggestion_tag.id }
    end

    it 'redirects back to suggestion tags page' do
      expect(response).to redirect_to(admin_suggestion_tags_path)
    end

    it 'removes the suggestion tag' do
      expect(SuggestionTag.find_by(id: suggestion_tag.id)).to be_nil
    end
  end
end
