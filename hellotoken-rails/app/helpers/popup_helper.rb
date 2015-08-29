module PopupHelper
  def generateFormHtml(question, article, reader, publisher, full_url=nil)
    form_html = label_tag(:ht_question, question.text, :id => "question_label")
    if !question.multiple_choice
      form_html += text_field_tag(:ht_question, "", :class => "ht-question", value: "")
      form_html += "<br/>".html_safe
      form_html += submit_tag("Submit", :class => "question-submit", :id => "question-enter")
      form_html += getSubmitScript(false)
    else
      form_html += "<div class='ht-question' name='ht_question' id='ht_choice'>".html_safe
      # randomize question choices, but not demographic ones
      if !question.random
        choices_collection = question.choices
      else
        choices_collection = question.choices.shuffle
      end
      choices_collection.each do |choice|
        if !question.use_images
          form_html += submit_tag(choice.text.upcase, :class => "question-submit", :id => 'question-submit', 
                                  name: "response[#{choice.id.to_s}]")
        else
          form_html += label_tag(choice.text.upcase) # the text for the choice
          form_html += image_submit_tag(choice.image.url(:medium), :class => "question-submit", :id => 'question-submit', 
                                  name: "response[#{choice.id.to_s}]", value: choice.text) # the image for the choice
        end
        form_html += '<br>'.html_safe
      end
      form_html += "</div>".html_safe
      form_html += getSubmitScript(true)
    end
    # hidden fields used to send information about the user
    form_html += hidden_field_tag('question_id',question.id)
    form_html += hidden_field_tag('article_id',article.id)
    form_html += hidden_field_tag('reader_id',reader.id)
    form_html += hidden_field_tag('demographic',question.demographic) unless question.demographic.blank?
    form_html += hidden_field_tag('full_url',full_url) 
    return form_html
  end

  def getMessage(question, reader, publisher)
    # AB Testing
    testOn = (publisher.email == "publisher@harvardpolitics.com" and (Time.new.min / 15).odd?)
    logger.info {"AB Testing On: #{testOn}"} # in this case "on" equals "off" i.e. not showing modal
    if testOn
      testingType = "no dialog"
    else
      testingType = "show dialog"
    end

    if question.nil? or testOn
      return 'close no pass'
    else
      return "question " + ({"question"     => {"alpha_id" => question.alpha_id}, 
                             "reader"       => {"alpha_id" => reader.alpha_id},
                             "testingType"  => testingType
                            }).to_json
    end
  end

  # just a handy method for generating the string used to send a message to the plugin
  def postMessage(msg)
    return ("<script>window.parent.postMessage('" + msg + "', document.referrer);</script>").html_safe
  end

  # javascript to listen for the triger for "answering" a question and then transmitting it
  def getSubmitScript(multiple_choice)
    if multiple_choice
      script = 
        "<script> 
          $('input.question-submit').click(function(event){
            window.parent.postMessage('answer', document.referrer)
          });
        </script>"
    else
      script = 
        "<script> 
          $('question-enter').click(function(event){
            window.parent.postMessage('answer', document.referrer)
          });
        </script>"
    end
    return script.html_safe
  end


end
