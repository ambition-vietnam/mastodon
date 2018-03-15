require 'rails_helper'

RSpec.describe Api::V1::TrendTagsController, type: :controller do
  render_views

  let!(:suggestion_tag) { Fabricate(:suggestion_tag) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'shows suggestion_tags' do
      get :index
      expect(assigns(:trend_tags)).to match([
        have_attributes(name: suggestion_tag.tag.name, description: suggestion_tag.description),
      ])
    end
  end
end
