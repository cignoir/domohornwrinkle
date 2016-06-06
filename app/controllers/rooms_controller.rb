class RoomsController < ApplicationController
  protect_from_forgery :except => ["stalker"]

  def stalker
    post_json = params[:post_json]
    posts = JSON.parse post_json

    posts.map do |post|
      Message.create(content: "#{post['content']}")
    end

    Message.where('created_at < ?', 1.day.ago).destroy_all

    head :ok
  end

  def show
    @messages = Message.order('created_at DESC')
  end
end
