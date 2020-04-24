require "open-uri"
require 'rss'

class Api::V1::PodcastsController < Api::V1::BaseController
  before_action :set_podcast, only: [ :dashboard, :dashboard_single, :update, :destroy ]
  before_action :set_s3_object, only: [:upload_audio_for_transcription]
  skip_after_action :verify_authorized, only: [:upload_audio_for_transcription, :download_transcription]

  # def index
  #   @podcasts = policy_scope(Podcast)
  # end

  # Display the user dashboard
  def dashboard
    @pod = parse_rss_all(@podcast)
  end

  # Display one episode details in dashboard
  def dashboard_single
    episode_id = params[:id]
    @pod = parse_rss_single(@podcast, episode_id)
  end

  def create
    @podcast = podcast.new(podcast_params)
    @podcast.user = current_user
    authorize @podcast
    if @podcast.save
      render :show, status: :created
    else
      render_error
    end
  end

  def update
    if @podcast.update(podcast_params)
      # rendre the existing show.json.jbuilder view
      render :dashboard
    else
      render_error
    end
  end

  def destroy
    @podcast.destroy
  end

  # ********** CUSTOM ************

  # Display the user podcast page
  def landing_page
    @podcast = Podcast.find_by(subdomain: params[:subdomain])
    authorize @podcast
    @rss_feed = parse_rss_all(@podcast)
  end

  def landing_page_single_episode
    @podcast = Podcast.find_by(subdomain: params[:subdomain])
    authorize @podcast
    @episode_db = @podcast.episodes.find_by(guid: params[:id])
    @rss_feed = parse_rss_all(@podcast)
    @episode_rss = @rss_feed[:items].detect{|x| x[:guid] == params[:id]}
  end

  # Upload episode's audio to S3
  def upload_audio_for_transcription
    upload = @s3_obj.upload_stream do |write_stream|
      IO.copy_stream(URI.open('https://chtbl.com/track/G5EG82/www.buzzsprout.com/740042/2205065-00-on-creating-japan-life-stories-with-paul-gaumer.mp3'), write_stream)
    end
    if upload 
      render json:{ message: "File uploaded"}
    else
      render json:{error: upload.errors}
    end
  end

  # Retrieve transcription from AWS Transcribe
  def download_transcription
    client = Aws::TranscribeService::Client.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    resp = client.get_transcription_job({
      transcription_job_name: "test_transcribe.mp3-4ec0fca3-7849-41df-96b6-07a793c60f3b"
    })
    status = resp.transcription_job.transcription_job_status

    if status === "COMPLETED"
      transcription_serialized = URI.open(resp.transcription_job.transcript.transcript_file_uri).read
      transcription_file = JSON.parse(transcription_serialized)
      # byebug
      transcript = transcription_file["results"]["transcripts"][0]["transcript"]
      render json: {
        transcript: transcript
      }
    else
      render json: {status: status}
    end

  end

  # ********** END CUSTOM ************

  private

  def set_podcast
    @podcast = Podcast.where(user: current_user).first
    authorize @podcast
  end

  def podcast_params
    params.require(:podcast).permit(:title, :description, :subdomain, :feed_url)
  end

  def render_error
    render json: { errors: @podcast.errors.full_messages },
      status: :unprocessable_entity
  end

  # Need for audio upload to S3
  def set_s3_object
    s3 = Aws::S3::Resource.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])  
    bucket_name = ENV["AWS_BUCKET_NAME"]
    @key= "audio_file.mp3"
    @s3_obj = s3.bucket(bucket_name).object(@key)
  end

  # Remove tags coming with the raw description
  def remove_html_tags(text)
    re = /<("[^"]*"|'[^']*'|[^'">])*>/
    text.gsub!(re, '')
  end

  # Parse and reformat rss feed
  def parse_rss_all(podcast)
    feed = nil
    URI.open(podcast.feed_url) do |rss|
      rss = RSS::Parser.parse(rss)
      channel = rss.channel
      image = {
        link: channel.image.link,
        title: channel.image.title,
        url: channel.image.url
      }
      items = channel.items.map do |item|
        ep_db = Episode.find_by(guid: item.guid.content)
        {
          title: ep_db ? ep_db.title : item.title,
          summary: ep_db ? ep_db.summary : remove_html_tags(item.description),
          show_notes: ep_db ? ep_db.show_notes : item.description,
          transcription: ep_db ? ep_db.transcription : nil,
          guid: item.guid.content,
          cover_image: image,
          enclosure: {
            length: item.enclosure.length,
            type: item.enclosure.type,
            url: item.enclosure.url,
            duration: item.itunes_duration.content != nil ? item.itunes_duration.content : "",
            pubDate: item.pubDate
          },
          podcast_title: channel.title,
        }
      end

      # Create podcast object based on existing data in DB
      pod = {
        id: podcast.id,
        title: podcast.title == "" ? channel.title : podcast.title,
        description: podcast.description == "" ? channel.description : podcast.description,
        feed_url: podcast.feed_url,
        cover_image: image,
        items: items,
        subdomain: podcast.subdomain
      }
    end
  end

  def parse_rss_single(podcast, episode_id)
    feed = nil
    URI.open(podcast.feed_url) do |rss|
      rss = RSS::Parser.parse(rss)
      channel = rss.channel
      image = {
        link: channel.image.link,
        title: channel.image.title,
        url: channel.image.url
      }
      ep_rss = channel.items.detect{|x| x.guid.content == episode_id}
      ep_db = Episode.find_by(guid: episode_id)

      episode = {
          title: ep_db ? ep_db.title : ep_rss.title,
          summary: ep_db ? ep_db.summary : remove_html_tags(ep_rss.description),
          show_notes: ep_db ? ep_db.show_notes : ep_rss.description,
          transcription: ep_db ? ep_db.transcription : nil,
          guid: ep_rss.guid.content,
          cover_image: image,
          enclosure: {
            length: ep_rss.enclosure.length,
            type: ep_rss.enclosure.type,
            url: ep_rss.enclosure.url,
            duration: ep_rss.itunes_duration.content != nil ? ep_rss.itunes_duration.content : "",
            pubDate: ep_rss.pubDate
          },
          podcast_title: channel.title,
          db_id: ep_db ? ep_db.id : nil,
        }

      # Create podcast object based on existing data in DB
      pod = {
        id: podcast.id,
        title: podcast.title == "" ? channel.title : podcast.title,
        description: podcast.description == "" ? channel.description : podcast.description,
        feed_url: podcast.feed_url,
        cover_image: image,
        episode: episode,
        subdomain: podcast.subdomain
      }
    end
  end
end
