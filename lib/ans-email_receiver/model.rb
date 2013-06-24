# -*- coding: utf-8 -*-

require "mail"

module Ans::EmailReceiver
  module Model
    def self.included(m)
      m.send :extend, ClassMethods

      m.class_eval do
        scope :old, lambda{
          where(arel_table[:created_at].lt(Arel::Nodes::SqlLiteral.new "now() - interval 1 year").to_sql)
        }
      end
    end

    module ClassMethods

      def receive(pop_mail)
        body = pop_mail.pop
        transaction do
          receive = new

          receive.body = body

          message = receive.mail

          receive.message_id = message.message_id
          receive.email = Array.wrap(message.from).first

          receive.save!

          yield receive
        end

      rescue ActiveRecord::RecordInvalid
        receive = new
        receive.body = pop_mail.pop
        message = receive.mail

        if receive = where(message_id: message.message_id).first
          receive.unique_id = pop_mail.unique_id
          receive.save
        end
      end

    end

    def mail
      @mail ||= Mail.new body
    end

    def bounced
      self.is_bounced = true
      save

      sync_email_queue

      after_bounced
    end

    private

    def sync_email_queue
      mail.parts.each do |part|
        EmailQueue.where(message_id: Mail.new(part.body).message_id).update_all email_receive_id: id
      end
    end

    def after_bounced
    end

  end
end
