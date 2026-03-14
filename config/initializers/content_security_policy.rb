# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data
    policy.object_src  :none
    # script-src uses nonces (see nonce_generator below) so :unsafe_inline is NOT needed
    policy.script_src  :self
    # style-src allows unsafe-inline because of inline style attributes in the layout
    policy.style_src   :self, :unsafe_inline
    policy.connect_src :self
  end

  # Generate session nonces for importmap inline scripts and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src)
end
