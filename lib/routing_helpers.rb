require 'pathname'

module RoutingHelpers

  def self.sayHello
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
  def self.manualLink(destTopic, destLevel, linkBody, destPart=nil)
    # Check that both the topic and level are correct. Then generate the link 
    if topic = Topic.where(short_name: destTopic).first
      if topic.level_names.include? destLevel 
        link = if destPart
          "<a href='/teaching?id=#{topic.id}&forLevel=#{destLevel.downcase}&currentPart=#{destPart}'> #{linkBody} </a>"
        else 
          "<a href='/teaching?id=#{topic.id}&forLevel=#{destLevel.downcase}'>#{linkBody}</a>"
        end
        return link
      else 
        raise "Level #{destLevel} does not exist for topic #{destTopic}"
      end 
    end 

    # If either of the above tests failed then we will return this error link.
    raise "Manual link error on #{f}, topic #{destTopic}, level #{destLevel}" 
    # return "<a href=\"javascript:window.alert('Sorry, this link is not currently available');\"> #{linkBody} </a>"

  end

  # Method called upon server startup to insert manual teaching links in all pages 
  # Cycle through each topic and all levels and look for ERB teaching pages in the 
  # corresponding directory. Then evaluate the link templates (which are of the 
  # form manualLink(destTopic, destLevel, linkBody, destPart)) in this context using
  # the binding call. The results are saved as HTML files. 
  def self.preprocessManualTeachingLinks
    puts "Expanding manual teaching page links"
    # This will crash on rake db:setup as the table doesn't actually exist yet.
    # So check for existence first 
    if ActiveRecord::Base.connection.data_source_exists? 'topics'
      Topic.all.each do |t| 
        t.level_names.map.with_index do |l, i|
          files = Dir["teaching/#{t.shortName}/#{i} #{l}/*.erb"]
          files.each do |f|
            begin
              rawStr = File.read(f)
              template = ERB.new(rawStr)
              flatHTMLString = template.result(binding)
              f['.erb'] = ''
              File.open(f, 'w') { |nf| nf << flatHTMLString }
            rescue Exception => e 
              puts "Error on page #{f}"
              puts e.to_s 
              raise "ManualLinkError"
            end 
          end 
        end 
      end 
    end 
  end 

  # Helper to return a path to the teaching directory for the topic and level 
  #
  # @param topic [String/Int] short topic name or topic ID eg shoulder
  # @param level [String/Int] short level name or topic level eg introduction 
  # @return [String] path to the teaching directory with trailing slash 
  def self.teachingDirectory(topic, level)
    if topic.is_a?(String) 
      tops = Topic.all.select { |t| t.shortName == topic }
      tpcObj = tops.first    
    else
      tpcObj = Topic.find(topic)
    end
    level = level.is_a?(String) ? level : tpcObj.shortName(level)
    dir = "teaching/#{tpcObj.shortName}/#{level}/" 
    if !(Dir.exist?(dir))
      raise "NonexistentDirectoryError"
    end
    return dir 
  end 


  # Send HTML and pages at the given location.
  # 
  # @param topicName [String] short topic name 
  # @param forLevel [String] short level name 
  # @return [[String]] paths, sorted from part 0 to N (N < 10)
  def self.teachingPagePaths(topicName, forLevel)
    pathStr = teachingDirectory(topicName, forLevel) 
    paths = Dir[pathStr + '*.html']
    if paths.empty?
      raise "NoPathsFound"
    end 
    return paths.sort_by do |s|
      # Some funky regexp -- disabled and back to simple extract last number between P and html! s[/\d{2,}/].to_i
      # so make sure that there are less than 10 pages in a level...
      s[s.rindex('P') + 1..s.rindex('.html') - 1].to_i
    end 
  
  end

  # Load teaching paths for all HTML pages 
  def self.prepareTeachingPaths()
    puts "Preparing teaching paths"
    if ActiveRecord::Base.connection.data_source_exists? 'topics'
      Topic.all.each do |t|
        paths = t.level_names.map.with_index do |l, i|
          ps = Dir["teaching/#{t.shortName}/#{i} #{l}/*.html"]
          ps.sort_by do |s| 
            # Some funky regexp -- disabled and back to simple extract last number between P and html! s[/\d{2,}/].to_i
            # so make sure that there are less than 10 pages in a level...
            s[s.rindex('P') + 1..s.rindex('.html') - 1].to_i
          end 
        end
        t.paths = paths 
        t.save 
      end
    end
    return 
  end


  # Read out level names from each topic's directory structure, save them 
  # in order to the topic's level_names field on the table. 
  def self.loadLevelNames()
    puts "Loading level names"
    if ActiveRecord::Base.connection.data_source_exists? 'topics'
      Topic.all.each do |t|
        dirs = Dir["teaching/#{t.shortName}/*"]
        dirs = dirs.filter { |d| File.directory?(d) }
        dirs = dirs.map do |d|
          p = Pathname.new(d)
          String(p.basename)
        end 
        dirs = dirs.sort_by { |d| d.split[0] }
        paths = dirs.map { |d| (d[1..]).strip }
        t.level_names = paths 
        t.save
      end 
    end
  end 

end 