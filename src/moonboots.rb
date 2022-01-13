#! /usr/bin/ruby
require('date')
require('yaml')

class MoonBoots
    attr_accessor :root_dir, :root_title, :output_dir, :sub_directories,
                  :css_file_dir, :font_url, :styling, :preformatted_text_is_open,
                  :build
    def initialize
        config = YAML.load_file('/home/matthew/Dev/personal/gemini/src/config.yml')
        @root_dir = config['root-dir']
        @root_title = config['root-title']
        @output_dir = config['output-dir']
        @sub_directories = config['sub-directories']
        @css_file_dir = config['css-file-dir']
        @font_url = config['font-url']
        @styling = config['styling']
        @preformatted_text_is_open = false
        @build = "#{Date.today}-site-build"
    end

    def bounce ## get it?
        create_directories()
    end

    def create_directories
        system("/bin/zsh", "-c", "mkdir #{@output_dir}/#{@build}")

        @sub_directories.each do |dir|
            system("/bin/zsh", "-c", "mkdir #{@output_dir}/#{build}/#{dir[0]}")
        end
        get_gemini_files()
    end

    def get_gemini_files
        files_found = `find #{@root_dir} -name "*.gmi"`.split("\n")
        puts "found #{files_found.length()} .gmi files to convert"
        parse_gemini_files(files_found)
    end

    def parse_gemini_files(files_found)
        files_found.each do |path|
            total_html_output = ""
            current_file = path.split("/")[path.split("/").length() - 1]
            current_dir = path.split("/")[path.split("/").length() - 2]

            puts "analysing #{current_file} in #{current_dir} now"

            gemtext_content_arr = `cat #{path}`.split("\n")
            gemtext_content_arr.each do |line, index|
                # first we handle preformatted text
                if @preformatted_text_is_open && line[0..2] != "```"
                    total_html_output << line + "\n"
                elsif line[0..2] === "```"
                    case @preformatted_text_is_open
                    when false
                        total_html_output << "<div class='preformatted'> \n"
                        @preformatted_text_is_open = true
                    else
                        total_html_output << "</div> \n"
                        @preformatted_text_is_open = false
                    end
                # handle heading #
                elsif line[0..2].include? "# "
                    total_html_output << "<h1>#{line[2..-1]}</h1> \n"
                # handle subheading ##
                elsif line[0..2].include? "## "
                    total_html_output << "<h2>#{line[2..-1]}</h2> \n"
                # handle sub-subheading ###
                elsif line[0..2].include? "###"
                    total_html_output << "<h3>#{line[3..-1]}</h3> \n"
                # handle links
                # TODO conditional if link href ends in image file extension
                elsif line[0..2].include? "=>"
                    line = line.gsub(".gmi", ".html")

                    # remove leading / in the root dir but not in subdirectories
                    # because bc it messes with hierarchical routing
                    if current_dir === @root_dir.split("/")[@root_dir.split("/").length() - 2]
                        line = line .sub("/", "")
                    end

                    link_href = line.split(" ")[1]
                    link_title = line.split(" ")[2..-1].join(" ")
                    total_html_output << "<a href='#{link_href}'>#{link_title}<a/> <br> \n"
                # handle list item
                elsif line[0] === "*"
                    total_html_output << "<li>#{line[1..-1]}</li> \n"
                # handle blockquote
                elsif line[0] === ">"
                    total_html_output << "<blockquote>#{line}</blockquote \n"
                # handle p text
                elsif line.length > 0
                    total_html_output << "<p>#{line}</p> \n"
                #handle empty line
                else
                    total_html_output << "<br> \n"
                end
            end
            build_html_files(total_html_output, current_dir, current_file)
        end
    end

    def build_html_files(total_html_output, current_dir, current_file)
        if current_dir != @root_dir.split("/")[@root_dir.split("/").length() - 2]
            # `mkdir #{output_dir}/#{build}/#{current_dir}`
            file = File.new("#{@output_dir}/#{@build}/#{current_dir}/#{current_file[0...-4]}.html", "w")
            file.puts("<head>\n<link rel='stylesheet' href='/../global.css'>\n#{@font_url}\n<title>#{current_dir}</title>\n</head>\n<body>\n<div id='content'>\n")
            file.puts(total_html_output)
            file.puts("</div>\n</body>\n")
            file.close
        else
            file = File.new("#{output_dir}/#{build}/#{current_file[0...-4]}.html", "w")
            file.puts("<head>\n<link rel='stylesheet' href='/global.css'>\n#{@font_url}\n<title>#{@root_title}</title>\n</head>\n<body>\n<div id='content'>\n")
            file.puts(total_html_output)
            file.puts("</div>\n</body>\n")
            file.close
        end
        puts "built html page from #{current_file}"
    end
end

mb = MoonBoots.new

mb.bounce()



