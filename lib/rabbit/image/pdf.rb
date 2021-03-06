require "rabbit/utils"

Rabbit::Utils.require_safe "poppler"

require "rabbit/gettext"
require "rabbit/image/base"

module Rabbit
  module ImageManipulable
    class PDF < Base
      include GetText

      unshift_loader(self)

      class << self
        def match?(filename)
          return true if File.extname(filename) == ".pdf"

          File.open(filename) do |file|
            line = file.gets
            return false if line.nil?

            begin
              /\A%PDF-1\.\d\z/ =~ line.chomp
            rescue ArgumentError
              false
            end
          end
        end
      end

      def draw(canvas, x, y, params={})
        if @document and canvas.poppler_available?
          default_params = {
            :width => width,
            :height => height,
          }
          canvas.draw_poppler_page(page, x, y, default_params.merge(params))
        else
          super
        end
      end

      def pixbuf
        @pixbuf ||= to_pixbuf
      end

      private
      def page
        index = self["page"] || 1
        begin
          index = Integer(index)
        rescue ArgumentError
          message = _("invalid PDF page number: <%s>") % index.inspect
          raise ImageLoadError.new("#{@filename}: #{message}")
        end
        _page = @document[index - 1]
        if _page.nil?
          message = _("%s page doesn't exist in PDF") % index
          raise ImageLoadError.new("#{@filename}: #{message}")
        end
        _page
      end

      def update_size
        @document = Poppler::Document.new(uri)
        @width, @height = page.size
      end

      def filename
        File.expand_path(@filename)
      end

      def uri
        "file://#{filename}"
      end

      def to_pixbuf
        w = original_width
        h = original_height
        pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, true, 8, w, h)
        page.render(0, 0, w, h, 1.0, 0, pixbuf)
        pixbuf
      end
    end
  end
end
