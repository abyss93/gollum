#!/usr/bin/ruby

require 'rss'
require 'uri'
require 'nokogiri'
require 'time'
require 'yaml'
require 'optparse'
require 'json'
require_relative 'mail_service'
require_relative 'article'
require_relative 'utils'
require_relative 'similarity'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rss_analyzer.rb [options]

  GOLLUM v0.1

  Scan RSS sources specified in sources.xml and filter by keywords specified in keywords file.
  After the scan is done articles are placed into a table and can be sent by email.
  "
  opts.on("-v", "--version", "Display version") do |v|
    options[:version] = v
    puts '0.1'
  end
  opts.on("-a", "--all", "Gather articles that did not match any keyword") do |v|
    options[:other_articles] = v
  end
  opts.on("-c", "--cluster", "Apply some basic NLP to cluster similar articles, topics are inferred from articles' title (WIP)") do |v|
    options[:similarity] = v
  end
  opts.on("-d", "--debug", "Enables logging on STDOUT") do |v|
    options[:debug] = v
  end
  opts.on("-e", "--email", "Send results by email") do |v|
    options[:email] = v
  end
  opts.on("-j", "--json", "Return results in JSON format") do |v|
    options[:json_format] = v
  end
end.parse!

mail_service_configuration = YAML.load_file('./config/mail_config.yml')
mail_service = MailService.new(mail_service_configuration)
mail_builder = mail_service.get_mail_builder
rss_sources = Utils.get_rss_sources


keywords = File.open('./config/keywords')
               .readlines
               .select {|line| line[0] != '#'}
               .map { |k| k.downcase.gsub(' ','').gsub("\n",'') }
puts "Keywords: #{keywords.inspect}" if options[:debug]

keyword_articles = []
other_articles = []

rss_sources.each do |source|
  puts "Processing #{source}" if options[:debug]
  
  begin
    URI.open(source) do |rss_xml|
      rss_feed = RSS::Parser.parse(rss_xml)
      rss_feed.items.each do |article|
        article = Article.new(rss_feed.channel.title, article)
        puts "\t Processing #{article.title}" if options[:debug]
        Utils.show_progress()

        next if article.older_than Utils::THRESHOLD_TIME

        if keywords.length > 0 and Utils.match article, keywords
          keyword_articles.push(article)
        else
          other_articles.push(article) if options[:other_articles]
        end    

      end
    end
  rescue Exception => e
    # capture general Exception is a bad practice, but in this context it's not too bad
    Utils.print_exception_info e, source if options[:debug]
  end
end

# making sure there will be no duplicate (same URL) articles
keyword_articles.uniq!
other_articles.uniq!

# look for similar articles to group
Similarity.execute(keyword_articles, options[:debug]) if options[:similarity]
Similarity.execute(other_articles, options[:debug]) if options[:other_articles] and options[:similarity]

# print summary of findings
if options[:debug]
  puts '________________________________________'
  puts "Feed articles: #{keyword_articles.length + other_articles.length}"
  puts "\tkeyword: #{keyword_articles.length}"
  puts "\tother: #{other_articles.length}"
  puts '________________________________________'
end

# send mail
if options[:email]
  to_send = mail_builder.add_header_image
              .add_header
              .add_articles(keyword_articles.sort_by {|ar| ar.keyword_matches})
  to_send.add_articles(other_articles) if options[:other_articles]
  to_send = to_send.add_footer
                 .build
  mail_service.send_mail(to_send, options[:debug])
end

# return results
if options[:json_format]
  if options[:other_articles]
    return { keyword_articles: keyword_articles, other_articles: other_articles }.to_json
  end
  return { keyword_articles: keyword_articles }.to_json
end