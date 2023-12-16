# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearchCommon

  has_attached_file :avatar,
    styles: { medium: '300x300>', thumb: '100x100>', head: '32x32#'},
    default_url: 'standard_:style.png'

  before_validation :clear_avatar

  validates_attachment_size :avatar, less_than: 1.megabyte
  validates_attachment_content_type :avatar,
    content_type: %r(\Aimage/.*\Z)

  ## Authlogic
  # call on authlogic
  acts_as_authentic do |c|
    # replace SHA512 by bcrypt
    c.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha512
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  #after_create :make_standard_phenotypes

  EMAIL = /
    \A
    [A-Z0-9_.&%+\-']+   # mailbox
    @
    (?:[A-Z0-9\-]+\.)+  # subdomains
    (?:[A-Z]{2,25})     # TLD
    \z
  /ix
  LOGIN = /\A[a-zA-Z0-9_][a-zA-Z0-9\.+\-_@ ]+\z/

  validates(
    :email,
    format: {
      with: EMAIL,
      message: proc {
        ::Authlogic::I18n.t(
          "error_messages.email_invalid",
          default: "should look like an email address."
        )
      }
    },
    length: { maximum: 100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_email?
    }
  )

  validates(
    :password,
    confirmation: { if: :require_password? },
    length: {
      minimum: 8,
      if: :require_password?
    }
  )

  validates(
    :password_confirmation,
    length: {
      minimum: 8,
      if: :require_password?
    }
  )

  ## End Authlogic

  # dependent so stuff gets destroyed on delete
  has_many :user_phenotypes, dependent: :destroy
  has_many :phenotypes, through: :user_phenotypes
  has_many :user_picture_phenotypes, dependent: :destroy
  has_many :picture_phenotypes, through: :user_picture_phenotypes
  has_many :genotypes, dependent: :destroy
  has_many :user_snps, through: :genotypes
  has_many :snps, through: :user_snps
  has_many :homepages, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  has_many :snp_comments # these shouldn't be deleted, but orphaned
  has_many :phenotype_comments, dependent: :destroy
  has_many :picture_phenotype_comments, dependent: :destroy
  has_one :open_humans_profile, dependent: :destroy

  # needed to edit several user_phenotypes at once, add and delete, and not empty
  accepts_nested_attributes_for :homepages, allow_destroy: true
  accepts_nested_attributes_for :user_phenotypes, allow_destroy: true

  pg_search_common_scope against: [:description, :name]

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.password_reset_instructions(self).deliver_later
  end

  def phenotype_length
    # tiny workaround for user-index
    phenotypes.length
  end

  def user_has_sequence_string
    # used in the user-index-page instead of ugly true/false
    if has_sequence
      'Yes'
    else
      'No'
    end
  end

  def check_if_phenotype_exists(charact)
    # checks so we don't create duplicate phenotypes
    if Phenotype.find_by_characteristic(charact) != nil
      true
    else
      false
    end
  end

  def check_and_make_standard_phenotypes(charact)
    # checks whether phenotype exists, creates one if doesn't,
    # creates fitting user_phenotype in both cases
    if check_if_phenotype_exists(charact) == true
      @phen_id = Phenotype.find_by_characteristic(charact).id
      UserPhenotype.create(phenotype_id: @phen_id, variation: '', user_id: id)
    else
      @phen_id = Phenotype.create(characteristic: charact).id
      UserPhenotype.create(phenotype_id: @phen_id, variation: '', user_id: id)
    end
  end

  def make_standard_phenotypes
    check_and_make_standard_phenotypes('Hair color')
    check_and_make_standard_phenotypes('Eye color')
    check_and_make_standard_phenotypes('Skin color')
    check_and_make_standard_phenotypes('Blood type')
  end

  def delete_avatar=(value)
    @delete_avatar = !value.to_i.zero?
  end

  def delete_avatar
    !!@delete_avatar
  end
  alias_method :delete_avatar?, :delete_avatar

  def clear_avatar
    self.avatar = nil if delete_avatar?
  end

  def display_help_header?
    # minor help method called in layouts/application header
    !help_one || !help_two || !help_three
  end

  def phenotype_count
    user_phenotypes.count
  end
end
