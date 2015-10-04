FactoryGirl.define do
  factory :snp_comment do
    comment_text 'This is a great SNP!'
    subject 'Great!'
    user_id 1
    snp_id 1
  end
end
