class Transcription::ParseTranscriptionResultsSingle
  def self.call(results)
    res = []
    results.each do |result|
      res << result.alternatives.first.transcript
    end
    trans = res.join(" ")
    return trans
  end
end
