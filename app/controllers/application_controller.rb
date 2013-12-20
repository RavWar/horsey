class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
end
