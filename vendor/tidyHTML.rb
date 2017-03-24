paths = Dir["teaching/**/*.html"]

paths.each do |p| 

    f = File.open(p)
    s = f.read 
    f.close 

    # Ruby script to tidy up all the HMTL files. 

    # Annoying header that TextEdit adds in. It's many lines long. 
    headerStart = "<!DOCTYPE"
    headerEnd = "<body>"
    if s.index(headerStart) && s.index(headerEnd)
        s[s.index(headerStart) .. (s.index(headerEnd) + headerEnd.length)] = ""
    end

    # Other one-liners that need to go. 
    redundants = [" class=\"Apple-converted-space\""]
    redundants << " class=\"p1\""
    redundants << " class=\"p2\""
    redundants << " class=\"p3\""
    redundants << " class=\"p4\""
    redundants << " class=\"p5\""
    redundants << "</body>"
    redundants << "</html>"
    redundants << "<b><i></i></b><br></p>"
    redundants << "<p><b></b><br></p>"
    redundants << "<p><br></p>"
    redundants << " class=\"ol1\""
    redundants << " class=\"li3\""
    redundants << " class=\"s1\""
    redundants << " class=\"Apple-tab-span\""

    # One-by-one strip them out. 
    redundants.each do |r|
        s = s.gsub(r, "")
    end

    File.open(p, 'w') { |f| f.write(s) }

end 
