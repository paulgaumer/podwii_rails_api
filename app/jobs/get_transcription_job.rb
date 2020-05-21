class GetTranscriptionJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 1

  def perform(episode_id, speakers_number)
    puts "IN GET_TRANSCRIPTION JOB FUNCTION"
    @episode = Episode.find(episode_id)
    @podcast = @episode.podcast

    # url = "https://flex.acast.com/www.scientificamerican.com/podcast/podcast.mp3?fileId=2A1EE68D-18E6-4E3B-BB1FA3C50BE5E395"

    # ***FOR PRODUCTION ***
    # url = @episode.enclosure["url"]
    # puts "EPISODE'S URL: #{url}"
    # audio_src = Transcription::DownloadAudioSource.call(url)
    # duration = Transcription::GetAudioDuration.call(audio_src, episode_id)
    # puts "DURATION: #{duration}"
    # audio_flac = Transcription::ConvertAudioToFlac.call(audio_src)
    # audio_stored = Transcription::UploadToStorage.call(audio_flac)
    # ************************

    # ***FOR LOCAL TESTS***
    audio_stored = { uri: "gs://podwii-audio-source/pod-test.wav" }
    # ************************

    if speakers_number > 1
      transcription = Transcription::InitTranscriptionMulti.call(audio_stored, speakers_number)
    else
      transcription = Transcription::InitTranscriptionSingle.call(audio_stored)
    end
    puts "EPISODE TRANSCRIPTED"
    @episode.transcription = transcription
    if @episode.save
      puts "EPISODE SAVED WITH TRANSCRIPTION"
      # ***FOR PRODUCTION ***
      # @podcast.update(transcription_time_used: @podcast.transcription_time_used + duration.to_f.ceil())
      # ************************
      puts "TRANSCRIPTION TIME USED UPDATED"
    else
      puts "ERROR: EPISODE WITH TRANSCRIPTION COULDN'T BE SAVED"
    end
  end
end
