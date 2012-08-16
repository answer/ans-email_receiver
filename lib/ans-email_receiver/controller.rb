# -*- coding: utf-8 -*-

module Ans::EmailReceiver
  module Controller
    def show
      Resque.enqueue "#{params[:id]}Receiver".constantize
      render text: "ok"
    rescue NameError
      # 見つからなかった場合の NotFound エラーは ActiveRecord のものを使いまわす
      raise ActiveRecord::RecordNotFound
    end
  end
end
