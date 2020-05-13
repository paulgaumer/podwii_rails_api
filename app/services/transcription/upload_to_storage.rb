require "google/cloud/storage"
require "json"

class Transcription::UploadToStorage
  def self.call(file)
    puts "FILE TO UPLOAD: #{file}"
    creds = Google::Cloud::Storage::Credentials.new JSON.parse(ENV["GOOGLE_APPLICATION_CREDENTIALS"])
    storage = Google::Cloud::Storage.new(
      project_id: ENV["CLOUD_PROJECT_ID"],
      credentials: creds,
    )
    puts "INIT NEW GOOGLE STORAGE"

    bucket_name = "podwii-audio-source"
    bucket = storage.bucket bucket_name, skip_lookup: true
    puts "FOUND BUCKET"
    stored_file = bucket.create_file "./tmp/#{file}", "#{file}"

    if stored_file.etag
      puts "UPLOADED TO GOOGLE STORAGE: #{file}"
      FileUtils.rm "./tmp/#{file}"
      puts "DELETED FLAC FILE ON SERVER"
      audio = { uri: "gs://#{stored_file.bucket}/#{stored_file.name}" }
      return audio
    else
      puts "UPLOAD TO GOOGLE STORAGE FAILED"
      return
    end
  end
end
