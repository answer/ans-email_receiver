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

    # job クラスの mail_name に対応したクラス名にする
    class InfoMailer < ApplicationMailer
      include Ans::EmailReceiver::Mailer

      def save(data)
        # メール受信の処理
        #mail = data[:mail]
        #email_receive = data[:email_receive]
      end
    end

    # スケジュール設定
    InfoReceiver:
      description: "info メールの受信処理を行う"

    # controller
    class EmailReceivesController
      include Ans::EmailReceiver::Controller
    end

    # /etc/aliases
    info: info, |sh -c "/usr/bin/wget '$1' >> /dev/null 2>&1" - "http://mydomain.co.jp/email_receives/info"

### 前提

EmailReceive が以下の属性を持つ

* `message_id` : `string` : メールアドレス
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

`MAIL_USER_#{mail_name}`, `MAIL_PASSWORD_#{mail_name}` の設定を参照する

デフォルトでは、エラーメール以外はサーバーからメールを削除しない

削除する場合は `delete?(email_receive)` メソッドで true を返す

`email_receive` は処理した EmailReceive のインスタンス(処理後 reload 済みのやつ)

エラーメールの削除はキャンセルできない


### オーバーライド可能なメソッドとデフォルト

    # model
    class EmailReceive
      include Ans::EmailReceiver::Model

      private

      def after_bounced
        # エラーメールの処理
      end
    end


## 設定

SystemSetting から設定を読み込む

使用される name とデフォルト

* `email_receive_#{mail_name}_host` : localhost
* `email_receive_#{mail_name}_port` : 110
* `email_receive_#{mail_name}_user` : `mail_name`
* `email_receive_#{mail_name}_password` : password


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
