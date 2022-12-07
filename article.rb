require_relative 'utils'

class Article

    attr_accessor :source, :title ,:description, :link, :date, :keyword_matches, :similar_articles

    def initialize(channel_title, raw_article)
        @source = channel_title
        @title = raw_article.title
        @description = raw_article.description
        if raw_article.link.is_a?(RSS::Atom::Feed::Link)
            @link = raw_article.link.href
        else
            @link = raw_article.link
        end
        @date = raw_article.pubDate.nil? ? raw_article.dc_date : raw_article.pubDate
        @keyword_matches = []
        @similar_articles = []
    end

    def older_than comparison_date
        begin
            article_datetime = @date.utc
        rescue Exception => e
            # if exception is raisen, assume article to be processed
            return true
        end
        return article_datetime < comparison_date
    end

    def check_for_cve
        return @description.scan(/CVE-[0-9]{4}-[0-9]+/) if not @description.nil?
    end

    def cve_output
        res_html = ""
        cve_list = Set.new(check_for_cve) # remove duplicates
        if !cve_list.empty?
            cve_list_html = ""
            cve_list.each do |cve|
                cve_list_html += "<li><a href=\"https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=#{cve}\">#{cve}</a></li>\n"
            end
            res_html = "
                    <br>
                    <i>   > Related CVEs</i>
                    <ul>
                        #{cve_list_html}
                    </ul>"
        end
        return res_html
    end

    def similar_articles_output
        res_html = ""
        similar_articles_html = ""
        if @similar_articles != []
            similar_articles.each do |article|
                similar_articles_html += "<li><a href=\"#{article.link}\">#{article.title}</a></li>\n"
            end
            res_html = "
                    <br>
                    <i>   > Similar articles</i>
                    <ul>
                        #{similar_articles_html}
                    </ul>"
        end
        return res_html
    end

    def similar_articles_output_slack
        res = ""
        if @similar_articles != []
            similar_articles_out = ""
            similar_articles.each do |article|
                similar_articles_out += "\t\t[#{article.title}](#{article.link})\n"
            end
            res = "\t> Similar articles\n#{similar_articles_out}"
        end
        return res
    end

    def cve_output_slack
        res = ""
        cve_list = Set.new(check_for_cve) # remove duplicates
        if !cve_list.empty?
            cve_list_out = ""
            cve_list.each do |cve|
                cve_list_out += "\t\t[#{cve}](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=#{cve})\n"
            end
            res = "\t> Related CVEs</i>\n#{cve_list_out}"
        end
        return res
    end

    # eql? abd hash methods used bu uniq!
    def eql?(other_obj)
        @link.eql?(other_obj.link)
    end
      
    def hash
        @link.hash
    end    

    def inspect
        custom_info
    end

    def to_s
        custom_info
    end

    def to_mail_format
        "<tr><td><a href=\"#{@link}\"><b>#{@title}</b></a>#{cve_output}#{similar_articles_output}</td><td><i>#{@source}</i></td><td><i>#{keyword_matches.join(', ')}</i></td>"
    end

    def to_slack_markdown
        "* [#{@title}](#{@link})\n#{cve_output_slack}\n#{similar_articles_output_slack}"
    end

    private

    def custom_info
"source: #{@source}
title: #{@title}
link: #{@link}
date: #{@date}
keyword_matches: #{@keyword_matches}"
    end

end