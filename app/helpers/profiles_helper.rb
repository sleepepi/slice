# frozen_string_literal: true

# Helps generate URLs for user profile pictures.
module ProfilesHelper
  def profile_picture_tag(user, size: 128, style: nil)
    image_tag(
      user.avatar_url(size),
      alt: "",
      class: "rounded img-ignore-selection",
      size: "#{size}x#{size}",
      style: style
    )
  end
end
