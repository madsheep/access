module GoogleIntegration
  module MainHelper
    def user_mail user
      name = user.name.downcase.gsub(/\s/, '.')
      "#{name}@#{AppConfig.email_domain}"
    end
  end
end
