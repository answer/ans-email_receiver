# Ans::EmailReceiver

メール受信のためのクラス、モジュール

## Installation

Add this line to your application's Gemfile:

    gem 'ans-email_receiver'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ans-email_receiver

## Usage

    # model
    class EmailReceive
      include Ans::EmailReceiver::Model

      private

      def after_bounced
        # エラーメールの処理
      end
    end

    # job
    class InfoReceiver
      include Ans::EmailReceiver::Job
      @queue = :receive
    end

    # mailer
    # job クラスの mail_name に対応したクラス名にする
    class InfoMailer < ApplicationMailer
      include Ans::EmailReceiver::Mailer

      def save(email_receive)
        # メール受信の処理
      end
    end

    # スケジュール設定
    InfoReceiver:
      description: "info メールの受信処理を行う"

    # controller
    class EmailNotificationsController < ApplicationController
      include Ans::EmailReceiver::Controller
    end

    # config/routes.rb
    resources :email_notifications, only: [:show]

    # /etc/aliases
    info: info, |sh -c "/usr/bin/wget '$1' >> /dev/null 2>&1" - "http://mydomain.co.jp/email_notifications/info"

### 前提

EmailReceive が以下の属性を持つ

* `message_id` : `string` : メッセージID **ユニーク**
* `email` : `string` : メールアドレス
* `body` : `text` : 本文
* `is_bounced` : `boolean` : bounce メールか？

### 概要

`message_id` を `email_receives` に登録して、処理を二重に実行しないようにする

ブロックの中で例外が発生した場合、 `email_receives` には登録されない

ブロックの最後でメール削除を行うことで、プログラムエラーによるメールの無視を防ぐ
(予期しない例外が発生した場合、 fix 後にもう一度処理することでそのメールを処理できる)

メーラークラスは、 `"#{mail_name.camelize}Mailer"` が使用される

異なるメーラークラスを使用する場合は `mailer` メソッドをオーバーライドする

メールユーザー、パスワードは SystemSetting から取得される

デフォルトでは、エラーメール以外はサーバーからメールを削除しない

削除する場合は `delete?(email_receive)` メソッドで true を返す

エラーメールの削除はキャンセルできない

メール受信時、 /etc/aliases で、メール受信用のアクションを wget で叩くように設定する

コントローラでは、指定された job を呼び出す

job クラスが見つからない場合、 404 ステータスで ng を表示する


### オーバーライド可能なメソッドとデフォルト

    # model
    class EmailReceive
      include Ans::EmailReceiver::Model

      private

      def after_bounced
        # エラーメールの処理
      end
    end

    # job
    class InfoReceiver
      include Ans::EmailReceiver::Job
      @queue = :receive

      private

      def mail_name
        # mailer の名前、 config の設定名を取得するために使用される
        @mail_name ||= self.class.to_s.gsub(/Receiver$/, "").underscore
      end
      def config
        # host, port, user, password メソッドを持つオブジェクトを返す
        @config ||= Config.new mail_name
      end
      def mailer
        # receive 処理を行う mailer を返す
        @mailer ||= "#{mail_name.camelize}Mailer".constantize
      end

      def delete?(email_receive)
        # 処理後にサーバーのメールを削除する場合、 true を返す
        false
      end
    end

    # mailer
    class InfoMailer < ApplicationMailer
      include Ans::EmailReceiver::Mailer

      def save(email_receive)
        # メール受信の処理
      end
    end


## 設定

SystemSetting から設定を読み込む

使用される name とデフォルト

* `email_receive_#{mail_name}_host` : localhost
* `email_receive_#{mail_name}_port` : 110
* `email_receive_#{mail_name}_user` : `mail_name`
* `email_receive_#{mail_name}_password` : password


## 例外処理について

EmailReceive を create する際、失敗する可能性があるが、以下に示す理由により、この例外は無視出来る

可能性があるエラーは以下のとおり
* `message_id` が nil
* `message_id` の長さが 255 文字以上
* `message_id` がユニークではない
* `email` の長さが 255 文字以上

このメソッドでは、一つのメールに対して、一回だけ処理を行う目的で使用する

nil の場合は、そもそもメールがパースできていないので処理は行うことはできない

長さ制限は、 255 文字以上の `message_id` を出力するメールサーバーが出現するまでは考えなくて良い

メールアドレスも、 255文字以上のアドレスは考えなくて良い

異なるメールで、同じ `message_id` を持つメールが送信された場合は受け付けられないが、
作成時から一定期間経過したものは delete することで回避する


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
