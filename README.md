# moonboots
A small ruby script to automatically generate HTML pages from .gmi gemini files

## installation + use
Clone this repository to your local machine. Update the appropriate settings in the `config.toml` file and run `ruby path/to/moonboots/src/moonboots.rb` to generate your static html files in their appropriate directories. 

## pro tip
consider automating this process to run whenever updates are made in your gemini static files directory. In linux, `inotifywait` is a great place to start :)
