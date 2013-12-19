class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def send_mail
    UserMailer.new_years_mail(params[:mail]).deliver
    redirect_to :back, notice: 'Письма отправлены'
  end
end
