require 'mail'
require_relative 'mail_builder'

class MailService

  attr_reader :sender, :recipient, :subject

  def initialize(mail_service_configuration)
    @sender = mail_service_configuration['sender']
    @recipient = mail_service_configuration['recipient']
    @subject = mail_service_configuration['subject']
    @images = mail_service_configuration['images']
    @color = mail_service_configuration['color']
    @background_color = mail_service_configuration['background_color']
    @header_html = mail_service_configuration['header_html']
    @footer_html = mail_service_configuration['footer_html']
  end

  def get_mail_builder
    return MailBuilder.new(@color, @background_color, @images, @header_html, @footer_html)
  end

  def send_mail(html_body, text_body="", debug=false)
    sender = @sender
    recipient = @recipient
    subject = @subject
    mail = Mail.new do
      from    sender
      to      recipient
      subject subject
      if text_body != ""
        text_part do
          body text_body
        end
      end
      if html_body != ""
        html_part do
          content_type 'text/html; charset=UTF-8'
          body html_body
        end
      end
    end
  
    # https://tonyteaches.tech/postfix-gmail-smtp-on-ubuntu/
    mail.delivery_method :sendmail
    mail.deliver
    puts "Sending mail to: #{recipient}" if debug
  end

end