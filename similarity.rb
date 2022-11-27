require 'set'

module Similarity

  def Similarity.execute(articles, debug)
    articles.each do |current_article|
      articles.each do |article_to_compare|
        next if current_article.link == article_to_compare.link
        # https://grammar.yourdictionary.com/capitalization/rules-for-capitalization-in-titles.html
        # https://en.wikipedia.org/wiki/Jaccard_index
        t1 = find_capital_words(current_article.title)
        t2 = find_capital_words(article_to_compare.title)
        similarity = jaccard_similarity(t1, t2)
        if debug
          puts '________________________________________'
          puts current_article.title
          puts article_to_compare.title
          puts similarity
          puts '________________________________________'
        end
        # group if titles are 80% or more similar and avoid to group more than one time (see not condition)
        if similarity >= 70 and not article_to_compare.source == current_article.source
          if debug
            puts "[#{current_article.title}] SIMILAR [#{article_to_compare.title}]" 
            puts '________________________________________'
          end
          current_article.similar_articles.push article_to_compare
          similar.push article_to_compare
        end
      end
    end
  end

  def Similarity.find_capital_words(text)
    return Set.new(text.scan(/([A-Z]\w+)/))
  end

  def Similarity.jaccard_similarity(a, b)
    intersection = a & b
    union = a | b
    return ((intersection.length.to_f / union.length.to_f) * 100).to_i
  end

end