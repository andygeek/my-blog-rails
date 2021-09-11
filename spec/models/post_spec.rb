require 'rails_helper'

RSpec.describe Post, type: :model do

  # Este pending es autogenerado, y sirve para que muestre el error al no encontrar nada
  pending "add some examples to (or delete) #{__FILE__}"

  describe "validations" do
    it "validate presence of required fields" do
      should validate_presence_of(:title)
      should validate_presence_of(:content)
      should validate_presence_of(:published)
      should validate_presence_of(:user_id)
    end
  end
  
end
