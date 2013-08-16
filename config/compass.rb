http_path       = "/"
sass_dir        = "scss"
css_dir         = "static/css"
images_dir      = "static/img"
javascripts_dir = "static/js"
output_style    = (environment == :production) ? :compressed : :nested
line_comments   = (environment == :production) ? false : true
