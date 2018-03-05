# frozen_string_literal: true

class Settings::OutgoingWebhooksController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_outgoing_webhook, only: [:edit, :update, :destroy, :generate]

  def index
    @outgoing_webhooks = OutgoingWebhook.all.order(:id)
  end

  def new
    @outgoing_webhook = OutgoingWebhook.new
  end

  def create
    @outgoing_webhook = OutgoingWebhook.new(outgoing_webhook_params_for_create)
    if @outgoing_webhook.save
      redirect_to settings_outgoing_webhooks_url, notice: I18n.t('settings.outgoing_webhooks.add_successfully')
    else
      flash.now[:alert] = I18n.t('settings.outgoing_webhooks.add_failed')
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @outgoing_webhook.update(outgoing_webhook_params)
      redirect_to settings_outgoing_webhooks_url, notice: I18n.t('settings.outgoing_webhooks.update_successfully')
    else
      flash.now[:alert] = I18n.t('settings.outgoing_webhooks.update_failed')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @outgoing_webhook.destroy
    redirect_to settings_outgoing_webhooks_url, notice: I18n.t('settings.outgoing_webhooks.delete_successfully')
  end

  def generate
    @outgoing_webhook.generate_token
    if @outgoing_webhook.save
      redirect_to settings_outgoing_webhooks_url, notice: I18n.t('settings.outgoing_webhooks.generate_successfully')
    else
      flash.now[:alert] = I18n.t('settings.outgoing_webhooks.generate_failed')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_outgoing_webhook
    @outgoing_webhook = OutgoingWebhook.find(params[:id])
  end

  def outgoing_webhook_params
    params.require(:outgoing_webhook).permit(:name, :url, :trigger_word)
  end

  def outgoing_webhook_params_for_create
    webhook_params = outgoing_webhook_params
    webhook_params[:account_id] = current_user.id
    webhook_params
  end
end
