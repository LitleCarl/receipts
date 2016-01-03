require 'prawn'
require 'prawn/table'

module Receipts
  class Receipt < Prawn::Document
    attr_reader :attributes, :id, :custom_font, :line_items, :logo, :message, :product, :receiver_info

    def initialize(attributes)
      @attributes     = attributes
      @id             = attributes.fetch(:id)
      @line_items     = attributes.fetch(:line_items)
      @custom_font    = attributes.fetch(:font, {})
      @message        = attributes.fetch(:message) { default_message }
      @logo           = attributes.fetch(:logo)
      @receiver_info  = attributes.fetch(:receiver_info)
      @width = 220
      @padding = 10

      @content_width = @width - @padding * 2
      @height = 300 + @line_items.count * 40
      super(margin: 0, page_size: [@width, @height])

      setup_fonts if custom_font.any?
      generate
    end

    private

      def default_message
        ''
      end

      def setup_fonts
        font_families.update "Primary" => custom_font
        font "Primary"
      end

      def generate
        bounding_box [0, @height], width: @width, height: @height do
          bounding_box [@padding, @height], width: @content_width, height: @height do
            header
            charge_details
            footer
          end
        end
      end

      def header
        move_down 25
        if logo.present?
          bounding_box([@content_width * 0.5 -25, @height -25], width:50, height: 50) do
            image open(logo), height: 50
          end
        else
          move_down 25
        end

        move_down 8
        text "<color rgb='a6a6a6'>订单编号: ##{id}</color>", inline_format: true

      end

      def charge_details
        borders = line_items.length - 2

        table(line_items, cell_style: { border_color: 'cccccc' }) do
          cells.padding = 12
          cells.borders = []
          row(0..borders).borders = [:bottom]
        end
      end

      def footer
        move_down 45
        text receiver_info.fetch(:name), inline_format: true
        text receiver_info.fetch(:delivery_time), inline_format: true
        text "<color rgb='888888'>#{receiver_info.fetch(:address) || ''}</color>", inline_format: true, size: 16
        text "<color rgb='888888'>#{receiver_info.fetch(:phone) || ''}</color>", inline_format: true, size: 16
        move_down 20
        text "#备注:#{message.blank? ? '无': message}", inline_format: true, size: 12.5, leading: 4
      end
  end
end
