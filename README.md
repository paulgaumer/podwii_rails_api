<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/paulgaumer/japan_life_stories">
    <img src="public/banner-seo.png" alt="Logo" width="500">
  </a>

  <h3 align="center">Podwii (Rails API)</h3>

  <p align="center">
    The easiest way to generate an optimized website for your podcast, transcribe your episodes and engage with your audience.
    <br />
    <br />
    <a href="https://podwii.com/">View Website</a>
    ·
    <a href="https://www.paulgaumer.com/#contact-form">Report Bug</a>
    ·
  </p>
</p>

<!-- TABLE OF CONTENTS -->

## Table of Contents

- [About the Project](#about-the-project)
  - [Built With](#built-with)
- [Installation](#installation)
- [Contact](#contact)

<!-- ABOUT THE PROJECT -->

## About The Project

Podwii is SaaS application helping podcasters better reach their audience. Generate a modern website in one-click, share your episodes and transcribe your audio for seo & accessibility.

### Built With

- [Ruby on Rails](https://rubyonrails.org/) - back-end
- [Next.js](https://www.nextjs.org/) - front-end ([Link to the repo](https://github.com/paulgaumer/podwii_next_app))
- [Tailwind CSS](https://tailwindcss.com)
- [Styled Components](https://styled-components.com/)
- [Heroku](https://Heroku.com) - hosting
- [Google Cloud APIs](https://cloud.google.com/) - transcription and data hosting
- [Ffmpeg](https://ffmpeg.org/) - audio processing
- [Sidekiq](https://sidekiq.org/)

<!-- GETTING STARTED -->

## Installation

1. Clone the repo

```sh
git clone git@github.com:paulgaumer/podwii_rails_api.git
```

2. Install packages

```sh
bundle install
```

3. Create db and run the migrations

```sh
rails db:create
rails db:migrate
```

4. Start your local Rails server

```sh
rails s
```

<!-- ### Environment variables

The following variables are needed:

- `GATSBY_API_WEATHER` from the [Open Weather Map API](https://openweathermap.org/)
- `GATSBY_GOOGLE_ANALYTICS` from [Google Analytics](https://analytics.google.com/) -->

<!-- CONTACT -->

## Contact

[Paul Gaumer](https://paulgaumer.com) - [@PaulGaumer](https://twitter.com/@PaulGaumer) - hello@paulgaumer.com

Project Link: [https://github.com/paulgaumer/podwii_rails_api](https://github.com/paulgaumer/podwii_rails_api)
