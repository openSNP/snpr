# frozen_string_literal: true
class UserMailer < ActionMailer::Base
default from: 'donotreply@opensnp.org'

  def password_reset_instructions(user)
    @user = user
    mail(subject: 'openSNP.org Password Reset Instructions', to: user.email)
  end

  def welcome_user(user)
    @user = user
    mail(subject: 'Welcome to openSNP.org', to: user.email)
  end

  def genotyping_results(target_address, link, phenotype_name, variation)
    @link = link
    @phenotype_name = phenotype_name
    @variation = variation
    mail(subject: 'openSNP.org: The data you requested is ready to be downloaded',
         to: target_address)
  end

  def no_genotyping_results(target_address, phenotype_name, variation)
    @phenotype_name = phenotype_name
    @variation = variation
    mail(subject: 'openSNP.org: No genotyping files match your search',
         to: target_address)
  end

  def parsing_error(user_id)
    @user = User.find_by_id(user_id)
    mail(subject: 'openSNP.org: Something went wrong while parsing', to: @user.email)
  end

  def duplicate_file(user_id)
    @user = User.find_by_id(user_id)
    mail(subject: 'openSNP.org: You uploaded a duplicate genotyping', to: @user.email)
  end

  def file_has_mails(user_id)
    @user = User.find_by_id(user_id)
    mail(subject: 'openSNP.org: You uploaded a genotyping with email addresses', to: @user.email)
  end

  def new_message(user_id, message_id)
    @user = User.find_by_id(user_id)
    @message = Message.find_by_id(message_id)
    mail(subject: "openSNP.org: You've got a new mail from #{User.find_by_id(@message.from_id).name}",
         to: @user.email)
  end

  def new_snp_comment(snp_comment, to_user)
    @user = to_user
    @snp_comment = snp_comment
    mail(subject: 'openSNP.org: You have a reply to one of your SNP-comments', to: @user.email)
  end

  def new_phenotype_comment(phenotype_comment, to_user)
    @user = to_user
    @phenotype_comment = phenotype_comment
    mail(subject: 'openSNP.org: You have a reply to one of your phenotype-comments', to: @user.email)
  end

  def new_picture_phenotype_comment(phenotype_comment, to_user)
    @user = to_user
    @phenotype_comment = phenotype_comment
    mail(subject: 'openSNP.org: You have a reply to one of your phenotype-comments', to: @user.email)
  end

  def new_phenotype(phenotype, user)
    @user = user
    @phenotype = phenotype
    mail(subject: 'openSNP.org: A new phenotype was entered on the platform', to: @user.email)
  end

  def newsletter(user)
    @user = user
    mail(subject: 'openSNP: The 2016 round-up and what\'s next', to: @user.email)
  end

  def survey(user)
    @user = user
    delivery_options = { user_name: ENV.fetch('SURVEY_EMAIL_USER'),
                          password: ENV.fetch('SURVEY_EMAIL_PASSWORD'),
                          address: ENV.fetch('SURVEY_EMAIL_ADDRESS'),
                          port: ENV.fetch('SURVEY_EMAIL_PORT') }
    mail(subject: 'openSNP: Read our survey results and meet Open Humans',
         to: @user.email,
         from: 'survey@opensnp.org',
         delivery_method_options: delivery_options)
  end

  def dump(target_address, link)
    @link = link
    mail(subject: 'openSNP.org: The data dump you requested is ready to be downloaded',
         to: target_address)
  end

  def no_dump(target_address)
    mail(subject: 'openSNP.org: Sorry, there is no data to be dumped', to: target_address)
  end

  def fitbit_dump(link, user_id)
    @link = link
    @user = User.find(user_id)
    mail(subject: 'openSNP.org: The Fitbit-data you requested is now ready for download', to: @user.email)
  end

  def finished_parsing(genotype_id, stats)
    genotype = Genotype.find(genotype_id)
    @user = genotype.user
    @stats = stats
    @vendor = {
      'ftdna-illumina' => 'FamilyTreeDNA',
      '23andme' => '23andMe',
      'IYG' => 'Inside Your Genome',
      'decodeme' => 'deCODEme',
      '23andme-exome-vcf' => '23andMe',
      'ancestry' => 'Ancestry',
      'genes-for-good' => 'Genes for Good'
    }.fetch(genotype.filetype)

    mail(to: @user.email, subject: 'Finished parsing your genotyping')
  end
end
