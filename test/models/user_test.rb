# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  active                  :boolean
#  email                   :string           default(""), not null
#  encrypted_password      :string           default(""), not null
#  first_name              :string
#  last_name               :string
#  last_password_change_at :datetime
#  password_expires_at     :datetime
#  preferences             :jsonb
#  remember_created_at     :datetime
#  reset_password_sent_at  :datetime
#  reset_password_token    :string
#  role                    :string           default("user"), not null
#  two_factor_enabled      :boolean          default(FALSE)
#  two_factor_secret       :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  company_id              :bigint
#
# Indexes
#
#  index_users_on_company_id            (company_id)
#  index_users_on_company_id_and_role   (company_id,role)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
