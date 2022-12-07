class SlackBuilder

    def initialize(header, footer)
        @message = ''
        @header = header
        @footer = footer
    end

    def add_header
        @message << @header
        return self
    end

    def add_footer
        @message << @footer
        return self
    end

    def add_to_list(element)
        @message << "#{element}"
        return self
    end

    def add_articles(articles)
        articles.each do |article|
            @message << "#{article.to_slack_markdown}\n"
        end
        return self
    end

    def build
        @message 
    end

end