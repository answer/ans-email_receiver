# -*- coding: utf-8 -*-

require "net/pop"

module Ans::EmailReceiver
  module JobHelper
    def self.included(m)
      def m.perform
        new.receive
      end
    end

    def receive
      Net::POP3.start(config.host, config.port, config.user, config.password) do |pop|
        pop.mails.each do |m|
          body = m.pop
          mail = to_mail body
          model.unique_transaction(mail, body) do |email_receive|
            mailer.receive email_receive.body
            email_receive.reload
            m.delete if email_receive.is_bounced || delete?(email_receive)
          end
        end
      end
    end

    private

    def config
      @config ||= Config.new mail_name
    end
    def model
      EmailReceive
    end
    def mailer
      "#{mail_name.downcase.camelize}Mailer".constantize
    end

    def delete?(email_receive)
      false
    end

    def to_mail(body)
      ReceiveMailer.receive(body)
    end

  end
end
