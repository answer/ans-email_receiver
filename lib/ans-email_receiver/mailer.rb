# -*- coding: utf-8 -*-

module Ans::EmailReceiver
  module Mailer

    def receive(mail)
      email_receive = EmailReceive.find_by_message_id! mail.message_id

      unless mail.bounced?
        save email_receive
      else
        bounced email_receive
      end
    end

    private

    def save(email_receive)
    end
    def bounced(email_receive)
      email_receive.bounced
    end

  end
end
