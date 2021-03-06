# frozen_string_literal: true

Paperclip.options[:read_timeout] = 60

Paperclip.interpolates :filename do |attachment, style|
  return attachment.original_filename if style == :original
  [basename(attachment, style), content_type_extension(attachment, style)].delete_if(&:empty?).join('.')
end

if ENV['S3_ENABLED'] == 'true'
  Aws.eager_autoload!(services: %w(S3))

  Paperclip::Attachment.default_options[:storage]        = :s3
  Paperclip::Attachment.default_options[:s3_protocol]    = ENV.fetch('S3_PROTOCOL') { 'https' }
  Paperclip::Attachment.default_options[:url]            = ':s3_domain_url'
  Paperclip::Attachment.default_options[:s3_host_name]   = ENV.fetch('S3_HOSTNAME') { "s3-#{ENV.fetch('S3_REGION')}.amazonaws.com" }
  Paperclip::Attachment.default_options[:path]           = '/:class/:attachment/:id_partition/:style/:filename'
  Paperclip::Attachment.default_options[:s3_headers]     = { 'Cache-Control' => 'max-age=315576000', 'Expires' => 10.years.from_now.httpdate }
  Paperclip::Attachment.default_options[:s3_permissions] = 'public-read'
  Paperclip::Attachment.default_options[:s3_region]      = ENV.fetch('S3_REGION') { 'us-east-1' }

  Paperclip::Attachment.default_options[:s3_credentials] = {
    bucket: ENV.fetch('S3_BUCKET'),
    access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
    secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
  }

  unless ENV['S3_ENDPOINT'].blank?
    Paperclip::Attachment.default_options[:s3_options] = {
      endpoint: ENV['S3_ENDPOINT'],
      force_path_style: true,
    }

    Paperclip::Attachment.default_options[:url] = ':s3_path_url'
  end

  unless ENV['S3_CLOUDFRONT_HOST'].blank?
    Paperclip::Attachment.default_options[:url]           = ':s3_alias_url'
    Paperclip::Attachment.default_options[:s3_host_alias] = ENV['S3_CLOUDFRONT_HOST']
  end
else
  Paperclip::Attachment.default_options[:path]           = (ENV['PAPERCLIP_ROOT_PATH'] || ':rails_root/public/system') + '/:class/:attachment/:id_partition/:style/:filename'
  Paperclip::Attachment.default_options[:url]            = (ENV['PAPERCLIP_ROOT_URL'] || '/system') + '/:class/:attachment/:id_partition/:style/:filename'
end
