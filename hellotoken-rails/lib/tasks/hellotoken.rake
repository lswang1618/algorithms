namespace :hellotoken do
  desc "Fill in geolocation for users with ip but no geo details"
  task fill_geolocation: :environment do
    ActiveRecord::Base.record_timestamps = false # don't update timestamps
    puts "Filling in details..."
    count = 0
    Reader.where.not(last_ip: nil).where.not(last_ip: "").find_each do |reader|
      begin
        if reader.city.blank? or reader.country.blank? or reader.region.blank?
          count += 1
          results = Geocoder.search(reader.last_ip)
          if geo = results.first
            data = geo.data
            reader.city = data[:city_name]
            reader.region = data[:region_name]
            reader.country = data[:country_name]
            if reader.changed?
              puts "New location for reader #{reader.id} for ip #{reader.last_ip}: City: #{reader.city}, Region: #{reader.region}, Country: #{reader.country},"
            end
            reader.save
          end
        end
      rescue => e
        puts "#{e}"
        next
      end
    end
    puts "#{count} readers filled in."
    ActiveRecord::Base.record_timestamps = true
  end

  desc "First time task for linking responses to articles"
  task link_responses: :environment do
    puts "Finding articles..."
    count = 0
    Response.where(article_id: nil).find_each do |response|
      begin
        # me being really lazy
        # slow and inefficient, but should only need to happen once
        url = response[:article]
        host = URI(url).host
        if host.count('.') > 1
          host = host[(host.index('.')+1)..-1]
        end
        article_hash = {
          url: url,
          path: URI(url).path,
          domain: host
        }
        publisher = Publisher.find_by(domain: host)
        raise "Couldn't find a publisher for response #{response.id} with url #{url}" unless publisher.present?
        article = Article.popup_visit(article_hash, publisher)
        response.update(article_id: article.id)
        article.update_num_responses
        puts "Linked response #{response.id} with url #{url} to article #{article.id}"
        count+=1
      rescue => e
        puts "#{e}"
        next
      end
    end
    puts "#{count} responses linked to articles"
  end

  desc "Link old articles together that were stored by url instead of domain+path (should be one time use)"
  task link_articles: :environment do
    Article.group(:domain, :path).count.each do |url, number|
      puts "Linking articles with domain #{url[0]} and path #{url[1]}..."
      # first, find an article to unify under
      primary_article = Article.find_or_create_by(domain: url[0], path: url[1], url: url[0] + url[1])
      # then find all the articles to link
      linked_articles = Article.where(domain: url[0], path: url[1]).includes(:responses)
      num_visits_increased = 0
      num_responses_increased = 0
      num_linked = linked_articles.count
      primary_article.publisher_id = linked_articles.first.publisher_id
      linked_articles.each do |article|
        unless article.id == primary_article.id
          primary_article.visits = (primary_article.visits || 0) + article.visits
          num_visits_increased += article.visits
          num_responses_increased += article.responses.count
          article.responses.update_all(article_id: primary_article.id)
          article.destroy
        end
      end
      primary_article.save
      puts "Linked #{num_linked} articles with #{num_visits_increased} total visits and #{num_responses_increased} total responses."
    end
  end

  desc "Reset counters"
  task reset_counters: :environment do
    Article.find_each {|article| Article.reset_counters(article.id, :responses)}
    Question.find_each {|question| Question.reset_counters(question.id, :responses)}
    Choice.find_each {|choice| Choice.reset_counters(choice.id, :responses)}
  end

  # this task is no longer necessary w/ creation of admin board
  desc "List researchers and publishers signed up"
  task list_emails: :environment do
    puts "Listing researcher emails by sign-up date:"
    puts Researcher.order(:created_at).pluck(:email).join(", ")
    puts "Listing publisher emails by sign-up date:"
    puts Publisher.order(:created_at).pluck(:email).join(", ")
  end

end

# automate by running
# $ crontab -e
# 0 0 1 * * cd /home/hellotoken-rails && /usr/local/rvm/gems/ruby-2.1.3/bin/rake RAILS_ENV=production hellotoken:fill_geolocation