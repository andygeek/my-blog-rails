require "rails_helper"

RSpec.describe "Posts", type: :request do
  
  # Cada describe son contextos
  describe "GET /posts" do

    it "should return ok" do
      get '/posts'
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end

    describe "Search" do
      let!(:hola_mundo) { create(:published_post, title: 'Hola mundo') }
      let!(:hola_rails) { create(:published_post, title: 'Hola rails') }
      let!(:curso_rails) { create(:published_post, title: 'Curso rails') }

      it "should filter post by title" do
        get "/posts?search=Hola"
        payload = JSON.parse(response.body)
        expect(payload).to_not be_empty
        expect(payload.size).to eq(2)
        expect(payload.map { |p| p["id"] }.sort).to eq([hola_mundo.id, hola_rails.id].sort)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "with data in the BD" do
    # Aqui utilizamos let de rspec y create_list de factory-bot
    let!(:posts) { create_list(:post, 10, published: true) }
    before { get '/posts' }

    it "should return all the published posts" do
      payload = JSON.parse(response.body)
      expect(payload.size).to eq(posts.size)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /posts/{id}" do
    let!(:post) { create(:post, published: true) }

    it "should return a post" do
      # Aqui hacemos el get despues de la prueba
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(response).to have_http_status(200)
      expect(payload["id"]).to eq(post.id)
    end
  end


end