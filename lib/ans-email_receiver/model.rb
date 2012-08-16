# -*- coding: utf-8 -*-

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

      def receive(body)
        old.delete_all

        transaction do
          receive = new
          receive.body = body

          mail = receive.mail

          receive.message_id = mail.message_id
          receive.email = Array.wrap(mail.from).first

          receive.save!

          yield receive
        end

      rescue ActiveRecord::RecordInvalid
        # 以下に示す理由により、この例外は無視出来る
        #
        # 可能性があるエラーは以下のとおり
        # message_id が nil
        # message_id の長さが 255 文字以上
        # message_id がユニークではない
        # email の長さが 255 文字以上
        #
        # このメソッドでは、一つのメールに対して、一回だけ処理を行う目的で使用する
        # nil の場合は、そもそもメールがパースできていないので処理は行うことはできない
        # 長さ制限は、 255 文字以上の message_id を出力するメールサーバーが出現するまでは考えなくて良い
        # メールアドレスも、 255文字以上のアドレスは考えなくて良い
        #
        # 異なるメールで、同じ message_id を持つメールが送信された場合は受け付けられないが、
        # 作成時から一定期間経過したものは delete することで回避する
      end

    end

    def mail
      @mail ||= ReceiveMailer.receive body
    end

    def bounced
      self.is_bounced = true
      save

      after_bounced
    end

    private

    def after_bounced
    end

  end
end
