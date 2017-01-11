require 'json'

class GarminScraper
  def initialize(username, password)
    # lazy-load mechanize to save on boot-time
    require 'mechanize'

    @username = username
    @password = password
    @agent = Mechanize.new
    @logged_in = false
  end

  def login
    signin_url = 'https://sso.garmin.com/sso/login?service=https%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&webhost=olaxpw-conctmodern006&source=https%3A%2F%2Fconnect.garmin.com%2Fen-US%2Fsignin&redirectAfterAccountLoginUrl=https%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&redirectAfterAccountCreationUrl=https%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&gauthHost=https%3A%2F%2Fsso.garmin.com%2Fsso&locale=en_US&id=gauth-widget&cssUrl=https%3A%2F%2Fstatic.garmincdn.com%2Fcom.garmin.connect%2Fui%2Fcss%2Fgauth-custom-v1.2-min.css&clientId=GarminConnect&rememberMeShown=true&rememberMeChecked=false&createAccountShown=true&openCreateAccount=false&usernameShown=false&displayNameShown=false&consumeServiceTicket=false&initialFocus=true&embedWidget=false&generateExtraServiceTicket=false&globalOptInShown=false&globalOptInChecked=false#'
    @agent.get(signin_url) do |page|
      result = page.form_with(action: /login/) do |f|
        f.field_with(name: /username/).value = @username
        f.field_with(name: /password/).value = @password
      end
      @agent.submit(result)
    end

    # steps inspired by:
    # https://github.com/kjkjava/garmin-connect-export/blob/master/gcexport.py#L107-L119
    auth_cookie = @agent.cookie_jar.jar['sso.garmin.com']['/sso']['CASTGC'].value
    auth_cookie = 'ST-0' + auth_cookie[4..-1]

    @agent.get("https://connect.garmin.com/post-auth/login?ticket=#{auth_cookie}") do |page|
      if !page.title =~ /Garmin Connect/
        raise 'Login failed -- destination page title is not "Garmin Connect"'
      end
    end

    @logged_in = true

    self
  end

  def sleep_schedule_json(date)
    raise 'Not logged in' unless @logged_in
    sleep_url = 'https://connect.garmin.com/modern/proxy/wellness-service/wellness' \
      "/dailySleepData/tdooner?date=#{date}&nonSleepBufferMinutes=60"

    @agent.get(sleep_url) do |page|
      return JSON.parse(page.body)
    end
  end

  def wellness(date)
    raise 'Not logged in' unless @logged_in
    steps_url = 'https://connect.garmin.com/modern/proxy/userstats-service/wellness' \
      "/daily/tdooner?fromDate=#{date}&untilDate=#{date}&grpParentActType=false"

    @agent.get(steps_url) do |page|
      return JSON.parse(page.body)
    end
  end
end
