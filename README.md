# moonboots
A small ruby script to automatically generate HTML pages from .gmi gemini files

## installation + use

__note__ moonboots uses zshell to execute directory-building commands, as the default ruby shell `/bin/sh` is a little wonky for those tasks. If you do not have `zsh` installed on your system, you can change that shell setting to `bash`, `fish`, or whatever else within the `src/moonboots.rb` file. 

Clone this repository to your local machine. Update the appropriate settings in the `config.toml` file and run `ruby path/to/moonboots/src/moonboots.rb` to generate your static html files in their appropriate directories. 

## pro tip
consider automating this process to run whenever updates are made in your gemini static files directory. In linux, `inotifywait` is a great place to start :)
