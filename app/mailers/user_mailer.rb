class UserMailer < ActionMailer::Base
  def new_years_mail params
    return unless to = params[:to] and to.present?

    name = params[:name]
    email = params[:email]
    subject = params[:subject]

    from = Mail::Address.new email
    from.display_name = name

    mail to: to, from: from.format, subject: subject
  end
end
