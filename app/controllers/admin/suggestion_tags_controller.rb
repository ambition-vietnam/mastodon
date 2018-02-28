# frozen_string_literal: true

module Admin
  class SuggestionTagsController < BaseController
    before_action :set_suggestion_tag, only: [:edit, :update, :destroy]

    def index
      @suggestion_tags = SuggestionTag.order(:order).preload(:tag)
    end

    def new
      @suggestion_tag = SuggestionTag.new(suggestion_type: SuggestionTag.suggestion_types[:normal])
      @suggestion_tag.build_tag
    end

    def create
      @suggestion_tag = SuggestionTag.new(suggestion_tag_params)

      if @suggestion_tag.save
        redirect_to admin_suggestion_tags_url, notice: I18n.t('admin.suggestion.add_successfully')
      else
        flash.now[:alert] = I18n.t('admin.suggestion.add_failed')
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @suggestion_tag.update(suggestion_tag_params_for_update)
        redirect_to admin_suggestion_tags_url, notice: I18n.t('admin.suggestion.update_successfully')
      else
        flash.now[:alert] = I18n.t('admin.suggestion.update_failed')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @suggestion_tag.destroy
      redirect_to admin_suggestion_tags_url, notice: I18n.t('admin.suggestion.delete_successfully')
    end

    private

    def set_suggestion_tag
      @suggestion_tag = SuggestionTag.find(params[:id])
    end

    def suggestion_tag_params
      params.require(:suggestion_tag).permit(:order, :description, :suggestion_type, tag_attributes: [:name])
    end

    def suggestion_tag_params_for_update
      params.require(:suggestion_tag).permit(:order, :description, :suggestion_type)
    end
  end
end