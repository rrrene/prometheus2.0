require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do
  describe "routing" do
    it "should route /search?utf8=yes&branch=Sisyphus&query=openbox to searches#show" do
      { :get => "/search?utf8=yes&branch=Sisyphus&query=openbox" }.should route_to(controller: 'searches',
                                                                                   action: 'show',
                                                                                   utf8: 'yes',
                                                                                   branch: 'Sisyphus',
                                                                                   query: 'openbox')
    end

    it "should route /en/search?utf8=yes&branch=Sisyphus&query=openbox to searches#show" do
      { :get => "/en/search?utf8=yes&branch=Sisyphus&query=openbox" }.should route_to(controller: 'searches',
                                                                                      action: 'show',
                                                                                      utf8: 'yes',
                                                                                      branch: 'Sisyphus',
                                                                                      query: 'openbox',
                                                                                      locale: 'en')
    end
  end
end
