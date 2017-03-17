# Insert ToggleImage placeholders and scripts. 

require 'fileutils'

def processString(rawString)

    imageNames = []
    # We know at least one tag exits, we are going to form an HTML snippet to 
    # directly replace the tag later on. Grab the positions of the tag within the rawString. 
    tagCount = rawString.scan("<ToggleImage ").count
    puts "Found #{tagCount} <ToggleImage> tags"

    while rawString.include?("<ToggleImage ")
        # Get the position of the unprocessed tag
        start = rawString.index("<ToggleImage ")
        finish = rawString.index(">", start)

        # Extract the image tag from the string. We need to infer information from this. 
        # How many images are to be toggled? Count the number of = signs. 
        rawTag = rawString[start..finish]
        count = rawTag.scan('=').count
        puts "Found #{count} images within the current tag: #{rawTag}"

        # Process each image (represented by an = sign) separately. 
        count.times do 
            # Grab the image name by scanning up to the next space. 
            s = rawTag.index('=')
            f = rawTag.index(' ', s)

            # No more spaces? Must be at the end of the tag. 
            if !f 
                f = rawTag.index('>', s) - 1
            end 

            # Append the name and wipe from the tag for the next loop.
            img = rawTag[s+1..f].strip
            imageNames << img[1 .. img.length-2]
            rawTag[s..f] = ""
        end
        
        if count != imageNames.count 
            puts "Warning: did not extact the expected number of imageNames, counts do not match up"
            puts imageNames.to_s
            return nil
        end 

        # And now construct the HTML tag. We will also prepare a dummy tag to replace the original 
        # so that we can keep track of the original state.
        pre = "<!-- Processed_Image_Toggle "
        htmlTag = "<div id=\'toggleImageArea\'>"
        count.times do |i|
            # Small bit of logic for the JS functions to point to the next image
            n = i + 1
            if n == count
                n = 0 
            end 
            
            # Image source goes in here, with id. 
            line = "\n\t" + "<img id=\'#{imageNames[i]}\' src=\'images/#{imageNames[i]}\' "    

            # First image of the set should be visible. All others set to 'none' display style. 
            if i != 0 
                line << "style=\'display: none;\' "
            end 

            # And the JS function. 
            line << "onclick=\"toggleToNextImage(this, \'#{imageNames[n]}\')\">"
            htmlTag << line 

            # The dummy tag
            pre << imageNames[i] + " "
        end
        htmlTag << "\n</div>"
        pre << "-->\n"

        # Stick the pre onto the html tag
        htmlTag.prepend(pre)
        rawString[start..finish] = htmlTag
    end 

    if tagCount == rawString.scan("<div id=\'toggleImageArea\'").count
        return rawString
    else 
        puts "Warning: number of <ImageToggle> tags does not match number of <divs> inserted."
        return nil 
    end 

end

# Main function starts here. 

puts "\nToggleImage HTML preprocessor, Tom Kirk, 17/3/17"
puts "Usage: ruby ToggleImagePreProcess <inputDirectory>"
puts "This will modify files in place!"
puts "This tool will recursively search for all html files within the given inputDirectory and then modify
them inplace, replacing <ImageToggle> tags with appropriate HTML and JS.\n\n"

if ARGV.first
    root = ARGV.first 
    paths = Dir[root + "/**/*.html"]
    errors = 0
    puts "Found #{paths.count} HTML files."
    puts "---------------------------------"


    paths.each do |path|
        # Read in the file path
        puts "Opening file #{path}"
        f = File.open(path)
        string = f.read
        f.close

        # Has it been fully processed - contain as many <divs> as <ToggleImages>?
        if string.scan("<ToggleImage").count == string.scan("<div id=\'toggleImageArea\'").count && string.scan("<ToggleImage").count != 0
            puts "Already processed this file."
        elsif string.include?("<ToggleImage")
            puts "File needs processing."
            string = processString(string)
            if string
                # Write out on top of the original file
                File.open(path, 'w') { |file| file.write(string) }
            else 
                "Error processing file #{path}, this has been skipped"
                next
            end 
        else
            puts "File does not need processing."
        end

        # # Create the output folders if they do not exist 
        # while outputDir[-1] != '/'
        #     outputDir = outputDir.chop
        # end
        # FileUtils.mkdir_p(outputDir) unless File.exists?(outputDir)

        puts "---------------------------------"

    end

    puts "Finished.\n"

end

