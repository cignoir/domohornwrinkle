require 'open-uri'

namespace :stalker do
  task :gaze => :environment do
    search_url = 'http://refind2ch.org/search?q=%E5%8D%83%E5%B9%B4%E6%88%A6%E4%BA%89%E3%82%A2%E3%82%A4%E3%82%AE%E3%82%B9&pl=2chnet'

    doc = Nokogiri::HTML.parse(open(search_url).read)
    urls = doc.css('.thread_url').take(2).map{ |node| node.attributes['href'].text }.reverse

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