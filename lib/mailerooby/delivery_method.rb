# frozen_string_literal: true

module Mailerooby
  class DeliveryMethod
    attr_accessor :settings

    def initialize(values)
      self.settings = values
    end

    def deliver!(mail)
      send_email_parser = SendEmailParser.new(mail: mail)
      response = EmailSender.send_email(send_email_parser: send_email_parser)
      handle_response(response)
    end
    
    private
    
    def handle_response(response)
      return if response["success"]

      error_message = response["message"] || "Unknown error"
      raise DeliveryError.new("Failed to send email: #{error_message}")
    end
  end
end
