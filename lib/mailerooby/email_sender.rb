require "httparty"

module Mailerooby
  class ValidationError < StandardError; end
  class Error < StandardError; end
  class BadRequestError < Error; end
  class UnauthorizedError < Error; end
  class GeneralAPIError < Error; end

  class EmailSender
      include HTTParty

      base_uri "https://smtp.maileroo.com/api/v2/emails"

      def self.send_email(from:, to:, subject:, plain:, html: nil, cc: nil, bcc: nil, reply_to: nil, attachments: nil)
        validate_parameters(from: from, to: to, subject: subject, plain: plain, html: html)
        headers = {
          "X-Api-Key" => Mailerooby.sending_api_key,
          "Content-Type" => "application/json"
        }
        body = {
          from: from,
          to: to,
          subject: subject,
          plain: plain,
          html: html,
          cc: cc,
          bcc: bcc,
          reply_to: reply_to,
          attachments: attachments
        }
        response = post(base_uri, headers: headers, body: body.to_json, multipart: true)

        case response.code
        when 400
          raise BadRequestError, "Bad request: #{response.body}"
        when 401
          raise UnauthorizedError, "Unauthorized: #{response.body}"
        when 200
          JSON.parse(response.body)
        else
          raise GeneralAPIError, "API Error: #{response.body}"
        end
      end

      private

      def self.validate_parameters(from:, to:, subject:, plain:, html:)
        raise ValidationError, "From address is missing" unless from&.dig(:address)
        raise ValidationError, "To address is missing" if to.nil? || !to.is_a?(Array) || !to.all?{|x| !!x&.dig(:address) }
        raise ValidationError, "Subject is missing" if subject.nil? || subject.strip.empty?
        raise ValidationError, "Plain or Html is missing" if plain.nil? || plain.strip.empty? || html.nil? || html.strip.empty?
      end

  end
end