#! /usr/bin/ruby
require('date')

preformatted_text_is_open = false
static_dir = '/home/gemini/gemini-server/static'
output_dir = '/home/matthew/Dev/personal/gemini/output'

build = "#{Date.today}-site-build"
system("/bin/zsh", "-c", "mkdir #{output_dir}/#{build}")

files_found = `find #{static_dir} -name "*.gmi"`.split("\n")
puts "found #{files_found.length()} .gmi files to convert"

files_found.each do |path|
    total_html_output = ""
    current_file = path.split("/")[path.split("/").length() - 1]
    current_dir = path.split("/")[path.split("/").length() - 2]

    puts "analysing #{current_file} in #{current_dir} now"

    gemtext_content_arr = `cat #{path}`.split("\n")
    gemtext_content_arr.each do |line, index|
        # first we handle preformatted text
        if preformatted_text_is_open && line[0..2] != "```"
            total_html_output << line
            total_html_output << "\n"
        elsif line[0..2] === "```"
            case preformatted_text_is_open
            when false
                total_html_output << "<pre>"
                total_html_output << "\n"
                preformatted_text_is_open = true
            else
                total_html_output << "</pre>"
                total_html_output << "\n"
                preformatted_text_is_open = false
            end
        # handle heading #
        elsif line[0..2].include? "# "
            total_html_output << "<h1>#{line[2..-1]}</h1>"
            total_html_output << "\n"
        # handle subheading ##
        elsif line[0..2].include? "## "
            total_html_output << "<h2>#{line[2..-1]}</h2>"
            total_html_output << "\n"
        # handle sub-subheading ###
        elsif line[0..2].include? "###"
            total_html_output << "<h3>#{line[3..-1]}</h3>"
            total_html_output << "\n"
        # handle links
        # TODO conditional if link href ends in image file extension
        elsif line[0..2].include? "=>"
            line = line.gsub(".gmi", ".html").gsub("'/", '')
            link_href = line.split(" ")[1]
            link_title = line.split(" ")[2..-1].join(" ")
            total_html_output << "<a href='#{link_href}'>#{link_title}<a/>"
            total_html_output << "\n"
        # handle list item
        elsif line[0] === "*"
            total_html_output << "<li>#{line[1..-1]}</li>"
            total_html_output << "\n"
        # handle blockquote
        elsif line[0] === ">"
            total_html_output << "<blockquote>#{line}</blockquote"
            total_html_output << "\n"
        # handle p text
        elsif line.length > 0
            total_html_output << "<p>#{line}</p>"
            total_html_output << "\n"
        #handle empty line
        else
            total_html_output << "<br>"
            total_html_output << "\n"
        end
    end

    if current_dir != 'static'
        `mkdir #{output_dir}/#{build}/#{current_dir}`
        file = File.new("#{output_dir}/#{build}/#{current_dir}/#{current_file[0...-4]}.html", "w")
        file.puts("<head>\n</head>\n<body>\n")
        file.puts(total_html_output)
        file.puts("</body>")
        file.close
    else
        file = File.new("#{output_dir}/#{build}/#{current_file[0...-4]}.html", "w")
        file.puts("<head>\n</head>\n<body>\n")
        file.puts(total_html_output)
        file.puts("</body>")
        file.close
    end
    puts "built html page from #{current_file}"
end

