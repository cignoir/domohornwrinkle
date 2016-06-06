require 'open-uri'

namespace :stalker do
  task :gaze, ['search_word'] => :environment do |task, args|
    urls = Stalker::Thread.find(args[:search_word]).take(2).reverse
    urls.each do |url|
      thread = Stalker::Thread.new(url.gsub(/l50/, ''))
      posts = thread.parse

      last_created_at = Message.maximum(:created_at).in_time_zone('Asia/Tokyo')
      posts = posts.select do |p|
        last_created_at && p.posted_at && Time.zone.parse(p.posted_at) > last_created_at
      end

      json = posts.map{ |p| Message.new(content: "#{p.message}") }.to_json

      conn = Faraday::Connection.new(:url => 'http://127.0.0.1:3000')
      conn.post do |req|
        req.url '/stalker'
        req.body = {
            post_json: json.to_s
        }
      end
    end
  end
end