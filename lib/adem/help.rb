def help
  text = <<-eos

ADEM is a tool for deploying and managing software on the Open Science Grid.

  Usage:
    adem command [options]

  Examples:
    adem config --display
    adem sites --update
    adem app --avail

  Further help:
    adem config -h/--help        Configure ADEM
    adem sites -h/--help         Manipulate the site list
    adem app -h/--help           Application installation
    adem help                    This help message
  eos
  puts text
  text
end
