class MailBuilder

    def initialize(color, background_color, images, header_html, footer_html)
        @message = ''
        @color = color
        @background_color = background_color
        @images = images
        @header_html = header_html
        @footer_html = footer_html
    end

    def add_header_image
        @message << "<img src=\"data:image/png;base64,#{@images[0]}\"/><br><br>"
        return self
    end

    def add_header
        @message << @header_html
        return self
    end

    def add_footer
        @message << @footer_html
        return self
    end

    def add_to_list(element)
        @message << "#{element}"
        return self
    end

    def add_articles(articles)
        @message << "
        <div class=\"content\">
            <table class=\"articles_table\"><tr><th>Feed</th><th>Source</th><th>Topics</th></tr>\n"
        articles.each do |article|
            @message << "\t\t\t\t#{article.to_mail_format}\n"
        end
        @message << "
            </table>
        </div>
        <hr>"
        return self
    end

    def build
        puts 'Building HTML'
        html = "
    <html>
        <head>
            <style>
                body {
                  font-family: Tahoma, Verdana, sans-serif;
                  font-size: 14px;
                }
                table.articles_table {
                  background-color: #FFFFFF;
                  width: 100%;
                  text-align: left;
                  border-collapse: collapse;
                }
                table.articles_table td, table.articles_table th {
                  border: 0px solid #AAAAAA;
                  padding: 5px 5px;
                  font-size: 13px;
                }
                table.articles_table tbody td {
                  font-size: 10px;
                }
                table.articles_table tr:nth-child(even) {
                  background: #D0E4F5;
                }
                table.articles_table thead {
                  background: #1C6EA4;
                  border-bottom: 2px solid #444444;
                }
                table.articles_table thead th {
                  font-size: 12px;
                  font-weight: bold;
                  color: #FFFFFF;
                }
            </style>
        </head>
        <body>
        " + @message + 
        "</body>
    </html>"
        puts html
        return html 
    end

end