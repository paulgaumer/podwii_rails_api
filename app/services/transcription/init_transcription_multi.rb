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

    # !!! INIT TRANSCRIPTION OPERATION !!!
    transcription_done = false
    operation_name = nil
    operation_obj = nil

    operation = speech.long_running_recognize config: config, audio: audio
    puts "OPERATION STARTED"
    operation_name = operation.name
    puts "OPERATION NAME: #{operation_name}"

    # !!! CHECK ON OPERATION STATUS !!!
    ops = ::Google::Cloud::Speech::V1::Speech::Operations.new do |config|
      config.credentials = JSON.parse(ENV["GOOGLE_APPLICATION_CREDENTIALS"])
    end
    puts "OPS INSTANCE CREATED"

    until transcription_done === true
      # wait 3 min
      sleep 300
      puts "ASKING GOOGLE SPEECH"
      res = ops.get_operation name: operation_name
      puts "*** OPERATION: ***"
      puts res
      if res.done?
        puts "TRANSCRIPTION OPERATION FINISHED"
        operation_obj = res
        transcription_done = true
        puts "*******"
      else
        puts "TRANSCRIPTION OPERATION NOT FINISHED"
        puts "*******"
      end
    end
    # operation.wait_until_done!

    # !!! PROCESS THE FINISHED OPERATION !!!
    raise operation_obj.results.message if operation_obj.error?
    results = operation_obj.response.results
    puts "OPERATION RESULTS RECEIVED"
    final_transcription = Transcription::ParseTranscriptionResultsMulti.call(results.last.alternatives.first.words)
    return final_transcription
  end
end
