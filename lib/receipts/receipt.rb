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

      @height = 300 + @line_items.count * 40
      super(margin: 0, page_size: [280, @height])

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
        bounding_box [0, @height], width: 280, height: @height do
          bounding_box [10, @height], width: 260, height: @height do
            header
            charge_details
            footer
          end
        end
      end

      def header
        move_down 60

        if logo.present?
          image open(logo), height: 32
        else
          move_down 32
        end

        move_down 8
        text "<color rgb='a6a6a6'>订单编号: ##{id}</color>", inline_format: true

        move_down 30
        text message, inline_format: true, size: 12.5, leading: 4
      end

      def charge_details
        move_down 30

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
        text "<color rgb='888888'>#{receiver_info.fetch(:address) || ''}</color>", inline_format: true
        text "<color rgb='888888'>#{receiver_info.fetch(:phone) || ''}</color>", inline_format: true
      end
  end
end
