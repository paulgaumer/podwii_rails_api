class Transcription::ParseTranscriptionResultsMulti
  class << self
    def call(input)
      puts "IN PARSING MULTI"
      speaker = ""
      terms = []
      time_start = 0
      time_end = 0
      final = []
      res = ""

      # binding.pry
      input.each_with_index do |item, i|
        # First Round
        if speaker === ""
          speaker = item.speaker_tag
          terms << item.word
          time_end = item.end_time.seconds
          if i === (input.length - 1)
            # binding.pry
            content = terms.join(" ")
            puts "FIRST ROUND CONTENT CREATED"
            ind = "<h4 id=\"transcript-speaker\">Speaker #{speaker}</h4><p id='transcript-content'>#{content}</p>"
            res = res + ind
          end
        else
          # Same Speaker
          if item.speaker_tag === speaker
            terms << item.word
            time_end = item.end_time.seconds
            if i === (input.length - 1)
              # binding.pry
              content = terms.join(" ")
              t_start = time_start.clone
              s = display_timestamp(t_start)
              t_end = time_end.clone
              e = display_timestamp(t_end)
              puts "SAME SPEAKER CONTENT CREATED"
              ind = "<h4 id=\"transcript-speaker\">Speaker #{speaker}</h4><p id='transcript-timestamp'>#{s} - #{e}</p><p id='transcript-content'>#{content}</p>"
              res = res + ind
            end
          else
            # New of Speaker
            # binding.pry
            content = terms.join(" ")
            puts "NEW SPEAKER CONTENT CREATED"
            t_start = time_start.clone
            s = display_timestamp(t_start)
            t_end = time_end.clone
            e = display_timestamp(t_end)
            puts "START OK"
            ind = "<h4 id=\"transcript-speaker\">Speaker #{speaker}</h4><p id='transcript-timestamp'>#{s} - #{e}</p><p id='transcript-content'>#{content}</p>"
            puts "IND OK"
            res = res + ind
            puts "RES OK"
            speaker = item.speaker_tag
            puts "SPEAKER OK"
            time_start = item.start_time.seconds
            puts "TIME START OK"
            terms = []
            terms << item.word
            puts "WORD INSERTED INTO TERMS"
            time_end = item.end_time.seconds
            puts "TIME END OK"
          end
        end
      end
      return res
    end

    private

    def to_min(sec)
      # binding.pry
      mm, ss = sec.divmod(60)
    end

    def display_timestamp(time)
      # binding.pry
      if time <= 60
        return "00:#{time <= 9 ? "0" : ""}#{time}"
      else
        t = to_min(time)
        return "#{t[0] <= 9 ? "0" : ""}#{t[0]}:#{t[1] <= 9 ? "0" : ""}#{t[1]}"
      end
    end
  end
end
