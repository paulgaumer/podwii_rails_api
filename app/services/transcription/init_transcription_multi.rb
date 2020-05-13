require "google/cloud/speech/v1/speech"
require "json"

class Transcription::InitTranscriptionMulti
  def self.call(audio_file, speakers_number)
    speech = ::Google::Cloud::Speech::V1::Speech::Client.new do |config|
      config.credentials = JSON.parse(ENV["GOOGLE_APPLICATION_CREDENTIALS"])
    end
    puts "INIT NEW GOOGLE SPEECH MULTI"

    config = { language_code: "en-US",
              model: "video",
              enable_automatic_punctuation: true,
              diarization_config: {
      "enable_speaker_diarization": true,
      "max_speaker_count": speakers_number,
      "min_speaker_count": speakers_number,
    } }

    puts "DECLARED CONFIG"

    audio = audio_file

    operation = speech.long_running_recognize config: config, audio: audio
    puts "OPERATION STARTED"
    operation.wait_until_done!
    raise operation.results.message if operation.error?
    results = operation.response.results
    puts "OPERATION RESULTS RECEIVED"
    final_transcription = Transcription::ParseTranscriptionResultsMulti.call(results.last.alternatives.first.words)

    # file.delete
    return final_transcription
  end
end
