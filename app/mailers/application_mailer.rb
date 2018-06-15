# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  SiteEmailAddress = 'operationanatomy@gmail.com'
  default from: SiteEmailAddress

  def send_feedback(_tone, comment, userID)
    puts 'Mailer has been called'
    @userID = userID
    @comment = comment
    mail(to: SiteEmailAddress, subject: 'OA feedback: #{tone}', fomat: 'text') do |format|
      format.text { render 'application_mailer/send_feedback.txt.erb' }
    end
  end
end
