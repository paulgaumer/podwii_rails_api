require "open-uri"
require "json"
require 'rss'

class Api::V1::PodcastsController < Api::V1::BaseController
  before_action :set_podcast, only: [ :dashboard, :dashboard_single, :update, :destroy ]
  before_action :set_s3_resource, only: [:upload_audio_for_transcription]
  skip_after_action :verify_authorized, only: [:upload_audio_for_transcription, :download_transcription, :fetch_instagram]

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
    @pod = parse_rss_all(@podcast)
  end

  def landing_page_single_episode
    @podcast = Podcast.find_by(subdomain: params[:subdomain])
    authorize @podcast
    episode_id = params[:id]
    @pod = parse_rss_single(@podcast, episode_id)
    # @episode_db = @podcast.episodes.find_by(guid: params[:id])
    # @episode_rss = @rss_feed[:items].detect{|x| x[:guid] == params[:id]}
  end

  

  def fetch_instagram
    @podcast = Podcast.find(params[:podcast_id])
    token = @podcast.instagram_access_token["access_token"]
    @instagram = get_instagram_pictures(token)
    render json: {instagram: @instagram}
  end

  # ********** END CUSTOM ************

  private

  def set_podcast
    @podcast = Podcast.where(user: current_user).first
    authorize @podcast
  end

  def podcast_params
    params.require(:podcast).permit(:title, :description, :subdomain, :feed_url, instagram_access_token: [:access_token, :expires_in])
  end

  def render_error
    render json: { errors: @podcast.errors.full_messages },
      status: :unprocessable_entity
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
      episodes = channel.items.map do |item|
        ep_db = Episode.find_by(guid: item.guid.content)
        {
          title: ep_db ? ep_db.title : item.title,
          summary: ep_db ? ep_db.summary : remove_html_tags(item.description),
          show_notes: ep_db ? ep_db.show_notes : item.description,
          transcription: ep_db ? ep_db.transcription : nil,
          guid: item.guid.content,
          cover_image: item.itunes_image != nil ? {url: item.itunes_image.href} : image,
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
        episodes: episodes,
        subdomain: podcast.subdomains.first.name,
        instagram_access_token: podcast.instagram_access_token,
        theme: podcast.themes.first
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
          cover_image: ep_rss.itunes_image != nil ? {url: ep_rss.itunes_image.href} : image,
          enclosure: {
            length: ep_rss.enclosure.length,
            type: ep_rss.enclosure.type,
            url: ep_rss.enclosure.url,
            duration: ep_rss.itunes_duration.content != nil ? ep_rss.itunes_duration.content : "",
            pubDate: ep_rss.pubDate
          },
          podcast_title: channel.title,
          id: ep_db ? ep_db.id : nil,
        }

      # Create podcast object based on existing data in DB
      pod = {
        id: podcast.id,
        title: podcast.title == "" ? channel.title : podcast.title,
        description: podcast.description == "" ? channel.description : podcast.description,
        feed_url: podcast.feed_url,
        cover_image: image,
        episode: episode,
        subdomain: podcast.subdomains.first.name,
        theme: podcast.themes.first
      }
    end
  end

  def get_instagram_pictures(token)
    media_list_url = "https://graph.instagram.com/me/media?&access_token=#{token}"

    result_serialized = open(media_list_url).read
    result = JSON.parse(result_serialized)
    
    list = result["data"]
    pictures = []
    if (list.length > 8)
      range = list.first(8)
      range.each do |pic|
        picture = get_picture(pic["id"], token)
        pictures << picture
      end
    else
      list.each do |pic|
        picture = get_picture(pic["id"], token)
        pictures << picture
      end
    end
    return pictures
  end
  
  def get_picture(id, token)
    url = "https://graph.instagram.com/#{id}?fields=media_url,media_type,permalink&access_token=#{token}"
    result_serialized = open(url).read
    result = JSON.parse(result_serialized)
  end

end
