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

メール受信部分の共通部分

    # model
    class EmailReceive
      acts_as_paranoid

      include Ans::EmailReceiver::ModelHelper
    end

    # job
    class MyReceiver
      include Ans::EmailReceiver::JobHelper

      @queue = :receive

      private

      def mail_name
        "info"
      end
    end

    # mailer
    class ApplicationMailer < ActionMailer::Base
    end
    class ApplicationMailer < Jpmobile::Mailer::Base # jpmobile のメーラーを使用する場合
    end

    # job クラスの mail_name に対応したクラス名にする
    class InfoMailer < ApplicationMailer
      def receive(mail)
        # メール受信の処理
      end
    end

オーバーライド可能なメソッドとデフォルト

* `mail_name` : 設定と、メーラーの呼出に使用される(デフォルトなし)
* `delete?(email_receive)` : 処理後、メールをサーバーから削除するかどうか(デフォルト: `false`)
* `mailer` : メール受信に使用するメーラー(デフォルト: `"#{MailName}Mailer"`)
* `config` : 設定を取得する(デフォルト: `Config.new mail_name`)
* `model` : メールの保存に使用するモデル(デフォルト: `EmailReceive`)

### 概要

`message_id` を `email_receives` に登録して、ユニークな処理を行う
ブロックの中で例外が発生した場合、 `email_receives` には登録されない
ブロックの最後でメール削除を行うことで、プログラムエラーによるメールの無視を防ぐことができる
(予期しない例外が発生した場合、 fix 後にもう一度処理することでそのメールを処理できる)

メーラークラスは、 `"#{mail_name.camelize}Mailer"` が使用される
異なるメーラークラスを使用する場合は `mailer` メソッドをオーバーライドする

メールユーザー、パスワードは SystemSetting から取得される
`MAIL_USER_#{mail_name}`, `MAIL_PASSWORD_#{mail_name}` の設定を参照する

デフォルトでは、エラーメール以外はサーバーからメールを削除しない
削除する場合は `delete?(email_receive)` メソッドで true を返す
`email_receive` は処理した EmailReceive のインスタンス(処理後 reload 済みのやつ)
エラーメールの削除はキャンセルできない


## 設定

SystemSetting から設定を読み込む

使用される name とデフォルト

* `mail_receive_#{mail_name}_host` : localhost
* `mail_receive_#{mail_name}_port` : 110
* `mail_receive_#{mail_name}_user` : user
* `mail_receive_#{mail_name}_password` : password


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
