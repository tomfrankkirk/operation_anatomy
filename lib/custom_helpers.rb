module RoutingHelpers

  def sayHello
    "hello" 
  end 

  # Helper method to dynamically fill-in manually specified links within 
  # teaching pages. Before a page is served up, ERBs are templated in the 
  # controller's scope which allows the the arguments defined within the page
  # to be passed into the function, which then generates the a href tags
  # and serves them up. Arguments should mirror the structure of the 
  # teaching directory. 
  # 
  # @param destTopic [String] short topic name eg shoulder
  # @param destLevel [String] short level name eg bones
  # @param linkBody [String] the body of the link to display 
  # @param destPart [Int] optional, part number to direct to (zero index)
  def manualLink(destTopic, destLevel, linkBody, destPart=nil)
    # Check that both the topic and level are correct. Then generate the link 
    if topic = (Topic.all.select { |t| t.shortName == destTopic }).first
      if topic.shortLevelNames.include? destLevel 
        link = if destPart
          "<a href='/teaching?id=#{topic.id}&forLevel=#{destLevel.downcase}&currentPart=#{destPart}'> #{linkBody} </a>"
        else 
          "<a href='/teaching?id=#{topic.id}&forLevel=#{destLevel.downcase}'>#{linkBody}</a>"
        end
        return link
      end 
    end 

    # If either of the above tests failed then we will return this error link. 
    return "<a href=\"javascript:window.alert('Sorry, this link is not currently available');\"> #{linkBody} </a>"

  end

  def teachingDirectory(topic, level)
    
    if topic.is_a?(String) 
      tops = Topic.all.select { |t| t.shortName == topic }
      tpcObj = tops.first    
    else
      tpcObj = Topic.find(topic)
    end
    level = level.is_a?(String) ? level : tpcObj.shortName(level)
    return "teaching/#{tpcObj.shortName}/#{level}/" 
  end 

end 