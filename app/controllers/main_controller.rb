class MainController < ApplicationController
  before_action :check_permissions
  include GoogleIntegration
  include GithubIntegration

  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }
  expose(:google_api) { GoogleIntegration::Api.new(session[:google_token]) }

  expose(:expected_teams) { GithubIntegration::Teams.all }
  expose(:expected_groups) { GoogleIntegration::Groups.all }

  expose(:validation_errors) { Storage.validation_errors }
  expose(:update_repo) { UpdateRepo.new }

  expose(:gh_diff) { GithubIntegration::Actions::GetDiff.new(expected_teams, gh_api) }
  expose(:google_diff) { GoogleIntegration::Actions::GetDiff.new(expected_groups, google_api) }

  expose(:sync_github) { GithubIntegration::Actions::SyncTeams.new(gh_api) }
  expose(:sync_google) { GoogleIntegration::Actions::SyncGroups.new(google_api) }

  expose(:get_gh_log) { GithubIntegration::Actions::GetLog.new(get_gh_diff) }
  expose(:get_google_log) { GoogleIntegration::Actions::GetLog.new(get_google_diff) }

  expose(:teams_cleanup) { GithubIntegration::Actions::CleanupTeams.new(expected_teams, gh_api) }
  expose(:missing_teams) { teams_cleanup.stranded_teams }

  def show_diff
    @gh_diff = gh_diff.now!
    @gh_log = get_gh_log.now!
    @google_diff = google_diff.now!
    @google_log = get_google_log.now!
    @google_log = []
  end

  def do_sync
    sync_github.now!(get_gh_diff)
    sync_google.now!(get_google_diff)
    @gh_diff = nil
    @google_diff = nil
  end

  def cleanup_teams
    teams_cleanup.now!
  end

  def index
    update_repo.now!
  end

  def check_permissions
    gh_api.client.patch_request("/orgs/#{gh_api.client.org}")
    rescue Github::Error::NotFound
      render 'main/unauthorized'
  end

  private

  def get_gh_diff
    @gh_diff ||= gh_diff.now!
  end

  def get_google_diff
    @google_diff ||= google_diff.now!
  end
end
