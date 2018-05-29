# frozen_string_literal: true

# Helps generate URLs for user profile pictures.
module ProfilesHelper
  def profile_picture_tag(user, size: 128, style: nil)
    image_tag(
      profile_picture_member_path(user),
      alt: "",
      class: "rounded img-ignore-selection",
      size: "#{size}x#{size}",
      style: style
    )
  end

  def public_profile_picture_tag(profile, size: 128, style: nil)
    image_tag(
      picture_profile_path(profile),
      alt: "",
      class: "rounded img-ignore-selection",
      size: "#{size}x#{size}",
      style: style
    )
  end
end
