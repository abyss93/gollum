module Utils

    SPINNER = Enumerator.new do |e|
        loop do
        e.yield '|'
        e.yield '/'
        e.yield '-'
        e.yield '\\'
        end
    end

    TODAY = Time.now
    THRESHOLD_TIME = Time.mktime(TODAY.year, TODAY.month, TODAY.day - 1, TODAY.hour, TODAY.min).utc

    def Utils.get_rss_sources
        result = []
        rss_file = File.open('sources.xml').read
        xml_sources = Nokogiri::XML(rss_file) do |config|
            # NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents. This is set by default!
            # RECOVER - Attempt to recover from errors. Recommended for parsing malformed or invalid documents. This is set by default!
            # sono settate per default, ma io le setto comunque esplicitamente
            config.strict.nonet
            config.strict.recover
        end
        # prendo gli elementi che hanno attirbuto xmlUrl
        xml_sources.xpath('//*[@xmlUrl]').each do |xml_obj|
            result.push xml_obj.attr('xmlUrl')
        end
        return result
    end
  
    def Utils.print_exception_info ex, rss_source
        puts '________________________________________'
        puts "Error while processing #{rss_source}"
        puts "=> ERROR: [#{ex}]"
        puts "=> BACKTRACE: #{ex.backtrace.join("\n")}"
        puts '________________________________________'
    end
  
    def Utils.match article, keywords
        # 1) article can be opened and used roughly, but html and non-informational
        #    elements are just noise
        #    article_text = URI.open(article.link).read.downcase.gsub(' ','')
        # 2) tools like trafilatura can be used to extract only the informational content of web page
        #    article_text = `trafilatura -u #{article.link}`
        # 3) use description, provided by default by RSS
        article_text = article.description.downcase.gsub(' ','')
        res = false
        keywords.each do |keyword|
            if article_text.include? keyword
                res = true
                article.keyword_matches.push keyword
            end         
        end
        return res
    end

    def Utils.show_progress()
        printf("\r~ wandering around Middle Earth ~ %s", SPINNER.next)
    end
end