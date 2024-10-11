# frozen_string_literal: true

class FollowButtonComponent < ViewComponent::Base
  def initialize(follower:, target:, name: nil)
    @signed_out = follower.nil?
    @target = target
    @following = follower&.following? target
    @name = name
  end

  def before_render
    @path = url_for(@target) + "/follows"
    @method = @following ? :delete : :post
    @i18n_key = @following ? ".unfollow" : ".follow"
  end

  def render?
    social_enabled? && (helpers.policy(Federails::Following).create? || remote_follow_allowed?)
  end

  erb_template <<-ERB
    <%= button_to translate(@i18n_key, name: @name), @path, method: @method, class: "btn btn-primary" %>
  ERB

  private

  def social_enabled?
    SiteSettings.multiuser_enabled? || SiteSettings.federation_enabled?
  end

  def remote_follow_allowed?
    SiteSettings.federation_enabled? && @signed_out
  end
end
