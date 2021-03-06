require 'uglifier'

module Artwork
  module View
    def activate_resolution_independence
      Thread.current[:artwork_script] ||= content_tag :script, compile_artwork_script
    end

    def artwork_tag(record, attachment_name, size, options = {})
      image_tag_options  = options[:image] || {}
      img_holder_options = options[:img_holder] || {}

      image_tag_options[:alt] ||= extract_title_from(record)

      image_url = record.artwork_url attachment_name, size, options

      if options[:auto_height]
        if options[:auto_height].respond_to?(:first)
          image_width  = options[:auto_height].first
          image_height = options[:auto_height].last
        else
          image = record.send(attachment_name)

          image_width  = image.width
          image_height = image.height
        end

        if image_width.present? and image_height.present?
          padding = ((image_height.to_f / image_width) * 100).round(4)

          img_holder_options[:style] = "padding-bottom:#{padding}%;"
        end
      end

      content_tag :div, :class => attachment_name do
        content_tag :div, img_holder_options.merge(:class => 'img-holder') do
          if options[:lazy]
            image_tag Artwork.blank_image, image_tag_options.merge(:lazy => nil, :class => Artwork.lazy_loading_class, 'data-src': image_url)
          else  
            image_tag image_url, image_tag_options
          end
        end
      end
    end

    private

    def extract_title_from(record)
      if record.respond_to? :title
        record.title
      elsif record.respond_to? :name
        record.name
      end
    end

    def compile_artwork_script
      artwork_script_path = Artwork.root_path + '/assets/javascripts/artwork.js'
      compiled_script     = Uglifier.compile(File.read(artwork_script_path))

      if compiled_script.respond_to?(:html_safe)
        compiled_script.html_safe
      else
        compiled_script
      end
    end
  end
end
