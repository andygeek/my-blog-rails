require "rails_helper"

RSpec.describe "Posts", type: :request do
  
  # Cada describe son contextos
  describe "GET /posts" do
    # Con el before ejecutamos una accion antes de la rpueba
    before { get '/posts' } 

    it "should return ok" do
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
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
    let(:post) { create(:post) }

    it "should return a post" do
      # Aqui hacemos el get despues de la prueba
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["id"]).to eq(post.id)
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /posts" do
    let!(:user) { create(:user) }

    it "should create a post" do
      req_payload = {
        post: {
          title: "titulo",
          content: "content",
          published: false,
          user_id: user.id
        }
      }

      # POST HTTP
      post "/posts", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["id"]).to_not be_empty
      # Podemos usar el numero ejemplo 200 o el identificador :created
      expect(response).to have_http_status(:created)
    end

    # Aqui vamos a verificar si lo que devuelve despues de la creacion es lo adecuado
    it "should return error message on invalid a post" do
      req_payload = {
        post: {
          content: "content",
          published: false,
          user_id: user.id
        }
      }

      # POST HTTP
      post "/posts", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["error"]).to_not be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /posts/{id}" do
    let!(:article) { create(:post) }

    it "should create a post" do
      req_payload = {
        post: {
          title: "titulo",
          content: "content",
          published: true,
        }
      }

      # PUT HTTP
      post "/posts/#{article.id}", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["id"]).to eq(article.id)
      # Podemos usar el numero ejemplo 200 o el identificador :created
      expect(response).to have_http_status(:ok)
    end


    # Aqui vamos a verificar si al hacer el PUT nos devuelve lo adecuado
    it "should return error message on invalid a post" do
      req_payload = {
        post: {
          title: nil,
          content: nil,
          published: false,
        }
      }

      # PUT HTTP
      post "/posts/#{article.id}", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["error"]).to_not be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end