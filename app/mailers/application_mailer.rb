class ApplicationMailer < ActionMailer::Base
  default from: "Rails Tutorial Sample App <noreply@mailgun.tugan.io>",
          reply_to: "sample-app-reply@tugan.io"
  layout 'mailer'
end
