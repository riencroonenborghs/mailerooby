# frozen_string_literal: true

module Mailerooby
  class SendEmailParser
    attr_reader :from, :to, :cc, :bcc, :reply_to, :subject, :plain, :html, :attachments
    attr_reader :validation_error

    def initialize(mail:)
      @mail = mail
      
      @from = { address: mail.from[0] }
      @to = parse_address(:to)
      @cc = parse_address(:cc)
      @bcc = parse_address(:bcc)
      @reply_to = parse_address(:reply_to)
      @subject = mail.subject
      @plain = mail.body.raw_source
      @html = mail.body.raw_source
      @attachments = parse_attachments
    end

    def valid?
      @validation_error = "From address is missing" and return false unless @from&.dig(:address)
      @validation_error = "To address is missing" and return false if @to.nil? || !@to.is_a?(Array) || !@to.all?{ |x| !!x&.dig(:address) }
      @validation_error = "Subject is missing" and return false if @subject.nil? || @subject.strip.empty?
      @validation_error = "Plain or Html is missing" and return false if @plain.nil? || @plain.strip.empty? || @html.nil? || @html.strip.empty?

      true
    end

    def to_h
      { from: @from, to: @to, subject: @subject, plain: @plain, html: @html, cc: @cc, bcc: @bcc, reply_to:  @reply_to, attachments: @attachments }.compact
    end

    private

    def parse_address(address)
      return nil unless @mail.respond_to?(address) && @mail.send(address)

      [@mail.send(address)].flatten.map do |x|
        { address: x }
      end
    end

    def parse_attachments
      return nil unless @mail.respond_to?(:attachments)

      @mail.attachments.map do |attachment|
        {
          file_name: attachment.filename,
          content: attachment.body.raw_source,
          content_type: attachment.mime_type,
          inline: false
        }
      end
    end
  end
end
