require "spec_helper"
require "mailerooby/email_sender"

RSpec.describe Mailerooby::EmailSender do
  describe ".send_email" do
    subject(:send_email) { Mailerooby::EmailSender.send_email(send_email_parser: send_email_parser) }

    let(:send_email_parser) { Mailerooby::SendEmailParser.new(mail: mail) }
    let(:mail) { double(from: from, to: to, subject: subject, body: body) }
    let(:from) { "sender@example.com" }
    let(:to) { "recipient@example.com" }
    let(:subject) { "Test Subject" }
    let(:body) { double(raw_source: "Test Body") }
    let(:sending_api_key) { "sending_api_key" }

    before do
      Mailerooby.sending_api_key = sending_api_key
    end

    def stub_maileroo_request(status:, response_body:)
      stub_request(:post, "https://smtp.maileroo.com/api/v2/emails").
         with(
           headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Content-Type" => "application/json",
              "User-Agent" => "Ruby",
              "X-Api-Key" => sending_api_key
           }
        ).
        to_return(status: status, body: response_body.to_json, headers: {})
    end

    it "sends an email successfully" do
      stub_maileroo_request(
        status: 200,
        response_body: { success: true }
      )
      response = send_email
      expect(response["success"]).to be true
    end

    context "when a parameter is missing" do
      let(:to) { nil }

      it "raises a validation error" do
        expect { send_email }.to raise_error(Mailerooby::ValidationError)
      end
    end

    context "when the API returns an error" do
      it "raises an error" do
        stub_maileroo_request(
          status: 400,
          response_body: { success: false, message: "Error" }
        )
        expect { send_email }.to raise_error(Mailerooby::BadRequestError)
      end
    end
  end
end
