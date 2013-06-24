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
      last_unique_id = EmailReceive.order("id desc").limit(1).pluck(:unique_id)

      Net::POP3.start(host, port, user, password) do |pop|
        mails = pop.mails

        # 最後の unique_id が取得できなければ、全て処理する
        is_match_unique_id = !last_unique_id

        mails.each do |mail|
          # 最後の unique_id が見つかった後から処理を開始する
          receive mail if is_match_unique_id
          is_match_unique_id ||= last_unique_id == mail.unique_id
        end

        # 前に処理したメールが削除済みの場合、最後の unique_id にマッチするメールはない
        # この場合、全て処理するべき
        unless is_match_unique_id
          mails.each{|mail| receive mail}
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
      error e, mail.body
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
