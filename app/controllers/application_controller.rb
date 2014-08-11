class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_locale

  def send_mail
    UserMailer.new_years_mail(params[:mail]).deliver
    redirect_to :back, notice: 'Письма отправлены.'
  end

  def save_score
    score = Score.create! name: params[:name], value: params[:value].to_i
    render partial: 'shared/top', locals: { current: score }
  end

  def get_place
    place = Score.get_place params[:score].to_i
    render text: place
  end

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    I18n.locale == I18n.default_locale ? { locale: nil } : { locale: I18n.locale }
  end
end
