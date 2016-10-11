# frozen_string_literal: true

# Helper functions for calendar.
module CalendarHelper
  def colors(index)
    colors = %w(
      #4733e6 #7dd148 #bfbf0d #9a9cff #16a766 #4986e7 #cb74e6 #9f33e6 #ff7637
      #92e1c0 #d06c64 #9fc6e7 #c2c2c2 #fa583c #AC725E #cca6ab #b89aff #f83b22
      #43d691 #F691B2 #a67ae2 #FFAD46 #b3dc6c
    )
    colors[index.to_i % colors.size]
  end
end
