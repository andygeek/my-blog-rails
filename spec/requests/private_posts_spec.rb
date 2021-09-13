require "rails_helper"

RSpec.describe "Posts with authentication", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, user_id: user.id) }
  let!(:other_user_post) { create(:post, user_id: other_user.id) }
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }

  let!(:auth_headers) {{'Authorization' => "Bearer #{user.auth_token}" } }
  let!(:other_auth_headers) {{'Authorization' => "Bearer #{other_user.auth_token}" } }
  # Authorization: Bearer xxxxx

  let!(:create_params) { { "post" => { "title" => "title", "content" => "content", "published" => true } } }
  let!(:update_params) { { "post" => { "title" => "title", "content" => "content", "published" => true } } }


  describe "GET /posts" do
    # context es otra forma de darle contexto a las pruebas
    context "with valid auth" do
      context "when requisting other's author post" do
        context "when post is public" do
          before { get "/posts/#{other_user_post.id}", headers: other_auth_headers }
          
          context "payload" do
            # payload
            subject { payload }
            it { is_expected.to include(:id) }
          end

          context "response" do
            # response
            subject { response }
            it { is_expected.to have_http_status(:ok)}
          end
        end


        context "when post is draft" do
          before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }
          context "payload" do
            # payload
            subject { payload }
            it { is_expected.to include(:error) }
          end
          context "response" do
            # response
            subject { response }
            it { is_expected.to have_http_status(:not_found)}
          end
        end
      end
      context "when requisting user's post" do

      end
    end
  end

  describe "POST /posts" do
    # con auth -> crear
    context "with valid auth" do
      # usamos la estructura donde primero tomamos el request y luego
      # verificamos lo que tenga el response
      before { post "/posts", params: create_params, headers: auth_headers }
      
      context "payload" do
        subject { payload }
        it { is_expected.to include(:id, :title, :content, :published)}
      end

      context "response" do
        subject {response}
        it {is_expected.to have_http_status(:ok)}
      end
    end

    # sin auth -> !crear -> 401
    context "without auth" do
      # Aqui le paso sin header
      before { post "/posts", params: create_params }
      
      context "payload" do
        subject { payload }
        it { is_expected.to include(:error)}
      end

      context "response" do
        subject {response}
        it {is_expected.to have_http_status(:unauthorized)}
      end
    end
  end

  describe "PUT /posts" do
    # con auth ->
      # actualizar un post nuestro
      # !actualizar un post de otro -> 401

    context "with valid auth" do
      context "when updating users's post" do
        before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }
        context "payload" do
          subject { payload }
          it { is_expected.to include(:id, :title, :content, :published)}
          it { expect(payload[:id]).to eq(user_post.id) }
        end
  
        context "response" do
          subject {response}
          it {is_expected.to have_http_status(:ok)}
        end      
      end

      context "when updating other users's post" do
        before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }
        context "payload" do
          subject { payload }
          it { is_expected.to include(:error)}
        end
  
        context "response" do
          subject {response}
          it {is_expected.to have_http_status(:not_found)}
        end      
      end
    end
  end

  private 

  def payload
    # Es un metodo comun que nos permite acceder a un hash con simbolos :id o string "id"
    JSON.parse(response.body).with_indifferent_access
  end
end