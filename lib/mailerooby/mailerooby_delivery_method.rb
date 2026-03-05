require 'mailerooby'

class MaileroobyDeliveryMethod
    def initialize(values)
      self.settings = values
    end

    attr_accessor :settings

    def deliver!(mail)
      @mail = mail

      from = { address: mail.from[0] }
      to = parse_address(:to)
      cc = parse_address(:cc)
      bcc = parse_address(:bcc)
      reply_to = parse_address(:reply_to)
      subject = mail.subject
      plain = mail.body.raw_source
      html = mail.body.raw_source
      attachments = parse_attachments

      # Send the email via Maileroob API
      response = Mailerooby::EmailSender.send_email(
        from: from, 
        to: to,
        cc: cc,
        bcc: bcc,
        reply_to: reply_to,
        subject: subject,
        plain: plain,
        html: html,
        attachments: attachments
      )
  
      # Check the response and raise an error if necessary
      handle_response(response)
    end
    
    private
    
    def parse_address(address)
      return nil unless @mail.send(address).present?

      [@mail.send(address)].flatten.map do |x|
        { address: x }
      end
    end

    def parse_attachments
      @mail.attachments.map do |attachment|
        {
          file_name: attachment.filename,
          content: attachment.body.raw_source,
          content_type: attachment.mime_type,
          inline: false
        }
      end
    end
    
    def handle_response(response)
        unless response["success"]
            error_message = response["message"] || "Unknown error"
            raise Mailerooby::DeliveryError.new("Failed to send email: #{error_message}")
        end
    end
end

module Mailerooby
    class DeliveryError < StandardError; end
end
  
