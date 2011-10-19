require File.dirname(__FILE__) + "/../spec_helper"

describe Discogs::Wrapper do

  before do
    @wrapper = Discogs::Wrapper.new("some_user_agent")
    @master_release_id = "666666"
  end

  describe "when asking for master_release information" do

    before do
      @http_request = mock(Net::HTTP)
      @http_response = mock(Net::HTTPResponse, :code => "200", :body => valid_master_release_xml)
      @http_response_as_file = mock(StringIO, :read => valid_master_release_xml)
      Zlib::GzipReader.should_receive(:new).and_return(@http_response_as_file)
      @http_request.should_receive(:start).and_return(@http_response)
      Net::HTTP.should_receive(:new).and_return(@http_request)

      @master_release = @wrapper.get_master_release(@master_release_id)
    end

    describe "when calling simple master_release attributes" do

      it "should have a title attribute" do
        @master_release.title.should == "Into the Abyss"
      end
  
      it "should have an ID attribute" do
        @master_release.id.should == "666666"
      end

      it "should have one or more tracks" do
        @master_release.tracklist.should be_instance_of(Array)
        @master_release.tracklist[0].should be_instance_of(Discogs::MasterRelease::Track)
      end
 
      it "should have one or more genres" do
        @master_release.genres.should be_instance_of(Array)
        @master_release.genres[0].should == "Heavy Metal"
      end

      it "should have one or more images" do
        @master_release.images.should be_instance_of(Array)
        @rmaster_elease.images[0].should be_instance_of(Discogs::Image)
      end

    end

    describe "when calling complex master_release attributes" do

      it "should have a duration for the first track" do
        @master_release.tracklist[0].duration.should == "8:11"
      end

      it "should have specifications for each image" do
        specs = [ [ '600', '595', 'primary' ], [ '600', '593', 'secondary' ], [ '600', '539', 'secondary' ], [ '600', '452', 'secondary' ], [ '600', '567', 'secondary' ] ]
        @master_release.images.each_with_index do |image, index|
          image.width.should == specs[index][0]
          image.height.should == specs[index][1]
          image.type.should == specs[index][2]
        end
      end

      it "should have a traversible list of styles" do
        @master_release.styles.should be_instance_of(Array)
        @master_release.styles[0].should == "Black Metal"
        @master_release.styles[1].should == "Thrash"
      end

      it "should have an artist associated to the second track" do
        @master_release.tracklist[1].artists.should be_instance_of(Array)
        @master_release.tracklist[1].artists[0].should be_instance_of(Discogs::MasterRelease::Track::Artist)
        @master_release.tracklist[1].artists[0].name.should == "Arakain"
      end

      it "should have an extra artist associated to the second track" do
        @master_release.tracklist[1].extraartists.should be_instance_of(Array)
        @master_release.tracklist[1].extraartists[0].should be_instance_of(Discogs::Release::Track::Artist)
        @master_release.tracklist[1].extraartists[0].name.should == "Debustrol"
        @master_release.tracklist[1].extraartists[0].role.should == "Sadism"
      end

      it "should have no artist associated to the third track" do
        @release.tracklist[2].artists.should be_nil
      end

    end

  end

end