require "google/cloud/speech/v1/speech"
require "json"

class Transcription::InitTranscriptionSingle
  def self.call(audio_file)
    speech = ::Google::Cloud::Speech::V1::Speech::Client.new do |config|
      config.credentials = JSON.parse(ENV["GOOGLE_APPLICATION_CREDENTIALS"])
    end

    puts "INIT NEW GOOGLE SPEECH SINGLE"

    config = { language_code: "en-US",
               model: "video",
               enable_automatic_punctuation: true }

    puts "DECLARED CONFIG"

    audio = audio_file

    operation = speech.long_running_recognize config: config, audio: audio
    puts "OPERATION STARTED"
    operation.wait_until_done!
    raise operation.results.message if operation.error?
    results = operation.response.results
    puts "OPERATION RESULTS RECEIVED"
    binding.pry
    final_transcription = Transcription::ParseTranscriptionResultsSingle.call(results)
    # file.delete
    return final_transcription
  end
end
