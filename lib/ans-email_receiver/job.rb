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

      Net::POP3.start(host, port, user, password) do |pop|
        pop.mails.each do |m|
          EmailReceive.receive(m.pop) do |email_receive|
            mailer.receive email_receive.body
            email_receive.reload
            m.delete if email_receive.email_queue.present? || delete?(email_receive)
          end
        end
      end
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

  end
end
