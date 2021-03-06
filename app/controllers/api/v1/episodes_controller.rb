require "open-uri"
require "json"
require "google/cloud/storage"
require "google/cloud/speech/v1/speech"

class Api::V1::EpisodesController < Api::V1::BaseController
  before_action :set_episode, only: [:update]
  skip_after_action :verify_authorized, only: [:upload_audio_for_transcription]

  def create
    @episode = Episode.new(episode_params)
    authorize @episode
    if @episode.save
      render json: { episode_id: @episode.id }
    else
      render_error
    end
  end

  def update
    if @episode.update(episode_params)
      head :no_content
    else
      render_error
    end
  end

  # Upload episode's audio to Google Speech-To-Text
  def upload_audio_for_transcription
    puts "IN UPLOAD AUDIO CONTROLLER FUNCTION"

    @speakers_number = params[:transcription][:speakers]
    @episode_id = params[:transcription][:ep_id]

    if @episode_id === nil
      puts "EPISODE DOESN'T EXIST"
      @episode = Episode.new(episode_params)
      if @episode.save
        GetTranscriptionJob.perform_later(@episode.id, @speakers_number)
        render json: { message: "Transcription has started" }
      else
        render_error
      end
    else
      puts "EPISODE EXISTS"
      GetTranscriptionJob.perform_later(@episode_id, @speakers_number)
      render json: { message: "Transcription has started" }
    end
  end

  private

  def set_episode
    @episode = Episode.find(params[:id])
    authorize @episode
  end

  def episode_params
    params.require(:episode).permit(:podcast_id, :guid, :title, :summary, :show_notes, :transcription, :podcast_title, :speakers_labels, speakers_labels: [:speaker1, :speaker2, :speaker3, :speaker4], enclosure: [:length, :type, :url, :duration, :pubDate], cover_image: [:link, :title, :url])
  end

  def transcription_params
    params.require(:transcription).permit(:speakers, :ep_id)
  end

  def render_error
    render json: { errors: @episode.errors.full_messages },
      status: :unprocessable_entity
  end
end
