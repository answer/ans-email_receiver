# -*- coding: utf-8 -*-

module Ans::EmailReceiver
  module ModelHelper
    def self.included(m)
      m.send :extend, ClassMethods
      m.send :scope, :old, lambda{
        where("created_at < now() - interval 1 year")
      }
    end

    module ClassMethods

      # メールに対して一回だけ処理を行う
      #
      #  body = m.pop
      #  mail = Mailer.receive body
      #  EmailReceive.unique_transaction mail, body do |email_receive|
      #    # メールの受信処理
      #  end
      #
      # メール受信時の処理を行うのに使用する
      # 受信したデータは別途削除するので、重複した処理を行わない用にする
      # 受信したメールの message-id を EmailReceive に登録することで、一回だけの処理を実現する
      #
      def unique_transaction(mail,body)
        delete_olds

        transaction do
          yield create! message_id: mail.message_id, email_address: mail.from.first, body: body
        end

      rescue ActiveRecord::RecordInvalid
        # 以下に示す理由により、この例外は無視出来る
        #
        # 可能性があるエラーは以下のとおり
        # message_id が nil
        # message_id の長さが 255 文字以上
        # message_id がユニークではない
        # email_address の長さが 255 文字以上
        #
        # このメソッドでは、一つのメールに対して、一回だけ処理を行う目的で使用する
        # nil の場合は、そもそもメールがパースできていないので処理は行うことはできない
        # 長さ制限は、 255 文字以上の message_id を出力するメールサーバーが出現するまでは考えなくて良い
        # メールアドレスも、 255文字以上のアドレスは考えなくて良い
        #
        # 異なるメールで、同じ message_id を持つメールが送信された場合は受け付けられないが、
        # 作成時から一定期間経過したものは delete(acts_as_paranoid) することで回避する
      end

      private

      def delete_olds
        old.delete_all
      end

    end

  end
end
