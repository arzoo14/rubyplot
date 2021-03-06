module Rubyplot
  module Artist
    module Plot
      # Class for holding multiple Bar plot objects.
      # Terminoligies used:
      #
      # * A 'bar' is a single bar of a single bar plot.
      # * A 'slot' is a box within which multiple bars can be plotted.
      # * 'padding' is the total whitespace on the left and right of a slot.
      class MultiBars < Artist::Plot::Base
        # The max. width that each bar can occupy.
        attr_reader :max_bar_width

        def initialize(*args, bar_plots:)
          super(args[0])
          @bar_plots = bar_plots
        end

        def process_data
          @bar_plots.each(&:process_data)
          @x_min = @bar_plots.map(&:x_min).min
          @y_min = @bar_plots.map(&:y_min).min
          @x_max = @bar_plots.map(&:x_max).max
          @y_max = @bar_plots.map(&:y_max).max
          configure_ranges!
          configure_plot_geometry_data!
        end

        def draw
          @bar_plots.each(&:draw)
        end

        private

        def configure_ranges!
          @y_min = @y_min > 0 ? 0 : @y_min
          @axes.y_range = [@y_min, @y_max]
        end
        
        def configure_plot_geometry_data!
          @num_max_slots = @bar_plots.map(&:num_bars).max
          @max_slot_width = (@x_max - @x_min) / @num_max_slots.to_f
          @spacing_ratio = @bar_plots[0].spacing_ratio
          @padding = @spacing_ratio * @max_slot_width
          @max_bars_width = @max_slot_width - @padding
          @bars_per_slot = @bar_plots.size
          @bar_plots.each_with_index do |bar, index|
            set_bar_dims bar, index
          end
        end
        
        def set_bar_dims bar_plot, index
          bar_plot.bar_width = @max_bars_width / @bars_per_slot
          @num_max_slots.times do |i|
            bar_plot.abs_x_left[i] = @x_min + i*@max_slot_width + @padding/2 +
              index * bar_plot.bar_width
            bar_plot.abs_y_left[i] = @y_min
          end
        end
      end # class MultiBars
    end # module Plot
  end # module Artist
end # module Rubyplot
