# -*- coding: utf-8 -*-

require "net/pop"

module Ans::EmailReceiver
  module Job
    def self.included(m)
      m.send :extend, ClassMethods
    end

    module ClassMethods
      def perform
        new.receive_all
      end
    end

    def receive_all
      host, port, user, password = config.host, config.port, config.user, config.password
      return if [host,port,user,password].any?{|s| s.blank?}

      EmailReceive.old.delete_all

      Net::POP3.start(host, port, user, password) do |pop|
        pop.mails.each do |mail|
          receive mail if EmailReceive.where(unique_id: mail.unique_id).blank?
        end
      end
    end
    def receive(mail)
      EmailReceive.receive(mail) do |email_receive|
        mailer.receive email_receive.body
        email_receive.reload
        mail.delete if email_receive.email_queue.present? || delete?(email_receive)
      end
    rescue => e
      error e, mail.pop
    end

    private

    def mail_name
      @mail_name ||= self.class.to_s.gsub(/Receiver$/, "").underscore
    end
    def config
      @config ||= Config.new mail_name
    end
    def mailer
      @mailer ||= "#{mail_name.camelize}Mailer".constantize
    end

    def delete?(email_receive)
      false
    end

    def error(e,mail)
    end

  end
end
