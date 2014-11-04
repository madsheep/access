module GithubHelper

  def github_team_path(team_name)
    "https://github.com/orgs/#{AppConfig.company}/teams/#{team_name}"
  end

end